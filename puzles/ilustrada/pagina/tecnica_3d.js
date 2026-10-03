// La caja viva en 3D: las técnicas B y C (DECISIÓN 29).
//   B · la pintura del boceto proyectada sobre una caja, una mesa y una sala sencillas (escena3d.js).
//   C · el modelo de Blender de la caja y de lo que hay en la mesa, con tinta y acuarela; la sala sigue pintada.
// Las dos comparten el lienzo WebGL, la sala, la mesa y la cámara. juego.js les pide lo mismo que a la técnica A:
// dibujar, pasar de la pantalla al boceto, anclar los efectos, moverse entre vistas y girar la caja.
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { mergeVertices } from 'three/addons/utils/BufferGeometryUtils.js';
import { aThree, crearProyector, rectanguloUV, cargarTextura, crearSala, crearMesa, crearObjetos, crearCajaPintada,
  crearCajonesPintados, materialPintura } from './escena3d.js';

const ANCHO = 1376, ALTO = 768;
const limitar = (v, a, b) => Math.min(b, Math.max(a, v));
const mezclar = (a, b, k) => a + (b - a) * k;
const suave = (a, b, x) => { const t = limitar((x - a) / (b - a), 0, 1); return t * t * (3 - 2 * t); };
const curva = k => (k < 0.5 ? 4 * k * k * k : 1 - Math.pow(-2 * k + 2, 3) / 2);
const EJE_Y = new THREE.Vector3(0, 1, 0);
const TAPA_ORIGEN = { x: 575, y: 519 }, TAPA_MESA = { x: 521, y: 642 };

// ---------------------------------------------------------------------------------------------
// El mundo común: el lienzo WebGL, la sala pintada, la mesa y las texturas del boceto
// ---------------------------------------------------------------------------------------------
let mundo = null;

function texturaDeImagen(imagen) {
  const t = new THREE.Texture(imagen);
  t.colorSpace = THREE.NoColorSpace;          // la pintura pasa tal cual
  t.minFilter = THREE.LinearMipmapLinearFilter;
  t.anisotropy = 4;
  t.needsUpdate = true;
  return t;
}

// El alfa de las siluetas, en la CPU: dice si un toque cae en el objeto pintado o en el hueco de al lado
function leerSilueta(op, nombre) {
  const s = op.datos.capas[nombre], c = document.createElement('canvas');
  c.width = s.w; c.height = s.h;
  const k = c.getContext('2d', { willReadFrequently: true });
  k.drawImage(op.img[nombre], 0, 0);
  const d = k.getImageData(0, 0, s.w, s.h).data;
  return (x, y) => {
    const i = Math.round(x - s.x), j = Math.round(y - s.y);
    return i < 0 || j < 0 || i >= s.w || j >= s.h ? 0 : d[(j * s.w + i) * 4 + 3] / 255;
  };
}

// Una silueta algo más estrecha (la de la pintura incluye un borde de mesa que, al girar, parece un halo)
function siluetaEstrecha(op, nombre, radio, recortarMas = null) {
  const s = op.datos.capas[nombre];
  const base = document.createElement('canvas'); base.width = ANCHO; base.height = ALTO;
  base.getContext('2d').drawImage(op.img[nombre], s.x, s.y);
  const c = document.createElement('canvas'); c.width = ANCHO; c.height = ALTO;
  const k = c.getContext('2d');
  k.drawImage(base, 0, 0);
  k.globalCompositeOperation = 'destination-in';
  const d = Math.round(radio * 0.7);
  for (const [dx, dy] of [[-radio, 0], [radio, 0], [0, -radio], [0, radio], [-d, -d], [d, d], [-d, d], [d, -d]]) k.drawImage(base, dx, dy);
  if (recortarMas) recortarMas(c);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.NoColorSpace;
  return t;
}

function prepararMundo(op) {
  if (mundo) return mundo;
  const render = new THREE.WebGLRenderer({ canvas: op.lienzo3d, antialias: true, powerPreference: 'high-performance' });
  render.setClearColor(0x0c0907, 1);
  const escena = new THREE.Scene();
  const proyector = crearProyector(op.camaraBoceto);
  const capas = op.datos.capas;
  // el boceto de frente con lo que ya ha pasado (juego.js lo rehace al cambiar de estado)
  const frente = new THREE.CanvasTexture(op.compuesto);
  frente.colorSpace = THREE.NoColorSpace; frente.minFilter = THREE.LinearMipmapLinearFilter; frente.anisotropy = 4;
  op.alHornear.push(() => { frente.needsUpdate = true; });
  // el ojo de la pintura: un lienzo pequeño, del tamaño de la almendra, que se repinta en cada cuadro
  const A = op.datos.almendra, xs = A.map(p => p[0]), ys = A.map(p => p[1]);
  const sitio = { x: Math.floor(Math.min(...xs) - 10), y: Math.floor(Math.min(...ys) - 13) };
  sitio.w = Math.ceil(Math.max(...xs) + 10) - sitio.x; sitio.h = Math.ceil(Math.max(...ys) + 10) - sitio.y;
  const escalaOjo = 4, lienzoOjo = document.createElement('canvas');
  lienzoOjo.width = sitio.w * escalaOjo; lienzoOjo.height = sitio.h * escalaOjo;
  const texOjo = new THREE.CanvasTexture(lienzoOjo);
  texOjo.colorSpace = THREE.NoColorSpace; texOjo.generateMipmaps = false; texOjo.minFilter = THREE.LinearFilter;
  const ojo = { lienzo: lienzoOjo, textura: texOjo, sitio, escala: escalaOjo,
    rect: rectanguloUV([sitio.x, sitio.y, sitio.x + sitio.w, sitio.y + sitio.h]) };
  // las planchas (juego.js): la pintura original y, solo donde había objetos, lo que Gemini pintó detrás
  const tex = {
    salaVacia: texturaDeImagen(op.planchas.sala), mesaVacia: texturaDeImagen(op.planchas.mesa),
    detras: texturaDeImagen(op.img.sala_detras), frente, ojo,
    siluetaIncensario: siluetaEstrecha(op, 'silueta_incensario', 3),
    siluetaTe: siluetaEstrecha(op, 'silueta_te', 2, op.recortarTe),
  };
  const sala = crearSala(op.escena3d, proyector, tex), mesa = crearMesa(op.escena3d, proyector, tex);
  escena.add(sala, mesa);
  const camara = new THREE.PerspectiveCamera(op.camaraBoceto.fov_vertical_grados, ANCHO / ALTO, 0.02, 40);
  // la geometría en reposo del boceto, para anclar los efectos (humo, luces) y para las vistas
  const e = op.escena3d, altoCaja = 0.21 * e.alto_caja, p = e.peana;
  const centroCaja = new THREE.Vector3(0, 0.034 + altoCaja / 2, 0);
  const cajasReposo = [
    new THREE.Box3(new THREE.Vector3(-0.11, 0.034, -0.11), new THREE.Vector3(0.11, 0.034 + altoCaja, 0.11)),
    new THREE.Box3().setFromCenterAndSize(aThree(p.centro[0], p.centro[1], (p.z_abajo + p.z_arriba) / 2),
      new THREE.Vector3(p.medio_x * 2, p.z_arriba - p.z_abajo, p.medio_y * 2)),
  ];
  const centro = nombre => { const o = e.objetos[nombre]; return aThree(o.base[0], o.base[1], o.base[2] + o.alto * 0.45); };
  mundo = {
    op, render, escena, proyector, tex, sala, mesa, camara, ojo, ancho: 1, alto: 1, ppp: 1,
    siluetas: { incensario: leerSilueta(op, 'silueta_incensario'), te: leerSilueta(op, 'silueta_te') },
    centroCaja, cajasReposo, altoCaja, centroIncensario: centro('incensario'), centroTe: centro('tetera'),
    zTablero: e.z_tablero, raycaster: new THREE.Raycaster(),
  };
  escena.add(sombraBajo(centroCaja.x, 0.017, 0.2, e.z_tablero + 0.0015));
  return mundo;
}

// Una sombra suave en la mesa (la plancha de la mesa vacía no la tiene)
function sombraBajo(x, z, radio, y) {
  const c = document.createElement('canvas'); c.width = c.height = 64;
  const k = c.getContext('2d'), g = k.createRadialGradient(32, 32, 4, 32, 32, 32);
  g.addColorStop(0, 'rgba(10,6,3,0.6)'); g.addColorStop(0.55, 'rgba(10,6,3,0.32)'); g.addColorStop(1, 'rgba(10,6,3,0)');
  k.fillStyle = g; k.fillRect(0, 0, 64, 64);
  const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.NoColorSpace;
  const m = new THREE.Mesh(new THREE.PlaneGeometry(radio * 2.3, radio * 2.3),
    new THREE.MeshBasicMaterial({ map: t, transparent: true, depthWrite: false, toneMapped: false }));
  m.rotation.x = -Math.PI / 2; m.position.set(x, y, z);
  m.raycast = () => {};
  return m;
}

// Del espacio a los píxeles del boceto, y del boceto a un rayo
function alBoceto(v) {
  const q = v.clone().project(mundo.proyector);
  return { x: (q.x + 1) / 2 * ANCHO, y: (1 - q.y) / 2 * ALTO };
}
function rayoDelBoceto(x, y) {
  const P = mundo.proyector.position;
  const q = new THREE.Vector3(x / ANCHO * 2 - 1, 1 - y / ALTO * 2, 0.5).unproject(mundo.proyector);
  return new THREE.Ray(P.clone(), q.sub(P).normalize());
}
// plano vertical que pasa por un punto y mira a la cámara del boceto
function planoFrontal(punto) {
  const n = mundo.proyector.position.clone().sub(punto); n.y = 0; n.normalize();
  return new THREE.Plane().setFromNormalAndCoplanarPoint(n, punto);
}
function esVisible(o) { for (; o; o = o.parent) if (!o.visible) return false; return true; }

// ---------------------------------------------------------------------------------------------
// Las vistas: la cámara del boceto, acercada (se mueve hacia el objeto) y recortada como la técnica A
// ---------------------------------------------------------------------------------------------
function crearRig(op, limites) {
  const P0 = mundo.proyector.position.clone(), Q0 = mundo.proyector.quaternion.clone();
  const adelante0 = new THREE.Vector3(0, 0, -1).applyQuaternion(Q0);
  const distCaja = mundo.centroCaja.distanceTo(P0);
  const puntoCara = rayoDelBoceto(860, 455).intersectPlane(new THREE.Plane(new THREE.Vector3(0, 0, 1), -0.11), new THREE.Vector3())
    || mundo.centroCaja.clone();
  const VISTAS = op.vistas;
  // qué mira cada vista: objetivo T, cuánto se acerca s (1 = donde se pintó) y alrededor de qué gira
  const definiciones = {
    sala: { T: P0.clone().add(adelante0.clone().multiplyScalar(distCaja)), s: 1, pivote: mundo.centroCaja },
    caja: { T: mundo.centroCaja, s: 0.62, pivote: mundo.centroCaja },
    incensario: { T: mundo.centroIncensario, s: 0.56, pivote: mundo.centroIncensario },
    cara: { T: puntoCara, s: 0.5, pivote: mundo.centroCaja },
    // el costado de los cajones, de cerca
    cajones: { T: new THREE.Vector3(0.11, mundo.centroCaja.y, 0), s: 0.46, pivote: mundo.centroCaja },
  };
  function encuadre(nombre) {
    const d = definiciones[nombre], v = VISTAS[nombre];
    const vertical = mundo.alto > mundo.ancho * 1.05;
    const [x0, y0, x1, y1] = vertical ? v.v : v.h;
    const rw = (x1 - x0) / d.s, rh = (y1 - y0) / d.s;
    const sc = Math.min(mundo.ancho / rw, mundo.alto / rh);
    const cw = mundo.ancho / sc, ch = mundo.alto / sc;
    let cx = ANCHO / 2, cy = ALTO / 2;
    if (d.s === 1) {
      // la vista de la sala es el boceto mismo: el recorte no se sale de la ilustración si cabe
      cx = (x0 + x1) / 2; cy = (y0 + y1) / 2;
      cx = cw >= ANCHO ? ANCHO / 2 : limitar(cx, cw / 2, ANCHO - cw / 2);
      cy = ch >= ALTO ? ALTO / 2 : limitar(cy, ch / 2, ALTO - ch / 2);
    }
    return { T: d.T.clone(), s: d.s, pivote: d.pivote.clone(), cx, cy, cw, ch };
  }
  const rig = {
    vista: 'sala', transicion: null, intro: null,
    th: 0, ph: 0, zoom: 1, vth: 0, vph: 0, vzoom: 0, thObj: 0, phObj: 0, zoomObj: 1,
    actual: null,
    irA(nombre, duracion = 0.75) {
      this.transicion = { desde: this.actual || encuadre(nombre), t: 0, duracion };
      this.vista = nombre;
      this.thObj = 0; this.phObj = 0; this.zoomObj = 1;
    },
    saltarA(nombre) { this.vista = nombre; this.transicion = null; this.actual = encuadre(nombre); this.th = this.ph = 0; this.zoom = 1; },
    empezar(duracion) { this.saltarA('sala'); this.intro = { t: 0, duracion }; },
    arrastrar(dx, dy) {
      const l = limites[this.vista] || limites.sala;
      this.thObj = limitar(this.thObj - dx * 0.0042, -l.th, l.th);
      this.phObj = limitar(this.phObj + dy * 0.0032, l.ph[0], l.ph[1]);
    },
    pellizcar(r) { this.zoomObj = limitar(this.zoomObj / r, limites.zoom[0], limites.zoom[1]); },
    actualizar(dt) {
      const destino = encuadre(this.vista);
      if (this.transicion) {
        const tr = this.transicion; tr.t += dt;
        const k = curva(limitar(tr.t / tr.duracion, 0, 1)), a = tr.desde;
        this.actual = {
          T: a.T.clone().lerp(destino.T, k), s: Math.exp(mezclar(Math.log(a.s), Math.log(destino.s), k)),
          pivote: a.pivote.clone().lerp(destino.pivote, k), cx: mezclar(a.cx, destino.cx, k), cy: mezclar(a.cy, destino.cy, k),
          cw: Math.exp(mezclar(Math.log(a.cw), Math.log(destino.cw), k)), ch: Math.exp(mezclar(Math.log(a.ch), Math.log(destino.ch), k)),
        };
        if (k >= 1) this.transicion = null;
      } else this.actual = destino;
      // la mirada (arrastrar) y el acercamiento (pellizcar), con muelle suave
      const muelle = (x, v, obj, kk = 38) => { const am = 2 * Math.sqrt(kk) * 0.92; v += ((obj - x) * kk - v * am) * dt; return [x + v * dt, v]; };
      [this.th, this.vth] = muelle(this.th, this.vth, this.thObj);
      [this.ph, this.vph] = muelle(this.ph, this.vph, this.phObj);
      [this.zoom, this.vzoom] = muelle(this.zoom, this.vzoom, this.zoomObj);
      if (this.intro) { this.intro.t += dt; if (this.intro.t >= this.intro.duracion) this.intro = null; }
    },
    // coloca la cámara: el encuadre, la mirada, el vaivén de cámara en mano y la sacudida
    colocar(reloj, sacudida) {
      const a = this.actual, cam = mundo.camara;
      const pos = a.T.clone().add(P0.clone().sub(a.T).multiplyScalar(a.s));
      const q = new THREE.Quaternion().setFromUnitVectors(adelante0, a.T.clone().sub(P0).normalize()).multiply(Q0);
      let th = this.th, ph = this.ph, zoom = this.zoom;
      if (this.intro) {
        const k = 1 - curva(limitar(this.intro.t / this.intro.duracion, 0, 1));
        th += -0.13 * k; ph += 0.07 * k; zoom *= 1 + 0.2 * k;
      }
      if (!op.quieto) {
        th += Math.sin(reloj * 0.13) * 0.0045 + Math.sin(reloj * 0.31) * 0.0018;
        ph += Math.sin(reloj * 0.11 + 1) * 0.0028;
        if (sacudida > 0) { th += Math.sin(reloj * 71) * sacudida * 0.00045; ph += Math.sin(reloj * 53 + 2) * sacudida * 0.00045; }
      }
      const rel = pos.sub(a.pivote);
      const qY = new THREE.Quaternion().setFromAxisAngle(EJE_Y, th);
      rel.applyQuaternion(qY);
      const derecha = new THREE.Vector3().crossVectors(EJE_Y, rel).normalize();
      const qX = new THREE.Quaternion().setFromAxisAngle(derecha, -ph);
      rel.applyQuaternion(qX).multiplyScalar(zoom);
      cam.position.copy(a.pivote).add(rel);
      cam.quaternion.copy(q).premultiply(qY).premultiply(qX);
      cam.aspect = ANCHO / ALTO;
      cam.setViewOffset(ANCHO, ALTO, a.cx - a.cw / 2, a.cy - a.ch / 2, a.cw, a.ch);
      cam.updateMatrixWorld(true);
    },
  };
  rig.saltarA('sala');
  return rig;
}

// ---------------------------------------------------------------------------------------------
// Técnica C: el modelo de Blender con tinta y acuarela
// ---------------------------------------------------------------------------------------------
// Papel: grano fino y manchas de pigmento, en el espacio de la pantalla (como el papel de una acuarela)
function texturaPapel() {
  const lado = 256, c = document.createElement('canvas'); c.width = c.height = lado;
  const k = c.getContext('2d'), datos = k.createImageData(lado, lado);
  const ruido = (x, y, s) => { const v = Math.sin(x * 12.9898 * s + y * 78.233 * s) * 43758.5453; return v - Math.floor(v); };
  const suave = (x, y, celda, s) => {
    const fx = x / celda, fy = y / celda, ix = Math.floor(fx), iy = Math.floor(fy), tx = fx - ix, ty = fy - iy;
    const n = lado / celda, r = (i, j) => ruido(((i % n) + n) % n, ((j % n) + n) % n, s);
    const u = tx * tx * (3 - 2 * tx), w = ty * ty * (3 - 2 * ty);
    return mezclar(mezclar(r(ix, iy), r(ix + 1, iy), u), mezclar(r(ix, iy + 1), r(ix + 1, iy + 1), u), w);
  };
  for (let y = 0; y < lado; y++) for (let x = 0; x < lado; x++) {
    const grano = ruido(x, y, 1) * 0.5 + suave(x, y, 4, 2) * 0.5;
    const mancha = suave(x, y, 64, 3) * 0.55 + suave(x, y, 32, 4) * 0.3 + suave(x, y, 16, 5) * 0.15;
    const i = (y * lado + x) * 4;
    datos.data[i] = grano * 255; datos.data[i + 1] = mancha * 255; datos.data[i + 2] = 0; datos.data[i + 3] = 255;
  }
  k.putImageData(datos, 0, 0);
  const t = new THREE.CanvasTexture(c);
  t.wrapS = t.wrapT = THREE.RepeatWrapping; t.colorSpace = THREE.NoColorSpace;
  return t;
}

const GLSL_ACUARELA = /* glsl */`
  vec3 col = outgoingLight;
  // pigmento que se acumula en los bordes de cada forma, como en la acuarela
  vec3 haciaOjo = normalize(vViewPosition);
  float rasante = 1.0 - abs(dot(normal, haciaOjo));
  col *= 1.0 - 0.3 * smoothstep(0.5, 0.97, rasante);
  col += uMetal * 0.32 * pow(max(dot(normal, haciaOjo), 0.0), 8.0) * vec3(0.95, 0.78, 0.42);
  // el papel: grano fino y manchas grandes de pigmento
  vec4 papel = texture2D(uPapel, gl_FragCoord.xy / 256.0);
  vec4 papelGrande = texture2D(uPapel, gl_FragCoord.xy / 900.0 + 0.37);
  col *= 0.9 + 0.17 * papel.r;
  col *= 0.86 + 0.26 * papelGrande.g;
  // la paleta del boceto: cálida, algo apagada
  float gris = dot(col, vec3(0.3, 0.55, 0.15));
  col = mix(vec3(gris), col, 0.85) * vec3(1.03, 0.97, 0.88);
  gl_FragColor = vec4(col, diffuseColor.a);`;

// El ojo de la cara de Blender, pintado en su textura (píxeles de una cara de 1024): el iris se mueve y el
// párpado baja; al despertar, el ojo y la cuenca vacía brillan en rojo
const GLSL_OJO = /* glsl */`
  {
    vec2 px = vMapUv * 1024.0;
    float t = (px.x - 205.0) / 215.0;
    if (t > 0.0 && t < 1.0) {
      float yc = 480.0 + 12.0 * t;
      float ys = yc - 31.0 * pow(sin(3.14159 * t), 0.85);
      float yi = yc + 23.0 * pow(sin(3.14159 * t), 0.9);
      if (px.y > ys - 1.0 && px.y < yi + 1.0) {
        vec3 blanco = pow(vec3(0.84, 0.77, 0.63), vec3(2.2)) * (0.72 + 0.28 * smoothstep(ys, ys + 16.0, px.y));
        vec2 c = vec2(335.0, 478.0) + uIris;
        float d = length(px - c);
        vec3 ojo = blanco;
        ojo = mix(ojo, pow(vec3(0.6, 0.16, 0.08), vec3(2.2)), smoothstep(25.0, 23.0, d));
        ojo = mix(ojo, pow(vec3(0.33, 0.06, 0.04), vec3(2.2)), smoothstep(25.0, 23.0, d) * smoothstep(13.0, 24.0, d) * 0.7);
        ojo = mix(ojo, vec3(0.002), smoothstep(10.0, 8.0, d));
        ojo = mix(ojo, vec3(1.0, 0.9, 0.75), smoothstep(4.0, 2.4, length(px - c - vec2(-7.0, -8.0))) * 0.85);
        float yl = ys + (yi - ys) * uCierre;
        vec3 madera = texture2D(map, vMapUv - vec2(0.0, 52.0 / 1024.0)).rgb;
        vec3 res = mix(madera, ojo, smoothstep(yl - 0.6, yl + 0.6, px.y));
        res = mix(res, vec3(0.01, 0.006, 0.004), (1.0 - smoothstep(1.4, 3.4, abs(px.y - yl))) * step(0.03, uCierre));
        float dentro = smoothstep(ys - 1.0, ys + 0.5, px.y) * (1.0 - smoothstep(yi - 0.5, yi + 1.0, px.y));
        diffuseColor.rgb = mix(diffuseColor.rgb, res, dentro);
        totalEmissiveRadiance += vec3(1.0, 0.1, 0.04) * uRojo * smoothstep(26.0, 14.0, d) * 2.2 * dentro;
      }
    }
    vec2 q = (px - vec2(690.0, 481.0)) / vec2(84.0, 30.0);
    totalEmissiveRadiance += vec3(1.0, 0.08, 0.03) * uRojo * smoothstep(1.0, 0.2, length(q)) * 1.8;
  }`;

function crearTintas() {
  const papel = texturaPapel();
  const grad = new THREE.DataTexture(new Uint8Array([70, 140, 205, 255]), 4, 1, THREE.RedFormat);
  grad.minFilter = grad.magFilter = THREE.NearestFilter; grad.needsUpdate = true;
  const ojo = { uIris: { value: new THREE.Vector2() }, uCierre: { value: 0 }, uRojo: { value: 0 } };
  const contorno = new THREE.ShaderMaterial({
    uniforms: { uGrosor: { value: 1.5 }, uResolucion: { value: new THREE.Vector2(1, 1) },
      uTinta: { value: new THREE.Color(0.12, 0.075, 0.05) } },
    vertexShader: /* glsl */`
      uniform float uGrosor; uniform vec2 uResolucion;
      void main() {
        vec4 clip = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        vec3 n = normalize(normalMatrix * normal);
        vec2 dir = (projectionMatrix * vec4(n.xy, 0.0, 0.0)).xy;
        float l = length(dir);
        if (l > 1e-5) dir /= l;
        clip.xy += dir * uGrosor * 2.0 / uResolucion * clip.w;
        gl_Position = clip;
      }`,
    fragmentShader: /* glsl */`uniform vec3 uTinta; void main() { gl_FragColor = vec4(uTinta, 1.0); }`,
    side: THREE.BackSide,
  });
  const cache = new Map();
  function material(original, { cara = false } = {}) {
    const clave = original.uuid + (cara ? 'c' : '');
    if (cache.has(clave)) return cache.get(clave);
    const parametros = { color: original.color ? original.color.clone() : new THREE.Color(1, 1, 1), map: original.map || null,
      gradientMap: grad, side: original.side ?? THREE.FrontSide };
    if (original.normalMap) { parametros.normalMap = original.normalMap; parametros.normalScale = original.normalScale.clone(); }
    const nombre = original.name || '';
    // el bronce, de latón oscuro; el barro, algo más claro
    if (nombre === 'Bronce') parametros.color.setRGB(0.13, 0.11, 0.05);          // latón oscuro, como el del boceto
    if (nombre === 'Barro') parametros.color.multiplyScalar(1.15);
    // los metales llevan un brillo suave donde miran a la cámara
    const metal = { Bronce: 1, OroViejo: 0.7, Hierro: 0.15 }[nombre] || 0;
    const m = new THREE.MeshToonMaterial(parametros);
    m.onBeforeCompile = sh => {
      sh.uniforms.uPapel = { value: papel };
      sh.uniforms.uMetal = { value: metal };
      let cabecera = 'uniform sampler2D uPapel;\nuniform float uMetal;\n';
      if (cara) { Object.assign(sh.uniforms, ojo); cabecera += 'uniform vec2 uIris;\nuniform float uCierre;\nuniform float uRojo;\n'; }
      sh.fragmentShader = sh.fragmentShader
        .replace('#include <common>', '#include <common>\n' + cabecera)
        .replace('#include <opaque_fragment>', GLSL_ACUARELA);
      if (cara) sh.fragmentShader = sh.fragmentShader.replace('#include <map_fragment>', '#include <map_fragment>\n' + GLSL_OJO);
    };
    if (cara) m.customProgramCacheKey = () => 'cara-viva';
    cache.set(clave, m);
    return m;
  }
  // un contorno a tinta: la misma malla, un poco hinchada y vuelta del revés (normales suavizadas)
  function contornear(malla) {
    const g = new THREE.BufferGeometry();
    g.setAttribute('position', malla.geometry.attributes.position);
    if (malla.geometry.index) g.setIndex(malla.geometry.index);
    const unida = mergeVertices(g, 1e-4);
    unida.computeVertexNormals();
    const borde = new THREE.Mesh(unida, contorno);
    borde.raycast = () => {};
    borde.userData.contorno = true;
    malla.add(borde);
  }
  return { papel, grad, ojo, contorno, material, contornear };
}

function geometriaCuerno(largo = 0.036, radio = 0.0072, curvatura = 0.011) {
  const seg = 16, lados = 12, pos = [], idx = [];
  for (let i = 0; i <= seg; i++) {
    const t = i / seg, x = curvatura * t * t, y = largo * t, r = radio * Math.pow(1 - t, 0.9) + 0.0003;
    for (let j = 0; j <= lados; j++) { const a = j / lados * Math.PI * 2; pos.push(x + Math.cos(a) * r, y, Math.sin(a) * r); }
  }
  for (let i = 0; i < seg; i++) for (let j = 0; j < lados; j++) {
    const a = i * (lados + 1) + j, b = a + lados + 1;
    idx.push(a, b, a + 1, b, b + 1, a + 1);
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  g.setIndex(idx); g.computeVertexNormals();
  return g;
}

function materialBrasas() {
  return new THREE.ShaderMaterial({
    uniforms: { uT: { value: 0 } },
    vertexShader: 'varying vec2 vUv; void main() { vUv = uv; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }',
    fragmentShader: /* glsl */`
      uniform float uT; varying vec2 vUv;
      float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
      float n(vec2 p) { vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
        return mix(mix(h(i), h(i + vec2(1, 0)), f.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), f.x), f.y); }
      void main() {
        vec2 p = vUv * 9.0;
        float v = n(p + vec2(uT * 0.3, -uT * 0.2)) * 0.6 + n(p * 2.3 - uT * 0.5) * 0.4;
        vec3 c = mix(vec3(0.16, 0.04, 0.02), vec3(1.0, 0.42, 0.1), smoothstep(0.35, 0.8, v));
        c = mix(c, vec3(1.0, 0.85, 0.5), smoothstep(0.78, 0.95, v));
        c *= 1.0 - 0.55 * smoothstep(0.6, 1.0, length(vUv - 0.5) * 2.0);
        gl_FragColor = vec4(c, 1.0);
      }`,
  });
}
function materialResplandor(color) {
  return new THREE.ShaderMaterial({
    uniforms: { uFuerza: { value: 0 }, uColor: { value: new THREE.Color(color) } },
    vertexShader: 'varying vec2 vUv; void main() { vUv = uv; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }',
    fragmentShader: /* glsl */`
      uniform float uFuerza; uniform vec3 uColor; varying vec2 vUv;
      void main() { float r = length(vUv - 0.5) * 2.0; gl_FragColor = vec4(uColor * uFuerza * (1.0 - smoothstep(0.2, 1.0, r)), 1.0); }`,
    transparent: true, blending: THREE.AdditiveBlending, depthWrite: false,
  });
}

// Qué representa cada pieza del modelo en el recorrido: un punto del boceto (las zonas de juego.js)
const ZONA_CAJON = { 0: [1047, 272], 2: [1132, 323], 3: [1044, 446], 4: [1088, 423], 6: [1047, 272], 7: [1132, 323], 8: [1044, 446] };
function zonaDePieza(nombres, estado) {
  const tiene = prefijo => nombres.some(n => n.startsWith(prefijo));
  if (tiene('LlaveBambu') || tiene('CajonDerecho_5')) return { x: 1072, y: 488, cara: 'frente' };
  // la nota está en el cajón abierto de en medio: tocar el cajón o el papel la abre
  if (tiene('Papel') || tiene('CajonDerecho_1')) return { x: 1138, y: 450, cara: 'frente' };
  const cajon = nombres.find(n => /^CajonDerecho_\d$/.test(n));
  if (cajon) { const i = Number(cajon.slice(-1)); return { x: ZONA_CAJON[i][0], y: ZONA_CAJON[i][1], cara: 'frente' }; }
  if (tiene('CajonDetras_4')) return { x: 737, y: 334, cara: 'detras' };
  if (tiene('CajonDetras')) return { x: 900, y: 330, cara: 'detras' };
  if (tiene('CajonLargo') || tiene('Cerradura')) return { x: 850, y: 516, cara: 'detras' };
  if (tiene('HuecoFicha') || tiene('PanelFicha')) return { x: 846, y: 368, cara: 'detras' };
  if (tiene('Borla') || tiene('Nudo') || tiene('Cordon')) return { x: 1086, y: 400, cara: 'detras' };
  if (tiene('Trampilla')) return { x: 930, y: 196, cara: 'frente' };
  if (tiene('CuernoPuesto') || tiene('CuernoIzquierdo')) return tiene('CuernoIzquierdo') ? { x: 835, y: 285, cara: 'frente' } : { x: 912, y: 291, cara: 'frente' };
  if (tiene('CuernoBrasas') || tiene('Brasas')) return estado.cuerno === 'brasas' ? { x: 593, y: 480, cara: 'frente' } : { x: 575, y: 540, cara: 'frente' };
  if (tiene('TapaIncensario')) return estado.tapaEnMesa ? { x: 521, y: 625, cara: 'frente' } : { x: 575, y: 540, cara: 'frente' };
  if (tiene('Incensario') || tiene('Leon')) return { x: 575, y: 540, cara: 'frente' };
  if (tiene('Tetera')) return { x: 1290, y: 550, cara: 'frente' };
  if (tiene('Taza')) return { x: 1230, y: 640, cara: 'frente' };
  return null;
}
// Las partes de la cara (en píxeles de su textura) y su sitio en el boceto
function zonaDeCara(px, py) {
  const cerca = (x, y, r) => Math.hypot(px - x, py - y) < r;
  if (cerca(636, 184, 72)) return { x: 912, y: 291 };                 // el hueco del cuerno
  if (px > 195 && px < 430 && py > 430 && py < 525) return { x: 785, y: 370 };   // el ojo abierto
  if (Math.hypot((px - 690) / 100, (py - 481) / 42) < 1) return { x: 905, y: 378 };   // la cuenca vacía
  if (Math.hypot((px - 512) / 140, (py - 800) / 60) < 1) return { x: 842, y: 484 };   // los labios
  return { x: 960, y: 560 };
}

// ---------------------------------------------------------------------------------------------
// Crear una técnica (B o C)
// ---------------------------------------------------------------------------------------------
export async function crearTecnica(letra, op) {
  prepararMundo(op);
  const esB = letra === 'B';
  const grupo = new THREE.Group();
  grupo.visible = false;
  mundo.escena.add(grupo);
  const caja = new THREE.Group();          // gira (y respira) alrededor de la peana
  caja.name = 'caja';
  grupo.add(caja);
  const limites = esB
    ? { sala: { th: 0.14, ph: [-0.05, 0.1] }, caja: { th: 0.38, ph: [-0.12, 0.22] }, incensario: { th: 0.32, ph: [-0.1, 0.22] },
        cara: { th: 0.32, ph: [-0.1, 0.2] }, cajones: { th: 0.42, ph: [-0.1, 0.3] }, zoom: [0.62, 1.12] }
    : { sala: { th: 0.24, ph: [-0.06, 0.14] }, caja: { th: 0.95, ph: [-0.15, 0.45] }, incensario: { th: 0.7, ph: [-0.12, 0.4] },
        cara: { th: 0.55, ph: [-0.12, 0.3] }, cajones: { th: 0.7, ph: [-0.12, 0.4] }, zoom: [0.62, 1.15] };
  const rig = crearRig(op, limites);
  const pistas = {};          // piezas que se animan (técnica C)
  let tintas = null, objetivosToque = [];
  let pintada = null, cajonesB = null, carasB = [], rolloB = null;

  if (esB) {
    // la caja pintada (frente y espalda, y los costados y la tapa también pintados de frente) y lo que hay en la
    // mesa, pintado sobre cilindros
    const [caraDerecha, caraIzquierda, caraArriba] = await Promise.all(['derecha', 'izquierda', 'arriba'].map(n => cargarTextura(`capas/cara_${n}.webp`)));
    const tex = { ...mundo.tex, caraDerecha, caraIzquierda, caraArriba, lacaPared: op.img.laca_pared };
    pintada = crearCajaPintada(op.escena3d, mundo.proyector, tex);
    caja.add(pintada.caja);
    // cuánto se mezcla cada cara pintada de frente: según lo lejos que esté la cámara de la del boceto, vista desde
    // la caja (la caja quieta es el espacio del mundo; la izquierda se pintó con la caja girada media vuelta)
    const P0 = mundo.proyector.position, yMedio = 0.034 + pintada.alto / 2;
    const cara = (centro, fuente, mezcla) => ({ centro, desde: fuente.clone().sub(centro).normalize(), mezcla });
    carasB = [
      cara(new THREE.Vector3(0.11, yMedio, 0), P0, pintada.mezclas.derecha),
      cara(new THREE.Vector3(-0.11, yMedio, 0), new THREE.Vector3(-P0.x, P0.y, -P0.z), pintada.mezclas.izquierda),
      cara(new THREE.Vector3(0, 0.034 + pintada.alto, 0), P0, pintada.mezclas.arriba),
    ];
    // los cajones del costado, con lo que guardan (la llave y la nota, tal como están pintadas)
    cajonesB = crearCajonesPintados(op.cajones, pintada.alto, mundo.proyector, tex, pintada.mezclas.derecha);
    for (const [id, c] of Object.entries(cajonesB)) {
      pintada.caja.add(c.grupo, c.agujero, c.sombra);
      const guarda = op.CAJONES[id].contiene;
      if (!guarda) continue;
      const imagen = op.img[guarda], t = new THREE.Texture(imagen);
      t.colorSpace = THREE.SRGBColorSpace; t.needsUpdate = true;
      const sprite = new THREE.Sprite(new THREE.SpriteMaterial({ map: t, transparent: true, depthWrite: false }));
      const pxm = c.dentro.distanceTo(P0) / op.camaraBoceto.focal_px;     // metros por píxel del boceto a esa distancia
      sprite.scale.set(imagen.width * pxm, imagen.height * pxm, 1);
      sprite.position.copy(c.dentro).add(new THREE.Vector3(0, imagen.height * pxm * 0.42, 0));
      sprite.userData.tipo = 'cajon'; sprite.userData.cajon = id;
      c.grupo.add(sprite); c[guarda] = sprite;
    }
    const objetos = crearObjetos(op.escena3d, mundo.proyector, mundo.tex);
    for (const o of Object.values(objetos)) grupo.add(o);
    // la sombra de la tetera y las tazas en la mesa (sus siluetas ya no traen la de la pintura)
    for (const [nombre, o] of Object.entries(op.escena3d.objetos)) {
      if (nombre === 'incensario') continue;
      const b = aThree(o.base[0], o.base[1], o.base[2]);
      grupo.add(sombraBajo(b.x, b.z, o.radio * 1.15, mundo.zTablero + 0.0012));
    }
    objetivosToque = [caja, ...Object.values(objetos)];
    if (op.decoracion) crearDecoracionB(grupo);
  } else {
    tintas = crearTintas();
    const cargador = new GLTFLoader();
    const [modeloCaja, modeloMesa] = await Promise.all([cargador.loadAsync('modelos/caja_viva.json'), cargador.loadAsync('modelos/mesa.json')]);
    // la caja: se apoya en la mesa y se ajusta a la altura de la caja pintada (el boceto la hace algo más alta)
    const raiz = modeloCaja.scene;
    raiz.position.set(0, mundo.zTablero, 0);
    raiz.scale.set(1.02, 1.07, 1.02);
    caja.add(raiz);
    // lo que hay en la mesa: cada pieza donde está en el boceto, con su alto
    const mesaC = modeloMesa.scene;
    grupo.add(mesaC);
    mesaC.updateMatrixWorld(true);
    const piezasDe = nombres => { const r = []; mesaC.traverse(o => { if (o.isMesh && nombres.some(n => o.name.startsWith(n))) r.push(o); }); return r; };
    const colocar = (nombre, mallas, alto) => {
      const o = op.escena3d.objetos[nombre];
      const bb = new THREE.Box3(); for (const m of mallas) bb.expandByObject(m);
      const base = new THREE.Vector3((bb.min.x + bb.max.x) / 2, bb.min.y, (bb.min.z + bb.max.z) / 2);
      const g = new THREE.Group(); g.position.copy(base); grupo.add(g); g.updateMatrixWorld(true);
      for (const m of mallas) g.attach(m);
      const escala = (alto || o.alto) / (bb.max.y - bb.min.y);
      g.position.copy(aThree(o.base[0], o.base[1], o.base[2])); g.scale.setScalar(escala);
      g.name = nombre;
      return g;
    };
    const incensario = colocar('incensario', piezasDe(['Incensario', 'Leon']));
    colocar('tetera', piezasDe(['Tetera', 'Pico']));
    colocar('taza_1', piezasDe(['Taza', 'TazaTe']).filter(m => !/001$/.test(m.name)));
    colocar('taza_2', piezasDe(['Taza001', 'TazaTe001']));
    grupo.remove(mesaC);
    grupo.updateMatrixWorld(true);
    // la tapa con el león: un grupo propio, con el origen en su base, para que vuele a la mesa
    const piezasTapa = []; incensario.traverse(o => { if (o.isMesh && /^(IncensarioTapa|Leon)/.test(o.name)) piezasTapa.push(o); });
    const bbTapa = new THREE.Box3(); for (const m of piezasTapa) bbTapa.expandByObject(m);
    const tapa = new THREE.Group(); tapa.name = 'TapaIncensario';
    tapa.position.set((bbTapa.min.x + bbTapa.max.x) / 2, bbTapa.min.y, (bbTapa.min.z + bbTapa.max.z) / 2);
    grupo.add(tapa); tapa.updateMatrixWorld(true);
    for (const m of piezasTapa) tapa.attach(m);
    pistas.tapa = tapa; pistas.tapaReposo = tapa.position.clone();
    // dónde se deja la tapa: el punto de la mesa del boceto
    pistas.tapaMesa = rayoDelBoceto(TAPA_MESA.x, TAPA_MESA.y).intersectPlane(new THREE.Plane(EJE_Y, -mundo.zTablero), new THREE.Vector3())
      || pistas.tapaReposo.clone();
    pistas.pxMundo = mundo.centroIncensario.distanceTo(mundo.proyector.position) / op.camaraBoceto.focal_px;
    // las brasas y el cuerno, dentro del cuenco
    const cuenco = new THREE.Box3(); incensario.traverse(o => { if (o.isMesh && o.name === 'Incensario') cuenco.expandByObject(o); });
    const radioCuenco = (cuenco.max.x - cuenco.min.x) / 2;
    const brasas = new THREE.Mesh(new THREE.CircleGeometry(radioCuenco * 0.82, 32), materialBrasas());
    brasas.rotation.x = -Math.PI / 2; brasas.name = 'Brasas';
    brasas.position.set((cuenco.min.x + cuenco.max.x) / 2, bbTapa.min.y - 0.004, (cuenco.min.z + cuenco.max.z) / 2);
    grupo.add(brasas); pistas.brasas = brasas;
    // el marfil, en tonos de sRGB: el material los pasa al espacio lineal
    const marfil = { color: new THREE.Color().setRGB(0.93, 0.87, 0.74, THREE.SRGBColorSpace), side: THREE.FrontSide, uuid: 'marfil' };
    const cuernoBrasas = new THREE.Mesh(geometriaCuerno(0.03, 0.0062), tintas.material(marfil));
    cuernoBrasas.name = 'CuernoBrasas';
    cuernoBrasas.position.copy(brasas.position).add(new THREE.Vector3(0.008, -0.006, 0.004));
    cuernoBrasas.rotation.set(0.35, 0.6, -0.5);
    grupo.add(cuernoBrasas); pistas.cuernoBrasas = cuernoBrasas;
    pistas.luzBrasas = new THREE.PointLight(0xff7a30, 0, 0.22, 2);
    pistas.luzBrasas.position.copy(brasas.position).add(new THREE.Vector3(0, 0.05, 0.02));
    grupo.add(pistas.luzBrasas);
    // las piezas de la caja que cambian: la llave, la cara (el ojo), la trampilla
    raiz.updateMatrixWorld(true);
    const porNombre = n => { let r = null; raiz.traverse(o => { if (!r && o.name === n) r = o; }); return r; };
    pistas.llave = porNombre('LlaveBambu');
    const cara = porNombre('Cara');
    // la cara: de píxeles de su textura (1024) a un punto de la caja (sin girar)
    cara.geometry.computeBoundingBox();
    const bbCara = cara.geometry.boundingBox;
    pistas.puntoCara = (px, py, salir = 0) => {
      const local = new THREE.Vector3(mezclar(bbCara.min.x, bbCara.max.x, px / 1024), mezclar(bbCara.max.y, bbCara.min.y, py / 1024), bbCara.max.z + salir);
      return caja.worldToLocal(cara.localToWorld(local));
    };
    // los cuernos: el de la izquierda siempre; el de la derecha cuando se pone
    const cuernoIzq = new THREE.Mesh(geometriaCuerno(0.036, 0.0072, -0.011), tintas.material(marfil));
    cuernoIzq.name = 'CuernoIzquierdo';
    cuernoIzq.position.copy(pistas.puntoCara(388, 184, -0.004)); cuernoIzq.rotation.set(0.45, 0, 0.32);
    const cuernoPuesto = new THREE.Mesh(geometriaCuerno(), tintas.material(marfil));
    cuernoPuesto.name = 'CuernoPuesto';
    cuernoPuesto.position.copy(pistas.puntoCara(636, 184, -0.004)); cuernoPuesto.rotation.set(0.45, 0, -0.32);
    caja.add(cuernoIzq, cuernoPuesto); pistas.cuernoPuesto = cuernoPuesto;
    // la trampilla: gira sobre su borde de atrás; debajo, luz
    const piezasTrampilla = []; raiz.traverse(o => { if (o.isMesh && o.name.startsWith('Trampilla')) piezasTrampilla.push(o); });
    const bbT = new THREE.Box3(); for (const m of piezasTrampilla) bbT.expandByObject(m);
    const bisagra = new THREE.Group();
    bisagra.position.copy(caja.worldToLocal(new THREE.Vector3((bbT.min.x + bbT.max.x) / 2, bbT.min.y, bbT.min.z)));
    caja.add(bisagra); bisagra.updateMatrixWorld(true);
    for (const m of piezasTrampilla) bisagra.attach(m);
    pistas.bisagra = bisagra;
    const anchoT = Math.max(bbT.max.x - bbT.min.x, bbT.max.z - bbT.min.z);
    const resplandor = new THREE.Mesh(new THREE.CircleGeometry(anchoT * 0.62, 32), materialResplandor(0xffc070));
    resplandor.rotation.x = -Math.PI / 2;
    resplandor.position.copy(caja.worldToLocal(new THREE.Vector3((bbT.min.x + bbT.max.x) / 2, bbT.min.y + 0.0015, (bbT.min.z + bbT.max.z) / 2)));
    resplandor.raycast = () => {};
    caja.add(resplandor); pistas.resplandor = resplandor;
    pistas.luzTrampilla = new THREE.PointLight(0xffc27a, 0, 0.9, 2);
    pistas.luzTrampilla.position.copy(resplandor.position).add(new THREE.Vector3(0, 0.08, 0));
    caja.add(pistas.luzTrampilla);
    // tinta y acuarela en todo el modelo; contornos menos en las piezas diminutas
    const aTinta = raizTinta => raizTinta.traverse(o => {
      if (!o.isMesh || o.userData.contorno || o.userData.conTinta || o === brasas || o === resplandor) return;
      o.userData.conTinta = true;
      if (!o.material.isMeshToonMaterial) o.material = tintas.material(o.material, { cara: o === cara });
      o.geometry.computeBoundingSphere();
      if (o.geometry.boundingSphere.radius > 0.007) tintas.contornear(o);
    });
    aTinta(caja); aTinta(grupo);
    // luces del boceto: la lámpara a la izquierda (cálida) y la luna por las ventanas (fría)
    const lampara = new THREE.DirectionalLight(0xffdcb4, 1.65); lampara.position.set(-0.75, 0.75, 0.55);
    const luna = new THREE.DirectionalLight(0x8fa6d6, 0.7); luna.position.set(0.9, 0.5, -0.7);
    const ambiente = new THREE.HemisphereLight(0xffe8cc, 0x3a2a1e, 0.9);
    grupo.add(lampara, luna, ambiente);
    objetivosToque = [caja, incensario, tapa, brasas, cuernoBrasas, ...grupo.children.filter(o => /^(tetera|taza)/.test(o.name))];
    grupo.add(sombraBajo(mundo.centroIncensario.x, mundo.centroIncensario.z, 0.075, mundo.zTablero + 0.0012));
  }

  // --- la caja en el tiempo: gira con el dedo y respira ----------------------------------------
  let giro = 0, giroObj = 0, vGiro = 0, trampilla = 0;
  const tec = {
    nombre: letra, listo: true, rig, tapa2D: esB,
    activar() {
      mundo.tecnica = tec;
      grupo.visible = true;
      op.lienzo3d.hidden = false;
      rig.saltarA(op.estado().vista);
      this.medir(mundo.ancho, mundo.alto, mundo.ppp);
    },
    desactivar() { grupo.visible = false; },
    medir(ancho, alto, ppp) {
      mundo.ancho = ancho; mundo.alto = alto; mundo.ppp = ppp;
      mundo.render.setPixelRatio(Math.min(ppp, 1.6));
      mundo.render.setSize(ancho, alto, false);
      if (tintas) {
        const b = mundo.render.getDrawingBufferSize(new THREE.Vector2());
        tintas.contorno.uniforms.uResolucion.value.copy(b);
        tintas.contorno.uniforms.uGrosor.value = Math.max(1.1, 1.25 * Math.min(ppp, 1.6) * Math.sqrt(alto / 420));
      }
    },
    irA(nombre, duracion) { rig.irA(nombre, duracion); },
    empezar(duracion) { rig.empezar(duracion); },
    cara() { return Math.cos(giro) >= 0 ? 'frente' : 'detras'; },
    girar(inmediato = false) {
      // media vuelta hasta la otra cara: la espalda más cercana o el frente más cercano
      const vuelta = 2 * Math.PI;
      giroObj = this.cara() === 'frente' ? Math.round((giro - Math.PI) / vuelta) * vuelta + Math.PI : Math.round(giro / vuelta) * vuelta;
      if (inmediato) { giro = giroObj; vGiro = 0; }
    },
    arrastrar(dx, dy, enCaja) {
      if (enCaja) giroObj += dx * 0.011;
      else rig.arrastrar(dx, dy);
    },
    soltar() {},
    pellizcar(r) { rig.pellizcar(r); },
    abrirTrampilla(k) { trampilla = k; },
    reiniciar() { giro = giroObj = vGiro = 0; trampilla = 0; },
    actualizar(dt) {
      rig.actualizar(dt);
      const kk = 30, am = 2 * Math.sqrt(kk) * 0.95;
      vGiro += ((giroObj - giro) * kk - vGiro * am) * dt; giro += vGiro * dt;
      const b = op.aliento();
      caja.rotation.y = giro;
      caja.scale.set(1 + 0.0028 * b, 1 + 0.0065 * b, 1 + 0.0028 * b);
      if (esB) {
        actualizarCajonesB();
        if (rolloB) { const r = op.decoracion.rollo; rolloB.rotation.set(r.a, 0, r.lift); }
      } else actualizarC(dt);
    },
    dibujar() {
      rig.colocar(op.reloj(), op.sacudida());
      if (esB) { pintarOjoB(); mezclarCaras(); }
      mundo.render.render(mundo.escena, mundo.camara);
    },
    // de la pantalla al boceto: qué se toca y en qué punto de la ilustración (frente o espalda)
    aPintura(sx, sy) {
      const hit = tocar(sx, sy);
      return hit ? hit.punto : null;
    },
    ancla,
    pantallaDe,
  };

  // La decoración viva de la B (juego.js la anima): las sombras del bambú, en un plano pegado a la pared del shoji que
  // toma su dibujo con la cámara del boceto (detrás de la caja, que lo tapa), y el rollo colgado, un plano con su
  // pintura en la pared del tokonoma que gira desde su gancho
  function crearDecoracionB(destino) {
    const d = op.decoracion, e = op.escena3d, [ex, ey] = e.esquina;
    const pv = new THREE.Matrix4().multiplyMatrices(mundo.proyector.projectionMatrix, mundo.proyector.matrixWorldInverse);
    // las sombras: el lienzo de juego.js, colocado en el rectángulo del shoji del boceto
    const lienzo = d.sombrasBambu, [x0, y0, x1, y1] = d.VENTANAS;
    const tex = new THREE.CanvasTexture(lienzo);
    tex.colorSpace = THREE.NoColorSpace; tex.generateMipmaps = false; tex.minFilter = THREE.LinearFilter;
    op.alPintarBambu = () => { tex.needsUpdate = true; };
    const mat = new THREE.ShaderMaterial({
      uniforms: { uSombra: { value: tex }, uProyector: { value: pv }, uRect: { value: new THREE.Vector4(x0 / ANCHO, y0 / ALTO, x1 / ANCHO, y1 / ALTO) } },
      vertexShader: `uniform mat4 uProyector; varying vec4 vProy;
        void main() { vProy = uProyector * modelMatrix * vec4(position, 1.0); gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }`,
      fragmentShader: `uniform sampler2D uSombra; uniform vec4 uRect; varying vec4 vProy;
        void main() {
          vec2 uv = vProy.xy / vProy.w * 0.5 + 0.5;
          vec2 q = (vec2(uv.x, 1.0 - uv.y) - uRect.xy) / (uRect.zw - uRect.xy);
          if (q.x < 0.0 || q.x > 1.0 || q.y < 0.0 || q.y > 1.0) discard;
          gl_FragColor = texture2D(uSombra, vec2(q.x, 1.0 - q.y));
        }`,
      transparent: true, depthWrite: false,
    });
    const esquinas = [[x0, y0], [x1, y0], [x1, y1], [x0, y1]].map(([x, y]) => rayoDelBoceto(x, y).intersectPlane(new THREE.Plane(new THREE.Vector3(0, 0, 1), ey), new THREE.Vector3()));
    const xs = esquinas.map(v => v.x), ys = esquinas.map(v => v.y);
    const ancho = Math.max(...xs) - Math.min(...xs) + 0.2, alto = Math.max(...ys) - Math.min(...ys) + 0.2;
    const sombras = new THREE.Mesh(new THREE.PlaneGeometry(ancho, alto), mat);
    sombras.position.set((Math.max(...xs) + Math.min(...xs)) / 2, (Math.max(...ys) + Math.min(...ys)) / 2, -ey + 0.004);
    sombras.raycast = () => {};
    destino.add(sombras);
    // el rollo: la tela y el palo de abajo, cada uno con el trozo de pintura que le toca, colgando del gancho
    const pared = new THREE.Plane(new THREE.Vector3(1, 0, 0), -(ex + 0.006));
    const enPared = (x, y) => rayoDelBoceto(x, y).intersectPlane(pared, new THREE.Vector3());
    const gancho = enPared(d.ROLLO.gancho.x, d.ROLLO.gancho.y);
    rolloB = new THREE.Group(); rolloB.position.copy(gancho);
    const [rx0, ry0, rx1, ry1] = d.ROLLO.rect;
    for (const [a, b, c2, dd] of [[245, ry0, 407, 301], [rx0, 299, rx1, ry1]]) {
      const v = [[a, b], [c2, b], [c2, dd], [a, dd]].map(([x, y]) => enPared(x, y).sub(gancho));
      const geo = new THREE.BufferGeometry();
      geo.setAttribute('position', new THREE.Float32BufferAttribute(v.flatMap(q => [q.x, q.y, q.z]), 3));
      geo.setAttribute('uv', new THREE.Float32BufferAttribute([0, 1, 1, 1, 1, 0, 0, 0], 2));
      geo.setIndex([0, 3, 1, 1, 3, 2]);
      const malla = new THREE.Mesh(geo, materialPintura(mundo.tex.frente, mundo.proyector,
        { reposo: new THREE.Matrix4().makeTranslation(gancho.x, gancho.y, gancho.z), lado: THREE.DoubleSide, recorte: rectanguloUV([a, b, c2, dd]) }));
      malla.userData.tipo = 'sala';
      rolloB.add(malla);
    }
    destino.add(rolloB);
  }
  // los cajones de la B: cuánto ha salido cada uno (lo lleva juego.js), su hueco, su sombra y lo que guarda
  function actualizarCajonesB() {
    const est = op.estado();
    for (const [id, c] of Object.entries(cajonesB)) {
      const k = op.cajonAbertura(id), abierto = k > 0.002;
      c.grupo.visible = c.agujero.visible = c.sombra.visible = abierto;
      c.grupo.position.x = Math.max(0, k) * op.cajones.sale;
      c.sombra.material.opacity = 0.55 * limitar(k * 2.5, 0, 1);
      if (c.llave) c.llave.visible = est.llave === 'cajon';
      if (c.nota) c.nota.visible = est.nota === 'cajon';
    }
  }
  // la pintura de frente de los costados y la tapa: nada desde la cámara del boceto, del todo al girar la caja
  const _camaraEnCaja = new THREE.Vector3(), _hacia = new THREE.Vector3();
  function mezclarCaras() {
    caja.updateMatrixWorld();
    caja.worldToLocal(_camaraEnCaja.copy(mundo.camara.position));
    for (const c of carasB) {
      _hacia.copy(_camaraEnCaja).sub(c.centro).normalize();
      c.mezcla.value = suave(0.1, 0.38, Math.acos(limitar(_hacia.dot(c.desde), -1, 1)));
    }
  }
  // en qué cajón cae un punto del costado derecho (en metros de Blender), con los cajones cerrados
  function cajonEnCostado(y, z) {
    const d = op.cajones.cajones.find(c => y >= c.y[0] && y <= c.y[1] && z >= c.z[0] && z <= c.z[1]);
    return d ? d.id : null;
  }
  function centroCajon(id) {
    const p = op.cajones.cajones.find(c => c.id === id).poligono;
    return { x: (p[0][0] + p[1][0] + p[2][0] + p[3][0]) / 4, y: (p[0][1] + p[1][1] + p[2][1] + p[3][1]) / 4 };
  }

  function pintarOjoB() {
    const { lienzo, sitio: r, escala } = mundo.ojo, c = lienzo.getContext('2d');
    c.setTransform(escala, 0, 0, escala, -r.x * escala, -r.y * escala);
    c.drawImage(op.compuesto, r.x, r.y, r.w, r.h, r.x, r.y, r.w, r.h);
    op.dibujarOjo(c);
    mundo.ojo.textura.needsUpdate = true;
  }

  // lo que cambia en el modelo de Blender con el estado
  let relojBrasas = 0;
  function actualizarC(dt) {
    const est = op.estado(), ojo = op.ojo();
    pistas.llave.visible = est.llave === 'cajon';
    pistas.cuernoPuesto.visible = est.cuerno === 'puesto';
    const abierta = est.tapa === 'abierta';
    pistas.brasas.visible = abierta;
    pistas.cuernoBrasas.visible = abierta && est.cuerno === 'brasas';
    relojBrasas += dt;
    pistas.brasas.material.uniforms.uT.value = relojBrasas;
    pistas.luzBrasas.intensity = abierta ? 0.12 * (0.75 + 0.25 * Math.sin(relojBrasas * 5.1) * Math.sin(relojBrasas * 2.3 + 1)) : 0;
    // la tapa: sigue la animación de juego.js (en píxeles del boceto) pero en 3D
    const tv = op.tapa(), t = pistas.tapa, s = pistas.pxMundo;
    t.rotation.set(0, 0, 0); t.scale.set(1, 1, 1);
    if (tv) {
      const e = limitar((TAPA_ORIGEN.x - tv.x) / (TAPA_ORIGEN.x - TAPA_MESA.x), 0, 1);
      if (e <= 0) t.position.copy(pistas.tapaReposo).add(new THREE.Vector3(0, (TAPA_ORIGEN.y - tv.y) * s, 0));
      else {
        const alzada = pistas.tapaReposo.clone().add(new THREE.Vector3(0, 30 * s, 0));
        const arco = mezclar(TAPA_ORIGEN.y - 30, TAPA_MESA.y, e) - tv.y;
        t.position.copy(alzada).lerp(pistas.tapaMesa, e).add(new THREE.Vector3(0, Math.max(0, arco) * s, 0));
      }
      t.rotation.z = -tv.ang * 2;
      t.scale.set(tv.sx, tv.sy, tv.sx);
    } else t.position.copy(op.conTapaEnMesa() ? pistas.tapaMesa : pistas.tapaReposo);
    // el ojo
    const u = tintas.ojo;
    u.uIris.value.set(ojo.ox * 2.55, ojo.oy * 2.1);
    u.uCierre.value = ojo.cerrado;
    const latido = 0.62 + 0.38 * Math.exp(-Math.pow(((op.reloj() % 1.7) - 0.1) / 0.09, 2));
    u.uRojo.value = op.despertar.ojos * latido;
    // la trampilla
    trampilla = op.despertar.trampilla;
    pistas.bisagra.rotation.x = -1.75 * trampilla;
    pistas.resplandor.material.uniforms.uFuerza.value = trampilla * (0.85 + 0.15 * Math.sin(op.reloj() * 3.1));
    pistas.luzTrampilla.intensity = 0.8 * trampilla;
  }

  // --- toques ----------------------------------------------------------------------------------
  function tocar(sx, sy) {
    const ndc = new THREE.Vector2(sx / mundo.ancho * 2 - 1, 1 - sy / mundo.alto * 2);
    rig.colocar(op.reloj(), 0);
    mundo.raycaster.setFromCamera(ndc, mundo.camara);
    const hits = mundo.raycaster.intersectObjects([...objetivosToque, mundo.mesa, mundo.sala], true);
    const est = op.estado();
    for (const h of hits) {
      const o = h.object;
      if (!esVisible(o) || o.userData.contorno) continue;
      const tipo = o.userData.tipo;
      if (esB && tipo === 'cajon') return { malla: o, punto: { ...centroCajon(o.userData.cajon), cara: 'frente', cajon: o.userData.cajon } };
      if (esB && tipo === 'caja') {
        const local = caja.worldToLocal(h.point.clone());
        const detras = h.face && (h.face.materialIndex === 1 || h.face.materialIndex === 5);
        // el costado de los cajones: el cajón cerrado que hay en ese punto
        if (o === pintada.cuerpo && h.face && h.face.materialIndex === 0) {
          const id = cajonEnCostado(-local.z, local.y);
          if (id) return { malla: o, punto: { ...centroCajon(id), cara: 'frente', cajon: id } };
        }
        if (detras) local.set(-local.x, local.y, -local.z);
        return { malla: o, punto: { ...alBoceto(local), cara: detras ? 'detras' : 'frente' } };
      }
      if (tipo === 'objeto') {
        const p = alBoceto(h.point);
        const alfa = o.name === 'incensario' ? mundo.siluetas.incensario(p.x, p.y) : mundo.siluetas.te(p.x, p.y);
        const [x0, y0, x1, y1] = op.escena3d.objetos[o.name].recorte;
        if (alfa > 0.5 && p.x >= x0 && p.x <= x1 && p.y >= y0 && p.y <= y1) return { malla: o, punto: { ...p, cara: 'frente' } };
        continue;
      }
      if (tipo === 'sala' || tipo === 'mesa') return { malla: o, punto: { ...alBoceto(h.point), cara: 'frente' } };
      if (!esB) {
        const nombres = []; for (let a = o; a; a = a.parent) if (a.name) nombres.push(a.name);
        if (nombres.includes('Cara') && h.uv) return { malla: o, punto: { ...zonaDeCara(h.uv.x * 1024, h.uv.y * 1024), cara: 'frente' } };
        const z = zonaDePieza(nombres, est);
        if (z) return { malla: o, punto: z };
        // otra parte de la caja: según hacia dónde mira la cara tocada
        let enCaja = false; for (let a = o; a; a = a.parent) if (a === caja) enCaja = true;
        if (enCaja && h.face) {
          const n = h.face.normal.clone().transformDirection(o.matrixWorld).applyQuaternion(caja.quaternion.clone().invert());
          if (n.y > 0.7) return { malla: o, punto: { x: 1100, y: 205, cara: 'frente' } };
          if (n.z < -0.6) return { malla: o, punto: { x: 900, y: 620, cara: 'detras' } };
          if (n.x < -0.6) return { malla: o, punto: { x: 1180, y: 400, cara: 'detras' } };
          if (n.x > 0.6) return { malla: o, punto: { x: 1175, y: 590, cara: 'frente' } };
          return { malla: o, punto: { x: 980, y: 560, cara: 'frente' } };
        }
      }
    }
    return null;
  }

  // --- anclas: un punto del boceto, en la pantalla de ahora (los efectos de juego.js lo usan) --------
  const _proyectado = new THREE.Vector3(), _derecha = new THREE.Vector3();
  function puntoReposo(x, y, objeto) {
    const rayo = rayoDelBoceto(x, y), r = new THREE.Vector3();
    if (objeto === 'caja' || objeto === 'caja_detras') {
      let mejor = null;
      for (const b of mundo.cajasReposo) { const q = rayo.intersectBox(b, new THREE.Vector3()); if (q && (!mejor || q.distanceTo(rayo.origin) < mejor.distanceTo(rayo.origin))) mejor = q; }
      return mejor || rayo.intersectPlane(planoFrontal(mundo.centroCaja), r);
    }
    if (objeto === 'incensario') return rayo.intersectPlane(planoFrontal(mundo.centroIncensario), r);
    if (objeto === 'te') return rayo.intersectPlane(planoFrontal(mundo.centroTe), r);
    if (objeto === 'mesa') return rayo.intersectPlane(new THREE.Plane(EJE_Y, -mundo.zTablero), r);
    // la sala: el suelo o una de las dos paredes, lo primero que encuentre el rayo
    const e = op.escena3d, planos = [new THREE.Plane(EJE_Y, -e.z_suelo), new THREE.Plane(new THREE.Vector3(0, 0, 1), e.esquina[1]),
      new THREE.Plane(new THREE.Vector3(1, 0, 0), -e.esquina[0])];
    let mejor = null;
    for (const pl of planos) { const q = rayo.intersectPlane(pl, new THREE.Vector3()); if (q && (!mejor || q.distanceTo(rayo.origin) < mejor.distanceTo(rayo.origin))) mejor = q; }
    return mejor;
  }
  function aPantalla(v) {
    _proyectado.copy(v).project(mundo.camara);
    return { x: (_proyectado.x + 1) / 2 * mundo.ancho, y: (1 - _proyectado.y) / 2 * mundo.alto, z: _proyectado.z };
  }
  // un punto del boceto (con su objeto) o un punto 3D ya calculado, en la pantalla de ahora
  function ancla(p, objeto = 'caja') {
    if (p.isVector3) { const s = aPantalla(p); return { x: s.x, y: s.y, k: 1, visible: s.z > -1 && s.z < 1 }; }
    const reposo = puntoReposo(p.x, p.y, objeto);
    if (!reposo) return null;
    const profundidad = reposo.distanceTo(mundo.proyector.position);
    let actual = reposo.clone();
    if (objeto === 'caja' || objeto === 'caja_detras') {
      if (objeto === 'caja_detras') actual.set(-actual.x, actual.y, -actual.z);
      actual = caja.localToWorld(actual);
    }
    const a = aPantalla(actual);
    // cuánto mide en la pantalla un píxel del boceto a esa profundidad
    _derecha.set(1, 0, 0).applyQuaternion(mundo.camara.quaternion).multiplyScalar(profundidad / op.camaraBoceto.focal_px);
    const b = aPantalla(actual.clone().add(_derecha));
    return { x: a.x, y: a.y, k: Math.hypot(b.x - a.x, b.y - a.y), visible: a.z > -1 && a.z < 1 };
  }
  // para la prueba automática: dónde tocar en la pantalla para dar en lo que representa un punto del boceto
  function pantallaDe(x, y, objeto = 'caja') {
    if (esB) return ancla({ x, y }, objeto);
    const est = op.estado();
    const dentroR = (x0, y0, x1, y1) => x >= x0 && x <= x1 && y >= y0 && y <= y1;
    let nombre = null, puntoCara = null;
    if (objeto === 'caja_detras') nombre = dentroR(715, 474, 990, 558) ? 'CajonLargo_frente' : dentroR(815, 328, 878, 408) ? 'HuecoFicha' : 'CajonDetras_8_frente';
    else if (dentroR(1028, 456, 1126, 522)) nombre = est.llave === 'cajon' ? 'LlaveBambu' : 'CajonDerecho_5';
    else if (dentroR(1104, 426, 1172, 474)) nombre = 'CajonDerecho_1';
    else if (dentroR(1021, 233, 1074, 312)) nombre = 'CajonDerecho_0';
    else if (Math.hypot(x - 912, y - 291) < 40) puntoCara = [636, 184];
    else if (Math.hypot((x - 785) / 38, (y - 370) / 19) < 1) puntoCara = [300, 478];
    else if (dentroR(566, 444, 620, 516) && est.tapa === 'abierta' && est.cuerno === 'brasas') nombre = 'CuernoBrasas';
    else if (dentroR(496, 426, 652, 612)) nombre = 'Incensario';
    if (puntoCara) return ancla(caja.localToWorld(pistas.puntoCara(puntoCara[0], puntoCara[1])));
    if (!nombre) return ancla({ x, y }, objeto);
    let malla = null; grupo.traverse(o => { if (!malla && o.name === nombre) malla = o; });
    if (!malla) return ancla({ x, y }, objeto);
    // un punto de la pieza que se vea de verdad (que el rayo dé en ella y no en otra cosa)
    const bb = new THREE.Box3().expandByObject(malla);
    for (const [fx, fy, fz] of [[0.5, 0.5, 0.5], [0.5, 0.7, 0.5], [0.3, 0.5, 0.7], [0.7, 0.5, 0.7], [0.5, 0.8, 0.8], [0.5, 0.3, 0.5]]) {
      const v = new THREE.Vector3(mezclar(bb.min.x, bb.max.x, fx), mezclar(bb.min.y, bb.max.y, fy), mezclar(bb.min.z, bb.max.z, fz));
      const s = aPantalla(v), hit = tocar(s.x, s.y);
      let es = false; if (hit) for (let a = hit.malla; a; a = a.parent) if (a === malla) es = true;
      if (es) return { x: s.x, y: s.y, k: 1, visible: true };
    }
    const s = aPantalla(bb.getCenter(new THREE.Vector3()));
    return { x: s.x, y: s.y, k: 1, visible: true };
  }
  return tec;
}

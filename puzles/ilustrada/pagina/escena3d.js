// La sala del boceto en 3D, para las técnicas B y C.
// La cámara desde la que está pintado el boceto (camara.json) proyecta las pinturas sobre una geometría
// sencilla: la sala (suelo y dos paredes), la mesa, lo que hay en ella y la caja. Desde esa cámara se ve
// exactamente la ilustración; al moverse aparece la profundidad. Los datos vienen en ejes de Blender
// (X derecha, Y fondo, Z arriba) y aquí se pasan a los de Three.js (Y arriba).
import * as THREE from 'three';

export const aThree = (x, y, z) => new THREE.Vector3(x, z, -y);

// La cámara del boceto, como cámara de Three.js
export function crearProyector(datos) {
  const R = datos.mundo_a_camara;
  const derecha = aThree(...R[0]);
  const arriba = aThree(...R[1]).negate();        // la fila 1 apunta hacia abajo en la imagen
  const adelante = aThree(...R[2]);
  const m = new THREE.Matrix4().makeBasis(derecha, arriba, adelante.clone().negate());
  const camara = new THREE.PerspectiveCamera(datos.fov_vertical_grados, datos.imagen[0] / datos.imagen[1], 0.02, 30);
  camara.position.copy(aThree(...datos.posicion));
  camara.quaternion.setFromRotationMatrix(m);
  camara.updateMatrixWorld(true);
  camara.updateProjectionMatrix();
  return camara;
}

// Material que pinta con la ilustración proyectada desde la cámara del boceto. «reposo» es la matriz del
// objeto cuando se pintó: si el objeto se mueve, la pintura se mueve con él. Fuera de la imagen, penumbra.
const vertice = /* glsl */`
  uniform mat4 uProyector;
  uniform mat4 uReposo;
  uniform float uUsarReposo;
  varying vec4 vProy;
  varying vec2 vUvCara;
  void main() {
    vec4 mundoReposo = uUsarReposo > 0.5 ? uReposo * vec4(position, 1.0) : modelMatrix * vec4(position, 1.0);
    vProy = uProyector * mundoReposo;
    vUvCara = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }`;
const fragmento = /* glsl */`
  uniform sampler2D uPintura;
  uniform sampler2D uMascara;
  uniform float uConMascara;
  uniform float uUmbral;
  uniform vec4 uRecorte;
  uniform float uConRecorte;
  uniform sampler2D uOjo;
  uniform vec4 uOjoRect;
  uniform float uConOjo;
  uniform vec3 uTinte;
  uniform vec3 uPenumbra;
  uniform sampler2D uFrontal;
  uniform float uConFrontal;
  uniform float uMezcla;
  varying vec4 vProy;
  varying vec2 vUvCara;
  void main() {
    vec2 uv = vProy.xy / vProy.w * 0.5 + 0.5;
    if (uConMascara > 0.5 && texture2D(uMascara, uv).a < uUmbral) discard;
    // cada objeto toma solo su trozo de la pintura (si no, la tetera saldría también en las tazas)
    if (uConRecorte > 0.5 && (uv.x < uRecorte.x || uv.x > uRecorte.z || uv.y < uRecorte.y || uv.y > uRecorte.w)) discard;
    vec3 c = texture2D(uPintura, clamp(uv, 0.001, 0.999)).rgb;
    // el ojo, que se mueve: un trocito de lienzo que se repinta en cada cuadro
    if (uConOjo > 0.5) {
      vec2 q = (uv - uOjoRect.xy) / (uOjoRect.zw - uOjoRect.xy);
      if (q.x >= 0.0 && q.x <= 1.0 && q.y >= 0.0 && q.y <= 1.0) c = texture2D(uOjo, q).rgb;
    }
    // fuera del cuadro pintado se apaga poco a poco hacia la penumbra de la sala
    vec2 fuera = max(vec2(0.0), max(-uv, uv - 1.0));
    float borde = smoothstep(0.0, 0.42, max(fuera.x * 1.78, fuera.y * 2.4));
    c = mix(c, uPenumbra, borde);
    // la cara pintada de frente (costados y tapa): cuanto más de frente se ve, más nítida que la proyección
    if (uConFrontal > 0.5 && uMezcla > 0.001) c = mix(c, texture2D(uFrontal, vUvCara).rgb, uMezcla);
    gl_FragColor = vec4(c * uTinte, 1.0);
  }`;

// Un rectángulo del boceto [x0, y0, x1, y1] (píxeles) en coordenadas de textura (y hacia arriba)
export const rectanguloUV = ([x0, y0, x1, y1], ancho = 1376, alto = 768) =>
  new THREE.Vector4(x0 / ancho, 1 - y1 / alto, x1 / ancho, 1 - y0 / alto);

// «frontal»: { textura, mezcla } con la cara pintada de frente (en las UV de la malla) y un uniforme compartido que
// dice cuánto se ve (0 = la proyección del boceto, exacta desde su cámara; 1 = la pintura de frente)
export function materialPintura(textura, proyector, { reposo = null, mascara = null, lado = THREE.FrontSide, umbral = 0.5,
  recorte = null, ojo = null, frontal = null } = {}) {
  const pv = new THREE.Matrix4().multiplyMatrices(proyector.projectionMatrix, proyector.matrixWorldInverse);
  return new THREE.ShaderMaterial({
    uniforms: {
      uPintura: { value: textura },
      uMascara: { value: mascara },
      uConMascara: { value: mascara ? 1 : 0 },
      uUmbral: { value: umbral },
      uRecorte: { value: recorte || new THREE.Vector4(0, 0, 1, 1) },
      uConRecorte: { value: recorte ? 1 : 0 },
      uOjo: { value: ojo ? ojo.textura : null },
      uOjoRect: { value: ojo ? ojo.rect : new THREE.Vector4(0, 0, 0, 0) },
      uConOjo: { value: ojo ? 1 : 0 },
      uProyector: { value: pv },
      uReposo: { value: reposo || new THREE.Matrix4() },
      uUsarReposo: { value: reposo ? 1 : 0 },
      uTinte: { value: new THREE.Color(1, 1, 1) },
      uPenumbra: { value: new THREE.Color(0.085, 0.062, 0.047) },
      uFrontal: { value: frontal ? frontal.textura : null },
      uConFrontal: { value: frontal ? 1 : 0 },
      uMezcla: frontal ? frontal.mezcla : { value: 0 },
    },
    vertexShader: vertice,
    fragmentShader: fragmento,
    side: lado,
  });
}

// Una capa recortada (imagen + su sitio en capas.json), puesta en un lienzo del tamaño del boceto
export function texturaDeCapa(imagen, sitio, ancho = 1376, alto = 768) {
  const lienzo = document.createElement('canvas');
  lienzo.width = ancho; lienzo.height = alto;
  lienzo.getContext('2d').drawImage(imagen, sitio.x, sitio.y);
  const t = new THREE.CanvasTexture(lienzo);
  t.colorSpace = THREE.NoColorSpace;
  return t;
}

export function cargarImagen(url) {
  return new Promise((ok, mal) => { const i = new Image(); i.onload = () => ok(i); i.onerror = mal; i.src = url; });
}

export function cargarTextura(url) {
  return new Promise((ok, mal) => new THREE.TextureLoader().load(url, t => {
    t.colorSpace = THREE.NoColorSpace;      // la pintura pasa tal cual, sin conversiones de color
    t.minFilter = THREE.LinearMipmapLinearFilter;
    t.anisotropy = 4;
    ok(t);
  }, undefined, mal));
}

// La sala: suelo, pared de la ventana y pared del tokonoma, con la plancha sin mesa
export function crearSala(escena, proyector, texturas) {
  const grupo = new THREE.Group();
  const mat = materialPintura(texturas.salaVacia, proyector, { lado: THREE.DoubleSide });
  const esquina = escena.esquina;
  const zFondo = -esquina[1];                         // pared de la ventana (Three: z)
  const xIzq = esquina[0];                            // pared del tokonoma (Three: x)
  const ySuelo = escena.z_suelo;
  const suelo = new THREE.Mesh(new THREE.PlaneGeometry(8, 8), mat);
  suelo.rotation.x = -Math.PI / 2;
  suelo.position.set(xIzq + 4, ySuelo, zFondo + 4);
  const fondo = new THREE.Mesh(new THREE.PlaneGeometry(8, 4), mat);
  fondo.position.set(xIzq + 4, ySuelo + 2, zFondo);
  const izquierda = new THREE.Mesh(new THREE.PlaneGeometry(8, 4), mat);
  izquierda.rotation.y = Math.PI / 2;
  izquierda.position.set(xIzq, ySuelo + 2, zFondo + 4);
  grupo.add(suelo, fondo, izquierda);
  for (const m of grupo.children) m.userData.tipo = 'sala';
  return grupo;
}

// La mesa redonda: tablero y patas, con la plancha de la mesa vacía
export function crearMesa(escena, proyector, texturas) {
  const grupo = new THREE.Group();
  const mat = materialPintura(texturas.mesaVacia, proyector);
  const { centro, radio, grueso } = escena.mesa;
  const zt = escena.z_tablero;
  const tablero = new THREE.Mesh(new THREE.CylinderGeometry(radio, radio, grueso, 96), mat);
  tablero.position.copy(aThree(centro[0], centro[1], zt - grueso / 2));
  grupo.add(tablero);
  const alto = zt - grueso - escena.z_suelo;
  for (let i = 0; i < 4; i++) {
    const a = Math.PI / 4 + i * Math.PI / 2;
    const pata = new THREE.Mesh(new THREE.BoxGeometry(0.045, alto, 0.045), mat);
    pata.position.copy(aThree(centro[0] + 0.3 * Math.cos(a), centro[1] + 0.3 * Math.sin(a), zt - grueso - alto / 2));
    grupo.add(pata);
  }
  for (const m of grupo.children) m.userData.tipo = 'mesa';
  return grupo;
}

// Lo que hay en la mesa: cilindros con la pintura y su silueta (lo de fuera no se pinta). Cada cilindro es lo
// bastante ancho y alto para cubrir el recorte de su objeto en el boceto (el asa y el pico de la tetera, el león).
export function crearObjetos(escena, proyector, texturas) {
  const objetos = {};
  const P = proyector.position;
  const rayo = (x, y) => {
    const q = new THREE.Vector3(x / 1376 * 2 - 1, 1 - y / 768 * 2, 0.5).unproject(proyector);
    return new THREE.Ray(P.clone(), q.sub(P).normalize());
  };
  for (const [nombre, o] of Object.entries(escena.objetos)) {
    const mascara = nombre === 'incensario' ? texturas.siluetaIncensario : texturas.siluetaTe;
    const mat = materialPintura(texturas.frente, proyector, { mascara, umbral: 0.55, recorte: rectanguloUV(o.recorte) });
    const eje = aThree(o.base[0], o.base[1], o.base[2]);
    const n = P.clone().sub(eje); n.y = 0; n.normalize();
    const plano = new THREE.Plane().setFromNormalAndCoplanarPoint(n, eje);
    const [x0, y0, x1, y1] = o.recorte, ym = (y0 + y1) / 2;
    let radio = o.radio, alto = o.alto * 1.08;
    for (const x of [x0, x1]) {
      const q = rayo(x, ym).intersectPlane(plano, new THREE.Vector3());
      if (q) radio = Math.max(radio, Math.hypot(q.x - eje.x, q.z - eje.z) * 1.02);
    }
    const arriba = rayo((x0 + x1) / 2, y0).intersectPlane(plano, new THREE.Vector3());
    if (arriba) alto = Math.max(alto, (arriba.y - eje.y) * 1.03);
    const malla = new THREE.Mesh(new THREE.CylinderGeometry(radio, radio, alto, 48, 1, true), mat);
    malla.position.copy(eje).add(new THREE.Vector3(0, alto / 2, 0));
    malla.name = nombre;
    malla.userData.tipo = 'objeto';
    objetos[nombre] = malla;
  }
  return objetos;
}

// La caja pintada (técnica B): cuerpo y peana. Lo que se ve en el boceto de frente (delante, derecha y
// arriba) sale de la pintura de frente; lo de detrás y la izquierda, de la pintura de espaldas, que es la
// misma caja girada media vuelta en su sitio. Los costados y la tapa se ven muy de lado en los bocetos: llevan
// además su repintado de frente (capas/cara_*.webp, herramientas/caras_boceto.py), que tecnica_3d.js mezcla
// cuando la caja gira o la cámara se mueve.
export function crearCajaPintada(escena, proyector, texturas) {
  const caja = new THREE.Group();
  caja.name = 'caja';
  const alto = 0.21 * escena.alto_caja;
  const p = escena.peana;
  const mFondo = new THREE.MeshBasicMaterial({ color: 0x0b0806 });
  const materiales = [];
  const mezclas = { derecha: { value: 0 }, izquierda: { value: 0 }, arriba: { value: 0 } };
  // caras de BoxGeometry: +x (derecha), −x (izquierda), +y (arriba), −y (abajo), +z (delante), −z (detrás)
  function pintar(malla, { ojo = null, caras = false } = {}) {
    malla.updateMatrix();
    const reposo = malla.matrix.clone();                                             // tal como se pintó
    const reposoDetras = new THREE.Matrix4().makeRotationY(Math.PI).multiply(malla.matrix);  // media vuelta
    const mF = materialPintura(texturas.frente, proyector, { reposo, ojo });
    const mD = materialPintura(texturas.detras, proyector, { reposo: reposoDetras });
    let mDer = mF, mIzq = mD, mArr = mF;
    if (caras) {
      mDer = materialPintura(texturas.frente, proyector, { reposo, frontal: { textura: texturas.caraDerecha, mezcla: mezclas.derecha } });
      mIzq = materialPintura(texturas.detras, proyector, { reposo: reposoDetras, frontal: { textura: texturas.caraIzquierda, mezcla: mezclas.izquierda } });
      mArr = materialPintura(texturas.frente, proyector, { reposo, frontal: { textura: texturas.caraArriba, mezcla: mezclas.arriba } });
      materiales.push(mDer, mIzq, mArr);
    }
    malla.material = [mDer, mIzq, mArr, mFondo, mF, mD];
    malla.userData.tipo = 'caja';
    materiales.push(mF, mD);
  }
  const cuerpo = new THREE.Mesh(new THREE.BoxGeometry(0.22, alto, 0.22));
  cuerpo.position.set(0, 0.034 + alto / 2, 0);
  const altoPeana = 0.034 - p.z_abajo;
  const peana = new THREE.Mesh(new THREE.BoxGeometry(p.medio_x * 2, altoPeana, p.medio_y * 2));
  peana.position.copy(aThree(p.centro[0], p.centro[1], p.z_abajo + altoPeana / 2));
  pintar(cuerpo, { ojo: texturas.ojo || null, caras: !!texturas.caraDerecha });
  pintar(peana);
  caja.add(cuerpo, peana);
  return { caja, cuerpo, peana, materiales, mezclas, alto };
}

// Texturas de laca para las paredes de los cajones, pintadas en un lienzo a partir de la laca del boceto (la pared
// de un cajón abierto): fuera, roja con luz de lámpara; dentro y el fondo, en sombra; el canto, más claro. Con un
// borde a tinta, como todo en el boceto.
function texturasLaca(laca) {
  const hacer = (ancho, alto, pintar) => {
    const c = document.createElement('canvas'); c.width = ancho; c.height = alto;
    const k = c.getContext('2d');
    pintar(k, ancho, alto);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;      // MeshBasicMaterial: entra en sRGB y sale igual
    t.anisotropy = 4;
    return t;
  };
  const vetas = (k, w, h, alfa) => {
    for (let i = 0; i < 26; i++) {
      const y = (i * 37 % 97) / 97 * h, g = 0.6 + (i % 3) * 0.5;
      k.strokeStyle = i % 2 ? `rgba(40, 12, 6, ${alfa})` : `rgba(255, 190, 140, ${alfa * 0.6})`;
      k.lineWidth = g; k.beginPath(); k.moveTo(0, y);
      for (let x = 0; x <= w; x += 16) k.lineTo(x, y + Math.sin(x * 0.07 + i) * 1.4);
      k.stroke();
    }
  };
  const tinta = (k, w, h, a = 0.85, g = 3) => { k.strokeStyle = `rgba(26, 10, 6, ${a})`; k.lineWidth = g; k.strokeRect(g / 2, g / 2, w - g, h - g); };
  const base = (k, w, h, luz, sombra) => {
    if (laca) k.drawImage(laca, 0, 0, w, h); else { k.fillStyle = '#90402a'; k.fillRect(0, 0, w, h); }
    const g = k.createLinearGradient(0, 0, w * 0.4, h);
    g.addColorStop(0, luz); g.addColorStop(1, sombra);
    k.globalCompositeOperation = 'soft-light'; k.fillStyle = g; k.fillRect(0, 0, w, h);
    k.globalCompositeOperation = 'source-over';
  };
  return {
    fuera: hacer(128, 64, (k, w, h) => {
      base(k, w, h, 'rgba(255, 200, 150, 0.9)', 'rgba(60, 20, 10, 0.7)');
      vetas(k, w, h, 0.16);
      const g = k.createLinearGradient(0, 0, w, 0);          // más oscuro hacia dentro de la caja
      g.addColorStop(0, 'rgba(20, 8, 4, 0.55)'); g.addColorStop(0.35, 'rgba(20, 8, 4, 0)');
      k.fillStyle = g; k.fillRect(0, 0, w, h);
      tinta(k, w, h);
    }),
    dentro: hacer(64, 64, (k, w, h) => {
      base(k, w, h, 'rgba(120, 60, 40, 0.6)', 'rgba(20, 6, 3, 0.9)');
      k.fillStyle = 'rgba(18, 7, 4, 0.55)'; k.fillRect(0, 0, w, h);
      vetas(k, w, h, 0.1);
      tinta(k, w, h, 0.6, 2);
    }),
    suelo: hacer(64, 64, (k, w, h) => {
      base(k, w, h, 'rgba(140, 70, 45, 0.6)', 'rgba(20, 6, 3, 0.9)');
      const g = k.createLinearGradient(0, 0, w, 0);          // en sombra al fondo del cajón
      g.addColorStop(0, 'rgba(12, 5, 3, 0.85)'); g.addColorStop(0.7, 'rgba(12, 5, 3, 0.35)');
      k.fillStyle = g; k.fillRect(0, 0, w, h);
      tinta(k, w, h, 0.5, 2);
    }),
    canto: hacer(32, 16, (k, w, h) => {
      base(k, w, h, 'rgba(255, 220, 170, 1)', 'rgba(200, 120, 80, 0.4)');
      k.fillStyle = 'rgba(255, 210, 160, 0.25)'; k.fillRect(0, 0, w, h);
      tinta(k, w, h, 0.7, 2);
    }),
  };
}

// Los cajones del costado (técnica B). Cerrados no se ven: los pinta la caja. Al abrirse, cada uno sale por +x con
// su frente (la misma proyección y el mismo repintado que el costado, pegados a él), sus paredes de laca, el hueco
// oscuro que deja y su sombra. Todo en metros, en el espacio de la caja; tecnica_3d.js mueve cada grupo.
// Las paredes son más bajas que el frente para que se vea lo que guarda (como en el boceto).
export function crearCajonesPintados(datos, alto, proyector, texturas, mezcla) {
  const X = datos.x, fondo = datos.fondo, t = 0.0025, grueso = 0.006;
  const laca = texturasLaca(texturas.lacaPared);
  const m = Object.fromEntries(Object.entries(laca).map(([n, tex]) => [n, new THREE.MeshBasicMaterial({ map: tex })]));
  const canto = new THREE.MeshBasicMaterial({ color: new THREE.Color().setRGB(0.3, 0.2, 0.12, THREE.SRGBColorSpace) });
  const hueco = new THREE.MeshBasicMaterial({ color: new THREE.Color().setRGB(0.06, 0.035, 0.022, THREE.SRGBColorSpace) });
  // la sombra que deja el cajón abierto en el costado, debajo de él
  const cs = document.createElement('canvas'); cs.width = 4; cs.height = 32;
  const ks = cs.getContext('2d'), gs = ks.createLinearGradient(0, 0, 0, 32);
  gs.addColorStop(0, 'rgba(8, 4, 2, 0.75)'); gs.addColorStop(1, 'rgba(8, 4, 2, 0)');
  ks.fillStyle = gs; ks.fillRect(0, 0, 4, 32);
  const texSombra = new THREE.CanvasTexture(cs);
  const caja3 = (sx, sy, sz, x, y, z, mats) => {
    const malla = new THREE.Mesh(new THREE.BoxGeometry(sx, sy, sz), mats);
    malla.position.set(x, y, z);
    return malla;
  };
  const cajones = {};
  for (const d of datos.cajones) {
    const [y0, y1] = d.y, [z0, z1] = d.z;                // Blender: y del costado (delante → atrás), z arriba
    const ancho = y1 - y0, altoC = z1 - z0, zc = -(y0 + y1) / 2, yc = (z0 + z1) / 2;
    const grupo = new THREE.Group();
    grupo.name = 'cajon_' + d.id;
    // el frente: una tabla con la pintura del costado en su cara de fuera (+x) y las UV de su trozo de costado
    const geo = new THREE.BoxGeometry(grueso, altoC, ancho);
    const uv = geo.attributes.uv;
    for (let i = 0; i < 4; i++) {                        // cara +x: u de delante (y0) a atrás, v de abajo arriba
      uv.setXY(i, (y0 + 0.11 + uv.getX(i) * ancho) / 0.22, (z0 - 0.034 + uv.getY(i) * altoC) / alto);
    }
    const frente = new THREE.Mesh(geo);
    frente.position.set(X - grueso / 2 + 0.0004, yc, zc);
    frente.updateMatrix();
    const mFrente = materialPintura(texturas.frente, proyector, { reposo: frente.matrix.clone(),
      frontal: texturas.caraDerecha ? { textura: texturas.caraDerecha, mezcla } : null });
    frente.material = [mFrente, canto, canto, canto, canto, canto];
    // la caja del cajón: paredes bajas, el fondo y la trasera (dentro de la caja mientras no sale del todo)
    const largo = fondo - grueso, xm = X - grueso - largo / 2, hw = altoC * 0.5;
    const cerca = caja3(largo, hw, t, xm, z0 + hw / 2, -y0 - t / 2, [m.dentro, m.dentro, m.canto, m.fuera, m.fuera, m.dentro]);
    const lejos = caja3(largo, hw, t, xm, z0 + hw / 2, -y1 + t / 2, [m.dentro, m.dentro, m.canto, m.fuera, m.dentro, m.fuera]);
    const suelo = caja3(largo, t, ancho - 2 * t, xm, z0 + t / 2, zc, [m.dentro, m.dentro, m.suelo, m.fuera, m.fuera, m.fuera]);
    const trasera = caja3(t, hw, ancho - 2 * t, X - fondo + t / 2, z0 + hw / 2, zc, [m.dentro, m.fuera, m.canto, m.fuera, m.fuera, m.fuera]);
    grupo.add(frente, cerca, lejos, suelo, trasera);
    // el hueco que deja en el costado y la sombra que hace debajo (no se mueven con el cajón)
    const agujero = new THREE.Mesh(new THREE.PlaneGeometry(ancho, altoC), hueco);
    agujero.rotation.y = Math.PI / 2; agujero.position.set(X + 0.0002, yc, zc);
    const sombra = new THREE.Mesh(new THREE.PlaneGeometry(ancho, 0.02),
      new THREE.MeshBasicMaterial({ map: texSombra, transparent: true, depthWrite: false, opacity: 0 }));
    sombra.rotation.y = Math.PI / 2; sombra.position.set(X + 0.0003, z0 - 0.01, zc);
    for (const o of [frente, cerca, lejos, suelo, trasera, agujero, sombra]) { o.userData.tipo = 'cajon'; o.userData.cajon = d.id; }
    sombra.raycast = () => {};
    cajones[d.id] = { grupo, agujero, sombra, materiales: [mFrente],
      // dónde va lo que guarda: hacia el fondo del cajón (para que asome por encima de la pared baja)
      dentro: new THREE.Vector3(X - grueso - 0.03, z0 + t, -(y0 + (y1 - y0) * 0.62)) };
  }
  return cajones;
}

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
  void main() {
    vec4 mundoReposo = uUsarReposo > 0.5 ? uReposo * vec4(position, 1.0) : modelMatrix * vec4(position, 1.0);
    vProy = uProyector * mundoReposo;
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
  varying vec4 vProy;
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
    gl_FragColor = vec4(c * uTinte, 1.0);
  }`;

// Un rectángulo del boceto [x0, y0, x1, y1] (píxeles) en coordenadas de textura (y hacia arriba)
export const rectanguloUV = ([x0, y0, x1, y1], ancho = 1376, alto = 768) =>
  new THREE.Vector4(x0 / ancho, 1 - y1 / alto, x1 / ancho, 1 - y0 / alto);

export function materialPintura(textura, proyector, { reposo = null, mascara = null, lado = THREE.FrontSide, umbral = 0.5,
  recorte = null, ojo = null } = {}) {
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
// misma caja girada media vuelta en su sitio.
export function crearCajaPintada(escena, proyector, texturas) {
  const caja = new THREE.Group();
  caja.name = 'caja';
  const alto = 0.21 * escena.alto_caja;
  const p = escena.peana;
  const mFondo = new THREE.MeshBasicMaterial({ color: 0x0b0806 });
  const materiales = [];
  // caras de BoxGeometry: +x (derecha), −x (izquierda), +y (arriba), −y (abajo), +z (delante), −z (detrás)
  function pintar(malla, ojo = null) {
    malla.updateMatrix();
    const reposo = malla.matrix.clone();                                             // tal como se pintó
    const reposoDetras = new THREE.Matrix4().makeRotationY(Math.PI).multiply(malla.matrix);  // media vuelta
    const mF = materialPintura(texturas.frente, proyector, { reposo, ojo });
    const mD = materialPintura(texturas.detras, proyector, { reposo: reposoDetras });
    malla.material = [mF, mD, mF, mFondo, mF, mD];
    malla.userData.tipo = 'caja';
    materiales.push(mF, mD);
  }
  const cuerpo = new THREE.Mesh(new THREE.BoxGeometry(0.22, alto, 0.22));
  cuerpo.position.set(0, 0.034 + alto / 2, 0);
  const altoPeana = 0.034 - p.z_abajo;
  const peana = new THREE.Mesh(new THREE.BoxGeometry(p.medio_x * 2, altoPeana, p.medio_y * 2));
  peana.position.copy(aThree(p.centro[0], p.centro[1], p.z_abajo + altoPeana / 2));
  pintar(cuerpo, texturas.ojo || null);
  pintar(peana);
  caja.add(cuerpo, peana);
  // los cajones abiertos sobresalen unos 5 cm por la derecha: un bloque con la pintura de frente, recortado con
  // la silueta de la caja (entre cajón y cajón se ve la sala)
  if (texturas.siluetaCaja) {
    const sobresale = 0.05;
    const cajones = new THREE.Mesh(new THREE.BoxGeometry(sobresale, alto, 0.22));
    cajones.position.set(0.11 + sobresale / 2, 0.034 + alto / 2, 0);
    cajones.updateMatrix();
    const m = materialPintura(texturas.frente, proyector, { reposo: cajones.matrix.clone(), mascara: texturas.siluetaCaja });
    const nada = new THREE.MeshBasicMaterial({ visible: false });
    cajones.material = [m, nada, m, nada, m, nada];
    cajones.userData.tipo = 'caja'; cajones.userData.soloFrente = true; cajones.userData.mascara = 'caja';
    caja.add(cajones);
    materiales.push(m);
  }
  return { caja, cuerpo, peana, materiales };
}

// La caja hija del nivel 2 («La caja de dentro»): una himitsu-bako pequeña que sale de la trampilla de la grande.
// Es 3D de verdad, con las caras pintadas de frente (Gemini, capas/hija_*.webp), y se abre como las cajas de
// Hakone: cinco tablillas que corren en orden. Debajo de cada una, una flecha de marquetería dice cuál sigue. La
// quinta es la tapa de atrás; detrás, un cajoncito con la cajita roja.
// Ejes locales (Three.js): +x derecha, +y arriba, +z el frente (el párpado tallado), −z la espalda.
import * as THREE from 'three';

export const LADO = 0.075;                // 7,5 cm
const GRUESO = 0.0034;                     // las tablillas
export const SALE_CAJONCITO = 0.55;        // cuánto sale el cajoncito de detrás (en fracción del lado)

// Las cinco tablillas, en el orden en que corren: su cara, su textura, hacia dónde corren (en ejes locales), cuánto
// (en fracción del lado) y adónde apunta la flecha que dejan ver (la cara de la tablilla siguiente)
export const TABLILLAS = [
  { cara: 'arriba', normal: [0, 1, 0], textura: 'asanoha', corre: [0, 0, 1], cuanto: 0.42, flecha: [1, 0, 0] },
  { cara: 'derecha', normal: [1, 0, 0], textura: 'kikko', corre: [0, -1, 0], cuanto: 0.42, flecha: [0, -1, 0] },
  { cara: 'abajo', normal: [0, -1, 0], textura: 'asanoha', corre: [-1, 0, 0], cuanto: 0.42, flecha: [-1, 0, 0] },
  { cara: 'izquierda', normal: [-1, 0, 0], textura: 'kikko', corre: [0, 1, 0], cuanto: 0.42, flecha: [0, 0, -1] },
  { cara: 'atras', normal: [0, 0, -1], textura: 'asanoha', corre: [1, 0, 0], cuanto: 0.86, flecha: null },
];

const v3 = a => new THREE.Vector3(...a);

// La madera de debajo de las tablillas (kiri, más oscura) con la flecha de marquetería, en un lienzo
function texturaFondo(flecha2D, rotulo) {
  const c = document.createElement('canvas'); c.width = c.height = 256;
  const k = c.getContext('2d');
  const g = k.createLinearGradient(0, 0, 256, 256);
  g.addColorStop(0, '#6e4a2c'); g.addColorStop(1, '#4a2f1b');
  k.fillStyle = g; k.fillRect(0, 0, 256, 256);
  // vetas
  for (let i = 0; i < 40; i++) {
    k.strokeStyle = i % 2 ? 'rgba(30, 16, 8, 0.18)' : 'rgba(150, 110, 70, 0.12)';
    k.lineWidth = 1 + (i % 3);
    const y = (i * 53) % 256;
    k.beginPath(); k.moveTo(0, y); k.bezierCurveTo(80, y + 6, 170, y - 6, 256, y + 3); k.stroke();
  }
  // la flecha, de madera clara con filo de tinta, en el centro de lo que la tablilla destapa
  if (flecha2D) {
    const [fx, fy, cx, cy] = flecha2D;
    k.save(); k.translate(cx * 256, cy * 256); k.rotate(Math.atan2(fy, fx));
    k.beginPath();
    k.moveTo(-34, -8); k.lineTo(10, -8); k.lineTo(10, -20); k.lineTo(36, 0); k.lineTo(10, 20); k.lineTo(10, 8); k.lineTo(-34, 8);
    k.closePath();
    k.fillStyle = '#e2c79a'; k.fill();
    k.lineWidth = 3; k.strokeStyle = 'rgba(28, 14, 6, 0.9)'; k.stroke();
    // marquetería: tres franjas dentro de la flecha
    k.strokeStyle = 'rgba(120, 80, 45, 0.55)'; k.lineWidth = 2;
    for (const y of [-3, 3]) { k.beginPath(); k.moveTo(-30, y); k.lineTo(12, y); k.stroke(); }
    k.restore();
  }
  if (rotulo) {           // el hueco del cajoncito
    k.fillStyle = 'rgba(12, 6, 3, 0.85)'; k.fillRect(70, 96, 116, 64);
    k.strokeStyle = 'rgba(200, 160, 90, 0.6)'; k.lineWidth = 3; k.strokeRect(70, 96, 116, 64);
  }
  k.strokeStyle = 'rgba(20, 10, 5, 0.95)'; k.lineWidth = 8; k.strokeRect(4, 4, 248, 248);
  const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 4;
  return t;
}

// Cómo se ve una dirección local sobre la cara (u a la derecha, v hacia abajo en la textura de esa cara)
function ejesCara(normal) {
  const n = v3(normal);
  // «arriba» de la textura: +y salvo en las caras de arriba y de abajo (allí, −z / +z)
  const arriba = Math.abs(n.y) > 0.5 ? new THREE.Vector3(0, 0, -n.y) : new THREE.Vector3(0, 1, 0);
  const derecha = new THREE.Vector3().crossVectors(arriba, n).normalize();
  return { n, arriba, derecha };
}

export function crearCajaHija(texturas) {
  const grupo = new THREE.Group();
  grupo.name = 'caja_hija';
  const cuerpo = new THREE.Group();          // lo que gira en la mano
  grupo.add(cuerpo);
  const material = tex => new THREE.MeshLambertMaterial({ map: tex });
  const laca = new THREE.MeshLambertMaterial({ color: new THREE.Color().setRGB(0.07, 0.045, 0.035, THREE.SRGBColorSpace) });
  const L = LADO, h = L / 2;
  // el cuerpo: un cubo de madera algo más pequeño; cada cara lleva su fondo con la flecha que destapa la tablilla
  const caras = { derecha: [1, 0, 0], izquierda: [-1, 0, 0], arriba: [0, 1, 0], abajo: [0, -1, 0], frente: [0, 0, 1], atras: [0, 0, -1] };
  const fondos = {};
  for (const t of TABLILLAS) {
    const { arriba, derecha } = ejesCara(t.normal);
    const corre = v3(t.corre);
    // lo destapado queda en el lado contrario a donde corre la tablilla
    const centro = corre.clone().multiplyScalar(-(0.5 - t.cuanto / 2));
    const cu = 0.5 + centro.dot(derecha), cv = 0.5 - centro.dot(arriba);
    const flecha = t.flecha ? [v3(t.flecha).dot(derecha), -v3(t.flecha).dot(arriba), cu, cv] : null;
    fondos[t.cara] = texturaFondo(flecha, t.cara === 'atras');
  }
  const ordenCaja = ['derecha', 'izquierda', 'arriba', 'abajo', 'frente', 'atras'];   // el de BoxGeometry
  const mCuerpo = ordenCaja.map(n => (fondos[n] ? material(fondos[n]) : laca));
  const nucleo = new THREE.Mesh(new THREE.BoxGeometry(L - 2 * GRUESO, L - 2 * GRUESO, L - 2 * GRUESO), mCuerpo);
  nucleo.userData = { tipo: 'hija', parte: 'cuerpo' };
  cuerpo.add(nucleo);
  // el frente: fijo, con el párpado tallado
  const tablillas = [];
  const tinta = new THREE.LineBasicMaterial({ color: 0x140b06 });
  const conTinta = (malla, geo) => { const a = new THREE.LineSegments(new THREE.EdgesGeometry(geo), tinta); a.raycast = () => {}; malla.add(a); };
  const hacerTabla = (normal, textura) => {
    const n = v3(normal);
    // las de los lados ocupan todo; las de arriba y abajo, entre ellas; las de delante y detrás, en medio
    // (así no se pisan en las aristas)
    const tam = normal[0] !== 0 ? [GRUESO, L, L] : normal[1] !== 0 ? [L - 2 * GRUESO, GRUESO, L] : [L - 2 * GRUESO, L - 2 * GRUESO, GRUESO];
    const geo = new THREE.BoxGeometry(...tam);
    const mats = [0, 1, 2, 3, 4, 5].map(() => laca);
    const indice = normal[0] > 0.5 ? 0 : normal[0] < -0.5 ? 1 : normal[1] > 0.5 ? 2 : normal[1] < -0.5 ? 3 : normal[2] > 0.5 ? 4 : 5;
    mats[indice] = material(texturas[textura]);
    const malla = new THREE.Mesh(geo, mats);
    malla.position.copy(n.clone().multiplyScalar(h - GRUESO / 2));
    conTinta(malla, geo);
    return malla;
  };
  conTinta(nucleo, nucleo.geometry);
  const frente = hacerTabla(caras.frente, 'frente');
  frente.userData = { tipo: 'hija', parte: 'frente' };
  cuerpo.add(frente);
  TABLILLAS.forEach((t, i) => {
    const m = hacerTabla(t.normal, t.textura);
    m.userData = { tipo: 'hija', parte: 'tablilla', tablilla: i };
    m.userData.reposo = m.position.clone();
    cuerpo.add(m);
    tablillas.push(m);
  });
  // el cajoncito de detrás (sale por −z) con la cajita roja dentro
  const cajon = new THREE.Group();
  const anchoC = L * 0.46, altoC = L * 0.26, fondoC = L * 0.6;
  // de kiri oscuro, para que la cajita roja resalte dentro
  const mFrenteC = new THREE.MeshLambertMaterial({ color: new THREE.Color().setRGB(0.36, 0.23, 0.14, THREE.SRGBColorSpace) });
  const frenteC = new THREE.Mesh(new THREE.BoxGeometry(anchoC, altoC, 0.003), mFrenteC);
  frenteC.position.z = -h + 0.0015;
  const caja3 = (sx, sy, sz, x, y, z) => { const m = new THREE.Mesh(new THREE.BoxGeometry(sx, sy, sz), mFrenteC); m.position.set(x, y, z); return m; };
  const zc = -h + fondoC / 2;
  cajon.add(frenteC,
    caja3(0.0015, altoC * 0.8, fondoC, -anchoC / 2, -altoC * 0.1, zc), caja3(0.0015, altoC * 0.8, fondoC, anchoC / 2, -altoC * 0.1, zc),
    caja3(anchoC, 0.0015, fondoC, 0, -altoC / 2, zc));
  // un tirador de latón
  const tirador = new THREE.Mesh(new THREE.TorusGeometry(0.0035, 0.0009, 6, 14),
    new THREE.MeshLambertMaterial({ color: new THREE.Color().setRGB(0.75, 0.58, 0.28, THREE.SRGBColorSpace) }));
  tirador.position.set(0, 0, -h - 0.0012);
  cajon.add(tirador);
  for (const o of cajon.children) o.userData = { tipo: 'hija', parte: 'cajon' };
  cajon.visible = false;
  cuerpo.add(cajon);
  // la cajita roja: un cilindro de laca con la tapa pintada (vista desde arriba)
  const radio = L * 0.15;
  const mTapa = new THREE.MeshLambertMaterial({ map: texturas.cajita, transparent: true });
  const mLaca = new THREE.MeshLambertMaterial({ color: new THREE.Color().setRGB(0.55, 0.1, 0.05, THREE.SRGBColorSpace) });
  const cajita = new THREE.Mesh(new THREE.CylinderGeometry(radio, radio, radio * 0.9, 28), [mLaca, mTapa, mLaca]);
  cajita.position.set(0, -altoC / 2 + radio * 0.45 + 0.001, zc);
  cajita.userData = { tipo: 'hija', parte: 'cajita' };
  cajon.add(cajita);

  // animaciones (0 … 1)
  const estado = { tablillas: TABLILLAS.map(() => 0), cajon: 0 };
  function poner() {
    TABLILLAS.forEach((t, i) => {
      const m = tablillas[i];
      m.position.copy(m.userData.reposo).add(v3(t.corre).multiplyScalar(t.cuanto * L * estado.tablillas[i]));
    });
    cajon.visible = estado.tablillas[4] > 0.5 || estado.cajon > 0;
    cajon.position.z = -estado.cajon * L * SALE_CAJONCITO;
  }
  poner();
  return {
    grupo, cuerpo, tablillas, cajon, cajita, estado, poner,
    // la normal de una tablilla en el mundo
    normalMundo(i) { return v3(TABLILLAS[i].normal).applyQuaternion(cuerpo.getWorldQuaternion(new THREE.Quaternion())); },
    centroMundo(i) { const p = tablillas[i].userData.reposo.clone(); return cuerpo.localToWorld(p); },
  };
}

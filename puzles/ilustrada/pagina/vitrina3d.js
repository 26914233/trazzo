// La vitrina 3D (pedida por el usuario el 09-10-2026: «ver el objeto por todos los lados, como en The Room»).
// Los objetos de la bandeja, de cerca y en 3D: se giran arrastrando el dedo en cualquier dirección (también por arriba y
// por debajo), se acercan pellizcando (o con la rueda) y un doble toque los deja como al principio. Es una escena
// pequeña de Three.js en su propio lienzo, con la luz cálida de la lámpara y un reflejo de la sala para el bronce y la
// laca. Los modelos se hacen por código, sin descargas: cada objeto con su forma y sus materiales.
import * as THREE from 'three';
import { crearCajaHija } from './caja_hija.js';

const V = (x, y, z = 0) => new THREE.Vector3(x, y, z);
const EJE_X = V(1, 0, 0), EJE_Y = V(0, 1, 0);
const FUENTE = '"Shippori Mincho", "Hiragino Mincho ProN", "Yu Mincho", "Noto Serif JP", Georgia, serif';

// ---------------------------------------------------------------------------------------------
// Texturas pintadas en un lienzo (papel, madera, caña, bronce…), con un azar de semilla fija: cada objeto se ve siempre
// igual
// ---------------------------------------------------------------------------------------------
function azarFijo(semilla) {
  let s = semilla >>> 0;
  return () => ((s = (Math.imul(s, 1664525) + 1013904223) >>> 0) / 4294967296);
}
function textura(w, h, dibujar, { repetir = false } = {}) {
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  dibujar(c.getContext('2d'), w, h);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 4;
  if (repetir) t.wrapS = t.wrapT = THREE.RepeatWrapping;
  return t;
}
// papel washi: fibras cortas y manchas suaves
function pintarWashi(g, w, h, semilla = 7, base = '#e9dcc0') {
  const azar = azarFijo(semilla);
  g.fillStyle = base; g.fillRect(0, 0, w, h);
  for (let i = 0; i < 6; i++) {
    const x = azar() * w, y = azar() * h, r = (0.2 + azar() * 0.4) * Math.max(w, h);
    const m = g.createRadialGradient(x, y, 0, x, y, r);
    m.addColorStop(0, `rgba(150, 110, 60, ${0.05 + azar() * 0.06})`); m.addColorStop(1, 'rgba(150, 110, 60, 0)');
    g.fillStyle = m; g.fillRect(0, 0, w, h);
  }
  g.lineWidth = 1;
  for (let i = 0; i < (w * h) / 900; i++) {
    const x = azar() * w, y = azar() * h, a = azar() * Math.PI, l = 3 + azar() * 10;
    g.strokeStyle = azar() < 0.5 ? 'rgba(255, 250, 235, 0.35)' : 'rgba(120, 90, 50, 0.12)';
    g.beginPath(); g.moveTo(x, y); g.quadraticCurveTo(x + Math.cos(a) * l * 0.5 + azar() * 3, y + Math.sin(a) * l * 0.5, x + Math.cos(a) * l, y + Math.sin(a) * l); g.stroke();
  }
}
// veta de madera (o de caña): líneas a lo largo, onduladas, de grosor y tono distintos
function pintarVeta(g, w, h, { base, claro, oscuro, semilla = 3, lineas = 60, onda = 2.5, nudos = 0 }) {
  const azar = azarFijo(semilla);
  g.fillStyle = base; g.fillRect(0, 0, w, h);
  for (let i = 0; i < lineas; i++) {
    const y0 = azar() * h, fase = azar() * 6, amp = onda * (0.5 + azar()), grosor = 0.6 + azar() * 2.2;
    g.strokeStyle = azar() < 0.55 ? oscuro : claro; g.globalAlpha = 0.18 + azar() * 0.35; g.lineWidth = grosor;
    g.beginPath();
    for (let x = 0; x <= w; x += 8) g.lineTo(x, y0 + Math.sin(x / w * 6 + fase) * amp + Math.sin(x / w * 23 + fase * 2) * amp * 0.3);
    g.stroke();
  }
  g.globalAlpha = 1;
  for (let i = 0; i < nudos; i++) {
    const x = azar() * w, y = azar() * h, r = 4 + azar() * 7;
    const m = g.createRadialGradient(x, y, 0, x, y, r);
    m.addColorStop(0, oscuro); m.addColorStop(1, 'rgba(0, 0, 0, 0)');
    g.globalAlpha = 0.5; g.fillStyle = m; g.beginPath(); g.ellipse(x, y, r * 1.8, r, 0, 0, Math.PI * 2); g.fill();
  }
  g.globalAlpha = 1;
}
// bronce con pátina: verde en los huecos, más claro donde se toca
function pintarBronce(g, w, h, semilla = 11) {
  const azar = azarFijo(semilla);
  g.fillStyle = '#b07d3c'; g.fillRect(0, 0, w, h);
  for (let i = 0; i < 70; i++) {
    const x = azar() * w, y = azar() * h, r = 3 + azar() * 16;
    const m = g.createRadialGradient(x, y, 0, x, y, r);
    const verde = azar() < 0.45;
    m.addColorStop(0, verde ? 'rgba(70, 120, 95, 0.55)' : 'rgba(90, 55, 25, 0.4)'); m.addColorStop(1, 'rgba(0, 0, 0, 0)');
    g.fillStyle = m; g.fillRect(x - r, y - r, r * 2, r * 2);
  }
  for (let i = 0; i < 40; i++) {
    g.strokeStyle = `rgba(255, 220, 160, ${0.08 + azar() * 0.1})`; g.lineWidth = 1;
    const y = azar() * h; g.beginPath(); g.moveTo(0, y); g.lineTo(w, y + (azar() - 0.5) * 6); g.stroke();
  }
}
const cargarTextura = url => new Promise((ok, mal) => new THREE.TextureLoader().load(url, t => {
  t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 4; ok(t);
}, undefined, mal));
async function fuenteLista(texto) {
  try { await document.fonts.load(`800 64px ${FUENTE}`, texto); } catch (e) { /* con la de respaldo */ }
}

// el reflejo de la sala: penumbra, la lámpara (cálida, arriba a la izquierda) y la claridad fría del shoji
function entornoSala(render) {
  const t = textura(512, 256, (g, w, h) => {
    const fondo = g.createLinearGradient(0, 0, 0, h);
    fondo.addColorStop(0, '#2c2119'); fondo.addColorStop(0.55, '#141009'); fondo.addColorStop(1, '#060403');
    g.fillStyle = fondo; g.fillRect(0, 0, w, h);
    const lampara = g.createRadialGradient(w * 0.2, h * 0.34, 0, w * 0.2, h * 0.34, h * 0.36);
    lampara.addColorStop(0, 'rgba(255, 220, 160, 1)'); lampara.addColorStop(0.35, 'rgba(255, 175, 95, 0.6)'); lampara.addColorStop(1, 'rgba(255, 175, 95, 0)');
    g.fillStyle = lampara; g.fillRect(0, 0, w, h);
    g.fillStyle = 'rgba(185, 198, 222, 0.32)'; g.fillRect(w * 0.6, h * 0.16, w * 0.17, h * 0.38);
    g.fillStyle = 'rgba(120, 90, 60, 0.25)'; g.fillRect(0, h * 0.72, w, h * 0.06);       // el borde de la mesa
  });
  t.mapping = THREE.EquirectangularReflectionMapping;
  const pmrem = new THREE.PMREMGenerator(render);
  const entorno = pmrem.fromEquirectangular(t).texture;
  t.dispose(); pmrem.dispose();
  return entorno;
}

// ---------------------------------------------------------------------------------------------
// Los modelos (cada uno, más o menos de una unidad de largo; la vitrina los centra y los encaja)
// ---------------------------------------------------------------------------------------------
const malla = (geo, mat) => new THREE.Mesh(geo, mat);

// la llave de bambú: diminuta, tallada en una caña (con sus nudos), el aro para colgarla y dos dientes; la punta,
// tostada por el incienso
function modeloLlave() {
  const g = new THREE.Group();
  const cana = textura(256, 64, (c, w, h) => pintarVeta(c, w, h, { base: '#c9ad6c', claro: '#efdca6', oscuro: '#7d6232', lineas: 46, onda: 0.8 }));
  const mat = new THREE.MeshStandardMaterial({ map: cana, roughness: 0.58 });
  const nudo = new THREE.MeshStandardMaterial({ color: new THREE.Color('#8f7440'), roughness: 0.6 });
  const tallo = malla(new THREE.CylinderGeometry(0.052, 0.058, 1.0, 24), mat);
  tallo.rotation.z = Math.PI / 2; g.add(tallo);
  for (const x of [-0.1, 0.24]) {
    const n = malla(new THREE.TorusGeometry(0.058, 0.014, 8, 28), nudo);
    n.rotation.y = Math.PI / 2; n.position.x = x; g.add(n);
  }
  const aro = malla(new THREE.TorusGeometry(0.15, 0.042, 14, 36), mat);
  aro.position.x = -0.64; aro.scale.set(1, 0.9, 0.75); g.add(aro);
  for (const [x, alto] of [[0.42, 0.17], [0.31, 0.11]]) {
    const d = malla(new THREE.BoxGeometry(0.055, alto, 0.05), mat);
    d.position.set(x, -alto / 2 - 0.035, 0); g.add(d);
  }
  const hollin = malla(new THREE.SphereGeometry(0.06, 16, 12), new THREE.MeshStandardMaterial({ color: new THREE.Color('#2a1d12'), roughness: 0.9 }));
  hollin.scale.set(0.5, 1, 1); hollin.position.x = 0.5; g.add(hollin);
  return g;
}

// el cuerno de marfil: una punta curva que se estrecha, con los anillos de crecimiento cerca de la base; todavía tibio
function modeloCuerno() {
  const curva = new THREE.QuadraticBezierCurve3(V(0.02, -0.55, 0), V(0.12, 0.05, 0.04), V(-0.2, 0.55, 0.1));
  const largo = 64, lados = 28;
  const geo = new THREE.TubeGeometry(curva, largo, 1, lados, false);
  const pos = geo.attributes.position, centro = new THREE.Vector3(), p = new THREE.Vector3();
  for (let i = 0; i <= largo; i++) {
    const t = i / largo, radio = 0.17 * Math.pow(1 - t, 0.8) + 0.006;
    curva.getPointAt(t, centro);
    for (let j = 0; j <= lados; j++) {
      const k = i * (lados + 1) + j;
      p.fromBufferAttribute(pos, k).sub(centro).multiplyScalar(radio).add(centro);
      pos.setXYZ(k, p.x, p.y, p.z);
    }
  }
  geo.computeVertexNormals();
  const marfil = textura(512, 64, (g, w, h) => {
    const largoG = g.createLinearGradient(0, 0, w, 0);
    largoG.addColorStop(0, '#8a6a43'); largoG.addColorStop(0.12, '#d9c7a2'); largoG.addColorStop(0.5, '#f1e6cd'); largoG.addColorStop(0.92, '#e8dbbd'); largoG.addColorStop(1, '#bfa77f');
    g.fillStyle = largoG; g.fillRect(0, 0, w, h);
    const azar = azarFijo(19);
    for (let i = 0; i < 26; i++) {                         // anillos de crecimiento, más juntos en la base
      const x = Math.pow(azar(), 1.8) * w * 0.55;
      g.strokeStyle = `rgba(110, 80, 45, ${0.12 + azar() * 0.22})`; g.lineWidth = 1 + azar() * 2.5;
      g.beginPath(); g.moveTo(x, 0); g.lineTo(x + (azar() - 0.5) * 6, h); g.stroke();
    }
    for (let i = 0; i < 30; i++) {                         // vetas finas a lo largo
      g.strokeStyle = 'rgba(160, 130, 90, 0.12)'; g.lineWidth = 1;
      const y = azar() * h; g.beginPath(); g.moveTo(0, y); g.lineTo(w, y + (azar() - 0.5) * 8); g.stroke();
    }
  });
  const mat = new THREE.MeshStandardMaterial({ map: marfil, roughness: 0.36, emissive: new THREE.Color('#3a1404'), emissiveIntensity: 0.12 });
  const g = new THREE.Group();
  g.add(malla(geo, mat));
  // la base, hueca: un disco oscuro dentro
  const base = malla(new THREE.CircleGeometry(0.168, 32), new THREE.MeshStandardMaterial({ color: new THREE.Color('#3b2817'), roughness: 0.9, side: THREE.DoubleSide }));
  const t0 = curva.getTangentAt(0);
  base.position.copy(curva.getPointAt(0)).addScaledVector(t0, 0.004);
  base.quaternion.setFromUnitVectors(V(0, 0, 1), t0.clone().negate());
  g.add(base);
  return g;
}

// el ojo de piedra de luna: una esfera lechosa con un brillo azulado y el iris a tinta, mirando un poco a otro lado
function modeloOjo() {
  const mapa = textura(1024, 512, (g, w, h) => {
    const fondo = g.createLinearGradient(0, 0, 0, h);
    fondo.addColorStop(0, '#dfe7ef'); fondo.addColorStop(0.5, '#f3f6f8'); fondo.addColorStop(1, '#d4dde8');
    g.fillStyle = fondo; g.fillRect(0, 0, w, h);
    const azar = azarFijo(23);
    for (let i = 0; i < 14; i++) {                         // el brillo de la piedra de luna: velos azulados
      const x = azar() * w, y = h * (0.25 + azar() * 0.5), r = 60 + azar() * 140;
      const m = g.createRadialGradient(x, y, 0, x, y, r);
      m.addColorStop(0, 'rgba(150, 185, 235, 0.32)'); m.addColorStop(1, 'rgba(150, 185, 235, 0)');
      g.fillStyle = m; g.beginPath(); g.ellipse(x, y, r * 1.6, r * 0.6, azar() - 0.5, 0, Math.PI * 2); g.fill();
    }
    // el iris (en u = 0,27: casi de frente, mirando un poco a un lado y hacia abajo)
    const cx = w * 0.27, cy = h * 0.53, R = w * 0.06;
    const iris = g.createRadialGradient(cx, cy, R * 0.3, cx, cy, R);
    iris.addColorStop(0, '#525c6c'); iris.addColorStop(0.7, '#2d333d'); iris.addColorStop(1, '#14161a');
    g.fillStyle = iris; g.beginPath(); g.arc(cx, cy, R, 0, Math.PI * 2); g.fill();
    g.strokeStyle = 'rgba(205, 215, 230, 0.35)'; g.lineWidth = 1.4;
    for (let i = 0; i < 64; i++) {                         // trazos de tinta del iris
      const a = (i / 64) * Math.PI * 2 + azar() * 0.05, r0 = R * (0.38 + azar() * 0.1), r1 = R * (0.8 + azar() * 0.15);
      g.beginPath(); g.moveTo(cx + Math.cos(a) * r0, cy + Math.sin(a) * r0); g.lineTo(cx + Math.cos(a) * r1, cy + Math.sin(a) * r1); g.stroke();
    }
    g.fillStyle = '#07080a'; g.beginPath(); g.arc(cx, cy, R * 0.36, 0, Math.PI * 2); g.fill();
    g.strokeStyle = '#0b0c0e'; g.lineWidth = R * 0.08; g.beginPath(); g.arc(cx, cy, R * 0.98, 0, Math.PI * 2); g.stroke();
  });
  const mat = new THREE.MeshPhysicalMaterial({ map: mapa, roughness: 0.12, clearcoat: 1, clearcoatRoughness: 0.04,
    emissive: new THREE.Color('#3e5a8a'), emissiveIntensity: 0.07 });
  return malla(new THREE.SphereGeometry(0.5, 64, 48), mat);
}

// la cajita de laca roja: redonda, con la tapa de olas de oro y el ojo cerrado (la pintura de su icono)
async function modeloCajita() {
  const tapa = await cargarTextura('capas/cajita.webp');
  const roja = new THREE.MeshPhysicalMaterial({ color: new THREE.Color('#8c1c12'), roughness: 0.32, clearcoat: 1, clearcoatRoughness: 0.12 });
  const lado = textura(512, 64, (g, w, h) => {
    g.fillStyle = '#8c1c12'; g.fillRect(0, 0, w, h);
    g.fillStyle = '#c9a052'; g.fillRect(0, h * 0.44, w, h * 0.05); g.fillRect(0, h * 0.53, w, h * 0.02);   // la junta, con su filete de oro
  });
  const ladoMat = new THREE.MeshPhysicalMaterial({ map: lado, roughness: 0.32, clearcoat: 1, clearcoatRoughness: 0.12 });
  const arriba = new THREE.MeshPhysicalMaterial({ map: tapa, roughness: 0.3, clearcoat: 1, clearcoatRoughness: 0.1 });
  const abajo = new THREE.MeshPhysicalMaterial({ color: new THREE.Color('#120806'), roughness: 0.4, clearcoat: 0.6 });
  const caja = malla(new THREE.CylinderGeometry(0.5, 0.49, 0.3, 64, 1), [ladoMat, arriba, abajo]);
  caja.rotation.y = -Math.PI / 2;
  const g = new THREE.Group(); g.add(caja);
  const filo = malla(new THREE.TorusGeometry(0.5, 0.012, 8, 64), roja);
  filo.rotation.x = Math.PI / 2; filo.position.y = 0.15; g.add(filo);
  return g;
}

// la ficha de shōgi: un peón de madera de boj, 歩 por delante y と (en rojo) por detrás
async function modeloFicha() {
  await fuenteLista('歩と');
  const forma = new THREE.Shape([V(-0.36, -0.5), V(0.36, -0.5), V(0.3, 0.24), V(0, 0.5), V(-0.3, 0.24)].map(p => new THREE.Vector2(p.x, p.y)));
  const grueso = 0.14;
  const madera = textura(256, 256, (g, w, h) => pintarVeta(g, w, h, { base: '#d8b878', claro: '#f0d9a6', oscuro: '#a3803f', lineas: 40, onda: 4 }));
  const cuerpo = malla(new THREE.ExtrudeGeometry(forma, { depth: grueso, bevelEnabled: true, bevelThickness: 0.015, bevelSize: 0.015, bevelSegments: 2 }),
    new THREE.MeshStandardMaterial({ map: madera, roughness: 0.5 }));
  cuerpo.position.z = -grueso / 2;
  const cara = (signo, color) => textura(256, 256, (g, w, h) => {
    pintarVeta(g, w, h, { base: '#d8b878', claro: '#f0d9a6', oscuro: '#a3803f', lineas: 40, onda: 4, semilla: signo > 0 ? 3 : 5 });
    g.fillStyle = color; g.font = `800 ${h * 0.4}px ${FUENTE}`; g.textAlign = 'center'; g.textBaseline = 'middle';
    g.fillText(signo > 0 ? '歩' : 'と', w / 2, h * 0.56);
  });
  const g = new THREE.Group(); g.add(cuerpo);
  for (const [signo, color] of [[1, '#16100a'], [-1, '#b3261b']]) {
    const geo = new THREE.ShapeGeometry(forma);
    const uv = geo.attributes.uv, pos = geo.attributes.position;
    for (let i = 0; i < uv.count; i++) uv.setXY(i, pos.getX(i) + 0.5, pos.getY(i) + 0.5);     // (la de detrás va girada: se lee bien)
    const m = malla(geo, new THREE.MeshStandardMaterial({ map: cara(signo, color), roughness: 0.5 }));
    m.position.z = signo * (grueso / 2 + 0.016);
    if (signo < 0) m.rotation.y = Math.PI;
    g.add(m);
  }
  return g;
}

// la campanilla de bronce, de mano: cuerpo de campana, el mango y, si ya lo tiene, el badajo dentro
function modeloCampanilla({ completa = false } = {}) {
  const bronce = textura(256, 256, (g, w, h) => pintarBronce(g, w, h));
  const mat = new THREE.MeshStandardMaterial({ map: bronce, metalness: 0.92, roughness: 0.34 });
  const dentro = new THREE.MeshStandardMaterial({ color: new THREE.Color('#3a2510'), metalness: 0.7, roughness: 0.6 });
  const fuera = [[0, 0.42], [0.14, 0.41], [0.25, 0.34], [0.31, 0.2], [0.34, 0.0], [0.4, -0.2], [0.48, -0.36], [0.5, -0.43]].map(([x, y]) => new THREE.Vector2(x, y));
  const interior = [[0.47, -0.43], [0.44, -0.37], [0.37, -0.2], [0.31, 0.0], [0.28, 0.18], [0.22, 0.3], [0.12, 0.36], [0, 0.37]].map(([x, y]) => new THREE.Vector2(x, y));
  const g = new THREE.Group();
  g.add(malla(new THREE.LatheGeometry(fuera, 64), mat));
  const hueco = malla(new THREE.LatheGeometry(interior, 64), dentro);
  hueco.material.side = THREE.BackSide; g.add(hueco);
  const labio = malla(new THREE.TorusGeometry(0.485, 0.018, 8, 64), mat);
  labio.rotation.x = Math.PI / 2; labio.position.y = -0.43; g.add(labio);
  const mango = malla(new THREE.CylinderGeometry(0.05, 0.065, 0.34, 20), mat);
  mango.position.y = 0.58; g.add(mango);
  const pomo = malla(new THREE.SphereGeometry(0.085, 24, 16), mat);
  pomo.position.y = 0.78; g.add(pomo);
  if (completa) {
    const badajo = modeloBadajo();
    badajo.scale.setScalar(0.62); badajo.position.y = -0.04; g.add(badajo);
  }
  return g;
}
// el badajo: una varilla con su bola y la anilla para colgarlo; recién sacado del té, todavía mojado
function modeloBadajo() {
  const bronce = textura(256, 256, (g, w, h) => pintarBronce(g, w, h, 29));
  const mat = new THREE.MeshStandardMaterial({ map: bronce, color: new THREE.Color('#a87a3e'), metalness: 0.9, roughness: 0.2 });
  const g = new THREE.Group();
  const vara = malla(new THREE.CylinderGeometry(0.032, 0.04, 0.72, 16), mat); g.add(vara);
  const bola = malla(new THREE.SphereGeometry(0.12, 28, 20), mat); bola.position.y = -0.42; g.add(bola);
  const anilla = malla(new THREE.TorusGeometry(0.07, 0.02, 10, 28), mat); anilla.position.y = 0.43; g.add(anilla);
  const agua = new THREE.MeshPhysicalMaterial({ color: new THREE.Color('#d9e6ea'), roughness: 0.02, metalness: 0, transparent: true, opacity: 0.55, clearcoat: 1 });
  for (const [x, y, r] of [[0.1, -0.36, 0.022], [-0.06, -0.5, 0.018], [0.035, -0.1, 0.012]]) {
    const gota = malla(new THREE.SphereGeometry(r, 12, 10), agua); gota.position.set(x, y, 0.09); gota.scale.y = 1.3; g.add(gota);
  }
  return g;
}

// la laca de urushi: un tarro negro y brillante con su tapa y el pincel encima
function modeloLaca() {
  const negra = new THREE.MeshPhysicalMaterial({ color: new THREE.Color('#0d0806'), roughness: 0.16, clearcoat: 1, clearcoatRoughness: 0.04 });
  const roja = new THREE.MeshPhysicalMaterial({ color: new THREE.Color('#7e1a10'), roughness: 0.25, clearcoat: 1 });
  const perfil = [[0, -0.32], [0.3, -0.32], [0.38, -0.25], [0.42, -0.08], [0.4, 0.08], [0.33, 0.17], [0.27, 0.19]].map(([x, y]) => new THREE.Vector2(x, y));
  const g = new THREE.Group();
  g.add(malla(new THREE.LatheGeometry(perfil, 64), negra));
  const tapa = malla(new THREE.CylinderGeometry(0.3, 0.31, 0.07, 48), negra); tapa.position.y = 0.225; g.add(tapa);
  const filete = malla(new THREE.TorusGeometry(0.305, 0.01, 8, 48), roja); filete.rotation.x = Math.PI / 2; filete.position.y = 0.19; g.add(filete);
  // el pincel: mango de caña y la punta de pelo, tumbado sobre la tapa
  const cana = textura(128, 32, (c, w, h) => pintarVeta(c, w, h, { base: '#b99a5e', claro: '#e2cb93', oscuro: '#6f5328', lineas: 18, onda: 0.4 }));
  const pincel = new THREE.Group();
  const mango = malla(new THREE.CylinderGeometry(0.022, 0.026, 0.62, 14), new THREE.MeshStandardMaterial({ map: cana, roughness: 0.55 }));
  mango.rotation.z = Math.PI / 2; pincel.add(mango);
  const virola = malla(new THREE.CylinderGeometry(0.03, 0.03, 0.05, 14), new THREE.MeshStandardMaterial({ color: new THREE.Color('#2b1a10'), roughness: 0.4 }));
  virola.rotation.z = Math.PI / 2; virola.position.x = 0.33; pincel.add(virola);
  const pelo = malla(new THREE.ConeGeometry(0.034, 0.15, 14), new THREE.MeshStandardMaterial({ color: new THREE.Color('#120c08'), roughness: 0.85 }));
  pelo.rotation.z = -Math.PI / 2; pelo.position.x = 0.43; pincel.add(pelo);
  pincel.position.set(0.02, 0.29, 0.02); pincel.rotation.y = 0.5;
  g.add(pincel);
  return g;
}

// el polvo de oro: un sobre de papel abultado, con su sello 金 y unas motas de oro en la boca
async function modeloOro() {
  await fuenteLista('金');
  const ancho = 0.92, alto = 0.62;
  const geo = new THREE.BoxGeometry(ancho, alto, 0.05, 16, 12, 1);
  const pos = geo.attributes.position;
  for (let i = 0; i < pos.count; i++) {                    // abultado, como un sobre con algo dentro
    const x = pos.getX(i) / (ancho / 2), y = pos.getY(i) / (alto / 2), z = pos.getZ(i);
    if (Math.abs(z) > 0.001) pos.setZ(i, z * (1 + 2.4 * Math.max(0, 1 - x * x) * Math.max(0, 1 - y * y)));
  }
  geo.computeVertexNormals();
  const frente = textura(512, 352, (g, w, h) => {
    pintarWashi(g, w, h, 31);
    g.strokeStyle = 'rgba(120, 90, 50, 0.3)'; g.lineWidth = 2;
    g.beginPath(); g.moveTo(0, h * 0.18); g.lineTo(w, h * 0.18); g.stroke();      // el doblez de arriba
    g.fillStyle = '#b8442d'; g.beginPath(); g.arc(w * 0.5, h * 0.58, h * 0.2, 0, Math.PI * 2); g.fill();
    g.fillStyle = '#f6e9d6'; g.font = `800 ${h * 0.24}px ${FUENTE}`; g.textAlign = 'center'; g.textBaseline = 'middle';
    g.fillText('金', w * 0.5, h * 0.6);
  });
  const dorso = textura(512, 352, (g, w, h) => {
    pintarWashi(g, w, h, 37);
    g.strokeStyle = 'rgba(120, 90, 50, 0.35)'; g.lineWidth = 2;                 // la solapa, doblada
    g.beginPath(); g.moveTo(0, h * 0.1); g.lineTo(w * 0.5, h * 0.55); g.lineTo(w, h * 0.1); g.stroke();
  });
  const papel = new THREE.MeshStandardMaterial({ color: new THREE.Color('#e3d4b5'), roughness: 0.92 });
  const sobre = malla(geo, [papel, papel, papel, papel,
    new THREE.MeshStandardMaterial({ map: frente, roughness: 0.9 }), new THREE.MeshStandardMaterial({ map: dorso, roughness: 0.9 })]);
  const g = new THREE.Group(); g.add(sobre);
  const oro = new THREE.MeshStandardMaterial({ color: new THREE.Color('#e5b54b'), metalness: 1, roughness: 0.22 });
  const azar = azarFijo(41);
  for (let i = 0; i < 18; i++) {
    const mota = malla(new THREE.OctahedronGeometry(0.008 + azar() * 0.01), oro);
    mota.position.set((azar() - 0.5) * ancho * 0.8, alto / 2 + 0.005 + azar() * 0.01, (azar() - 0.5) * 0.06);
    g.add(mota);
  }
  return g;
}

// papeles: la tarjeta del lazo y el secreto (con su dibujo por delante; por detrás, el papel y la tinta que traspasa)
async function modeloPapel(url, { semilla = 43, curva = 0.06, ancho = 0.95 } = {}) {
  const frente = await cargarTextura(url);
  const img = frente.image, proporcion = img && img.width ? img.height / img.width : 0.6;
  const alto = ancho * proporcion;
  const geo = new THREE.PlaneGeometry(ancho, alto, 24, 8);
  const pos = geo.attributes.position;
  for (let i = 0; i < pos.count; i++) { const x = pos.getX(i) / (ancho / 2); pos.setZ(i, -curva * x * x); }
  geo.computeVertexNormals();
  const dorso = textura(512, Math.round(512 * proporcion), (g, w, h) => {
    pintarWashi(g, w, h, semilla);
    // (la tinta que traspasa: desde detrás se ve al revés, y eso ya lo hace la cara de atrás)
    if (img) { g.save(); g.globalAlpha = 0.1; g.drawImage(img, 0, 0, w, h); g.restore(); }
  });
  const g = new THREE.Group();
  g.add(malla(geo, new THREE.MeshStandardMaterial({ map: frente, roughness: 0.9, side: THREE.FrontSide })));
  g.add(malla(geo, new THREE.MeshStandardMaterial({ map: dorso, roughness: 0.92, side: THREE.BackSide })));
  return g;
}

// el manojo de tsukegi: tiras finas de ciprés con la punta de azufre, atadas con un cordel
function modeloTsukegi() {
  const madera = textura(64, 256, (g, w, h) => {
    g.save(); g.translate(w, 0); g.rotate(Math.PI / 2);
    pintarVeta(g, h, w, { base: '#e4d0a6', claro: '#f6e8c6', oscuro: '#a8895a', lineas: 14, onda: 0.6, semilla: 47 });
    g.restore();
  });
  const mat = new THREE.MeshStandardMaterial({ map: madera, roughness: 0.7 });
  const azufre = new THREE.MeshStandardMaterial({ color: new THREE.Color('#d6bf3a'), roughness: 0.95 });
  const g = new THREE.Group(), azar = azarFijo(53);
  for (let i = 0; i < 9; i++) {
    const tira = new THREE.Group();
    tira.add(malla(new THREE.BoxGeometry(0.06, 1.0, 0.012), mat));
    const punta = malla(new THREE.BoxGeometry(0.066, 0.13, 0.02), azufre); punta.position.y = 0.45; tira.add(punta);
    tira.position.set((i - 4) * 0.024 + (azar() - 0.5) * 0.01, (azar() - 0.5) * 0.04, (azar() - 0.5) * 0.05);
    tira.rotation.set((azar() - 0.5) * 0.08, (azar() - 0.5) * 0.5, (i - 4) * 0.035 + (azar() - 0.5) * 0.03);
    g.add(tira);
  }
  const cordel = malla(new THREE.TorusGeometry(0.13, 0.012, 8, 40), new THREE.MeshStandardMaterial({ color: new THREE.Color('#8a6a44'), roughness: 0.95 }));
  cordel.rotation.x = Math.PI / 2; cordel.scale.set(1, 0.42, 1); cordel.position.y = -0.12; g.add(cordel);
  return g;
}

// la caja pequeña: la misma del nivel 2 (sus tablillas, cerradas otra vez)
async function modeloHija() {
  const [asanoha, kikko, frente, cajita] = await Promise.all(['hija_asanoha', 'hija_kikko', 'hija_frente', 'cajita'].map(n => cargarTextura(`capas/${n}.webp`)));
  return crearCajaHija({ asanoha, kikko, frente, cajita }).grupo;
}

// lo que no tiene modelo propio: su dibujo como una pieza recortada y gruesa (por detrás, más oscura)
async function modeloRecorte(url) {
  const t = await cargarTextura(url);
  const img = t.image, proporcion = img && img.width ? img.height / img.width : 1;
  const geo = new THREE.PlaneGeometry(1, proporcion);
  const g = new THREE.Group();
  g.add(malla(geo, new THREE.MeshStandardMaterial({ map: t, alphaTest: 0.4, roughness: 0.6, side: THREE.FrontSide })));
  const dorso = malla(geo, new THREE.MeshStandardMaterial({ map: t, alphaTest: 0.4, roughness: 0.7, color: new THREE.Color('#5a4632'), side: THREE.BackSide }));
  dorso.position.z = -0.02; g.add(dorso);
  return g;
}

const MODELOS = {
  llave: () => modeloLlave(),
  cuerno: () => modeloCuerno(),
  ojo: () => modeloOjo(),
  cajita: () => modeloCajita(),
  ficha: () => modeloFicha(),
  campanilla: r => modeloCampanilla(r),
  badajo: () => modeloBadajo(),
  laca: () => modeloLaca(),
  oro: () => modeloOro(),
  tarjeta: r => modeloPapel(r.icono, { semilla: 59, ancho: 0.9 }),
  secreto: () => modeloPapel('capas/secreto.webp', { semilla: 61, curva: 0.08 }),
  tsukegi: () => modeloTsukegi(),
  hija: () => modeloHija(),
};
// cómo se presenta cada uno al abrir la vitrina (un poco de lado, para que se vea que tiene volumen)
const PRESENTACION = {
  llave: [0.5, -0.35, 0.15], cuerno: [0.25, 0.6, 0.1], ojo: [0.05, -0.15, 0], cajita: [0.62, -0.25, 0], ficha: [0.15, -0.45, 0],
  campanilla: [0.32, 0.4, 0], badajo: [0.2, 0.5, 0.25], laca: [0.42, 0.5, 0], oro: [0.25, -0.35, 0.05], tarjeta: [0.15, -0.3, 0.03],
  secreto: [0.12, -0.25, 0], tsukegi: [0.2, 0.45, 0.3], hija: [0.45, -0.6, 0],
};

function liberar(objeto) {
  objeto.traverse(o => {
    if (o.geometry) o.geometry.dispose();
    const mats = o.material ? (Array.isArray(o.material) ? o.material : [o.material]) : [];
    for (const m of mats) { for (const v of Object.values(m)) if (v && v.isTexture) v.dispose(); m.dispose(); }
  });
}

// ---------------------------------------------------------------------------------------------
// La vitrina: el lienzo, la luz, el giro con el dedo y el bucle (solo mientras está abierta)
// ---------------------------------------------------------------------------------------------
export function crearVitrina(lienzo, { quieto = false } = {}) {
  const render = new THREE.WebGLRenderer({ canvas: lienzo, alpha: true, antialias: true, powerPreference: 'low-power' });
  render.setClearColor(0x000000, 0);
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping; render.toneMappingExposure = 1.1;
  const escena = new THREE.Scene();
  escena.environment = entornoSala(render);
  escena.environmentIntensity = 0.9;
  escena.add(new THREE.HemisphereLight(0xffe4c0, 0x1a120c, 0.6));
  const clave = new THREE.DirectionalLight(0xffd6a0, 2.4); clave.position.set(-1.6, 2.0, 2.4); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x9fb6ff, 0.9); contra.position.set(1.8, 0.9, -2.2); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0xffc890, 0.4); relleno.position.set(1.5, -0.8, 1.8); escena.add(relleno);
  const camara = new THREE.PerspectiveCamera(30, 1, 0.01, 50);
  const pivote = new THREE.Group(); escena.add(pivote);

  let modelo = null, objeto = null, distancia = 3, activo = false, ultimo = 0, peticion = 0;
  const giro = { q: new THREE.Quaternion(), inicio: new THREE.Quaternion(), vx: 0, vy: 0, zoom: 1, zoomObjetivo: 1, tocado: false, t: 0, volver: 0 };
  const dedos = new Map();
  let pellizco = null, ultimoToque = 0;
  const _q = new THREE.Quaternion();

  function medir() {
    const r = lienzo.getBoundingClientRect();
    if (!r.width || !r.height) return;
    render.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    render.setSize(r.width, r.height, false);
    camara.aspect = r.width / r.height; camara.updateProjectionMatrix();
  }
  function girar(dx, dy) {                                  // en radianes, alrededor de los ejes de la pantalla
    if (dx) giro.q.premultiply(_q.setFromAxisAngle(EJE_Y, dx));
    if (dy) giro.q.premultiply(_q.setFromAxisAngle(EJE_X, dy));
    giro.q.normalize();
  }
  function cuadro(ahora) {
    if (!activo) return;
    const dt = Math.min(0.05, Math.max(0, (ahora - ultimo) / 1000)); ultimo = ahora;
    giro.t += dt;
    if (giro.volver > 0) {                                  // el doble toque: vuelve a como se presentó
      giro.volver = Math.max(0, giro.volver - dt);
      giro.q.slerp(giro.inicio, 1 - Math.exp(-dt * 9)); giro.zoomObjetivo = 1;
    } else if (!dedos.size && (giro.vx || giro.vy)) {       // la inercia al soltar
      girar(giro.vx * dt, giro.vy * dt);
      const freno = Math.exp(-dt * 3.2);
      giro.vx *= freno; giro.vy *= freno;
      if (Math.abs(giro.vx) + Math.abs(giro.vy) < 0.01) giro.vx = giro.vy = 0;
    }
    pivote.quaternion.copy(giro.q);
    if (!giro.tocado && !quieto) {                          // antes de tocarlo, se mece despacio en la mano
      pivote.quaternion.premultiply(_q.setFromAxisAngle(EJE_Y, Math.sin(giro.t * 0.7) * 0.35));
    }
    giro.zoom += (giro.zoomObjetivo - giro.zoom) * (1 - Math.exp(-dt * 10));
    camara.position.set(0, 0, distancia / giro.zoom); camara.lookAt(0, 0, 0);
    render.render(escena, camara);
    peticion = requestAnimationFrame(cuadro);
  }
  function quitar() {
    if (modelo) { pivote.remove(modelo); liberar(modelo); modelo = null; }
  }

  async function mostrar(id, recursos = {}) {
    quitar();
    objeto = id;
    const hacer = MODELOS[id] || (r => modeloRecorte(r.icono));
    const nuevo = await hacer(recursos);
    if (objeto !== id) { liberar(nuevo); return false; }     // se cerró (u otro objeto) mientras se hacía
    const caja = new THREE.Box3().setFromObject(nuevo);
    const centro = caja.getCenter(new THREE.Vector3());
    const envoltorio = new THREE.Group();
    nuevo.position.sub(centro); envoltorio.add(nuevo);
    const radio = caja.getBoundingSphere(new THREE.Sphere()).radius || 0.5;
    distancia = radio / Math.sin(THREE.MathUtils.degToRad(camara.fov / 2)) * 1.06;
    modelo = envoltorio; pivote.add(modelo);
    const [rx, ry, rz] = PRESENTACION[id] || [0.2, -0.4, 0];
    giro.inicio.setFromEuler(new THREE.Euler(rx, ry, rz)); giro.q.copy(giro.inicio);
    Object.assign(giro, { vx: 0, vy: 0, zoom: 0.85, zoomObjetivo: 1, tocado: false, t: 0, volver: 0 });
    if (!activo) { activo = true; ultimo = performance.now(); medir(); peticion = requestAnimationFrame(cuadro); }
    return true;
  }
  function cerrar() {
    objeto = null; activo = false;
    cancelAnimationFrame(peticion);
    dedos.clear(); pellizco = null;
    quitar();
  }

  // el dedo: arrastrar gira (en la dirección del arrastre, también arriba y abajo); dos dedos acercan o alejan
  const radianesPorPixel = () => Math.PI / Math.max(160, lienzo.clientWidth) * 1.25;
  lienzo.addEventListener('pointerdown', e => {
    if (!activo) return;
    lienzo.setPointerCapture(e.pointerId);
    dedos.set(e.pointerId, { x: e.clientX, y: e.clientY, x0: e.clientX, y0: e.clientY, t: performance.now() });
    giro.tocado = true; giro.vx = giro.vy = 0; giro.volver = 0;
    if (dedos.size === 2) {
      const [a, b] = [...dedos.values()];
      pellizco = { d: Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)), zoom: giro.zoomObjetivo };
    }
  });
  lienzo.addEventListener('pointermove', e => {
    const d = dedos.get(e.pointerId);
    if (!d) return;
    const dx = e.clientX - d.x, dy = e.clientY - d.y, ahora = performance.now(), paso = Math.max(0.008, (ahora - d.t) / 1000);
    d.x = e.clientX; d.y = e.clientY; d.t = ahora;
    if (dedos.size >= 2 && pellizco) {
      const [a, b] = [...dedos.values()];
      giro.zoomObjetivo = THREE.MathUtils.clamp(pellizco.zoom * Math.hypot(a.x - b.x, a.y - b.y) / pellizco.d, 0.75, 2.6);
      return;
    }
    const k = radianesPorPixel();
    girar(dx * k, dy * k);
    giro.vx = quieto ? 0 : dx * k / paso; giro.vy = quieto ? 0 : dy * k / paso;
  });
  const soltar = e => {
    const d = dedos.get(e.pointerId);
    if (!d) return;
    dedos.delete(e.pointerId);
    if (dedos.size < 2) pellizco = null;
    if (performance.now() - d.t > 90) giro.vx = giro.vy = 0;            // se paró antes de soltar: sin inercia
    const quieto2 = Math.hypot(e.clientX - d.x0, e.clientY - d.y0) < 10;
    if (quieto2 && e.type === 'pointerup') {
      const ahora = performance.now();
      if (ahora - ultimoToque < 320) { giro.volver = 0.6; giro.vx = giro.vy = 0; ultimoToque = 0; }
      else ultimoToque = ahora;
    }
  };
  lienzo.addEventListener('pointerup', soltar);
  lienzo.addEventListener('pointercancel', soltar);
  lienzo.addEventListener('wheel', e => {
    if (!activo) return;
    e.preventDefault();
    giro.zoomObjetivo = THREE.MathUtils.clamp(giro.zoomObjetivo * Math.exp(-e.deltaY * 0.0015), 0.75, 2.6);
  }, { passive: false });
  // con el teclado: las flechas giran, + y − acercan, Intro lo deja como estaba
  lienzo.addEventListener('keydown', e => {
    if (!activo) return;
    const paso = 0.22;
    const teclas = { ArrowLeft: [-paso, 0], ArrowRight: [paso, 0], ArrowUp: [0, -paso], ArrowDown: [0, paso] };
    if (teclas[e.key]) { giro.tocado = true; girar(...teclas[e.key]); e.preventDefault(); }
    else if (e.key === '+' || e.key === '=') giro.zoomObjetivo = Math.min(2.6, giro.zoomObjetivo * 1.15);
    else if (e.key === '-') giro.zoomObjetivo = Math.max(0.75, giro.zoomObjetivo / 1.15);
    else if (e.key === 'Enter') giro.volver = 0.6;
  });
  window.addEventListener('resize', () => { if (activo) medir(); });

  return {
    mostrar, cerrar, medir,
    get activo() { return activo; },
    // para la prueba automática: qué objeto, cuánto se ha girado (ángulo desde la presentación) y el zoom
    estado: () => ({ objeto, activo, giro: 2 * Math.acos(Math.min(1, Math.abs(giro.q.dot(giro.inicio)))), zoom: giro.zoomObjetivo,
      tieneModelo: !!modelo, propio: !!MODELOS[objeto] }),
  };
}

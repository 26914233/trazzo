// Lo que se dibuja por código en el nivel 4 («El oro»), sin imágenes nuevas: las esquirlas de la mejilla (con la
// madera de la propia cara, sacada del boceto: capas/mejilla.webp), el tarro de laca con su pincel, el sobre de polvo
// de oro y las juntas de laca y de oro del kintsugi. Con el aire de tinta del boceto.

const TINTA = 'rgba(30, 18, 10, 0.92)';
const BERMELLON = '#b8442d';
const ORO = '#e2a83a', ORO_CLARO = '#fff0b8', ORO_OSCURO = '#5e3c12';

function lienzo(w, h) { const c = document.createElement('canvas'); c.width = Math.max(1, Math.round(w)); c.height = Math.max(1, Math.round(h)); return c; }
function camino(c, puntos) { c.beginPath(); puntos.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); }

// la longitud de una línea quebrada y el trozo entre dos fracciones de su largo (0…1)
export function largo(puntos) {
  let l = 0;
  for (let i = 1; i < puntos.length; i++) l += Math.hypot(puntos[i][0] - puntos[i - 1][0], puntos[i][1] - puntos[i - 1][1]);
  return l;
}
export function tramo(puntos, desde, hasta) {
  const total = largo(puntos), a = desde * total, b = hasta * total, r = [];
  let acum = 0;
  for (let i = 1; i < puntos.length; i++) {
    const [x0, y0] = puntos[i - 1], [x1, y1] = puntos[i], l = Math.hypot(x1 - x0, y1 - y0);
    const s0 = acum, s1 = acum + l;
    acum = s1;
    if (s1 < a || s0 > b || l === 0) continue;
    const t0 = Math.max(0, (a - s0) / l), t1 = Math.min(1, (b - s0) / l);
    const p0 = [x0 + (x1 - x0) * t0, y0 + (y1 - y0) * t0], p1 = [x0 + (x1 - x0) * t1, y0 + (y1 - y0) * t1];
    if (!r.length) r.push(p0);
    r.push(p1);
  }
  return r;
}
// n puntos repartidos a lo largo de una línea quebrada (para saber qué parte de una junta se ha repasado)
export function muestrear(puntos, n) {
  const r = [];
  for (let i = 0; i < n; i++) { const t = (i + 0.5) / n, q = tramo(puntos, 0, t); r.push(q[q.length - 1] || puntos[0]); }
  return r;
}

// La madera de la mejilla, ampliada: la capa del boceto (lisa y suave al ampliarla) más una veta fina dibujada, para
// que de cerca no parezca borrosa. «s» son píxeles del lienzo por píxel del boceto; devuelve el lienzo de la zona.
export function maderaMejilla(imagen, s) {
  const w = imagen.width * s, h = imagen.height * s, c = lienzo(w, h), k = c.getContext('2d');
  k.imageSmoothingEnabled = true; k.imageSmoothingQuality = 'high';
  k.drawImage(imagen, 0, 0, w, h);
  // la veta: líneas casi verticales, ondulantes, unas más oscuras que otras
  k.save();
  k.globalCompositeOperation = 'source-atop';
  const azar = (() => { let x = 7; return () => ((x = (x * 16807) % 2147483647) / 2147483647); })();
  for (let i = 0; i < 26; i++) {
    const x0 = azar() * w, oscura = azar() < 0.3;
    k.strokeStyle = oscura ? 'rgba(96, 60, 30, 0.32)' : 'rgba(120, 84, 48, 0.16)';
    k.lineWidth = (oscura ? 1.4 : 0.8) * s * 0.35;
    k.beginPath();
    for (let y = -4; y <= h + 4; y += 6) {
      const x = x0 + Math.sin(y / (h * 0.21) + i) * s * 0.9 + Math.sin(y / (h * 0.07) + i * 3) * s * 0.18;
      y < 0 ? k.moveTo(x, y) : k.lineTo(x, y);
    }
    k.stroke();
  }
  // un poco de luz de arriba a la izquierda, como en la cara
  const luz = k.createLinearGradient(0, 0, w, h);
  luz.addColorStop(0, 'rgba(255, 236, 200, 0.12)'); luz.addColorStop(1, 'rgba(40, 20, 8, 0.12)');
  k.fillStyle = luz; k.fillRect(0, 0, w, h);
  k.restore();
  c.escala = s;
  return c;
}

// Una esquirla: su polígono (en píxeles del boceto, con el mismo origen que «origenMadera», la esquina de la madera)
// relleno con la madera, con el canto claro de la madera rota y la línea de tinta. Se dibuja en «c» ya colocada
// (traslación y giro hechos por quien llama), a «s» píxeles por píxel del boceto.
export function pintarEsquirla(c, poligono, madera, origenMadera, s, { sombra = true, brillo = 0 } = {}) {
  const pts = poligono.map(([x, y]) => [x * s, y * s]);
  c.save();
  if (sombra) {
    c.save(); c.translate(s * 0.9, s * 1.4);
    camino(c, pts); c.closePath(); c.fillStyle = 'rgba(10, 5, 2, 0.45)'; c.filter = `blur(${Math.max(1, s * 0.6)}px)`; c.fill();
    c.restore();
  }
  camino(c, pts); c.closePath();
  c.save(); c.clip();
  const f = s / (madera.escala || s);
  c.drawImage(madera, origenMadera[0] * s, origenMadera[1] * s, madera.width * f, madera.height * f);
  // el canto roto: un borde claro por dentro, como la madera fresca
  c.lineJoin = 'round';
  c.strokeStyle = 'rgba(246, 222, 178, 0.55)'; c.lineWidth = s * 1.1; camino(c, pts); c.closePath(); c.stroke();
  if (brillo > 0) { c.fillStyle = `rgba(255, 236, 190, ${0.35 * brillo})`; c.fillRect(-1e4, -1e4, 2e4, 2e4); }
  c.restore();
  c.strokeStyle = TINTA; c.lineWidth = Math.max(1.2, s * 0.32); c.lineJoin = 'round';
  camino(c, pts); c.closePath(); c.stroke();
  c.restore();
}

// Una junta con laca: marrón rojizo muy oscuro, brillante, solo donde se ha repasado (lista de sí/no por muestra)
export function pintarLaca(c, junta, repasada, grosor) {
  const n = repasada.length;
  c.save();
  c.lineCap = 'round'; c.lineJoin = 'round';
  for (let i = 0; i < n; i++) {
    if (!repasada[i]) continue;
    const t = tramo(junta, i / n, (i + 1) / n);
    if (t.length < 2) continue;
    c.strokeStyle = 'rgba(52, 14, 8, 0.95)'; c.lineWidth = grosor; camino(c, t); c.stroke();
    c.strokeStyle = 'rgba(160, 70, 50, 0.45)'; c.lineWidth = grosor * 0.35; camino(c, t.map(([x, y]) => [x - grosor * 0.15, y - grosor * 0.2])); c.stroke();
  }
  c.restore();
}

// Una junta de oro (todo lo dorado de la lista, o, si «hasta» es un número, el trozo hasta esa fracción del largo):
// un trazo de oro con su luz, como el kintsugi recién pulido
export function pintarOro(c, junta, dorada, grosor, { hasta = null, chispa = 0 } = {}) {
  const tramos = [];
  if (hasta !== null) { if (hasta > 0) tramos.push(tramo(junta, 0, hasta)); }
  else {
    const n = dorada.length;
    for (let i = 0; i < n; i++) if (dorada[i]) tramos.push(tramo(junta, i / n, (i + 1) / n));
  }
  c.save();
  c.lineCap = 'round'; c.lineJoin = 'round';
  for (const t of tramos) {
    if (t.length < 2) continue;
    c.strokeStyle = ORO_OSCURO; c.lineWidth = grosor * 1.5; camino(c, t); c.stroke();
    c.strokeStyle = ORO; c.lineWidth = grosor; camino(c, t); c.stroke();
    c.strokeStyle = ORO_CLARO; c.lineWidth = grosor * 0.38; camino(c, t.map(([x, y]) => [x - grosor * 0.12, y - grosor * 0.18])); c.stroke();
  }
  if (chispa > 0 && tramos.length) {
    // un destello que corre por el oro
    const todo = tramos.flat(), i = Math.floor((chispa % 1) * todo.length), p = todo[Math.min(i, todo.length - 1)];
    const g = c.createRadialGradient(p[0], p[1], 0, p[0], p[1], grosor * 4);
    g.addColorStop(0, 'rgba(255, 250, 220, 0.95)'); g.addColorStop(1, 'rgba(255, 230, 150, 0)');
    c.fillStyle = g; c.beginPath(); c.arc(p[0], p[1], grosor * 4, 0, Math.PI * 2); c.fill();
  }
  c.restore();
}

// El tarro de laca (urushi): laca negra con el borde rojo y la tapa con su pincel de bambú
export function dibujarTarroLaca(w = 100, h = 120) {
  const c = lienzo(w, h), k = c.getContext('2d'), cx = w / 2;
  // el pincel, saliendo de la tapa, inclinado
  k.save(); k.translate(cx + w * 0.06, h * 0.36); k.rotate(0.38);
  k.fillStyle = '#c9a76a'; k.fillRect(-w * 0.035, -h * 0.34, w * 0.07, h * 0.34);
  k.strokeStyle = TINTA; k.lineWidth = 1.6; k.strokeRect(-w * 0.035, -h * 0.34, w * 0.07, h * 0.34);
  for (let i = 1; i < 4; i++) { k.beginPath(); k.moveTo(-w * 0.035, -h * 0.34 * i / 4); k.lineTo(w * 0.035, -h * 0.34 * i / 4); k.stroke(); }
  k.restore();
  // el cuerpo
  const cuerpo = k.createLinearGradient(cx - w * 0.3, 0, cx + w * 0.3, 0);
  cuerpo.addColorStop(0, '#2a1a12'); cuerpo.addColorStop(0.35, '#4a2e22'); cuerpo.addColorStop(1, '#120a06');
  k.fillStyle = cuerpo;
  k.beginPath();
  k.moveTo(cx - w * 0.3, h * 0.44); k.quadraticCurveTo(cx - w * 0.36, h * 0.86, cx - w * 0.2, h * 0.92);
  k.lineTo(cx + w * 0.2, h * 0.92); k.quadraticCurveTo(cx + w * 0.36, h * 0.86, cx + w * 0.3, h * 0.44); k.closePath();
  k.fill(); k.strokeStyle = TINTA; k.lineWidth = 2; k.stroke();
  // el borde rojo y la tapa
  k.fillStyle = BERMELLON; k.beginPath(); k.ellipse(cx, h * 0.44, w * 0.31, h * 0.05, 0, 0, Math.PI * 2); k.fill(); k.stroke();
  k.fillStyle = '#1c110b'; k.beginPath(); k.ellipse(cx, h * 0.4, w * 0.27, h * 0.05, 0, 0, Math.PI * 2); k.fill(); k.stroke();
  // el brillo de la laca
  k.strokeStyle = 'rgba(255, 230, 200, 0.45)'; k.lineWidth = 2.4;
  k.beginPath(); k.moveTo(cx - w * 0.2, h * 0.52); k.quadraticCurveTo(cx - w * 0.25, h * 0.7, cx - w * 0.16, h * 0.84); k.stroke();
  return c;
}

// El sobre de polvo de oro: papel washi doblado, con el oro asomando y un sello rojo
export function dibujarSobreOro(w = 110, h = 100) {
  const c = lienzo(w, h), k = c.getContext('2d');
  const papel = k.createLinearGradient(0, 0, w, h);
  papel.addColorStop(0, '#f2e7cf'); papel.addColorStop(1, '#d8c7a2');
  k.fillStyle = papel;
  k.beginPath(); k.moveTo(w * 0.12, h * 0.3); k.lineTo(w * 0.88, h * 0.22); k.lineTo(w * 0.9, h * 0.82); k.lineTo(w * 0.1, h * 0.86); k.closePath();
  k.fill(); k.strokeStyle = TINTA; k.lineWidth = 2; k.lineJoin = 'round'; k.stroke();
  // la solapa de arriba, abierta, y el oro dentro
  k.fillStyle = ORO;
  k.beginPath(); k.moveTo(w * 0.14, h * 0.31); k.quadraticCurveTo(w * 0.5, h * 0.42, w * 0.86, h * 0.24); k.lineTo(w * 0.82, h * 0.36);
  k.quadraticCurveTo(w * 0.5, h * 0.5, w * 0.18, h * 0.4); k.closePath(); k.fill();
  for (let i = 0; i < 40; i++) {
    const x = w * (0.2 + 0.6 * ((i * 37) % 100) / 100), y = h * (0.34 + 0.08 * ((i * 53) % 100) / 100);
    k.fillStyle = i % 3 ? ORO_CLARO : '#fff6d2'; k.fillRect(x, y, 1.4, 1.4);
  }
  k.fillStyle = '#e9dcc0';
  k.beginPath(); k.moveTo(w * 0.12, h * 0.3); k.lineTo(w * 0.5, h * 0.06); k.lineTo(w * 0.88, h * 0.22); k.quadraticCurveTo(w * 0.5, h * 0.36, w * 0.12, h * 0.3); k.closePath();
  k.fill(); k.strokeStyle = TINTA; k.stroke();
  // el sello
  k.fillStyle = BERMELLON; k.beginPath(); k.arc(w * 0.7, h * 0.66, w * 0.08, 0, Math.PI * 2); k.fill();
  k.fillStyle = '#f2e7cf'; k.font = `700 ${Math.round(w * 0.11)}px serif`; k.textAlign = 'center'; k.textBaseline = 'middle';
  k.fillText('金', w * 0.7, h * 0.665);
  return c;
}

// el icono de las esquirlas para la bandeja: las que lleves («cuales»), un poco separadas
export function iconoEsquirlas(esquirlas, cuales, madera, origen, s, lado = 96) {
  const c = lienzo(lado, lado), k = c.getContext('2d');
  const todos = esquirlas.flat(), x0 = Math.min(...todos.map(q => q[0])), x1 = Math.max(...todos.map(q => q[0]));
  const y0 = Math.min(...todos.map(q => q[1])), y1 = Math.max(...todos.map(q => q[1]));
  const escala = lado * 0.62 / Math.max(x1 - x0, y1 - y0), cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
  const separar = [[-5, 1], [4, -4], [5, 5]];
  for (const i of cuales) {
    k.save();
    k.translate(lado / 2 + separar[i][0] * escala * 0.6, lado / 2 + separar[i][1] * escala * 0.6);
    k.scale(escala / s, escala / s);
    k.translate(-cx * s, -cy * s);
    pintarEsquirla(k, esquirlas[i], madera, origen, s, { sombra: false });
    k.restore();
  }
  return c;
}

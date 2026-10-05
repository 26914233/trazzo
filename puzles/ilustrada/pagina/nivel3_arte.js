// Lo que se dibuja por código en los niveles 3 y final (sin imágenes nuevas): la tinta que revela la luz fría del ojo
// de piedra de luna, la ficha de shōgi (歩 y, por detrás, と en rojo), la campanilla, su badajo y el corazón de la
// caja. Todo con el aire de tinta del boceto: trazos de pincel con el borde algo corrido.

const TINTA = 'rgba(24, 15, 10, 0.92)';
const BERMELLON = '#b8442d';

function lienzo(w, h) { const c = document.createElement('canvas'); c.width = w; c.height = h; return c; }

// un trazo de pincel: más grueso en medio que en las puntas, con una segunda pasada corrida (la tinta que se abre)
export function pincel(c, puntos, grosor = 4, color = TINTA, corrido = 0.18) {
  const n = puntos.length;
  if (n < 2) return;
  for (const [g, a] of [[grosor * 1.9, corrido], [grosor, 1]]) {
    c.save();
    c.globalAlpha *= a;
    c.strokeStyle = color; c.lineCap = 'round'; c.lineJoin = 'round';
    for (let i = 1; i < n; i++) {
      const t = i / (n - 1), ancho = g * (0.45 + 0.55 * Math.sin(Math.PI * Math.min(1, t * 1.15)));
      c.lineWidth = Math.max(0.6, ancho);
      c.beginPath(); c.moveTo(puntos[i - 1][0], puntos[i - 1][1]); c.lineTo(puntos[i][0], puntos[i][1]); c.stroke();
    }
    c.restore();
  }
}
// una curva de Bézier en puntos, para el pincel
function curva(p0, p1, p2, p3, pasos = 18) {
  const r = [];
  for (let i = 0; i <= pasos; i++) {
    const t = i / pasos, u = 1 - t;
    r.push([u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0],
      u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1]]);
  }
  return r;
}
const FUENTE_KANJI = '"Shippori Mincho", "Hiragino Mincho ProN", "Yu Mincho", "Noto Serif JP", "Noto Serif CJK JP", "Noto Sans CJK JP", serif';

// La forma de una ficha de shōgi (un pentágono alargado, con la punta arriba), en un rectángulo w × h
function contornoFicha(c, x, y, w, h) {
  c.beginPath();
  c.moveTo(x + w / 2, y);
  c.lineTo(x + w * 0.88, y + h * 0.22);
  c.lineTo(x + w, y + h);
  c.lineTo(x, y + h);
  c.lineTo(x + w * 0.12, y + h * 0.22);
  c.closePath();
}

// La ficha: de madera clara, con el carácter grabado en tinta (歩, el peón) o en bermellón (と, el peón coronado)
export function dibujarFicha(lado = 'peon', w = 120, h = 140) {
  const c = lienzo(w, h), k = c.getContext('2d'), m = w * 0.06;
  const fw = w - 2 * m, fh = h - 2 * m;
  // la sombra y el canto
  k.fillStyle = 'rgba(20, 10, 4, 0.35)'; contornoFicha(k, m + 3, m + 5, fw, fh); k.fill();
  const g = k.createLinearGradient(m, m, m + fw, m + fh);
  g.addColorStop(0, '#e9cf98'); g.addColorStop(0.55, '#d6b276'); g.addColorStop(1, '#b88d55');
  k.fillStyle = g; contornoFicha(k, m, m, fw, fh); k.fill();
  // las vetas de la madera
  k.save(); contornoFicha(k, m, m, fw, fh); k.clip();
  k.strokeStyle = 'rgba(120, 80, 40, 0.25)'; k.lineWidth = 1.2;
  for (let i = 0; i < 9; i++) {
    const x0 = m + fw * (i + 0.5) / 9;
    k.beginPath(); k.moveTo(x0, m); k.bezierCurveTo(x0 + 6, m + fh * 0.3, x0 - 5, m + fh * 0.7, x0 + 3, m + fh); k.stroke();
  }
  k.restore();
  k.strokeStyle = 'rgba(40, 24, 12, 0.95)'; k.lineWidth = Math.max(2, w * 0.025); k.lineJoin = 'round';
  contornoFicha(k, m, m, fw, fh); k.stroke();
  // el carácter
  k.fillStyle = lado === 'promovida' ? BERMELLON : 'rgba(26, 16, 10, 0.95)';
  k.font = `800 ${Math.round(fh * 0.46)}px ${FUENTE_KANJI}`;
  k.textAlign = 'center'; k.textBaseline = 'middle';
  k.fillText(lado === 'promovida' ? 'と' : '歩', m + fw / 2, m + fh * 0.6);
  return c;
}

// La campanilla de bronce, colgada de un cordón rojo. Con el badajo, asoma por abajo
export function dibujarCampanilla(conBadajo = false, w = 96, h = 120) {
  const c = lienzo(w, h), k = c.getContext('2d');
  const cx = w / 2, arriba = h * 0.24, abajo = h * 0.82, r = w * 0.36;
  // el cordón
  k.strokeStyle = BERMELLON; k.lineWidth = w * 0.045; k.lineCap = 'round';
  k.beginPath(); k.moveTo(cx, arriba); k.bezierCurveTo(cx - w * 0.16, h * 0.02, cx + w * 0.16, h * 0.02, cx, arriba); k.stroke();
  // el badajo (antes que la campana: queda detrás de su borde)
  if (conBadajo) {
    k.strokeStyle = '#5a3c1c'; k.lineWidth = w * 0.035;
    k.beginPath(); k.moveTo(cx, abajo - h * 0.18); k.lineTo(cx + w * 0.02, abajo + h * 0.06); k.stroke();
    const gb = k.createRadialGradient(cx - 2, abajo + h * 0.06, 1, cx, abajo + h * 0.08, w * 0.07);
    gb.addColorStop(0, '#d9aa5e'); gb.addColorStop(1, '#6b4519');
    k.fillStyle = gb; k.beginPath(); k.arc(cx + w * 0.02, abajo + h * 0.08, w * 0.065, 0, Math.PI * 2); k.fill();
  }
  // la campana: cuerpo de bronce con brillo de la lámpara
  const g = k.createLinearGradient(cx - r, 0, cx + r, 0);
  g.addColorStop(0, '#5b3a17'); g.addColorStop(0.32, '#c9934a'); g.addColorStop(0.5, '#f0cf8a'); g.addColorStop(0.75, '#a8722f'); g.addColorStop(1, '#4a2e12');
  k.fillStyle = g;
  k.beginPath();
  k.moveTo(cx - r * 0.42, arriba);
  k.bezierCurveTo(cx - r * 0.5, arriba + h * 0.18, cx - r * 0.86, abajo - h * 0.12, cx - r * 1.04, abajo);
  k.quadraticCurveTo(cx, abajo + h * 0.06, cx + r * 1.04, abajo);
  k.bezierCurveTo(cx + r * 0.86, abajo - h * 0.12, cx + r * 0.5, arriba + h * 0.18, cx + r * 0.42, arriba);
  k.quadraticCurveTo(cx, arriba - h * 0.05, cx - r * 0.42, arriba);
  k.closePath(); k.fill();
  k.strokeStyle = 'rgba(32, 18, 8, 0.95)'; k.lineWidth = Math.max(1.6, w * 0.022); k.stroke();
  // un ribete y un sello grabados
  k.strokeStyle = 'rgba(60, 34, 12, 0.7)'; k.lineWidth = w * 0.014;
  k.beginPath(); k.ellipse(cx, abajo - h * 0.08, r * 0.92, h * 0.025, 0, 0, Math.PI); k.stroke();
  k.beginPath(); k.arc(cx, arriba + h * 0.28, w * 0.06, 0, Math.PI * 2); k.stroke();
  return c;
}

// El badajo: una varilla de bronce con una bola, mojado de té
export function dibujarBadajo(w = 60, h = 90) {
  const c = lienzo(w, h), k = c.getContext('2d'), cx = w / 2;
  k.strokeStyle = '#5a3c1c'; k.lineWidth = w * 0.09; k.lineCap = 'round';
  k.beginPath(); k.moveTo(cx - 2, h * 0.1); k.lineTo(cx + 2, h * 0.68); k.stroke();
  k.strokeStyle = '#b58646'; k.lineWidth = w * 0.035;
  k.beginPath(); k.moveTo(cx - 3, h * 0.12); k.lineTo(cx, h * 0.62); k.stroke();
  const g = k.createRadialGradient(cx - 4, h * 0.72, 2, cx, h * 0.78, w * 0.2);
  g.addColorStop(0, '#f2cd86'); g.addColorStop(0.6, '#a87332'); g.addColorStop(1, '#4b2e10');
  k.fillStyle = g; k.beginPath(); k.arc(cx + 2, h * 0.78, w * 0.18, 0, Math.PI * 2); k.fill();
  k.strokeStyle = 'rgba(30, 16, 6, 0.9)'; k.lineWidth = 1.6; k.stroke();
  // una gota de té
  k.fillStyle = 'rgba(150, 120, 40, 0.65)'; k.beginPath(); k.ellipse(cx + 8, h * 0.9, 3, 4.5, 0, 0, Math.PI * 2); k.fill();
  return c;
}

// Las tintas que revela la luz fría (en píxeles del boceto, con su tamaño real en la escena)
// en el rollo: la ficha coronada, en rojo, y una flecha que baja a la varilla
export function tintaRollo() {
  const c = lienzo(96, 120), k = c.getContext('2d');
  k.save(); k.translate(26, 8);
  k.fillStyle = 'rgba(184, 68, 45, 0.18)'; contornoFicha(k, 0, 0, 44, 52); k.fill();
  k.restore();
  pincel(k, [[48, 8], [65, 19], [70, 60], [26, 60], [31, 19], [48, 8]], 2.6, BERMELLON);
  k.fillStyle = BERMELLON; k.font = `800 26px ${FUENTE_KANJI}`; k.textAlign = 'center'; k.textBaseline = 'middle';
  k.fillText('と', 48, 40);
  pincel(k, curva([48, 66], [36, 82], [62, 92], [48, 110]), 3.2);
  pincel(k, [[38, 101], [48, 112], [58, 100]], 2.8);
  return c;
}
// en la mesa: una tetera que vierte en una taza, y algo pequeño que cae del chorro
export function tintaTe() {
  const c = lienzo(170, 100), k = c.getContext('2d');
  pincel(k, curva([92, 36], [92, 6], [148, 6], [150, 36]), 3.4);          // la tetera, inclinada
  pincel(k, curva([150, 36], [152, 64], [100, 70], [92, 36]), 3.4);
  pincel(k, curva([94, 34], [80, 30], [70, 26], [60, 22]), 3);             // el pico
  pincel(k, curva([150, 30], [166, 26], [166, 48], [148, 52]), 2.4);       // el asa
  pincel(k, curva([58, 24], [50, 40], [46, 56], [44, 70]), 2, 'rgba(24,15,10,0.6)');   // el chorro
  k.fillStyle = TINTA; k.beginPath(); k.arc(47, 50, 3.6, 0, Math.PI * 2); k.fill();    // lo que cae
  pincel(k, [[47, 47], [46, 40]], 1.6);
  pincel(k, curva([22, 74], [26, 96], [64, 96], [68, 74]), 3.2);           // la taza
  pincel(k, [[20, 74], [70, 74]], 2.6);
  return c;
}
// en el tatami: tres trazos como una respiración (sube, se queda, baja) y la campanilla en el que baja
export function tintaSuelo() {
  const c = lienzo(240, 90), k = c.getContext('2d');
  pincel(k, curva([8, 70], [30, 70], [50, 18], [72, 18]), 3.6);
  pincel(k, [[90, 18], [140, 18]], 3.4);
  pincel(k, curva([158, 18], [180, 18], [200, 70], [222, 70]), 3.6);
  // la campanilla pequeña sobre el trazo que baja
  k.save(); k.translate(186, 26);
  pincel(k, curva([-9, 22], [-7, 6], [7, 6], [9, 22]), 2.4);
  pincel(k, [[-11, 22], [11, 22]], 2.2);
  pincel(k, [[0, 22], [0, 28]], 2);
  k.restore();
  return c;
}

// Un icono cuadrado para la bandeja (data URL), con la pieza centrada
export function icono(fuente, lado = 96) {
  const c = lienzo(lado, lado), k = c.getContext('2d'), s = Math.min(lado / fuente.width, lado / fuente.height) * 0.9;
  k.drawImage(fuente, (lado - fuente.width * s) / 2, (lado - fuente.height * s) / 2, fuente.width * s, fuente.height * s);
  return c.toDataURL('image/png');
}

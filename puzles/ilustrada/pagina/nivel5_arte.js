// Lo que se dibuja por código en el nivel 5 («La cómoda»), sin imágenes nuevas: la borla del costado izquierdo (su lazo,
// el cordón, la cabeza y los flecos, para poder desatarla y tirar de ella), la tarjeta del lazo, el manojo de tsukegi, el
// cordón con su pasador dentro del cajón escondido y las cosas pequeñas de los cajones de la espalda. Con el aire de tinta
// del boceto. La borla se dibuja en píxeles del repintado del costado (capas/cara_izquierda.webp, 1024 × 1024).

const TINTA = 'rgba(30, 14, 9, 0.94)';
const SEDA = { base: '#8f2c27', clara: '#d9806f', oscura: '#4a1210', media: '#b2453a' };

function lienzo(w, h) { const c = document.createElement('canvas'); c.width = Math.max(1, Math.round(w)); c.height = Math.max(1, Math.round(h)); return c; }
const azarDe = semilla => { let x = semilla; return () => ((x = (x * 16807) % 2147483647) / 2147483647); };

// Un cordón de seda torcido a lo largo de una línea quebrada: contorno de tinta, cuerpo rojo, las vueltas de la torsión
// (trazos oblicuos) y un brillo a un lado. «ancho» en píxeles del lienzo.
export function cordon(c, puntos, ancho, { alfa = 1, torsion = 0 } = {}) {
  if (puntos.length < 2) return;
  const trazar = () => { c.beginPath(); puntos.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); };
  c.save();
  c.globalAlpha = alfa;
  c.lineCap = 'round'; c.lineJoin = 'round';
  trazar(); c.strokeStyle = TINTA; c.lineWidth = ancho + Math.max(2, ancho * 0.22); c.stroke();
  trazar(); c.strokeStyle = SEDA.base; c.lineWidth = ancho; c.stroke();
  // la luz de arriba a la izquierda: un brillo desplazado
  c.save(); c.translate(-ancho * 0.16, -ancho * 0.12);
  trazar(); c.strokeStyle = 'rgba(217, 128, 111, 0.55)'; c.lineWidth = ancho * 0.32; c.stroke();
  c.restore();
  // la torsión: trazos oblicuos cada poco, a lo largo del cordón
  let acum = torsion;
  const paso = ancho * 0.62;
  for (let i = 1; i < puntos.length; i++) {
    const [x0, y0] = puntos[i - 1], [x1, y1] = puntos[i], l = Math.hypot(x1 - x0, y1 - y0);
    if (l < 1e-3) continue;
    const ux = (x1 - x0) / l, uy = (y1 - y0) / l, nx = -uy, ny = ux;
    for (let s = (paso - (acum % paso)) % paso; s < l; s += paso) {
      const x = x0 + ux * s, y = y0 + uy * s, h = ancho * 0.46;
      c.beginPath();
      c.moveTo(x + nx * h - ux * h * 0.55, y + ny * h - uy * h * 0.55);
      c.lineTo(x - nx * h + ux * h * 0.55, y - ny * h + uy * h * 0.55);
      c.strokeStyle = 'rgba(60, 14, 12, 0.6)'; c.lineWidth = Math.max(1, ancho * 0.12); c.stroke();
    }
    acum += l;
  }
  c.restore();
}

// Una curva de Bézier cúbica como línea quebrada (para los cordones)
export function bezier(a, b, cc, d, n = 24) {
  const r = [];
  for (let i = 0; i <= n; i++) {
    const t = i / n, u = 1 - t;
    r.push([u * u * u * a[0] + 3 * u * u * t * b[0] + 3 * u * t * t * cc[0] + t * t * t * d[0],
      u * u * u * a[1] + 3 * u * u * t * b[1] + 3 * u * t * t * cc[1] + t * t * t * d[1]]);
  }
  return r;
}

// Un lazo: sale del nudo, da la vuelta y vuelve a él. «centro», «rx», «ry»: su óvalo; «k» encoge (0 … 1)
function lazo(nudo, centro, rx, ry, k) {
  const cx = nudo[0] + (centro[0] - nudo[0]) * k, cy = nudo[1] + (centro[1] - nudo[1]) * k;
  const lado = Math.sign(centro[0] - nudo[0]) || 1, r = [];
  // empieza en el nudo, sube por un lado del óvalo, da la vuelta por la punta y baja por el otro hasta el nudo
  const n = 36;
  for (let i = 0; i <= n; i++) {
    const t = i / n, a = Math.PI * 2 * t;
    // óvalo con la punta lejos del nudo: el ángulo 0 es la punta del lado del nudo
    const ox = -lado * Math.cos(a) * rx * k, oy = -Math.sin(a) * ry * k * (lado > 0 ? 1 : -1);
    const x = cx + ox, y = cy + oy;
    // cerca del nudo, el lazo se estrecha hacia él
    const cerca = Math.pow(Math.cos(a * 0.5), 8);
    r.push([x + (nudo[0] - x) * cerca, y + (nudo[1] - y) * cerca]);
  }
  return r;
}

// La borla. «g»: la geometría de capas/nivel5.json (borla); «e»: cómo está ahora:
//   desatado (0 atado … 1 suelto), aprieto (0 … 1, lo apretado del lazo), bajada (0 … 1, cuánto se ha tirado de ella),
//   meneo (ángulo pequeño, rad), colaNegra ('izq' | 'der').
// Se dibuja en «c» en píxeles del costado, con el origen ya puesto (quien llama hace la escala y la traslación).
export function dibujarBorla(c, g, e) {
  const BAJA = 110;                                       // cuánto baja la borla al tirar de ella del todo (px del costado)
  const desatado = e.desatado || 0, aprieto = e.aprieto || 0, bajada = e.bajada || 0;
  const [h0, h1] = g.hebras, nudo = g.nudo;
  const cab = g.cabeza, fl = g.flecos;
  const dy = BAJA * bajada;
  const arribaCabeza = [cab.centro[0], cab.centro[1] - cab.ry * 0.95 + dy];
  // el meneo: la cabeza y los flecos giran un poco alrededor de donde sale el cordón
  const piv = [ (h0[0] + h1[0]) / 2, h0[1] ];
  const girar = ([x, y]) => {
    const s = Math.sin(e.meneo || 0), co = Math.cos(e.meneo || 0), px = x - piv[0], py = y - piv[1];
    return [piv[0] + px * co - py * s, piv[1] + px * s + py * co];
  };
  const ancho = 23;
  // 1. las dos hebras: del corte al nudo (atada) o rectas hasta la cabeza (suelta)
  const nudoV = [nudo[0] + (arribaCabeza[0] - nudo[0]) * desatado, nudo[1] + (arribaCabeza[1] - 60 - nudo[1]) * desatado];
  for (const [i, h] of [h0, h1].entries()) {
    const fin = girar([arribaCabeza[0] + (i ? 13 : -13), arribaCabeza[1] + 6]);
    const medio = girar([nudoV[0] + (i ? 9 : -9), nudoV[1]]);
    cordon(c, bezier(h, [h[0], h[1] + 30], [medio[0], medio[1] - 30], medio, 14).concat(bezier(medio, [medio[0], medio[1] + 40],
      [fin[0], fin[1] - 50], fin, 18).slice(1)), ancho, { torsion: i * 7 });
  }
  // 2. el lazo (dos lazos y dos colas), que se encoge al desatarse
  const k = Math.max(0, 1 - desatado * 1.25);
  if (k > 0.02) {
    const apretar = 1 - 0.28 * aprieto;
    const nudoD = girar(nudo);
    cordon(c, lazo(nudoD, g.lazo_izq.centro, g.lazo_izq.rx * apretar, g.lazo_izq.ry * apretar, k), ancho * 0.92, { alfa: Math.min(1, k * 3) });
    cordon(c, lazo(nudoD, g.lazo_der.centro, g.lazo_der.rx * apretar, g.lazo_der.ry * apretar, k), ancho * 0.92, { alfa: Math.min(1, k * 3), torsion: 4 });
    // las colas: cortas, colgando del nudo; una con la punta negra
    for (const lado of ['izq', 'der']) {
      const sx = lado === 'izq' ? -1 : 1, largoCola = 96 * k;
      const fin = [nudoD[0] + sx * 34 * k, nudoD[1] + largoCola];
      const pts = bezier(nudoD, [nudoD[0] + sx * 10, nudoD[1] + 20], [fin[0] - sx * 6, fin[1] - 30], fin, 12);
      cordon(c, pts, ancho * 0.8, { alfa: Math.min(1, k * 3), torsion: lado === 'izq' ? 2 : 9 });
      if (lado === e.colaNegra) {
        // la punta, envuelta en hilo negro
        const n = pts.length, [xa, ya] = pts[n - 4], [xb, yb] = pts[n - 1];
        c.save(); c.globalAlpha = Math.min(1, k * 3); c.lineCap = 'round';
        c.beginPath(); c.moveTo(xa, ya); c.lineTo(xb, yb); c.strokeStyle = '#141010'; c.lineWidth = ancho * 0.86; c.stroke();
        for (let t = 0.15; t < 1; t += 0.22) {
          const x = xa + (xb - xa) * t, y = ya + (yb - ya) * t;
          c.beginPath(); c.moveTo(x - ancho * 0.42, y - 2); c.lineTo(x + ancho * 0.42, y + 2);
          c.strokeStyle = 'rgba(120, 110, 100, 0.45)'; c.lineWidth = 1.6; c.stroke();
        }
        c.restore();
      } else {
        // la otra: la punta deshilachada, roja
        const [xb, yb] = pts[pts.length - 1];
        c.save(); c.globalAlpha = Math.min(1, k * 3);
        for (let j = -3; j <= 3; j++) {
          c.beginPath(); c.moveTo(xb + j * 2.6, yb - 4); c.lineTo(xb + j * 3.4, yb + 9 + Math.abs(j));
          c.strokeStyle = j % 2 ? SEDA.clara : SEDA.base; c.lineWidth = 2.4; c.stroke();
        }
        c.restore();
      }
    }
    // el nudo: una bola de vueltas
    c.save(); c.globalAlpha = Math.min(1, k * 3);
    c.beginPath(); c.ellipse(nudoD[0], nudoD[1], 26 * Math.max(k, 0.4), 22 * Math.max(k, 0.4), 0, 0, Math.PI * 2);
    c.fillStyle = SEDA.base; c.fill(); c.strokeStyle = TINTA; c.lineWidth = 4; c.stroke();
    for (let j = -2; j <= 2; j++) {
      c.beginPath(); c.moveTo(nudoD[0] - 20 * k, nudoD[1] + j * 7); c.quadraticCurveTo(nudoD[0], nudoD[1] + j * 7 - 6, nudoD[0] + 20 * k, nudoD[1] + j * 7);
      c.strokeStyle = 'rgba(60, 14, 12, 0.6)'; c.lineWidth = 2; c.stroke();
    }
    c.restore();
  }
  // 3. la cabeza y los flecos (bajan al tirar)
  c.save();
  c.translate(piv[0], piv[1]); c.rotate(e.meneo || 0); c.translate(-piv[0], -piv[1]);
  c.translate(0, dy);
  dibujarFlecos(c, cab, fl);
  dibujarCabeza(c, cab);
  c.restore();
}

function dibujarCabeza(c, cab) {
  const [x, y] = cab.centro, rx = cab.rx * 0.86, ry = cab.ry * 0.9;
  // el bulbo, con hilo enrollado
  const g = c.createRadialGradient(x - rx * 0.35, y - ry * 0.45, rx * 0.1, x, y, rx * 1.1);
  g.addColorStop(0, SEDA.clara); g.addColorStop(0.45, SEDA.media); g.addColorStop(1, SEDA.oscura);
  c.beginPath(); c.ellipse(x, y - ry * 0.12, rx, ry, 0, 0, Math.PI * 2);
  c.fillStyle = g; c.fill();
  c.save(); c.clip();
  for (let i = -6; i <= 6; i++) {
    const yy = y - ry * 0.12 + i * ry * 0.16;
    c.beginPath(); c.moveTo(x - rx * 1.1, yy); c.quadraticCurveTo(x, yy + ry * 0.22, x + rx * 1.1, yy);
    c.strokeStyle = i % 2 ? 'rgba(70, 16, 14, 0.4)' : 'rgba(240, 160, 140, 0.25)'; c.lineWidth = 2.2; c.stroke();
  }
  c.restore();
  c.beginPath(); c.ellipse(x, y - ry * 0.12, rx, ry, 0, 0, Math.PI * 2); c.strokeStyle = TINTA; c.lineWidth = 4.5; c.stroke();
  // el collar de abajo
  const yc = y + ry * 0.82;
  c.beginPath(); c.ellipse(x, yc, rx * 1.02, ry * 0.26, 0, 0, Math.PI * 2);
  const gc = c.createLinearGradient(0, yc - ry * 0.26, 0, yc + ry * 0.26);
  gc.addColorStop(0, '#e6a291'); gc.addColorStop(1, '#7a201c');
  c.fillStyle = gc; c.fill(); c.strokeStyle = TINTA; c.lineWidth = 3.5; c.stroke();
}

function dibujarFlecos(c, cab, fl) {
  const x = cab.centro[0], y0 = fl.arriba, y1 = fl.abajo, a0 = fl.ancho_arriba / 2, a1 = fl.ancho_abajo / 2;
  // el cuerpo: más oscuro en los lados, con luz en medio
  c.beginPath();
  c.moveTo(x - a0, y0); c.lineTo(x + a0, y0);
  c.quadraticCurveTo(x + a1 * 1.02, (y0 + y1) / 2, x + a1, y1);
  c.lineTo(x - a1, y1);
  c.quadraticCurveTo(x - a1 * 1.02, (y0 + y1) / 2, x - a0, y0);
  c.closePath();
  const g = c.createLinearGradient(x - a1, 0, x + a1, 0);
  g.addColorStop(0, SEDA.oscura); g.addColorStop(0.32, SEDA.base); g.addColorStop(0.5, SEDA.media);
  g.addColorStop(0.7, SEDA.base); g.addColorStop(1, '#3a0d0b');
  c.fillStyle = g; c.fill();
  c.save(); c.clip();
  // los hilos: líneas casi verticales que se abren hacia abajo
  const azar = azarDe(19);
  for (let i = 0; i <= 64; i++) {
    const t = i / 64, xa = x - a0 + 2 * a0 * t, xb = x - a1 + 2 * a1 * t + (azar() - 0.5) * 6;
    c.beginPath(); c.moveTo(xa, y0); c.quadraticCurveTo((xa + xb) / 2 + (azar() - 0.5) * 8, (y0 + y1) / 2, xb, y1 + 4);
    c.strokeStyle = i % 3 === 0 ? 'rgba(60, 12, 10, 0.55)' : i % 3 === 1 ? 'rgba(230, 140, 125, 0.32)' : 'rgba(150, 50, 44, 0.4)';
    c.lineWidth = i % 3 === 0 ? 1.8 : 1.3; c.stroke();
  }
  // sombra bajo el collar
  const gs = c.createLinearGradient(0, y0, 0, y0 + 40);
  gs.addColorStop(0, 'rgba(30, 6, 5, 0.55)'); gs.addColorStop(1, 'rgba(30, 6, 5, 0)');
  c.fillStyle = gs; c.fillRect(x - a1 - 10, y0, 2 * a1 + 20, 40);
  c.restore();
  // el contorno a tinta y las puntas desiguales de abajo
  c.beginPath();
  c.moveTo(x - a0, y0); c.quadraticCurveTo(x - a1 * 1.02, (y0 + y1) / 2, x - a1, y1);
  c.moveTo(x + a0, y0); c.quadraticCurveTo(x + a1 * 1.02, (y0 + y1) / 2, x + a1, y1);
  c.strokeStyle = TINTA; c.lineWidth = 4; c.stroke();
  c.beginPath();
  for (let i = 0; i <= 28; i++) {
    const t = i / 28, xx = x - a1 + 2 * a1 * t, yy = y1 + (i % 2 ? 6 : 0) + Math.sin(i * 1.7) * 3;
    i ? c.lineTo(xx, yy) : c.moveTo(xx, yy);
  }
  c.strokeStyle = 'rgba(30, 10, 8, 0.7)'; c.lineWidth = 2.5; c.stroke();
}

// Dónde se toca cada parte de la borla (en píxeles del costado): el nudo, los lazos, las colas y la cabeza con los
// flecos. Devuelve 'lazo_izq', 'lazo_der', 'cola_izq', 'cola_der', 'nudo', 'borla' o null.
export function parteDeBorla(g, e, x, y) {
  const desatado = e.desatado || 0, dy = 110 * (e.bajada || 0);
  const cab = g.cabeza, fl = g.flecos;
  const enElipse = (cx, cy, rx, ry) => Math.pow((x - cx) / rx, 2) + Math.pow((y - cy) / ry, 2) <= 1;
  if (enElipse(cab.centro[0], cab.centro[1] + dy, cab.rx * 1.05, cab.ry * 1.15)) return 'borla';
  if (y > fl.arriba + dy && y < fl.abajo + dy + 20 && Math.abs(x - cab.centro[0]) < fl.ancho_abajo / 2 + 10) return 'borla';
  if (desatado < 0.5) {
    const n = g.nudo;
    if (Math.hypot(x - n[0], y - n[1]) < 30) return 'nudo';
    for (const lado of ['izq', 'der']) {
      const sx = lado === 'izq' ? -1 : 1, fin = [n[0] + sx * 34, n[1] + 96];
      // la cola: cerca de su línea, del nudo a la punta
      const t = Math.max(0, Math.min(1, ((x - n[0]) * (fin[0] - n[0]) + (y - n[1]) * (fin[1] - n[1])) / (34 * 34 + 96 * 96)));
      if (t > 0.35 && Math.hypot(x - (n[0] + (fin[0] - n[0]) * t), y - (n[1] + (fin[1] - n[1]) * t)) < 26) return 'cola_' + lado;
    }
    const li = g.lazo_izq, ld = g.lazo_der;
    if (enElipse(li.centro[0], li.centro[1], li.rx * 1.12, li.ry * 1.3)) return 'lazo_izq';
    if (enElipse(ld.centro[0], ld.centro[1], ld.rx * 1.12, ld.ry * 1.3)) return 'lazo_der';
  }
  // el cordón entre el corte y la cabeza
  if (Math.abs(x - (g.hebras[0][0] + g.hebras[1][0]) / 2) < 40 && y > g.corte && y < cab.centro[1] + dy) return desatado < 0.5 ? 'nudo' : 'borla';
  return null;
}

// La tarjeta del lazo: papel, un lazo a tinta y una flecha que tira de la cola de punta negra
export function dibujarTarjetaLazo(w = 240, h = 170) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 240;
  k.fillStyle = '#efe5cf'; k.fillRect(0, 0, w, h);
  const azar = azarDe(5);
  for (let i = 0; i < 140; i++) { k.fillStyle = `rgba(120, 95, 60, ${0.04 + azar() * 0.05})`; k.fillRect(azar() * w, azar() * h, 1 + azar() * 3, 1); }
  k.strokeStyle = 'rgba(110, 86, 60, 0.6)'; k.lineWidth = 2 * s; k.strokeRect(3 * s, 3 * s, w - 6 * s, h - 6 * s);
  k.save(); k.scale(s, s);
  k.lineCap = 'round'; k.lineJoin = 'round';
  const tinta = (pts, ancho = 5) => { k.beginPath(); pts.forEach(([x, y], i) => (i ? k.lineTo(x, y) : k.moveTo(x, y))); k.strokeStyle = 'rgba(30, 24, 30, 0.9)'; k.lineWidth = ancho; k.stroke(); };
  const nudo = [120, 70];
  tinta(lazo(nudo, [72, 66], 40, 20, 1));
  tinta(lazo(nudo, [166, 62], 34, 19, 1));
  const colaI = bezier(nudo, [114, 86], [104, 108], [100, 126], 10), colaD = bezier(nudo, [126, 86], [136, 108], [140, 124], 10);
  tinta(colaI); tinta(colaD);
  k.beginPath(); k.ellipse(nudo[0], nudo[1], 9, 8, 0, 0, Math.PI * 2); k.fillStyle = 'rgba(30, 24, 30, 0.9)'; k.fill();
  // la punta negra, rellena; la otra, vacía
  tinta([colaD[colaD.length - 3], colaD[colaD.length - 1]], 10);
  // la flecha: tira de esa cola, hacia abajo y fuera
  k.strokeStyle = '#a3362a'; k.fillStyle = '#a3362a'; k.lineWidth = 3;
  k.beginPath(); k.moveTo(146, 132); k.quadraticCurveTo(170, 150, 196, 146); k.stroke();
  k.beginPath(); k.moveTo(202, 145); k.lineTo(190, 139); k.lineTo(192, 152); k.closePath(); k.fill();
  k.restore();
  return c;
}

// El manojo de tsukegi: tiras finas de ciprés, con la punta amarilla de azufre, atadas con una banda de papel.
// «encendida» (0 … 1): una de ellas, con su llama (nivel 6)
export function dibujarTsukegi(w = 200, h = 150, { cuantas = 7, encendida = 0, t = 0 } = {}) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 200;
  k.save(); k.scale(s, s);
  for (let i = 0; i < cuantas; i++) {
    const a = -0.22 + i * (0.44 / Math.max(1, cuantas - 1)), x0 = 100 + Math.sin(a) * 20, y0 = 132;
    const x1 = 100 + Math.sin(a) * 104, y1 = 132 - Math.cos(a) * 112;
    k.save(); k.translate(x0, y0); k.rotate(a);
    k.fillStyle = i % 2 ? '#e2c891' : '#d9bb7d'; k.strokeStyle = 'rgba(90, 60, 30, 0.85)'; k.lineWidth = 1.5;
    k.beginPath(); k.rect(-4.5, -112, 9, 112); k.fill(); k.stroke();
    // la veta
    k.strokeStyle = 'rgba(150, 110, 60, 0.4)'; k.lineWidth = 0.8;
    k.beginPath(); k.moveTo(-1.5, -110); k.lineTo(-1, -4); k.moveTo(2, -108); k.lineTo(1.6, -6); k.stroke();
    // la punta de azufre
    k.fillStyle = '#e8d23a'; k.strokeStyle = 'rgba(110, 90, 20, 0.9)';
    k.beginPath(); k.ellipse(0, -112, 6, 10, 0, 0, Math.PI * 2); k.fill(); k.stroke();
    k.restore();
    if (encendida > 0 && i === Math.floor(cuantas / 2)) dibujarLlama(k, x1, y1 - 6, 26 * encendida, t);
  }
  // la banda de papel con su línea roja
  k.fillStyle = '#f2ece0'; k.strokeStyle = 'rgba(90, 70, 50, 0.8)'; k.lineWidth = 1.5;
  k.beginPath(); k.rect(70, 92, 60, 18); k.fill(); k.stroke();
  k.strokeStyle = '#b23a2c'; k.lineWidth = 2.5; k.beginPath(); k.moveTo(70, 101); k.lineTo(130, 101); k.stroke();
  k.restore();
  return c;
}

// Una llama pequeña (de tsukegi o de mecha): azul en la base, amarilla y blanca dentro; «t» la hace temblar
export function dibujarLlama(c, x, y, alto, t = 0) {
  if (alto <= 0.5) return;
  const temblor = Math.sin(t * 13) * 0.08 + Math.sin(t * 29 + 1) * 0.05;
  c.save();
  c.translate(x, y); c.rotate(temblor * 0.5);
  const h = alto * (1 + temblor), a = alto * 0.36;
  const halo = c.createRadialGradient(0, -h * 0.35, 0, 0, -h * 0.35, alto * 1.8);
  halo.addColorStop(0, 'rgba(255, 190, 90, 0.35)'); halo.addColorStop(1, 'rgba(255, 150, 50, 0)');
  c.fillStyle = halo; c.beginPath(); c.arc(0, -h * 0.35, alto * 1.8, 0, Math.PI * 2); c.fill();
  const forma = (ancho, alto2) => {
    c.beginPath(); c.moveTo(0, 0);
    c.bezierCurveTo(ancho, -alto2 * 0.15, ancho * 0.7, -alto2 * 0.6, 0, -alto2);
    c.bezierCurveTo(-ancho * 0.7, -alto2 * 0.6, -ancho, -alto2 * 0.15, 0, 0);
  };
  forma(a, h); const g = c.createLinearGradient(0, 0, 0, -h);
  g.addColorStop(0, 'rgba(80, 120, 255, 0.85)'); g.addColorStop(0.25, 'rgba(255, 170, 60, 0.95)'); g.addColorStop(1, 'rgba(255, 120, 40, 0.1)');
  c.fillStyle = g; c.fill();
  forma(a * 0.5, h * 0.62); c.fillStyle = 'rgba(255, 245, 200, 0.9)'; c.fill();
  c.restore();
}

// Dentro del cajón escondido: el cordón rojo de la borla, tirante, que cruza la caja y sujeta un pasador de madera
export function dibujarCordonPasador(w = 260, h = 120, tenso = 1) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 260;
  k.save(); k.scale(s, s);
  // el pasador: una clavija de madera que baja hacia el costado de los cajones
  const caida = (1 - tenso) * 26;
  k.fillStyle = '#c9a26a'; k.strokeStyle = 'rgba(60, 36, 16, 0.9)'; k.lineWidth = 2;
  k.beginPath(); k.rect(122, 52 + caida, 16, 60); k.fill(); k.stroke();
  k.beginPath(); k.ellipse(130, 52 + caida, 8, 4, 0, 0, Math.PI * 2); k.fill(); k.stroke();
  // el cordón, de lado a lado (un poco caído en medio si ya no tira)
  const pts = bezier([0, 40], [80, 40 + caida * 0.4], [180, 40 + caida * 0.4], [260, 40], 30);
  // la vuelta alrededor del pasador
  cordon(k, pts, 12);
  k.beginPath(); k.ellipse(130, 47 + caida, 13, 8, 0, 0, Math.PI * 2); k.strokeStyle = SEDA.base; k.lineWidth = 6; k.stroke();
  k.strokeStyle = TINTA; k.lineWidth = 1.5; k.stroke();
  k.restore();
  return c;
}

// Las cosas pequeñas de los cajones de la espalda
export function dibujarOvillo(w = 90, h = 80) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 90;
  k.save(); k.scale(s, s);
  const g = k.createRadialGradient(38, 34, 4, 45, 42, 32);
  g.addColorStop(0, SEDA.clara); g.addColorStop(1, SEDA.oscura);
  k.beginPath(); k.ellipse(45, 44, 30, 26, 0, 0, Math.PI * 2); k.fillStyle = g; k.fill();
  k.save(); k.clip();
  for (let i = 0; i < 16; i++) {
    k.beginPath(); k.ellipse(45, 44, 30, 8 + i * 1.5, i * 0.4, 0, Math.PI * 2);
    k.strokeStyle = i % 2 ? 'rgba(70, 16, 14, 0.4)' : 'rgba(240, 150, 130, 0.3)'; k.lineWidth = 1.2; k.stroke();
  }
  k.restore();
  k.beginPath(); k.ellipse(45, 44, 30, 26, 0, 0, Math.PI * 2); k.strokeStyle = TINTA; k.lineWidth = 2.5; k.stroke();
  k.beginPath(); k.moveTo(70, 56); k.bezierCurveTo(80, 64, 74, 74, 86, 76); k.strokeStyle = SEDA.base; k.lineWidth = 2.5; k.stroke();
  k.restore();
  return c;
}
export function dibujarFrasquito(w = 60, h = 90) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 60;
  k.save(); k.scale(s, s);
  k.beginPath(); k.moveTo(22, 8); k.lineTo(38, 8); k.lineTo(38, 26); k.bezierCurveTo(54, 34, 54, 84, 30, 86); k.bezierCurveTo(6, 84, 6, 34, 22, 26); k.closePath();
  const g = k.createLinearGradient(8, 0, 52, 0);
  g.addColorStop(0, 'rgba(150, 170, 150, 0.55)'); g.addColorStop(0.4, 'rgba(230, 240, 220, 0.5)'); g.addColorStop(1, 'rgba(90, 110, 90, 0.6)');
  k.fillStyle = g; k.fill(); k.strokeStyle = TINTA; k.lineWidth = 2; k.stroke();
  // un resto de aceite en el fondo
  k.save(); k.clip(); k.fillStyle = 'rgba(200, 160, 50, 0.55)'; k.fillRect(0, 72, 60, 20); k.restore();
  k.fillStyle = '#8a6a40'; k.fillRect(20, 2, 20, 8); k.strokeRect(20, 2, 20, 8);
  k.restore();
  return c;
}
export function dibujarDedal(w = 60, h = 60) {
  const c = lienzo(w, h), k = c.getContext('2d'), s = w / 60;
  k.save(); k.scale(s, s);
  k.beginPath(); k.moveTo(12, 50); k.lineTo(16, 16); k.quadraticCurveTo(30, 4, 44, 16); k.lineTo(48, 50); k.closePath();
  const g = k.createLinearGradient(12, 0, 48, 0);
  g.addColorStop(0, '#5e3c12'); g.addColorStop(0.45, '#d8a64a'); g.addColorStop(1, '#4a2c0c');
  k.fillStyle = g; k.fill(); k.strokeStyle = TINTA; k.lineWidth = 2; k.stroke();
  k.fillStyle = 'rgba(40, 20, 6, 0.5)';
  for (let y = 20; y < 48; y += 6) for (let x = 18 + (y % 12 ? 3 : 0); x < 44; x += 6) { k.beginPath(); k.arc(x, y, 1.1, 0, Math.PI * 2); k.fill(); }
  k.beginPath(); k.ellipse(30, 50, 18, 4, 0, 0, Math.PI * 2); k.strokeStyle = '#2a1606'; k.stroke();
  k.restore();
  return c;
}

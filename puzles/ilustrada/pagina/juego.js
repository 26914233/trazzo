// La caja viva: el mismo recorrido con tres técnicas (DECISIÓN 29).
//   A · la ilustración por capas, con profundidad (2D, en un lienzo; aquí mismo).
//   B · la pintura proyectada sobre una caja 3D (Three.js, tecnica_3d.js).
//   C · el modelo de Blender con tinta y acuarela (Three.js, tecnica_3d.js).
// Aquí está todo lo que no depende de la técnica: el estado y el recorrido, el ojo, la respiración, el humo y
// la luz, los sonidos, la interfaz, los toques y la técnica A.

// ---------------------------------------------------------------------------------------------
// Datos de la ilustración (píxeles del boceto de 1376 × 768; ver preparar_capas.py)
// ---------------------------------------------------------------------------------------------
const ANCHO = 1376, ALTO = 768;
const CAPAS = ['sala', 'sala_vacia', 'sala_mesa_vacia', 'sala_detras', 'tapa', 'incensario_abierto', 'incensario_vacio',
  'cuerno_brasas', 'llave', 'cajon_vacio', 'cuerno', 'cuerno_puesto', 'despierta_ojos', 'despierta_trampilla',
  'despierta_humo', 'ojo_vacio', 'iris', 'silueta_mesa', 'silueta_caja', 'silueta_caja_detras', 'silueta_incensario',
  'silueta_te'];
const SONIDOS = ['noche', 'fuego', 'trabado', 'recoger', 'encajar', 'despertar', 'final_caja_viva', 'suspiro', 'ojo_abre',
  'grunido', 'espiritu', 'papel', 'llave', 'candado_abre', 'tope_madera', 'clic_madera', 'acercar', 'pista', 'toque',
  'mecanismo', 'racha', 'bisagra', 'deslizar_madera'];

// Encuadres de la técnica A: [x0, y0, x1, y1] de lo que debe verse en horizontal (h) y en vertical (v)
const VISTAS = {
  sala:       { h: [0, 70, 1376, 698],    v: [480, 140, 1250, 720] },
  caja:       { h: [668, 176, 1222, 612], v: [592, 168, 1232, 640] },
  incensario: { h: [446, 392, 734, 664],  v: [440, 360, 740, 664] },
  cara:       { h: [700, 300, 1020, 640], v: [726, 228, 1000, 560] },
};
const OJO = { x: 784.5, y: 369 };            // iris en reposo
const CUENCA = { x: 905, y: 378 };
const LAMPARA = { x: 604, y: 302 };
const HUECO_FRENTE = { x: 912, y: 293 };
const TRAMPILLA = { x: 930, y: 196 };
const EJE_CAJA = 927;                         // el eje vertical de la caja en el boceto (para girarla)
const ANCLA_CAJA = { x: 928, y: 640 };        // la caja respira desde su peana
const TAPA_ORIGEN = { x: 575, y: 519 };       // centro de la base de la tapa
const TAPA_MESA = { x: 521, y: 642 };         // donde se deja: en la mesa, delante del incensario
const CERRADURA = { x: 576, y: 508 };
const CAJA = [[686, 200], [790, 168], [1150, 178], [1205, 215], [1210, 530], [1180, 545], [1180, 600], [1160, 640],
  [1000, 690], [660, 615], [655, 585], [686, 545]];
const INCENSARIO = ['rect', 496, 426, 652, 612];

// ---------------------------------------------------------------------------------------------
// Utilidades
// ---------------------------------------------------------------------------------------------
export const limitar = (v, a, b) => Math.min(b, Math.max(a, v));
export const mezclar = (a, b, k) => a + (b - a) * k;
export const suave = k => k * k * (3 - 2 * k);
export const curva = k => (k < 0.5 ? 4 * k * k * k : 1 - Math.pow(-2 * k + 2, 3) / 2);
export const salida = k => 1 - Math.pow(1 - k, 3);
const azar = (a, b) => a + Math.random() * (b - a);
const elegir = lista => lista[Math.floor(Math.random() * lista.length)];
const quieto = matchMedia('(prefers-reduced-motion: reduce)').matches;

function dentro(forma, p) {
  const [tipo, a, b, c, d] = forma;
  if (tipo === 'rect') return p.x >= a && p.x <= c && p.y >= b && p.y <= d;
  if (tipo === 'elipse') { const dx = (p.x - a) / c, dy = (p.y - b) / d; return dx * dx + dy * dy <= 1; }
  if (tipo === 'poli') {
    let si = false;
    for (let i = 0, j = a.length - 1; i < a.length; j = i++) {
      const [xi, yi] = a[i], [xj, yj] = a[j];
      if ((yi > p.y) !== (yj > p.y) && p.x < (xj - xi) * (p.y - yi) / (yj - yi) + xi) si = !si;
    }
    return si;
  }
  return false;
}

// Reloj del juego: las esperas y animaciones van con él (se para si la pestaña no se ve)
let reloj = 0;
const esperas = [];
const esperar = s => new Promise(ok => esperas.push({ hasta: reloj + s, ok }));
const animaciones = [];
function animar(duracion, paso, fin, retraso = 0) { animaciones.push({ t: -retraso, duracion, paso, fin }); }
const animarPromesa = (duracion, paso, retraso = 0) => new Promise(ok => animar(duracion, paso, ok, retraso));
const temporizadores = [];
function setTimeoutReloj(s, f) { temporizadores.push({ hasta: reloj + s, f }); }

// ---------------------------------------------------------------------------------------------
// Elementos y lienzos
// ---------------------------------------------------------------------------------------------
const $ = id => document.getElementById(id);
const lienzo = $('lienzo'), ctx = lienzo.getContext('2d');      // 2D: la técnica A entera; en B y C, lo de encima
const lienzo3d = $('lienzo3d');
const el = {
  volver: $('volver'), pista: $('boton-pista'), sonido: $('boton-sonido'), girar: $('boton-girar'),
  mensaje: $('mensaje'), portada: $('portada'), entrar: $('boton-entrar'), nota: $('nota'), final: $('final'),
  otra: $('boton-otra'), cargando: $('cargando'), huecos: { llave: $('hueco-llave'), cuerno: $('hueco-cuerno') },
  tecnicas: $('tecnicas'), cambiar: $('cambiar-tecnica'), aviso3d: $('aviso3d'),
};
let ancho = 1, alto = 1, ppp = 1;
const img = {};
let datos = null, camaraBoceto = null, escena3d = null;
const compuesto = document.createElement('canvas');      // el boceto de frente, con lo que ya ha pasado
const fondoBorroso = document.createElement('canvas');   // la sala en miniatura: ampliada, queda difuminada
fondoBorroso.width = 86; fondoBorroso.height = 48;
const capas2d = {};                                       // capas recortadas para la técnica A

function medir() {
  const r = lienzo.getBoundingClientRect();
  ancho = Math.max(1, r.width); alto = Math.max(1, r.height);
  ppp = Math.min(window.devicePixelRatio || 1, 2);
  lienzo.width = Math.round(ancho * ppp); lienzo.height = Math.round(alto * ppp);
  vineta = null;
  if (tec && tec.medir) tec.medir(ancho, alto, ppp);
}
window.addEventListener('resize', medir);

// ---------------------------------------------------------------------------------------------
// Estado
// ---------------------------------------------------------------------------------------------
function estadoInicial() {
  return {
    fase: 'portada',          // portada | jugando | despertar | fin
    vista: 'sala',
    llave: 'cajon',           // cajon | mano | usada
    tapa: 'puesta',           // puesta | abierta
    tapaEnMesa: false,
    cuerno: 'brasas',         // brasas | mano | puesto
    seleccion: null,
    ocupado: false,
    intentosLlave: 0,
    insistencia: {},
    vistos: {},
    pistas: 0,
  };
}
let estado = estadoInicial();

// ---------------------------------------------------------------------------------------------
// Sonido (WebAudio; arranca con el primer toque)
// ---------------------------------------------------------------------------------------------
const audio = { ctx: null, maestro: null, buffers: {}, bucles: {}, pendientes: {}, mudo: false };
function prepararAudio() {
  const Contexto = window.AudioContext || window.webkitAudioContext;
  if (!Contexto) return;
  try { audio.ctx = new Contexto(); } catch (e) { return; }
  audio.maestro = audio.ctx.createGain();
  audio.maestro.gain.value = 0.9;
  audio.maestro.connect(audio.ctx.destination);
  for (const nombre of SONIDOS) {
    fetch('sonidos/' + nombre + '.wav')
      .then(r => r.arrayBuffer())
      .then(b => new Promise((ok, mal) => audio.ctx.decodeAudioData(b, ok, mal)))
      .then(buffer => {
        audio.buffers[nombre] = buffer;
        const p = audio.pendientes[nombre];
        if (p) { delete audio.pendientes[nombre]; bucle(nombre, p.db, p.fundido); }
      })
      .catch(() => {});
  }
}
function desbloquearAudio() { if (audio.ctx && audio.ctx.state !== 'running') audio.ctx.resume().catch(() => {}); }
function sonar(nombre, db = 0, tono = 1) {
  const buffer = audio.buffers[nombre];
  if (!audio.ctx || !buffer) return;
  const fuente = audio.ctx.createBufferSource();
  fuente.buffer = buffer; fuente.playbackRate.value = tono;
  const g = audio.ctx.createGain(); g.gain.value = Math.pow(10, db / 20);
  fuente.connect(g); g.connect(audio.maestro); fuente.start();
}
function bucle(nombre, db = 0, fundido = 1) {
  if (!audio.ctx || audio.bucles[nombre]) return;
  const buffer = audio.buffers[nombre];
  if (!buffer) { audio.pendientes[nombre] = { db, fundido }; return; }
  const fuente = audio.ctx.createBufferSource();
  fuente.buffer = buffer; fuente.loop = true;
  const g = audio.ctx.createGain(), ahora = audio.ctx.currentTime;
  g.gain.setValueAtTime(0.0001, ahora);
  g.gain.exponentialRampToValueAtTime(Math.pow(10, db / 20), ahora + Math.max(0.05, fundido));
  fuente.connect(g); g.connect(audio.maestro); fuente.start();
  audio.bucles[nombre] = { fuente, g };
}
function pararBucle(nombre, fundido = 1) {
  delete audio.pendientes[nombre];
  const b = audio.bucles[nombre];
  if (!b) return;
  delete audio.bucles[nombre];
  const ahora = audio.ctx.currentTime;
  b.g.gain.cancelScheduledValues(ahora);
  b.g.gain.setValueAtTime(Math.max(0.0001, b.g.gain.value), ahora);
  b.g.gain.exponentialRampToValueAtTime(0.0001, ahora + fundido);
  b.fuente.stop(ahora + fundido + 0.05);
}
function vibrar(ms) { try { if (navigator.vibrate) navigator.vibrate(ms); } catch (e) { /* sin vibración */ } }

// ---------------------------------------------------------------------------------------------
// El ojo: mira, parpadea, se entorna y se distrae con la luz. Se dibuja en coordenadas del boceto.
// ---------------------------------------------------------------------------------------------
const ojo = {
  ox: 0, oy: 0, vx: 0, vy: 0,
  punto: null, ultimoToque: -99,
  parpadoBase: 1,           // 1 = cerrado (duerme)
  entornado: 0, entornadoHasta: 0,
  parpadeo: null, proximoParpadeo: 4,
  distraidoHasta: 0,
  vagar: null, proximoVagar: 0,
  micro: { x: 0, y: 0 }, proximoMicro: 0,
  visible: 1,
  cerrado: 1,
};
let almendra, bordeSup, muestras, colorParpado;
function interpolar(linea, x) {
  for (let i = 1; i < linea.length; i++) {
    const [x0, y0] = linea[i - 1], [x1, y1] = linea[i];
    if (x <= x1) return y0 + (y1 - y0) * limitar((x - x0) / (x1 - x0 || 1), 0, 1);
  }
  return linea[linea.length - 1][1];
}
function prepararOjo() {
  const A = datos.almendra;
  almendra = new Path2D();
  A.forEach(([x, y], i) => (i ? almendra.lineTo(x, y) : almendra.moveTo(x, y)));
  almendra.closePath();
  const sup = A.slice(0, 10);
  const inf = [A[0], ...A.slice(10).reverse(), A[9]];
  bordeSup = new Path2D();
  sup.forEach(([x, y], i) => (i ? bordeSup.lineTo(x, y) : bordeSup.moveTo(x, y)));
  muestras = [];
  for (let x = sup[0][0]; x <= sup[sup.length - 1][0] + 0.01; x += 1.5) muestras.push({ x, s: interpolar(sup, x), i: interpolar(inf, x) });
  colorParpado = colorMedio(img.sala, 770, 346, 30, 6);
}
function colorMedio(imagen, x, y, w, h) {
  try {
    const c = document.createElement('canvas'); c.width = w; c.height = h;
    const k = c.getContext('2d'); k.drawImage(imagen, x, y, w, h, 0, 0, w, h);
    const d = k.getImageData(0, 0, w, h).data; let r = 0, g = 0, b = 0;
    for (let i = 0; i < d.length; i += 4) { r += d[i]; g += d[i + 1]; b += d[i + 2]; }
    const n = d.length / 4;
    return [r / n, g / n, b / n].map(Math.round);
  } catch (e) { return [212, 182, 142]; }
}
// Te ve mientras no duerma ni mire la lámpara (un parpadeo es demasiado corto para aprovecharlo)
const laCajaMira = () => estado.fase === 'jugando' && ojo.parpadoBase < 0.5 && reloj >= ojo.distraidoHasta && caraVisible() === 'frente';
function mirarA(p, segundos = 2.5) { ojo.punto = p; ojo.ultimoToque = reloj + segundos - 2.5; }
function entornar(segundos = 1.6) { ojo.entornadoHasta = reloj + segundos; }
function parpadear(lento = false) { ojo.parpadeo = { t: 0, cierre: lento ? 0.16 : 0.075, pausa: lento ? 0.12 : 0.04, apertura: lento ? 0.3 : 0.14 }; }

function actualizarOjo(dt) {
  let objetivo = { x: 0, y: 0 };
  const haciaPunto = p => ({ x: 13.5 * Math.tanh((p.x - OJO.x) / 240), y: 3.4 * Math.tanh((p.y - OJO.y) / 200) });
  if (reloj < ojo.distraidoHasta) objetivo = haciaPunto(LAMPARA);
  else if (ojo.punto && reloj - ojo.ultimoToque < 2.5) objetivo = haciaPunto(ojo.punto);
  else {
    if (reloj >= ojo.proximoVagar) {
      ojo.vagar = elegir([null, null, null, LAMPARA, { x: 60, y: 260 }, { x: 1000, y: 70 }, { x: 575, y: 540 }, { x: 1290, y: 560 }, { x: 700, y: 700 }]);
      ojo.proximoVagar = reloj + azar(1.4, 3.8);
    }
    if (ojo.vagar) objetivo = haciaPunto(ojo.vagar);
  }
  if (reloj >= ojo.proximoMicro) {
    ojo.micro = { x: azar(-0.7, 0.7), y: azar(-0.35, 0.35) };
    ojo.proximoMicro = reloj + azar(0.35, 1.1);
  }
  objetivo.x += ojo.micro.x; objetivo.y += ojo.micro.y;
  const k = 560, amort = 2 * Math.sqrt(k) * 0.78;
  for (let r = dt; r > 0; r -= 1 / 120) {
    const h = Math.min(r, 1 / 120);
    ojo.vx += ((objetivo.x - ojo.ox) * k - ojo.vx * amort) * h;
    ojo.vy += ((objetivo.y - ojo.oy) * k - ojo.vy * amort) * h;
    ojo.ox += ojo.vx * h; ojo.oy += ojo.vy * h;
  }
  if (ojo.parpadoBase < 0.5 && reloj >= ojo.proximoParpadeo && !ojo.parpadeo) {
    parpadear();
    ojo.proximoParpadeo = reloj + (Math.random() < 0.2 ? 0.35 : azar(2.8, 6.5));
  }
  let cierre = 0;
  if (ojo.parpadeo) {
    const p = ojo.parpadeo; p.t += dt;
    if (p.t < p.cierre) cierre = p.t / p.cierre;
    else if (p.t < p.cierre + p.pausa) cierre = 1;
    else if (p.t < p.cierre + p.pausa + p.apertura) cierre = 1 - (p.t - p.cierre - p.pausa) / p.apertura;
    else ojo.parpadeo = null;
  }
  const meta = reloj < ojo.entornadoHasta ? 0.46 : 0;
  ojo.entornado = mezclar(ojo.entornado, meta, 1 - Math.exp(-dt * 10));
  ojo.cerrado = Math.max(ojo.parpadoBase, cierre, ojo.entornado);
}
// Dibuja el ojo en «c», que ya está en coordenadas del boceto
export function dibujarOjo(c) {
  if (ojo.visible <= 0.001 || !almendra) return;
  c.save();
  c.globalAlpha = ojo.visible;
  const v = datos.capas.ojo_vacio;
  c.drawImage(img.ojo_vacio, v.x, v.y);
  c.save();
  c.clip(almendra);
  const ir = datos.capas.iris;
  c.drawImage(img.iris, ir.x + ojo.ox, ir.y + ojo.oy);
  c.fillStyle = 'rgba(255, 246, 230, 0.6)';
  c.beginPath(); c.arc(OJO.x + ojo.ox - 3.4, OJO.y + ojo.oy - 2.8, 1.25, 0, Math.PI * 2); c.fill();
  c.lineJoin = 'round';
  c.strokeStyle = 'rgba(32, 17, 10, 0.3)'; c.lineWidth = 8; c.stroke(bordeSup);
  c.strokeStyle = 'rgba(32, 17, 10, 0.3)'; c.lineWidth = 3.6; c.stroke(bordeSup);
  c.restore();
  dibujarParpado(c, ojo.cerrado);
  c.restore();
}
function dibujarParpado(c, p) {
  if (p <= 0.015) return;
  const borde = muestras.map(m => ({ x: m.x, y: m.s + (m.i - m.s) * p }));
  c.beginPath();
  muestras.forEach((m, i) => (i ? c.lineTo(m.x, m.s - 4.6) : c.moveTo(m.x, m.s - 4.6)));
  for (let i = borde.length - 1; i >= 0; i--) c.lineTo(borde[i].x, borde[i].y);
  c.closePath();
  const [r, g, b] = colorParpado;
  const gr = c.createLinearGradient(0, 352, 0, 384);
  gr.addColorStop(0, `rgb(${r}, ${g}, ${b})`);
  gr.addColorStop(0.75, `rgb(${Math.min(255, r + 10)}, ${Math.min(255, g + 11)}, ${Math.min(255, b + 12)})`);
  gr.addColorStop(1, `rgb(${r - 40}, ${g - 46}, ${b - 46})`);
  c.fillStyle = gr; c.fill();
  c.beginPath();
  borde.forEach((q, i) => (i ? c.lineTo(q.x, q.y - 1.4) : c.moveTo(q.x, q.y - 1.4)));
  c.lineCap = 'round'; c.lineJoin = 'round';
  c.strokeStyle = 'rgba(70, 42, 26, 0.35)'; c.lineWidth = 7; c.stroke();
  c.strokeStyle = 'rgba(30, 15, 9, 0.96)'; c.lineWidth = 4.2; c.stroke();
}

// ---------------------------------------------------------------------------------------------
// Respiración de la caja (contiene el aliento cuando la fuerzan)
// ---------------------------------------------------------------------------------------------
const aliento = { fase: 0, valor: 0, contenidoHasta: 0, soltando: 0 };
function contenerAliento(segundos = 1.8) { aliento.contenidoHasta = reloj + segundos; }
function actualizarAliento(dt) {
  if (reloj < aliento.contenidoHasta) {
    aliento.valor = mezclar(aliento.valor, 1, 1 - Math.exp(-dt * 6));
    aliento.soltando = 0.6;
  } else if (aliento.soltando > 0) {
    aliento.soltando -= dt;
    aliento.valor = mezclar(aliento.valor, 0, 1 - Math.exp(-dt * 9));
    if (aliento.soltando <= 0) aliento.fase = Math.PI;
  } else {
    aliento.fase += dt * (Math.PI * 2 / 4.8) * (1 + 0.15 * Math.sin(reloj * 0.21));
    aliento.valor = 0.5 - 0.5 * Math.cos(aliento.fase);
  }
}

// ---------------------------------------------------------------------------------------------
// Humo pintado: cintas que se retuercen, con el borde a tinta como en la ilustración. Cada efecto lleva su
// «objeto» (sala, caja, incensario, te): en la técnica A decide su capa; en B y C, a qué se ancla en 3D.
// ---------------------------------------------------------------------------------------------
class Cinta {
  constructor(x, y, o = {}) {
    this.x = x; this.y = y; this.objeto = o.objeto || 'sala';
    this.ritmo = o.ritmo ?? 16; this.vida = o.vida ?? 4.5; this.vel = o.vel ?? 24;
    this.ancho = o.ancho ?? 4; this.alfa = o.alfa ?? 0.45; this.tinta = o.tinta ?? 0.22;
    this.dir = o.dir ?? { x: 0, y: -1 }; this.rizo = o.rizo ?? 1; this.flota = o.flota ?? 5;
    this.color = o.color ?? [240, 234, 222]; this.duracion = o.duracion ?? Infinity;
    this.semilla = Math.random() * 100; this.nodos = []; this.acum = 0; this.edad = 0; this.intensidad = o.intensidad ?? 1;
  }
  get viva() { return this.nodos.length > 0 || this.edad < this.duracion; }
  actualizar(dt) {
    this.edad += dt;
    if (this.edad < this.duracion) {
      this.acum += dt * this.ritmo;
      while (this.acum >= 1) {
        this.acum -= 1;
        // el temblor de la salida es lento y continuo: si fuera al azar, la cinta saldría en zigzag
        const vaiven = Math.sin(reloj * 1.7 + this.semilla) * 0.7 + Math.sin(reloj * 0.63 + this.semilla * 3) * 0.5;
        this.nodos.push({ x: this.x + vaiven * 0.4, y: this.y, vx: this.dir.x * this.vel + vaiven * 1.2,
          vy: this.dir.y * this.vel, e: 0, f: this.semilla + reloj * 1.9 });
      }
    }
    for (const n of this.nodos) {
      n.e += dt;
      const empuje = Math.sin(n.y * 0.034 + reloj * 0.8 + this.semilla) * 10 + Math.sin(n.y * 0.012 - reloj * 0.37 + this.semilla * 2) * 7;
      n.vx += empuje * this.rizo * dt;
      n.vy -= this.flota * dt;
      n.vx *= 1 - 0.7 * dt; n.vy *= 1 - 0.22 * dt;
      n.x += n.vx * dt; n.y += n.vy * dt;
    }
    while (this.nodos.length && this.nodos[0].e > this.vida) this.nodos.shift();
  }
  dibujar(c) {
    const N = this.nodos.length;
    if (N < 4 || this.intensidad <= 0) return;
    const izq = [], der = [], bi = [], bd = [];
    for (let i = N - 1; i >= 0; i--) {
      const n = this.nodos[i], a = this.nodos[Math.min(N - 1, i + 2)], b = this.nodos[Math.max(0, i - 2)];
      let tx = b.x - a.x, ty = b.y - a.y; const l = Math.hypot(tx, ty) || 1; tx /= l; ty /= l;
      const k = n.e / this.vida;
      const base = this.ancho * (0.35 + 2.2 * k);
      const w = base * (0.3 + 0.7 * Math.abs(Math.cos(n.f + n.e * 0.8)));
      const h = base * 1.6 + 2;
      izq.push([n.x - ty * w / 2, n.y + tx * w / 2]); der.push([n.x + ty * w / 2, n.y - tx * w / 2]);
      bi.push([n.x - ty * h / 2, n.y + tx * h / 2]); bd.push([n.x + ty * h / 2, n.y - tx * h / 2]);
    }
    const p0 = this.nodos[N - 1], p1 = this.nodos[0];
    const [r, g, b] = this.color, a = this.alfa * this.intensidad;
    const degradado = f => {
      const gr = c.createLinearGradient(p0.x, p0.y, p1.x, p1.y + 0.01);
      gr.addColorStop(0, `rgba(${r},${g},${b},0)`);
      gr.addColorStop(0.07, `rgba(${r},${g},${b},${a * f})`);
      gr.addColorStop(0.55, `rgba(${r},${g},${b},${a * f * 0.5})`);
      gr.addColorStop(1, `rgba(${r},${g},${b},0)`);
      return gr;
    };
    const cinta = (l, d) => {
      c.beginPath();
      l.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y)));
      for (let i = d.length - 1; i >= 0; i--) c.lineTo(d[i][0], d[i][1]);
      c.closePath();
    };
    cinta(bi, bd); c.fillStyle = degradado(0.22); c.fill();
    cinta(izq, der); c.fillStyle = degradado(1); c.fill();
    if (this.tinta > 0) {
      const t = this.tinta * this.intensidad;
      const gt = c.createLinearGradient(p0.x, p0.y, p1.x, p1.y + 0.01);
      gt.addColorStop(0, 'rgba(70,52,40,0)'); gt.addColorStop(0.1, `rgba(70,52,40,${t})`);
      gt.addColorStop(0.6, `rgba(70,52,40,${t * 0.45})`); gt.addColorStop(1, 'rgba(70,52,40,0)');
      c.strokeStyle = gt; c.lineWidth = 0.7;
      c.beginPath(); izq.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.stroke();
      c.beginPath(); der.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.stroke();
    }
  }
}
const humos = { incienso: [], te: [], sueltos: [] };
const nubes = [];      // humo en bulto, suave, de las bocanadas
// Bocanada de humo por una junta: un bulto suave que sale, se abre y sube
function bocanada(x, y, dx, dy, cuanto = 1, objeto = 'caja') {
  for (let i = 0; i < 4 + 2 * Math.round(cuanto); i++) {
    const lejos = azar(0.2, 1);
    nubes.push({ x: x + azar(-4, 4), y: y + azar(-4, 4), ax: x, ay: y, objeto, vx: (dx * azar(14, 30) + azar(-6, 6)) * lejos,
      vy: (dy * azar(14, 30) - 8) * lejos, r0: azar(5, 9), r1: azar(24, 40) * (0.85 + 0.3 * cuanto), t: -i * 0.06,
      vida: azar(1.5, 2.4), alfa: 0.6 });
  }
}
function polvareda(x, y) {
  for (let i = 0; i < 7; i++) {
    const lado = i % 2 ? 1 : -1;
    nubes.push({ x: x + lado * azar(20, 50), y: y + azar(-4, 2), ax: x, ay: y, objeto: 'incensario', vx: lado * azar(14, 30),
      vy: azar(-10, -3), r0: azar(3, 5), r1: azar(12, 20), t: -i * 0.03, vida: azar(0.8, 1.3), alfa: 0.26, color: '214,196,170' });
  }
}
function actualizarNubes(dt) {
  for (let i = nubes.length - 1; i >= 0; i--) {
    const n = nubes[i]; n.t += dt;
    if (n.t < 0) continue;
    n.x += n.vx * dt; n.y += n.vy * dt; n.vx *= 1 - 1.2 * dt; n.vy = n.vy * (1 - 1.2 * dt) - 8 * dt;
    if (n.t >= n.vida) nubes.splice(i, 1);
  }
}
function dibujarNube(c, n) {
  if (n.t < 0) return;
  const k = Math.min(1, n.t / n.vida), r = mezclar(n.r0, n.r1, salida(k)), a = n.alfa * Math.min(1, k / 0.12) * Math.pow(1 - k, 1.4);
  if (a <= 0.004) return;
  const g = c.createRadialGradient(n.x, n.y, 0, n.x, n.y, r);
  const col = n.color || '238,232,222';
  g.addColorStop(0, `rgba(${col},${a})`); g.addColorStop(0.5, `rgba(${col},${a * 0.6})`); g.addColorStop(1, `rgba(${col},0)`);
  c.fillStyle = g; c.fillRect(n.x - r, n.y - r, r * 2, r * 2);
}
function humoDelIncienso() {
  humos.incienso = estado.tapa === 'abierta'
    ? [new Cinta(566, 494, { ritmo: 18, vida: 5.2, vel: 30, ancho: 5, alfa: 0.5, objeto: 'incensario' }),
       new Cinta(586, 496, { ritmo: 16, vida: 4.6, vel: 26, ancho: 4, alfa: 0.4, objeto: 'incensario' })]
    : [new Cinta(531, 462, { ritmo: 14, vida: 5, vel: 22, ancho: 3.4, alfa: 0.42, objeto: 'incensario' })];
}

// ---------------------------------------------------------------------------------------------
// Luz: lámpara andon, brasas, motas de polvo, ojos rojos y la trampilla
// ---------------------------------------------------------------------------------------------
const lampara = { agitadaHasta: 0, fuerza: 0, intensidad: 1, apagada: 0, proxima: 16 };
function agitarLampara(segundos, fuerza) { lampara.agitadaHasta = reloj + segundos; lampara.fuerza = fuerza; }
function actualizarLampara() {
  let i = 1 + 0.035 * Math.sin(reloj * 7.3) + 0.025 * Math.sin(reloj * 11.9 + 1) + 0.02 * Math.sin(reloj * 23.1);
  if (reloj < lampara.agitadaHasta) i += lampara.fuerza * (0.55 * Math.sin(reloj * 31) * Math.sin(reloj * 7.7) - 0.15);
  lampara.intensidad = Math.max(0.15, i) * (1 - lampara.apagada);
  // de vez en cuando la llama tiembla sola y el ojo la mira un momento: así se aprende
  if (estado.fase === 'jugando' && reloj >= lampara.proxima) {
    lampara.proxima = reloj + azar(14, 24);
    agitarLampara(0.9, 0.6);
    if (reloj > ojo.distraidoHasta) ojo.distraidoHasta = reloj + 1.3;
  }
}
const motas = [];
function prepararMotas() {
  motas.length = 0;
  for (let i = 0; i < 34; i++) {
    const enLampara = i < 22;
    motas.push({ x: enLampara ? azar(470, 760) : azar(720, 1320), y: enLampara ? azar(170, 480) : azar(20, 210),
      vx: azar(-2.5, 2.5), vy: azar(-1.6, 0.8), r: azar(0.7, 1.7), fase: azar(0, 7), lampara: enLampara });
  }
}
function actualizarMotas(dt) {
  for (const m of motas) {
    m.vx += Math.sin(reloj * 0.5 + m.fase) * 0.6 * dt; m.vy += Math.cos(reloj * 0.37 + m.fase) * 0.4 * dt;
    m.x += m.vx * dt; m.y += m.vy * dt;
    if (m.lampara) { if (m.x < 440 || m.x > 790 || m.y < 150 || m.y > 500) { m.x = azar(500, 720); m.y = azar(200, 460); } }
    else if (m.x < 690 || m.x > 1350 || m.y < 0 || m.y > 230) { m.x = azar(740, 1300); m.y = azar(30, 200); }
  }
}
let puntoLuz = null;
function prepararPuntoLuz() {
  puntoLuz = document.createElement('canvas'); puntoLuz.width = puntoLuz.height = 32;
  const k = puntoLuz.getContext('2d'), g = k.createRadialGradient(16, 16, 0, 16, 16, 16);
  g.addColorStop(0, 'rgba(255,240,210,1)'); g.addColorStop(0.35, 'rgba(255,220,170,0.45)'); g.addColorStop(1, 'rgba(255,200,140,0)');
  k.fillStyle = g; k.fillRect(0, 0, 32, 32);
}
function brillo(c, x, y, r, color, alfa) {
  if (alfa <= 0.002) return;
  const g = c.createRadialGradient(x, y, 0, x, y, r);
  g.addColorStop(0, `rgba(${color},${alfa})`); g.addColorStop(0.45, `rgba(${color},${alfa * 0.38})`); g.addColorStop(1, `rgba(${color},0)`);
  c.fillStyle = g; c.fillRect(x - r, y - r, r * 2, r * 2);
}
const destellos = [];   // luces de un momento (anillo de la trampilla, ojo rojo en la cuenca…)
function destello(x, y, r, color, alfa, duracion, objeto = 'caja') { destellos.push({ x, y, r, color, alfa, duracion, t: 0, objeto }); }
const despertar = { ojos: 0, humo: 0, trampilla: 0, oscuridad: 0 };

// Las luces y el humo de un objeto, en coordenadas del boceto (las usa cada técnica a su manera)
function luces(objeto) {
  const l = [];
  const li = lampara.intensidad;
  if (objeto === 'sala') {
    l.push([LAMPARA.x, LAMPARA.y, 230, '255,176,96', 0.12 * li], [LAMPARA.x, LAMPARA.y - 6, 70, '255,214,150', 0.16 * li]);
  }
  if (objeto === 'incensario' && estado.tapa === 'abierta') {
    const f = 0.75 + 0.25 * Math.sin(reloj * 5.1) * Math.sin(reloj * 2.3 + 1);
    l.push([578, 500, 44, '255,120,40', 0.28 * f], [578, 530, 110, '255,110,40', 0.08 * f]);
  }
  if (objeto === 'caja' && despertar.ojos > 0) {
    const t = reloj % 1.7, latido = 0.62 + 0.38 * Math.exp(-Math.pow((t - 0.1) / 0.09, 2)) + 0.22 * Math.exp(-Math.pow((t - 0.42) / 0.09, 2));
    l.push([OJO.x + 2, OJO.y, 62, '255,40,28', 0.4 * despertar.ojos * latido], [CUENCA.x, CUENCA.y, 62, '255,40,28', 0.4 * despertar.ojos * latido]);
  }
  if (objeto === 'caja' && despertar.trampilla > 0) {
    const tiembla = 0.85 + 0.15 * Math.sin(reloj * 3.1) * Math.sin(reloj * 1.3);
    l.push([TRAMPILLA.x, TRAMPILLA.y, 150, '255,210,130', 0.32 * despertar.trampilla * tiembla]);
  }
  for (const d of destellos) if (d.objeto === objeto) l.push([d.x, d.y, d.r, d.color, d.alfa * Math.pow(1 - d.t / d.duracion, 1.6)]);
  return l;
}
function dibujarLuces(c, objeto) { for (const [x, y, r, col, a] of luces(objeto)) brillo(c, x, y, r, col, a); }
function dibujarHumo(c, objeto) {
  for (const n of nubes) if (n.objeto === objeto) dibujarNube(c, n);
  for (const lista of [humos.incienso, humos.te, humos.sueltos]) for (const h of lista) if (h.objeto === objeto) h.dibujar(c);
}
function dibujarMotas(c) {
  const li = lampara.intensidad;
  for (const mo of motas) {
    const a = (mo.lampara ? 0.5 * li : 0.32) * (0.45 + 0.55 * Math.sin(reloj * 1.7 + mo.fase * 3));
    if (a <= 0.02) continue;
    c.globalAlpha = a; const r = mo.r * 2.6;
    c.drawImage(puntoLuz, mo.x - r, mo.y - r, r * 2, r * 2);
  }
  c.globalAlpha = 1;
}
function dibujarHaz(c) {
  if (despertar.trampilla <= 0) return;
  const tiembla = 0.85 + 0.15 * Math.sin(reloj * 3.1) * Math.sin(reloj * 1.3);
  c.globalAlpha = 0.1 * despertar.trampilla * tiembla;
  const haz = c.createLinearGradient(0, TRAMPILLA.y, 0, 0);
  haz.addColorStop(0, 'rgba(255,222,150,1)'); haz.addColorStop(1, 'rgba(255,222,150,0)');
  c.fillStyle = haz; c.beginPath();
  c.moveTo(TRAMPILLA.x - 52, TRAMPILLA.y); c.lineTo(TRAMPILLA.x + 56, TRAMPILLA.y); c.lineTo(TRAMPILLA.x + 215, 0); c.lineTo(TRAMPILLA.x - 175, 0);
  c.closePath(); c.fill(); c.globalAlpha = 1;
}

// ---------------------------------------------------------------------------------------------
// La ilustración compuesta de frente (la sala con lo que ya ha pasado) y las capas de la técnica A
// ---------------------------------------------------------------------------------------------
function pintarCapa(c, nombre, alfa = 1) {
  const d = datos.capas[nombre];
  c.globalAlpha = alfa;
  c.drawImage(img[nombre], d.x, d.y);
  c.globalAlpha = 1;
}
function dibujarTapa(c, x, y, ang = 0, sx = 1, sy = 1) {
  c.save(); c.translate(x, y); c.rotate(ang); c.scale(sx, sy);
  c.drawImage(img.tapa, -55, -81);
  c.restore();
}
function tapaEnLaMesa(c) {
  const { x, y } = TAPA_MESA, s = 1.04;
  c.save();
  c.globalAlpha = 0.12; c.translate(x, y + 1); c.scale(s, -s * 0.4); c.drawImage(img.tapa, -55, -81);
  c.restore();
  const sombra = c.createRadialGradient(x, y, 4, x, y, 58);
  sombra.addColorStop(0, 'rgba(18, 9, 4, 0.55)'); sombra.addColorStop(1, 'rgba(18, 9, 4, 0)');
  c.save(); c.translate(x, y); c.scale(1, 0.17); c.translate(-x, -y);
  c.fillStyle = sombra; c.beginPath(); c.arc(x, y, 58, 0, Math.PI * 2); c.fill();
  c.restore();
  dibujarTapa(c, x, y, 0, s, s);
}
// Recorta «fuente» (lienzo o imagen del tamaño del boceto) con una silueta
function recortar(destino, fuente, silueta) {
  const s = datos.capas[silueta];
  destino.width = s.w; destino.height = s.h;
  const k = destino.getContext('2d');
  k.clearRect(0, 0, s.w, s.h);
  k.drawImage(fuente, s.x, s.y, s.w, s.h, 0, 0, s.w, s.h);
  k.globalCompositeOperation = 'destination-in';
  k.drawImage(img[silueta], 0, 0);
  k.globalCompositeOperation = 'source-over';
  destino.sitio = s;
}
let alHornear = [];     // las técnicas 3D se apuntan para actualizar sus texturas
function hornear() {
  const c = compuesto.getContext('2d');
  c.clearRect(0, 0, ANCHO, ALTO);
  c.drawImage(img.sala, 0, 0);
  if (estado.llave !== 'cajon') pintarCapa(c, 'cajon_vacio');
  if (estado.tapa === 'abierta') pintarCapa(c, estado.cuerno === 'brasas' ? 'incensario_abierto' : 'incensario_vacio');
  if (estado.cuerno === 'puesto') pintarCapa(c, 'cuerno_puesto');
  if (despertar.humo > 0) pintarCapa(c, 'despierta_humo', despertar.humo);
  if (despertar.ojos > 0) pintarCapa(c, 'despierta_ojos', despertar.ojos);
  if (despertar.trampilla > 0) pintarCapa(c, 'despierta_trampilla', despertar.trampilla);
  // capas de la técnica A
  recortar(capas2d.caja || (capas2d.caja = document.createElement('canvas')), compuesto, 'silueta_caja');
  recortar(capas2d.incensario || (capas2d.incensario = document.createElement('canvas')), compuesto, 'silueta_incensario');
  const f = fondoBorroso.getContext('2d');
  f.imageSmoothingEnabled = true; f.imageSmoothingQuality = 'high';
  f.drawImage(compuesto, 0, 0, fondoBorroso.width, fondoBorroso.height);
  for (const fn of alHornear) fn();
}
// Las planchas: la pintura tal cual y, solo donde había objetos (la caja, la mesa, el incensario, el té), lo que
// Gemini pintó detrás. Quieta, la escena es el boceto exacto; al moverse, detrás de cada cosa aparece algo.
const planchas = {};
const lienzoBoceto = () => { const c = document.createElement('canvas'); c.width = ANCHO; c.height = ALTO; return c; };
// un punto de la escena (ejes de Blender, metros) en píxeles del boceto, con la cámara de camara.json
function proyectarBoceto(x, y, z) {
  const R = camaraBoceto.mundo_a_camara, C = camaraBoceto.posicion, f = camaraBoceto.focal_px;
  const d = [x - C[0], y - C[1], z - C[2]];
  const c = R.map(r => r[0] * d[0] + r[1] * d[1] + r[2] * d[2]);
  return [ANCHO / 2 + f * c[0] / c[2], ALTO / 2 + f * c[1] / c[2]];
}
function rellenarEnvolvente(k, puntos) {
  const p = puntos.slice().sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const cruz = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const abajo = [], arriba = [];
  for (const q of p) { while (abajo.length >= 2 && cruz(abajo[abajo.length - 2], abajo[abajo.length - 1], q) <= 0) abajo.pop(); abajo.push(q); }
  for (const q of p.reverse()) { while (arriba.length >= 2 && cruz(arriba[arriba.length - 2], arriba[arriba.length - 1], q) <= 0) arriba.pop(); arriba.push(q); }
  const h = abajo.slice(0, -1).concat(arriba.slice(0, -1));
  k.beginPath(); h.forEach(([x, y], i) => (i ? k.lineTo(x, y) : k.moveTo(x, y))); k.closePath(); k.fill();
}
// la mesa entera: su silueta en la pintura más el tablero, el canto y las patas proyectados (la silueta tiene huecos)
function mascaraDeMesa() {
  const c = lienzoBoceto(), k = c.getContext('2d');
  const s = datos.capas.silueta_mesa;
  k.drawImage(img.silueta_mesa, s.x, s.y);
  k.fillStyle = '#fff';
  const e = escena3d, { centro, radio, grueso } = e.mesa, zt = e.z_tablero, r = radio * 1.04, tablero = [];
  let y0 = s.y, y1 = s.y + s.h;
  for (let i = 0; i < 96; i++) {
    const a = i / 96 * Math.PI * 2, x = centro[0] + r * Math.cos(a), y = centro[1] + r * Math.sin(a);
    tablero.push(proyectarBoceto(x, y, zt), proyectarBoceto(x, y, zt - grueso));
  }
  rellenarEnvolvente(k, tablero);
  const alto = zt - grueso - e.z_suelo;
  for (let i = 0; i < 4; i++) {
    const a = Math.PI / 4 + i * Math.PI / 2, x = centro[0] + 0.3 * Math.cos(a), y = centro[1] + 0.3 * Math.sin(a), pata = [];
    for (const dx of [-0.03, 0.03]) for (const dy of [-0.03, 0.03]) for (const z of [zt - grueso, zt - grueso - alto]) pata.push(proyectarBoceto(x + dx, y + dy, z));
    rellenarEnvolvente(k, pata);
    for (const q of pata) y1 = Math.max(y1, q[1]);
  }
  for (const q of tablero) { y0 = Math.min(y0, q[1]); y1 = Math.max(y1, q[1]); }
  c.franja = [Math.max(0, Math.floor(y0)), Math.min(ALTO, Math.ceil(y1))];
  return c;
}
// la pintura con agujeros donde están los objetos (un poco más anchos), rellenos con la plancha vacía
function plancha(vacia, siluetas, extra = null) {
  const agujeros = lienzoBoceto(), a = agujeros.getContext('2d');
  for (const n of siluetas) {
    const s = datos.capas[n];
    for (const [dx, dy] of [[0, 0], [-2, 0], [2, 0], [0, -2], [0, 2]]) a.drawImage(img[n], s.x + dx, s.y + dy);
  }
  if (extra) a.drawImage(extra, 0, 0);
  const pintura = lienzoBoceto(), p = pintura.getContext('2d');
  p.drawImage(img.sala, 0, 0);
  p.globalCompositeOperation = 'destination-out';
  p.drawImage(agujeros, 0, 0);
  const c = lienzoBoceto(), k = c.getContext('2d');
  k.drawImage(vacia, 0, 0);
  k.drawImage(pintura, 0, 0);
  return c;
}
function prepararCapasFijas() {
  const mascaraMesa = mascaraDeMesa();
  planchas.sala = plancha(img.sala_vacia, ['silueta_caja', 'silueta_incensario', 'silueta_te'], mascaraMesa);
  planchas.mesa = plancha(img.sala_mesa_vacia, ['silueta_caja', 'silueta_incensario', 'silueta_te']);
  // la mesa de la técnica A: su plancha, recortada con la mesa entera
  const m = capas2d.mesa = lienzoBoceto(), k = m.getContext('2d');
  k.drawImage(planchas.mesa, 0, 0);
  k.globalCompositeOperation = 'destination-in';
  k.drawImage(mascaraMesa, 0, 0);
  m.sitio = { x: 0, y: 0, w: ANCHO, h: ALTO };
  m.franja = mascaraMesa.franja;
  recortar(capas2d.te = document.createElement('canvas'), img.sala, 'silueta_te');
  recortar(capas2d.cajaDetras = document.createElement('canvas'), img.sala_detras, 'silueta_caja_detras');
}

// ---------------------------------------------------------------------------------------------
// Técnica A: la ilustración por capas. La cámara se acerca a cada vista y, al arrastrar, se mueve: cada capa
// se desplaza según su profundidad (la sala, lejos, se mueve más que la caja). La caja se gira como en un
// teatro de papel: se estrecha, se da la vuelta y aparece su espalda.
// ---------------------------------------------------------------------------------------------
const tecnicaA = {
  nombre: 'A',
  cam: { cx: ANCHO / 2, cy: ALTO / 2, s: 1 },
  transicion: null,
  mirada: { x: 0, y: 0, vx: 0, vy: 0, objetivoX: 0, objetivoY: 0 },   // cuánto se ha movido la cámara (m)
  giro: 0, giroObjetivo: 0,                                           // la caja: 0 de frente, π de espaldas
  zoom: 1, zoomObjetivo: 1,                                           // pellizcar acerca un poco más
  camDibujo: { cx: ANCHO / 2, cy: ALTO / 2, s: 1 },
  activar() { lienzo3d.hidden = true; lienzo.classList.remove('encima'); this.transicion = null; Object.assign(this.cam, this.camaraDe(estado.vista)); },
  desactivar() {},
  medir() {},
  camaraDe(nombre, extra = 1) {
    const v = VISTAS[nombre];
    const [x0, y0, x1, y1] = alto > ancho * 1.05 ? v.v : v.h;
    const s = Math.min(ancho / (x1 - x0), alto / (y1 - y0)) * extra;
    let cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
    const mx = ancho / (2 * s), my = alto / (2 * s);
    cx = 2 * mx >= ANCHO ? ANCHO / 2 : limitar(cx, mx, ANCHO - mx);
    cy = 2 * my >= ALTO ? ALTO / 2 : limitar(cy, my, ALTO - my);
    return { cx, cy, s };
  },
  irA(nombre, duracion = 0.75) {
    this.transicion = { desde: { ...this.cam }, t: 0, duracion };
    // al cambiar de vista la cámara vuelve a su sitio poco a poco
    this.mirada.objetivoX = 0; this.mirada.objetivoY = 0; this.zoomObjetivo = 1;
  },
  empezar(duracion) {
    this.transicion = { desde: { ...this.cam, s: this.cam.s * 1.07 }, t: 0, duracion };
  },
  actualizar(dt) {
    this.zoom = mezclar(this.zoom, this.zoomObjetivo, 1 - Math.exp(-dt * 8));
    const destino = this.camaraDe(estado.vista, this.zoom);
    if (this.transicion) {
      this.transicion.t += dt;
      const k = curva(limitar(this.transicion.t / this.transicion.duracion, 0, 1));
      const d = this.transicion.desde;
      this.cam.cx = mezclar(d.cx, destino.cx, k); this.cam.cy = mezclar(d.cy, destino.cy, k);
      this.cam.s = Math.exp(mezclar(Math.log(d.s), Math.log(destino.s), k));
      if (k >= 1) this.transicion = null;
    } else Object.assign(this.cam, destino);
    // la mirada (el arrastre) con muelle suave
    const m = this.mirada, k = 40, am = 2 * Math.sqrt(k) * 0.9;
    m.vx += ((m.objetivoX - m.x) * k - m.vx * am) * dt; m.vy += ((m.objetivoY - m.y) * k - m.vy * am) * dt;
    m.x += m.vx * dt; m.y += m.vy * dt;
    // el giro de la caja
    const dg = this.giroObjetivo - this.giro;
    this.giro += dg * (1 - Math.exp(-dt * 5.5));
    if (Math.abs(dg) < 0.002) this.giro = this.giroObjetivo;
  },
  // desplazamiento de una capa a la profundidad «z» (m) por la mirada, en píxeles del boceto
  paralaje(z) {
    const f = camaraBoceto.focal_px, zc = escena3d.profundidad.caja;
    return { x: this.mirada.x * f * (1 / zc - 1 / z), y: this.mirada.y * f * (1 / zc - 1 / z) };
  },
  profundidadFila(lista, y) {
    const p = escena3d.profundidad.paso_filas, i = limitar(y / p, 0, lista.length - 1.001), a = Math.floor(i);
    return mezclar(lista[a], lista[a + 1], i - a);
  },
  cara() { return Math.cos(this.giro) >= 0 ? 'frente' : 'detras'; },
  girar(inmediato = false) { this.giroObjetivo = this.giroObjetivo === 0 ? Math.PI : 0; if (inmediato) this.giro = this.giroObjetivo; },
  arrastrar(dx, dy) {
    // un dedo que arrastra mueve la cámara: hasta 9 cm a cada lado y 5 hacia arriba o abajo
    const m = this.mirada, k = 0.0011 / Math.max(0.6, this.cam.s);
    m.objetivoX = limitar(m.objetivoX - dx * k, -0.09, 0.09);
    m.objetivoY = limitar(m.objetivoY - dy * k, -0.05, 0.05);
  },
  soltar() {},
  pellizcar(r) { this.zoomObjetivo = limitar(this.zoomObjetivo * r, 1, 1.6); },
  reiniciar() { this.giro = this.giroObjetivo = 0; this.zoomObjetivo = 1; Object.assign(this.mirada, { objetivoX: 0, objetivoY: 0 }); },
  camaraViva() {
    let { cx, cy, s } = this.cam;
    if (!quieto) {
      cx += Math.sin(reloj * 0.13) * 2.2 + Math.sin(reloj * 0.31) * 0.8;
      cy += Math.sin(reloj * 0.11 + 1) * 1.6;
      s *= 1 + Math.sin(reloj * 0.07) * 0.003;
      if (reloj < sacudida.hasta) {
        const f = sacudida.fuerza * (sacudida.hasta - reloj);
        cx += Math.sin(reloj * 71) * f / s; cy += Math.sin(reloj * 53 + 2) * f / s;
      }
    }
    return { cx, cy, s };
  },
  // de la pantalla al boceto (frente o espalda): primero la caja, que está delante; luego cada capa con su
  // desplazamiento por la profundidad
  aPintura(x, y) {
    const { cx, cy, s } = this.camDibujo;
    const p = { x: cx + (x - ancho / 2) / s, y: cy + (y - alto / 2) / s };
    const cara = this.cara(), escala = Math.max(0.05, Math.abs(Math.cos(this.giro)));
    const enCaja = { x: EJE_CAJA + (p.x - EJE_CAJA) / escala, y: p.y };
    if (dentro(['poli', CAJA], enCaja)) return { ...enCaja, cara };
    const prof = escena3d.profundidad, di = this.paralaje(prof.incensario), dt_ = this.paralaje(prof.te);
    const enIncensario = { x: p.x - di.x, y: p.y - di.y };
    if (dentro(INCENSARIO, enIncensario) || dentro(['rect', 462, 600, 580, 650], enIncensario)) return { ...enIncensario, cara: 'frente' };
    const enTe = { x: p.x - dt_.x, y: p.y - dt_.y };
    if (dentro(['rect', 1140, 470, 1376, 700], enTe)) return { ...enTe, cara: 'frente' };
    const ds = this.paralaje(this.profundidadFila(prof.sala, p.y));
    return { x: p.x - ds.x, y: p.y - ds.y, cara: 'frente' };
  },
  // del boceto a la pantalla, en la capa del objeto (la caja con su giro y su respiración)
  ancla(p, objeto = 'caja') {
    const { cx, cy, s } = this.camDibujo, prof = escena3d.profundidad;
    let x = p.x, y = p.y, k = s;
    if (objeto === 'caja' || objeto === 'caja_detras') {
      const b = aliento.valor, e = Math.max(0.03, Math.abs(Math.cos(this.giro)));
      x = ANCLA_CAJA.x + (x - ANCLA_CAJA.x) * (1 + 0.0028 * b); y = ANCLA_CAJA.y + (y - ANCLA_CAJA.y) * (1 + 0.0065 * b);
      x = EJE_CAJA + (x - EJE_CAJA) * e;
    } else {
      const d = this.paralaje(objeto === 'incensario' || objeto === 'mesa' ? prof.incensario : objeto === 'te' ? prof.te : this.profundidadFila(prof.sala, y));
      x += d.x; y += d.y;
    }
    return { x: ancho / 2 + (x - cx) * s, y: alto / 2 + (y - cy) * s, k, visible: true };
  },
  dibujar() {
    const c = ctx;
    this.camDibujo = this.camaraViva();
    const { cx, cy, s } = this.camDibujo;
    c.setTransform(ppp, 0, 0, ppp, 0, 0);
    c.fillStyle = '#0c0907'; c.fillRect(0, 0, ancho, alto);
    if (alto / 2 - s * cy > 0.5 || alto / 2 + s * (ALTO - cy) < alto - 0.5) {
      const k = alto / ALTO * 1.1;
      c.imageSmoothingEnabled = true; c.imageSmoothingQuality = 'high';
      c.drawImage(fondoBorroso, ancho / 2 - cx * k, alto / 2 - ALTO * k / 2, ANCHO * k, ALTO * k);
      c.fillStyle = 'rgba(12, 9, 7, 0.6)'; c.fillRect(0, 0, ancho, alto);
    }
    const base = [ppp * s, 0, 0, ppp * s, ppp * (ancho / 2 - s * cx), ppp * (alto / 2 - s * cy)];
    c.setTransform(...base);
    c.imageSmoothingEnabled = true; c.imageSmoothingQuality = 'high';
    const p = escena3d.profundidad;
    // 1. la sala, por franjas: cada una a su profundidad (paredes lejos, el suelo se acerca)
    this.porFranjas(c, planchas.sala, 0, ALTO, y => this.profundidadFila(p.sala, y), null, true);
    // 2. la mesa, también por franjas (el borde de delante está más cerca que el del fondo)
    const m = capas2d.mesa;
    this.porFranjas(c, m, m.franja[0], m.franja[1], y => this.profundidadFila(p.mesa, y), m.sitio, true);
    // 3. lo que hay en la mesa y la tapa del incensario
    const di = this.paralaje(p.incensario), dt_ = this.paralaje(p.te);
    c.save(); c.translate(dt_.x, dt_.y); c.drawImage(capas2d.te, capas2d.te.sitio.x, capas2d.te.sitio.y);
    dibujarHumo(c, 'te'); c.restore();
    c.save(); c.translate(di.x, di.y);
    c.drawImage(capas2d.incensario, capas2d.incensario.sitio.x, capas2d.incensario.sitio.y);
    if (estado.tapaEnMesa) tapaEnLaMesa(c);
    if (tapaVuelo) dibujarTapa(c, tapaVuelo.x, tapaVuelo.y, tapaVuelo.ang, tapaVuelo.sx, tapaVuelo.sy);
    if (llaveGirando) dibujarLlaveGirando(c);
    dibujarHumo(c, 'incensario');
    c.restore();
    // 4. la caja: respira y se gira
    this.dibujarCaja(c);
    // 5. el humo de la sala, la oscuridad del despertar y las luces que suman
    dibujarHumo(c, 'sala');
    c.save(); c.translate(...Object.values(this.paralaje(3.2)));
    c.globalCompositeOperation = 'lighter';
    dibujarLuces(c, 'sala'); dibujarMotas(c);
    c.restore();
    c.save(); c.translate(di.x, di.y); c.globalCompositeOperation = 'lighter'; dibujarLuces(c, 'incensario'); c.restore();
    if (despertar.oscuridad > 0) {
      c.save(); c.setTransform(ppp, 0, 0, ppp, 0, 0);
      c.fillStyle = `rgba(6, 4, 8, ${despertar.oscuridad})`; c.fillRect(0, 0, ancho, alto);
      c.restore();
    }
    if (this.cara() === 'frente') {
      c.save(); c.globalCompositeOperation = 'lighter'; this.transformarCaja(c);
      dibujarLuces(c, 'caja'); dibujarHaz(c); c.restore();
    }
    c.globalCompositeOperation = 'source-over';
    // bordes de la ilustración (en vertical sobra pantalla)
    c.setTransform(ppp, 0, 0, ppp, 0, 0);
    const arriba = alto / 2 - s * cy, abajo = alto / 2 + s * (ALTO - cy);
    if (arriba > 0.5) {
      const g = c.createLinearGradient(0, arriba, 0, arriba + 36); g.addColorStop(0, 'rgba(12,9,7,1)'); g.addColorStop(1, 'rgba(12,9,7,0)');
      c.fillStyle = g; c.fillRect(0, arriba - 1, ancho, 37);
    }
    if (abajo < alto - 0.5) {
      const g = c.createLinearGradient(0, abajo, 0, abajo - 36); g.addColorStop(0, 'rgba(12,9,7,1)'); g.addColorStop(1, 'rgba(12,9,7,0)');
      c.fillStyle = g; c.fillRect(0, abajo - 36, ancho, 37);
    }
  },
  // dibuja una imagen por franjas horizontales, cada una desplazada según la profundidad de su fila; con «bordes»,
  // lo que asoma por los lados de la ilustración se rellena estirando su última columna (no se ve negro)
  porFranjas(c, imagen, y0, y1, profundidad, sitio = null, bordes = false) {
    const paso = 16, ox = sitio ? sitio.x : 0, oy = sitio ? sitio.y : 0, w = sitio ? sitio.w : ANCHO;
    for (let y = y0; y < y1; y += paso) {
      const h = Math.min(paso, y1 - y);
      const d = this.paralaje(profundidad(y + h / 2));
      // un píxel de solape para que no se vean costuras
      c.drawImage(imagen, 0, y - oy, w, h + 1, ox + d.x, y + d.y, w, h + 1);
      if (bordes && d.x > 0.3) c.drawImage(imagen, 0, y - oy, 1, h + 1, ox + d.x - 160, y + d.y, 160.5, h + 1);
      if (bordes && d.x < -0.3) c.drawImage(imagen, w - 1, y - oy, 1, h + 1, ox + w + d.x - 0.5, y + d.y, 160, h + 1);
    }
  },
  transformarCaja(c) {
    const b = aliento.valor, e = Math.cos(this.giro);
    c.translate(ANCLA_CAJA.x, ANCLA_CAJA.y); c.scale(1 + 0.0028 * b, 1 + 0.0065 * b); c.translate(-ANCLA_CAJA.x, -ANCLA_CAJA.y);
    c.translate(EJE_CAJA, 0); c.scale(Math.max(0.03, Math.abs(e)), 1); c.translate(-EJE_CAJA, 0);
  },
  dibujarCaja(c) {
    const e = Math.abs(Math.cos(this.giro)), frente = this.cara() === 'frente';
    c.save();
    this.transformarCaja(c);
    const capa = frente ? capas2d.caja : capas2d.cajaDetras;
    c.drawImage(capa, capa.sitio.x, capa.sitio.y);
    if (frente && (estado.cuerno !== 'puesto' || despertar.ojos < 1)) dibujarOjo(c);
    if (tapaVuelo === null && vueloEnCaja) dibujarVueloEnCaja(c);
    // de canto se oscurece, como un papel que gira
    if (e < 0.999) {
      c.globalCompositeOperation = 'source-atop';
      c.fillStyle = `rgba(10, 6, 4, ${0.55 * (1 - e)})`;
      c.fillRect(capa.sitio.x, capa.sitio.y, capa.sitio.w, capa.sitio.h);
      c.globalCompositeOperation = 'source-over';
    }
    dibujarHumo(c, 'caja'); dibujarHumo(c, 'caja_detras');
    c.restore();
  },
};
let tapaVuelo = null, llaveGirando = null, vueloEnCaja = null;
function dibujarLlaveGirando(c) {
  const d = datos.capas.llave, k = llaveGirando.t;
  c.save(); c.globalAlpha = 1 - suave(Math.max(0, k - 0.6) / 0.4);
  c.translate(CERRADURA.x, CERRADURA.y); c.rotate(-1.2 * salida(k)); c.scale(0.8, 0.8 - 0.35 * salida(k));
  c.drawImage(img.llave, -d.w / 2, -d.h / 2);
  c.restore();
}
function dibujarVueloEnCaja() {}

// ---------------------------------------------------------------------------------------------
// Cámara: sacudida común
// ---------------------------------------------------------------------------------------------
const sacudida = { fuerza: 0, hasta: 0 };
function sacudir(fuerza, duracion) { sacudida.fuerza = fuerza / duracion; sacudida.hasta = reloj + duracion; }

// ---------------------------------------------------------------------------------------------
// La técnica activa y el dibujo de lo de encima en B y C (humo, luces, polvo) con anclas en 3D
// ---------------------------------------------------------------------------------------------
let tec = tecnicaA;
const tecnicas = { A: tecnicaA };
const caraVisible = () => (tec ? tec.cara() : 'frente');
function irA(nombre, duracion = 0.75) {
  if (estado.vista === nombre && !(tec.transicion)) { /* ya está */ }
  estado.vista = nombre;
  tec.irA(nombre, duracion);
  el.volver.hidden = nombre === 'sala' || estado.fase !== 'jugando';
  if (nombre !== 'sala') sonar('acercar', -16, nombre === 'incensario' ? 1.1 : 1);
  if (mensajeHasta) mensajeHasta = Math.min(mensajeHasta, reloj + 0.3);
}
// En B y C: cada cosa que se dibuja en el boceto se lleva a la pantalla con su ancla en 3D
function dibujarEncima3D() {
  const c = ctx;
  c.setTransform(ppp, 0, 0, ppp, 0, 0);
  c.clearRect(0, 0, ancho, alto);
  const conAncla = (x, y, objeto, dibujo) => {
    const m = tec.ancla({ x, y }, objeto);
    if (!m || !m.visible) return;
    c.setTransform(ppp * m.k, 0, 0, ppp * m.k, ppp * (m.x - m.k * x), ppp * (m.y - m.k * y));
    dibujo();
  };
  if (tec.tapa2D) {
    if (estado.tapaEnMesa) conAncla(TAPA_MESA.x, TAPA_MESA.y, 'mesa', () => tapaEnLaMesa(ctx));
    if (tapaVuelo) conAncla(TAPA_ORIGEN.x, TAPA_ORIGEN.y, 'incensario', () => dibujarTapa(ctx, tapaVuelo.x, tapaVuelo.y, tapaVuelo.ang, tapaVuelo.sx, tapaVuelo.sy));
  }
  if (llaveGirando) conAncla(CERRADURA.x, CERRADURA.y, 'incensario', () => dibujarLlaveGirando(ctx));
  c.setTransform(ppp, 0, 0, ppp, 0, 0);
  for (const n of nubes) conAncla(n.ax, n.ay, n.objeto, () => dibujarNube(ctx, n));
  for (const lista of [humos.incienso, humos.te, humos.sueltos]) for (const h of lista) conAncla(h.x, h.y, h.objeto, () => h.dibujar(ctx));
  if (despertar.oscuridad > 0) {
    c.setTransform(ppp, 0, 0, ppp, 0, 0);
    c.fillStyle = `rgba(6, 4, 8, ${despertar.oscuridad})`; c.fillRect(0, 0, ancho, alto);
  }
  c.globalCompositeOperation = 'lighter';
  for (const objeto of ['sala', 'incensario', 'caja']) {
    if (objeto === 'caja' && tec.cara() !== 'frente') continue;
    for (const [x, y, r, col, a] of luces(objeto)) conAncla(x, y, objeto, () => brillo(ctx, x, y, r, col, a));
  }
  if (tec.cara() === 'frente') conAncla(TRAMPILLA.x, TRAMPILLA.y, 'caja', () => dibujarHaz(ctx));
  const li = lampara.intensidad;
  for (const mo of motas) {
    const a = (mo.lampara ? 0.5 * li : 0.32) * (0.45 + 0.55 * Math.sin(reloj * 1.7 + mo.fase * 3));
    if (a <= 0.02) continue;
    conAncla(mo.x, mo.y, 'sala', () => { ctx.globalAlpha = a; const r = mo.r * 2.6; ctx.drawImage(puntoLuz, mo.x - r, mo.y - r, r * 2, r * 2); ctx.globalAlpha = 1; });
  }
  c.globalCompositeOperation = 'source-over';
}

// ---------------------------------------------------------------------------------------------
// Vuelos: lo que se coge va al inventario, y lo que se usa sale de él
// ---------------------------------------------------------------------------------------------
const vuelos = [];
function volar(o) { return new Promise(ok => vuelos.push({ ...o, t: 0, ok })); }
function rectHueco(nombre) {
  const r = el.huecos[nombre].getBoundingClientRect(), l = lienzo.getBoundingClientRect();
  return { x: r.left - l.left + r.width / 2, y: r.top - l.top + r.height / 2 };
}
async function alInventario(objeto, capa, ancla = 'caja') {
  const d = datos.capas[capa], hueco = el.huecos[objeto];
  hueco.hidden = false; hueco.querySelector('img').style.opacity = 0;
  const centro = { x: d.x + d.w / 2, y: d.y + d.h / 2 };
  const pantalla = () => { const m = tec.ancla(centro, ancla); return m || { x: ancho / 2, y: alto / 2, k: 1 }; };
  await volar({ imagen: img[capa], w: d.w, h: d.h, desde: pantalla, hacia: () => rectHueco(objeto),
    sDesde: () => pantalla().k, sHacia: () => 40 / Math.max(d.w, d.h), duracion: 0.75, arco: 70 });
  hueco.querySelector('img').style.opacity = 1;
  hueco.classList.remove('llega'); void hueco.offsetWidth; hueco.classList.add('llega');
}
async function desdeInventario(objeto, capa, destino, ancla, desde = null) {
  const d = datos.capas[capa], hueco = el.huecos[objeto];
  const inicio = desde || rectHueco(objeto);
  hueco.hidden = true;
  const pantalla = () => { const m = tec.ancla(destino, ancla); return m || { x: ancho / 2, y: alto / 2, k: 1 }; };
  await volar({ imagen: img[capa], w: d.w, h: d.h, desde: () => inicio, hacia: pantalla,
    sDesde: () => 40 / Math.max(d.w, d.h), sHacia: () => pantalla().k, duracion: 0.7, arco: 50 });
}
function dibujarVuelos() {
  const c = ctx;
  c.setTransform(ppp, 0, 0, ppp, 0, 0);
  for (const v of vuelos) {
    const k = curva(limitar(v.t / v.duracion, 0, 1));
    const a = v.desde(), z = v.hacia();
    const x = mezclar(a.x, z.x, k), y = mezclar(a.y, z.y, k) - Math.sin(k * Math.PI) * v.arco;
    const esc = mezclar(v.sDesde(), v.sHacia(), k);
    c.save(); c.translate(x, y); c.rotate(Math.sin(k * Math.PI) * 0.25);
    c.shadowColor = 'rgba(0,0,0,0.6)'; c.shadowBlur = 12; c.shadowOffsetY = 6;
    c.drawImage(v.imagen, -v.w * esc / 2, -v.h * esc / 2, v.w * esc, v.h * esc);
    c.restore();
  }
}
let vineta = null;
function dibujarVineta() {
  const c = ctx;
  c.setTransform(ppp, 0, 0, ppp, 0, 0);
  if (!vineta) {
    const r = Math.max(ancho, alto);
    vineta = c.createRadialGradient(ancho / 2, alto * 0.48, r * 0.3, ancho / 2, alto * 0.5, r * 0.82);
    vineta.addColorStop(0, 'rgba(8,5,3,0)'); vineta.addColorStop(1, 'rgba(8,5,3,0.62)');
  }
  c.fillStyle = vineta; c.fillRect(0, 0, ancho, alto);
}

// ---------------------------------------------------------------------------------------------
// Mensajes y pistas
// ---------------------------------------------------------------------------------------------
let mensajeHasta = 0;
function mensaje(texto, segundos) {
  el.mensaje.textContent = texto;
  el.mensaje.classList.add('visible');
  mensajeHasta = reloj + (segundos || Math.max(2.6, 1.3 + texto.length * 0.055));
}
function primeraVez(clave) { if (estado.vistos[clave]) return false; estado.vistos[clave] = true; return true; }
function insistir(clave) {
  const r = estado.insistencia[clave] || { n: 0, t: -99 };
  r.n = reloj - r.t < 6 ? r.n + 1 : 1; r.t = reloj;
  estado.insistencia[clave] = r;
  return r.n;
}
function pista() {
  sonar('pista', -8);
  const n = estado.pistas++;
  if (estado.llave === 'cajon') {
    if (caraVisible() !== 'frente') return mensaje('La llave estaba del otro lado. Gira la caja.');
    if (estado.intentosLlave === 0) return mensaje(n % 2 ? 'En el cajón de abajo, a la derecha de la caja, brilla algo.' : 'Hay cajones abiertos en el costado de la caja. Mira dentro.');
    return mensaje('Mientras el ojo te mira, la caja no deja tocar nada. Haz que mire la lámpara.');
  }
  if (estado.tapa === 'puesta') return mensaje(n % 2 ? 'El incensario: la cerradura está bajo el león. Elige la llave y toca el incensario.' : 'La llave es diminuta. ¿Qué tiene una cerradura pequeña en esta sala?');
  if (estado.cuerno === 'brasas') return mensaje('Algo blanco asoma entre las brasas del incensario.');
  if (estado.cuerno === 'mano') return mensaje(caraVisible() === 'frente' ? 'A la cara le falta un cuerno. Elige el cuerno y toca el hueco de la frente.' : 'El hueco del cuerno está en la cara. Gira la caja.');
  return mensaje('Ya está despierta.');
}

// ---------------------------------------------------------------------------------------------
// Lo que se puede tocar: en el boceto de frente (la sala y la cara de la caja) y en el de espaldas
// ---------------------------------------------------------------------------------------------
const ZONAS = [
  // la caja de frente: de cerca
  { grupo: 'caja', forma: ['rect', 1028, 456, 1126, 522], si: () => estado.llave === 'cajon', tocar: tocarLlave },
  { grupo: 'caja', forma: ['rect', 1104, 426, 1172, 474], tocar: leerNota },
  { grupo: 'caja', forma: ['rect', 1021, 233, 1074, 312], tocar: () => cajonCerrado('a', 1072, 262, 1, -0.5) },
  { grupo: 'caja', forma: ['rect', 1111, 295, 1154, 352], tocar: () => cajonCerrado('b', 1150, 302, 0.8, -1) },
  { grupo: 'caja', forma: ['rect', 1021, 403, 1067, 489], tocar: () => cajonCerrado('c', 1066, 420, 1, -0.6) },
  { grupo: 'caja', forma: ['rect', 1067, 385, 1110, 461], tocar: () => cajonCerrado('d', 1108, 392, 1, -0.8) },
  { grupo: 'caja', forma: ['rect', 1078, 212, 1188, 296], tocar: () => cajonVacio() },
  { grupo: 'caja', forma: ['rect', 1074, 308, 1122, 384], tocar: () => cajonVacio() },
  { grupo: 'caja', forma: ['rect', 1110, 352, 1182, 437], tocar: () => cajonVacio() },
  { grupo: 'caja', forma: ['rect', 1092, 426, 1204, 530], tocar: () => cajonVacio() },
  { grupo: 'caja', forma: ['rect', 1020, 460, 1140, 582], tocar: () => cajonVacio(estado.llave === 'cajon' ? null : 'El cajón de la llave. Ahora, vacío.') },
  { grupo: 'caja', forma: ['elipse', 785, 370, 38, 19], tocar: tocarOjo },
  { grupo: 'caja', forma: ['elipse', 905, 378, 36, 21], tocar: tocarCuenca },
  { grupo: 'caja', forma: ['elipse', 912, 291, 30, 30], tocar: tocarFrente },
  { grupo: 'caja', forma: ['rect', 800, 250, 870, 318], tocar: () => mensaje('Un cuerno de marfil. Le falta su pareja.') },
  { grupo: 'caja', forma: ['elipse', 842, 484, 52, 24], tocar: () => mensaje('Los labios están tallados, pero parecen tibios.') },
  { grupo: 'caja', forma: ['elipse', 930, 196, 66, 18], tocar: tocarTrampilla },
  // el incensario: de cerca
  { grupo: 'incensario', forma: ['rect', 566, 444, 620, 516], si: () => estado.tapa === 'abierta' && estado.cuerno === 'brasas', tocar: cogerCuerno },
  { grupo: 'incensario', forma: ['rect', 462, 600, 580, 650], si: () => estado.tapaEnMesa, tocar: () => mensaje('La tapa del león. Ya no guarda nada.') },
  { grupo: 'incensario', forma: INCENSARIO, tocar: tocarIncensario },
  // la sala: desde cualquier vista
  { grupo: 'sala', forma: ['rect', 535, 212, 676, 434], tocar: tocarLampara },
  { grupo: 'sala', forma: ['rect', 1206, 476, 1376, 626], tocar: () => mensaje('Té verde. Todavía está tibio.') },
  { grupo: 'sala', forma: ['rect', 1140, 592, 1336, 698], tocar: () => mensaje('Dos tazas servidas. Nadie vino a beberlas.') },
  { grupo: 'sala', forma: ['rect', 236, 0, 416, 336], tocar: () => mensaje('Una montaña entre la niebla, pintada a tinta.') },
  { grupo: 'sala', forma: ['rect', 0, 0, 138, 500], tocar: () => mensaje('La puerta no se abre. Primero, la caja.') },
  { grupo: 'sala', forma: ['rect', 664, 0, 1376, 172], tocar: () => mensaje('Fuera, la noche está quieta.') },
  { grupo: 'sala', forma: ['rect', 1210, 172, 1376, 470], tocar: () => mensaje('Fuera, la noche está quieta.') },
];
// la espalda de la caja (en el boceto de espaldas)
const ZONAS_DETRAS = [
  { forma: ['rect', 687, 300, 787, 368], tocar: () => mensaje('Vacío. En el fondo, una muesca con forma de ficha.') },
  { forma: ['rect', 815, 328, 878, 408], tocar: () => mensaje('Un hueco con forma de ficha de shōgi. Falta la ficha.') },
  { forma: ['rect', 715, 474, 990, 558], tocar: () => cajonCerrado('largo', 860, 478, 0.2, -1, 'Tiene cerradura, pero no es la de la llave de bambú.', 'caja_detras') },
  { forma: ['rect', 1050, 195, 1122, 552], tocar: () => mensaje('Una borla de seda roja. El nudo está muy apretado.') },
  { forma: ['rect', 715, 233, 990, 495], tocar: () => cajonCerrado('detras', 900, 330, 0.4, -1, null, 'caja_detras') },
];

function tocarEscena(sx, sy) {
  if (estado.fase !== 'jugando' || estado.ocupado) return;
  const p = tec.aPintura(sx, sy);
  if (!p) { if (estado.vista !== 'sala') irA('sala'); return; }
  if (estado.seleccion) { usarObjeto(estado.seleccion, p, null); return; }
  const v = estado.vista, deCerca = v === 'caja' || v === 'cara';
  if (p.cara === 'detras') {
    if (!deCerca) { irA('caja'); return; }
    for (const z of ZONAS_DETRAS) if (dentro(z.forma, p)) { sonar('toque', -14); z.tocar(p); return; }
    sonar('toque', -14); mensaje('La espalda de la caja: más cajones y un hueco extraño.');
    return;
  }
  for (const z of ZONAS) {
    if (z.si && !z.si()) continue;
    if (!dentro(z.forma, p)) continue;
    if (z.grupo === 'caja' && !deCerca) { irA('caja'); return; }
    if (z.grupo === 'incensario' && v !== 'incensario') { irA('incensario'); return; }
    sonar('toque', -14);
    z.tocar(p);
    return;
  }
  if (dentro(['poli', CAJA], p)) {
    if (!deCerca) irA('caja');
    else { sonar('toque', -14); mensaje(elegir(['La madera está tibia, como si respirara.', 'Mosaico de maderas claras y oscuras. Ni una junta se mueve.'])); }
    return;
  }
  if (v !== 'sala') irA('sala');
}

// La resistencia creativa: no se mueve ni se marca; reacciona la caja entera y va a más
function resistir(x, y, dx, dy, punto, veces, objeto = 'caja') {
  sonar('trabado', -2); vibrar(35);
  contenerAliento(1.4 + 0.4 * Math.min(veces, 3));
  if (objeto === 'caja') mirarA(punto, 3);
  entornar(1.6 + 0.4 * veces);
  bocanada(x, y, dx, dy, Math.min(veces, 3), objeto);
  if (veces >= 3) {
    sonar('grunido', -6, 0.9); sacudir(3, 0.35);
    agitarLampara(0.7, 0.8);
    setTimeoutReloj(1.2, () => bocanada(1010, 560, 0.4, -1, 2));
  }
}
function cajonCerrado(cual, x, y, dx, dy, texto, objeto = 'caja') {
  const veces = insistir('cajon-' + cual);
  resistir(x, y, dx, dy, { x, y }, veces, objeto);
  if (texto && veces === 1) mensaje(texto);
  else if (primeraVez('cajon-cerrado')) mensaje('Cerrado. La caja contiene el aliento.');
  else if (veces === 2) mensaje('Ni se mueve. El ojo te sigue la mano.');
  else if (veces >= 3) mensaje('No insistas: no va a ceder.');
}
function cajonVacio(texto) { mensaje(texto || elegir(['Vacío.', 'Vacío. Huele a incienso viejo.', 'Vacío, pero el fondo está tibio.'])); }
function tocarLlave() {
  if (laCajaMira()) {
    estado.intentosLlave++;
    const veces = insistir('llave');
    resistir(1094, 468, 1, -0.7, { x: 1078, y: 490 }, veces);
    const n = estado.intentosLlave;
    mensaje(n === 1 ? 'No te deja cogerla mientras te mira.' : n === 2 ? 'Tendrías que hacer que mire a otra parte.' : 'La llama de la lámpara la distrae.');
    return;
  }
  estado.llave = 'mano';
  hornear();
  sonar('recoger', -2);
  alInventario('llave', 'llave', 'caja');
  mensaje('Una llave de bambú, diminuta.');
  setTimeoutReloj(1.1, () => {
    mirarA({ x: 1080, y: 490 }, 2.2); entornar(1.4);
    if (reloj < ojo.distraidoHasta + 2) mensaje('Lo ha visto. Ya es tarde.');
  });
}
function tocarLampara() {
  agitarLampara(1.5, 1);
  sonar('racha', -14, 1.25);
  ojo.distraidoHasta = reloj + 5;
  ojo.punto = null;
  mensaje(primeraVez('lampara') ? 'La llama tiembla y el ojo se va hacia ella.' : 'La llama tiembla.');
}
function tocarOjo() { parpadear(true); entornar(1.2); sonar('suspiro', -16, 1.4); mensaje('Parpadea. No le gusta que la toquen.'); }
function tocarCuenca() { destello(CUENCA.x, CUENCA.y + 2, 26, '255,40,30', 0.55, 1.3); sonar('suspiro', -14, 0.8); mensaje('Una cuenca vacía. Dentro, algo rojo se apaga.'); }
function tocarFrente() {
  mirarA({ x: 912, y: 230 }, 2);
  mensaje(primeraVez('frente') ? 'Aquí había otro cuerno. La madera está astillada.' : 'El hueco del cuerno. La caja mira hacia arriba.');
}
function tocarTrampilla() {
  const veces = insistir('trampilla');
  destello(TRAMPILLA.x, TRAMPILLA.y, 70, '255,205,120', 0.45, 1.1);
  sonar('trabado', -4, 0.85); vibrar(25);
  contenerAliento(1.2); mirarA({ x: 930, y: 196 }, 2);
  if (veces >= 3) bocanada(980, 196, 0.6, -1, 2);
  mensaje(primeraVez('trampilla') ? 'La trampilla está fría. Algo late debajo.' : 'Late, pero no se abre.');
}
function tocarIncensario() {
  if (estado.tapa === 'abierta') { mensaje(estado.cuerno === 'brasas' ? 'Algo blanco asoma entre las brasas.' : 'Solo quedan brasas.'); return; }
  const veces = insistir('incensario');
  sonar('trabado', -3, 1.15); vibrar(30);
  bocanada(560, 478, -0.3, -1, Math.min(veces, 3), 'incensario'); bocanada(600, 480, 0.3, -1, 1, 'incensario');
  mirarA({ x: 575, y: 500 }, 2);
  mensaje(primeraVez('incensario') ? 'La tapa no cede. Bajo el león hay una cerradura diminuta.' : 'El león no suelta la tapa.');
}
function leerNota() {
  sonar('papel', -4);
  el.nota.hidden = false;
  requestAnimationFrame(() => el.nota.classList.remove('oculta'));
}
// La nota se cierra con un toque que empiece en ella (el toque que la abrió no cuenta)
let toqueEnNota = false;
function cerrarNota() {
  if (el.nota.hidden) return;
  el.nota.classList.add('oculta');
  setTimeout(() => { el.nota.hidden = true; }, 600);
  sonar('papel', -8, 1.2);
}
el.nota.addEventListener('pointerdown', () => { toqueEnNota = true; });
el.nota.addEventListener('pointerup', () => { if (toqueEnNota) cerrarNota(); toqueEnNota = false; });
document.addEventListener('keydown', e => { if (e.key === 'Escape' || e.key === 'Enter') cerrarNota(); });

function cogerCuerno() {
  estado.cuerno = 'mano';
  hornear();
  sonar('recoger', -2);
  for (let i = 0; i < 6; i++) destello(azar(568, 600), azar(486, 504), azar(6, 12), '255,150,60', 0.6, azar(0.4, 0.9), 'incensario');
  alInventario('cuerno', 'cuerno_brasas', 'incensario');
  mensaje('Un cuerno de marfil. Todavía quema un poco.');
}

// ---------------------------------------------------------------------------------------------
// Usar lo que llevas
// ---------------------------------------------------------------------------------------------
function seleccionar(objeto) {
  estado.seleccion = estado.seleccion === objeto ? null : objeto;
  for (const [nombre, h] of Object.entries(el.huecos)) h.classList.toggle('elegido', estado.seleccion === nombre);
  if (estado.seleccion) mensaje(objeto === 'llave' ? 'La llave de bambú. ¿Dónde la usas?' : 'El cuerno de marfil. ¿Dónde va?', 2.4);
}
function usarObjeto(objeto, p, desde = null) {
  const deseleccionar = () => { estado.seleccion = null; for (const h of Object.values(el.huecos)) h.classList.remove('elegido'); };
  const deFrente = p && p.cara !== 'detras';
  if (objeto === 'llave' && deFrente && dentro(INCENSARIO, p) && estado.tapa === 'puesta') { deseleccionar(); abrirIncensario(desde); return; }
  if (objeto === 'cuerno' && deFrente && dentro(['elipse', 912, 291, 40, 40], p)) { deseleccionar(); ponerCuerno(desde); return; }
  deseleccionar();
  sonar('trabado', -8, 1.2);
  const enCaja = p && (p.cara === 'detras' || dentro(['poli', CAJA], p));
  if (objeto === 'llave') mensaje(p && p.cara === 'detras' && dentro(['rect', 715, 474, 990, 558], p) ? 'No es esta llave: es demasiado pequeña.' : enCaja ? 'La llave no entra en la caja.' : 'La llave no entra ahí.');
  else mensaje(enCaja ? 'Ahí no encaja. ¿Dónde le falta un cuerno?' : 'Ahí no encaja.');
}

async function abrirIncensario(desde) {
  estado.ocupado = true;
  irA('incensario');
  await desdeInventario('llave', 'llave', CERRADURA, 'incensario', desde);
  estado.llave = 'usada';
  sonar('llave', -2);
  const giro = { t: 0 };
  llaveGirando = giro;
  await animarPromesa(0.45, k => { giro.t = k; });
  llaveGirando = null;
  sonar('candado_abre', -2);
  estado.tapa = 'abierta';
  tapaVuelo = { x: TAPA_ORIGEN.x, y: TAPA_ORIGEN.y, ang: 0, sx: 1, sy: 1 };
  hornear();
  humoDelIncienso();
  await animarTapa();
  bucle('fuego', -21, 2);
  mensaje('Algo blanco asoma entre las brasas.');
  estado.ocupado = false;
}
function animarTapa() {
  const a = TAPA_ORIGEN, b = TAPA_MESA, alto = 30;
  return new Promise(ok => {
    animar(0.4, k => {
      tapaVuelo.ang = Math.sin(k * Math.PI * 6) * 0.035 * (1 - k);
      tapaVuelo.y = a.y - Math.abs(Math.sin(k * Math.PI * 6)) * 1.6 * (1 - k);
    }, () => {
      sonar('clic_madera', -4);
      bocanada(560, 500, -0.6, -1, 1, 'incensario'); bocanada(592, 500, 0.6, -1, 1, 'incensario');
      animar(0.5, k => { const e = salida(k); tapaVuelo.y = a.y - alto * e; tapaVuelo.ang = -0.07 * e; }, () => {
        animar(0.65, k => {
          const e = curva(k);
          tapaVuelo.x = mezclar(a.x, b.x, e);
          tapaVuelo.y = mezclar(a.y - alto, b.y, e) - Math.sin(e * Math.PI) * 24;
          tapaVuelo.ang = mezclar(-0.07, 0.03, e);
          tapaVuelo.sx = tapaVuelo.sy = mezclar(1, 1.04, e);
        }, () => {
          sonar('tope_madera', -2); vibrar(20);
          polvareda(b.x, b.y - 6);
          animar(0.28, k => {
            const q = Math.sin(k * Math.PI);
            tapaVuelo.sy = 1.04 * (1 - 0.06 * q); tapaVuelo.sx = 1.04 * (1 + 0.03 * q); tapaVuelo.ang = 0.03 * (1 - k);
          }, () => { estado.tapaEnMesa = true; tapaVuelo = null; hornear(); ok(); });
        });
      });
    });
  });
}
async function ponerCuerno(desde) {
  estado.ocupado = true;
  if (caraVisible() !== 'frente') { tec.girar(); await esperar(0.8); }
  if (estado.vista !== 'caja' && estado.vista !== 'cara') { irA('caja'); await esperar(0.6); }
  const d = datos.capas.cuerno;
  mirarA(HUECO_FRENTE, 3);
  await desdeInventario('cuerno', 'cuerno', { x: d.x + d.w / 2, y: d.y + d.h / 2 }, 'caja', desde);
  estado.cuerno = 'puesto';
  hornear();
  despertarCaja();
}

// El despertar: el cuerno encaja, la sala contiene el aliento y la caja abre los ojos
async function despertarCaja() {
  estado.fase = 'despertar';
  el.volver.hidden = true;
  sonar('encajar', -1); vibrar(60); sacudir(5, 0.35);
  ojo.punto = null; ojo.distraidoHasta = 0;
  await esperar(0.5);
  pararBucle('noche', 2.5);
  sonar('grunido', -3, 0.8);
  agitarLampara(2.2, 1.2);
  contenerAliento(2.4);
  animar(1.6, k => { despertar.oscuridad = 0.42 * suave(k); lampara.apagada = 0.45 * suave(k); });
  await esperar(1.2);
  animar(0.5, k => { ojo.parpadoBase = suave(k); });
  await esperar(0.9);
  sonar('despertar', 0); vibrar(120); sacudir(7, 0.5);
  irA('cara', 6.5);
  destello(OJO.x, OJO.y, 90, '255,50,35', 0.85, 0.9); destello(CUENCA.x, CUENCA.y, 90, '255,50,35', 0.85, 0.9);
  animar(0.3, k => { despertar.ojos = k; ojo.visible = 1 - k; hornear(); });
  await esperar(0.4);
  animar(1.8, k => { despertar.humo = suave(k); hornear(); });
  for (const [x, y, dx, dy] of [[700, 548, -0.5, -1], [1006, 560, 0.4, -1], [1150, 196, 0.5, -1], [705, 212, -0.4, -1], [1190, 420, 0.8, -0.8], [1120, 520, 0.6, -1]]) {
    humos.sueltos.push(new Cinta(x, y, { ritmo: 18, vida: 6, vel: 22, ancho: 6, alfa: 0.36, dir: { x: dx, y: dy }, duracion: 9, rizo: 1.4,
      color: [226, 233, 240], tinta: 0.18, objeto: 'caja' }));
  }
  await esperar(0.6);
  sonar('mecanismo', -2); sonar('bisagra', -4);
  destello(TRAMPILLA.x, TRAMPILLA.y - 10, 200, '255,215,140', 0.7, 1.4);
  animar(0.8, k => { despertar.trampilla = suave(k); hornear(); if (tec.abrirTrampilla) tec.abrirTrampilla(suave(k)); });
  await esperar(1.6);
  sonar('espiritu', -3); sonar('final_caja_viva', -2);
  bucle('noche', -17, 4);
  await esperar(2.8);
  estado.fase = 'fin';
  estado.ocupado = false;
  el.final.hidden = false;
  requestAnimationFrame(() => el.final.classList.remove('oculta'));
}

// ---------------------------------------------------------------------------------------------
// Bucle
// ---------------------------------------------------------------------------------------------
let ultimo = performance.now();
function actualizar(dt) {
  reloj += dt;
  for (let i = esperas.length - 1; i >= 0; i--) if (reloj >= esperas[i].hasta) { const e = esperas.splice(i, 1)[0]; e.ok(); }
  for (let i = temporizadores.length - 1; i >= 0; i--) if (reloj >= temporizadores[i].hasta) { const e = temporizadores.splice(i, 1)[0]; e.f(); }
  for (let i = animaciones.length - 1; i >= 0; i--) {
    const a = animaciones[i];
    a.t += dt;
    if (a.t < 0) continue;
    const k = Math.min(1, a.t / a.duracion);
    a.paso(k);
    if (k >= 1) { animaciones.splice(i, 1); if (a.fin) a.fin(); }
  }
  for (let i = vuelos.length - 1; i >= 0; i--) { const v = vuelos[i]; v.t += dt; if (v.t >= v.duracion) { vuelos.splice(i, 1); v.ok(); } }
  for (let i = destellos.length - 1; i >= 0; i--) { destellos[i].t += dt; if (destellos[i].t >= destellos[i].duracion) destellos.splice(i, 1); }
  actualizarOjo(dt);
  actualizarAliento(dt);
  actualizarLampara();
  actualizarMotas(dt);
  actualizarNubes(dt);
  for (const h of humos.incienso) h.actualizar(dt);
  for (const h of humos.te) h.actualizar(dt);
  for (let i = humos.sueltos.length - 1; i >= 0; i--) { const h = humos.sueltos[i]; h.actualizar(dt); if (!h.viva) humos.sueltos.splice(i, 1); }
  tec.actualizar(dt);
  if (estado.fase === 'jugando' && !estado.vistos.espalda && caraVisible() === 'detras') {
    estado.vistos.espalda = true;
    mensaje('La espalda: más cajones, una cerradura y un hueco con forma de ficha.');
  }
  if (mensajeHasta && reloj >= mensajeHasta) { el.mensaje.classList.remove('visible'); mensajeHasta = 0; }
}
function cuadro(ahora) {
  const dt = Math.min(0.05, Math.max(0, (ahora - ultimo) / 1000));
  ultimo = ahora;
  if (datos && tec.listo !== false) {
    actualizar(dt);
    tec.dibujar();
    if (tec.nombre !== 'A') dibujarEncima3D();
    dibujarVineta();
    dibujarVuelos();
  }
  requestAnimationFrame(cuadro);
}

// ---------------------------------------------------------------------------------------------
// Toques: tocar, arrastrar (mover la cámara o girar la caja) y pellizcar (acercarse)
// ---------------------------------------------------------------------------------------------
const punteros = new Map();
let puntero = null, arrastre = null, pellizco = null;
function posicion(e) { const r = lienzo.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; }
lienzo.addEventListener('pointerdown', e => {
  desbloquearAudio();
  const q = posicion(e);
  punteros.set(e.pointerId, q);
  if (punteros.size === 2) {
    const [a, b] = [...punteros.values()];
    pellizco = { d: Math.hypot(a.x - b.x, a.y - b.y) };
    puntero = null;
    return;
  }
  const p = tec.aPintura(q.x, q.y);
  puntero = { ...q, x0: q.x, y0: q.y, inicio: performance.now(), id: e.pointerId, movido: 0, enCaja: !!(p && (p.cara === 'detras' || dentro(['poli', CAJA], p))) };
  if (estado.fase === 'jugando' && p && p.cara === 'frente') mirarA(p);
});
lienzo.addEventListener('pointermove', e => {
  const q = posicion(e);
  if (punteros.has(e.pointerId)) punteros.set(e.pointerId, q);
  if (pellizco && punteros.size === 2) {
    const [a, b] = [...punteros.values()];
    const d = Math.hypot(a.x - b.x, a.y - b.y);
    tec.pellizcar(d / pellizco.d);
    pellizco.d = d;
    return;
  }
  if ((e.pointerType === 'mouse' || puntero) && estado.fase === 'jugando') {
    const p = tec.aPintura(q.x, q.y);
    if (p && p.cara === 'frente') mirarA(p);
  }
  if (puntero && e.pointerId === puntero.id) {
    const dx = q.x - puntero.x, dy = q.y - puntero.y;
    puntero.movido = Math.max(puntero.movido, Math.hypot(q.x - puntero.x0, q.y - puntero.y0));
    if (puntero.movido > 10 && estado.fase !== 'portada' && !estado.ocupado) {
      tec.arrastrar(dx, dy, puntero.enCaja);
      if (tec.nombre !== 'A' && puntero.enCaja && !puntero.sonoGiro && puntero.movido > 24) { puntero.sonoGiro = true; sonar('deslizar_madera', -14, 1.1); }
    }
    puntero.x = q.x; puntero.y = q.y;
    // en la técnica A, deslizar la caja de lado la gira
    if (tec.nombre === 'A' && puntero.enCaja && Math.abs(q.x - puntero.x0) > 90 && !puntero.giro && !estado.ocupado && estado.fase === 'jugando') {
      puntero.giro = true; girarCaja();
    }
  }
});
function finToque(e) {
  punteros.delete(e.pointerId);
  if (pellizco) { if (punteros.size < 2) pellizco = null; return; }
  if (!puntero || e.pointerId !== puntero.id) return;
  const q = posicion(e);
  if (puntero.movido < 16 && performance.now() - puntero.inicio < 900 && e.type === 'pointerup') tocarEscena(q.x, q.y);
  else tec.soltar();
  puntero = null;
}
lienzo.addEventListener('pointerup', finToque);
lienzo.addEventListener('pointercancel', finToque);
// sin el clic fantasma que el móvil manda tras un toque (caería en lo que se acaba de abrir)
lienzo.addEventListener('touchend', e => { if (e.cancelable) e.preventDefault(); }, { passive: false });
lienzo.addEventListener('wheel', e => { e.preventDefault(); tec.pellizcar(e.deltaY < 0 ? 1.08 : 0.93); }, { passive: false });

function girarCaja() {
  if (estado.fase !== 'jugando' || estado.ocupado) return;
  sonar('deslizar_madera', -10, 1.1);
  tec.girar();
  if (estado.vista === 'sala') irA('caja');
  setTimeoutReloj(0.45, () => bocanada(EJE_CAJA, 600, 0, -1, 0.5));
}

for (const [objeto, hueco] of Object.entries(el.huecos)) {
  hueco.addEventListener('pointerdown', e => {
    if (estado.ocupado || estado.fase !== 'jugando') return;
    desbloquearAudio();
    hueco.setPointerCapture(e.pointerId);
    arrastre = { objeto, id: e.pointerId, x: e.clientX, y: e.clientY, movido: false, fantasma: null };
  });
  hueco.addEventListener('pointermove', e => {
    if (!arrastre || e.pointerId !== arrastre.id) return;
    if (!arrastre.movido && Math.hypot(e.clientX - arrastre.x, e.clientY - arrastre.y) > 12) {
      arrastre.movido = true;
      const f = document.createElement('img');
      f.id = 'arrastre'; f.src = hueco.querySelector('img').src; f.alt = '';
      $('juego').appendChild(f); arrastre.fantasma = f;
      hueco.querySelector('img').style.opacity = 0.25;
    }
    if (arrastre.fantasma) {
      const r = $('juego').getBoundingClientRect();
      arrastre.fantasma.style.left = (e.clientX - r.left) + 'px'; arrastre.fantasma.style.top = (e.clientY - r.top - 30) + 'px';
      const q = posicion(e); const p = tec.aPintura(q.x, q.y - 30); if (p && p.cara === 'frente') mirarA(p);
    }
  });
  const soltar = e => {
    if (!arrastre || e.pointerId !== arrastre.id) return;
    const a = arrastre; arrastre = null;
    hueco.querySelector('img').style.opacity = 1;
    if (a.fantasma) a.fantasma.remove();
    if (e.type === 'pointercancel') return;
    if (!a.movido) { seleccionar(a.objeto); return; }
    const q = posicion(e); q.y -= 30;
    usarObjeto(a.objeto, tec.aPintura(q.x, q.y), q);
  };
  hueco.addEventListener('pointerup', soltar);
  hueco.addEventListener('pointercancel', soltar);
  hueco.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); seleccionar(objeto); } });
}
el.volver.addEventListener('click', () => { if (!estado.ocupado) irA('sala'); });
el.girar.addEventListener('click', () => { desbloquearAudio(); girarCaja(); });
el.pista.addEventListener('click', () => { desbloquearAudio(); if (estado.fase === 'jugando') pista(); });
el.sonido.addEventListener('click', () => {
  desbloquearAudio();
  audio.mudo = !audio.mudo;
  if (audio.maestro) audio.maestro.gain.setTargetAtTime(audio.mudo ? 0 : 0.9, audio.ctx.currentTime, 0.05);
  el.sonido.setAttribute('aria-pressed', String(!audio.mudo));
  el.sonido.setAttribute('aria-label', audio.mudo ? 'Poner el sonido' : 'Quitar el sonido');
  $('onda').toggleAttribute('hidden', audio.mudo); $('tachado').toggleAttribute('hidden', !audio.mudo);
});
document.addEventListener('visibilitychange', () => { ultimo = performance.now(); });

// ---------------------------------------------------------------------------------------------
// Las técnicas: A está aquí; B y C se cargan cuando se eligen (traen Three.js)
// ---------------------------------------------------------------------------------------------
let eleccion = 'A';
const NOMBRES_TECNICA = { A: 'A · Ilustración por capas', B: 'B · Pintura sobre 3D', C: 'C · 3D con acuarela' };
const TEXTOS_TECNICA = {
  A: 'La ilustración misma, por capas: la cámara se mueve con profundidad y la caja gira como en un teatro de papel.',
  B: 'La pintura puesta sobre una caja en 3D: la caja gira de verdad y la cámara da vueltas a su alrededor.',
  C: 'El modelo 3D de la caja, pintado con tinta y acuarela: más libertad de cámara, menos boceto.',
};
function marcarEleccion(letra) {
  eleccion = letra;
  const texto = $('tecnica-texto');
  if (texto) texto.textContent = TEXTOS_TECNICA[letra];
  for (const b of el.tecnicas.querySelectorAll('button')) b.setAttribute('aria-pressed', String(b.dataset.tecnica === letra));
  for (const b of el.cambiar.querySelectorAll('button')) b.setAttribute('aria-pressed', String(b.dataset.tecnica === letra));
}
let modulo3d = null, opciones3d = null;
async function usarTecnica(letra) {
  if (tecnicas[letra] && tec === tecnicas[letra]) return true;
  if (!tecnicas[letra]) {
    // cada técnica 3D se prepara la primera vez que se elige (C trae además el modelo de Blender, unos 2 MB)
    el.aviso3d.hidden = false; el.aviso3d.textContent = letra === 'C' ? 'Cargando el modelo 3D…' : 'Preparando la escena 3D…';
    try {
      modulo3d = modulo3d || await import('./tecnica_3d.js');
      opciones3d = opciones3d || { lienzo3d, camaraBoceto, escena3d, img, datos, compuesto, planchas, dibujarOjo, vistas: VISTAS, ojo: () => ojo,
        estado: () => estado, reloj: () => reloj, aliento: () => aliento.valor, despertar, alHornear,
        tapa: () => tapaVuelo, conTapaEnMesa: () => estado.tapaEnMesa, llaveGirando: () => llaveGirando,
        sacudida: () => (reloj < sacudida.hasta ? sacudida.fuerza * (sacudida.hasta - reloj) : 0), quieto };
      tecnicas[letra] = await modulo3d.crearTecnica(letra, opciones3d);
    } catch (e) {
      console.error(e);
      el.aviso3d.textContent = 'Este móvil no pudo abrir la escena 3D. La técnica A sí funciona.';
      setTimeout(() => { el.aviso3d.hidden = true; }, 3500);
      return false;
    }
    el.aviso3d.hidden = true;
  }
  if (tec && tec.desactivar) tec.desactivar();
  tec = tecnicas[letra];
  tec.activar();
  tec.medir && tec.medir(ancho, alto, ppp);
  if (letra === 'A') { lienzo.classList.remove('encima'); } else { lienzo.classList.add('encima'); }
  marcarEleccion(letra);
  return true;
}
for (const b of el.tecnicas.querySelectorAll('button')) b.addEventListener('click', () => marcarEleccion(b.dataset.tecnica));
for (const b of el.cambiar.querySelectorAll('button')) b.addEventListener('click', async () => {
  desbloquearAudio();
  if (estado.ocupado) return;
  const antes = tec.cara();
  if (await usarTecnica(b.dataset.tecnica)) {
    if (antes !== tec.cara()) tec.girar(true);
    mensaje(NOMBRES_TECNICA[b.dataset.tecnica], 1.6);
  }
});

// ---------------------------------------------------------------------------------------------
// Empezar, despertar el ojo y volver a empezar
// ---------------------------------------------------------------------------------------------
async function entrar() {
  desbloquearAudio();
  el.entrar.disabled = true;
  if (!(await usarTecnica(eleccion))) await usarTecnica('A');
  el.entrar.disabled = false;
  el.portada.classList.add('oculta');
  setTimeout(() => { el.portada.hidden = true; }, 950);
  bucle('noche', -13, 3);
  estado.fase = 'jugando';
  estado.vista = 'sala';
  tec.empezar ? tec.empezar(3.2) : tec.irA('sala', 3.2);
  el.volver.hidden = true;
  el.cambiar.hidden = false; el.girar.hidden = false;
  lampara.proxima = reloj + 12;
  await esperar(1.3);
  sonar('ojo_abre', -4);
  animar(0.7, k => { ojo.parpadoBase = 1 - 0.65 * salida(k); }, null);
  animar(0.25, k => { ojo.parpadoBase = 0.35 + 0.25 * k; }, null, 0.85);
  animar(0.6, k => { ojo.parpadoBase = 0.6 * (1 - salida(k)); }, null, 1.25);
  await esperar(1.9);
  ojo.parpadoBase = 0;
  if (estado.vista === 'sala') mensaje(alto > ancho ? 'Toca la caja para acercarte. Arrastra para mover la cámara.' : 'Toca la caja para acercarte. Arrastra para mover la cámara y desliza la caja para girarla.');
}
function reiniciar() {
  for (const h of Object.values(el.huecos)) { h.hidden = true; h.classList.remove('elegido'); }
  estado = estadoInicial();
  Object.assign(despertar, { ojos: 0, humo: 0, trampilla: 0, oscuridad: 0 });
  ojo.visible = 1; ojo.parpadoBase = 1; ojo.entornado = 0; ojo.distraidoHasta = 0;
  lampara.apagada = 0; tapaVuelo = null; humos.sueltos.length = 0; nubes.length = 0;
  pararBucle('fuego', 1);
  humoDelIncienso();
  hornear();
  for (const t of Object.values(tecnicas)) if (t.reiniciar) t.reiniciar();
  el.final.classList.add('oculta');
  setTimeout(() => { el.final.hidden = true; }, 900);
  entrar();
}
el.entrar.addEventListener('click', entrar);
el.otra.addEventListener('click', reiniciar);

// Si la página se actualiza con alguien jugando, conserva por dónde iba
function restaurar(guardado) {
  if (!guardado || !guardado.estado || guardado.estado.fase === 'portada') return false;
  const g = guardado.estado;
  estado = { ...estadoInicial(), ...g, ocupado: false, seleccion: null, vista: 'sala' };
  if (estado.fase === 'despertar') estado.fase = 'fin';
  if (estado.tapa === 'abierta') estado.tapaEnMesa = true;
  if (estado.llave === 'mano') el.huecos.llave.hidden = false;
  if (estado.cuerno === 'mano') el.huecos.cuerno.hidden = false;
  ojo.parpadoBase = 0;
  if (estado.fase === 'fin') {
    estado.cuerno = 'puesto';
    Object.assign(despertar, { ojos: 1, humo: 1, trampilla: 1, oscuridad: 0.42 });
    ojo.visible = 0; lampara.apagada = 0.45;
    el.final.hidden = false; el.final.classList.remove('oculta');
  }
  el.portada.hidden = true;
  el.cambiar.hidden = false; el.girar.hidden = false;
  return true;
}

async function arrancar(guardado) {
  medir();
  el.cargando.hidden = false; el.cargando.textContent = 'Preparando la sala…';
  prepararAudio();
  try {
    const [d, cam, esc, ...imagenes] = await Promise.all([
      fetch('capas/capas.json').then(r => r.json()),
      fetch('capas/camara.json').then(r => r.json()),
      fetch('capas/escena.json').then(r => r.json()),
      ...CAPAS.map(n => new Promise((ok, mal) => {
        const i = new Image();
        i.onload = () => ok(i);
        i.onerror = () => mal(new Error(n));
        i.src = 'capas/' + n + '.webp';
      })),
    ]);
    CAPAS.forEach((n, i) => { img[n] = imagenes[i]; });
    datos = d; camaraBoceto = cam; escena3d = esc;
  } catch (e) {
    el.cargando.textContent = 'No se pudo cargar la ilustración. Recarga la página.';
    return;
  }
  compuesto.width = ANCHO; compuesto.height = ALTO;
  prepararOjo(); prepararMotas(); prepararPuntoLuz(); prepararCapasFijas();
  const restaurado = restaurar(guardado);
  hornear();
  humoDelIncienso();
  humos.te = [new Cinta(1188, 611, { ritmo: 9, vida: 2.8, vel: 13, ancho: 2.4, alfa: 0.14, tinta: 0.05, rizo: 0.8, objeto: 'te' }),
              new Cinta(1287, 627, { ritmo: 9, vida: 2.6, vel: 12, ancho: 2.2, alfa: 0.12, tinta: 0.05, rizo: 0.8, objeto: 'te' })];
  tecnicaA.activar();
  el.cargando.hidden = true;
  marcarEleccion(eleccion);
  el.entrar.disabled = false; el.entrar.textContent = 'Entrar en la sala';
  if (restaurado) { if (guardado.tecnica && guardado.tecnica !== 'A') await usarTecnica(guardado.tecnica); if (estado.fase === 'jugando') bucle('noche', -13, 2); }
}

const caliente = window.claude && window.claude.hot;
if (caliente && caliente.snapshot) caliente.snapshot(() => ({ estado: { ...estado, ocupado: false, seleccion: null }, tecnica: tec.nombre }));
requestAnimationFrame(cuadro);
if (caliente && caliente.ready) caliente.ready(arrancar); else arrancar((caliente && caliente.data) || {});

// Para la prueba automática (no hace nada si nadie la usa)
window.__prueba = {
  estado: () => estado, ojo: () => ojo, tecnica: () => tec.nombre, cara: () => tec.cara(), reloj: () => reloj,
  aPantalla: (x, y, objeto = 'caja') => { const m = tec.pantallaDe ? tec.pantallaDe(x, y, objeto) : tec.ancla({ x, y }, objeto); return m ? { x: m.x, y: m.y } : null; },
  usarTecnica: letra => usarTecnica(letra), girar: () => girarCaja(), irA: nombre => irA(nombre),
  distraer: () => { ojo.distraidoHasta = reloj + 5; },
};
window.__tec = () => tec;

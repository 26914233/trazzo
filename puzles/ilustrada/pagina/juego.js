// La caja viva ilustrada. El juego va con la técnica B (DECISIÓN 29, cerrada el 03-10-2026): la pintura del boceto
// proyectada sobre una caja 3D (Three.js, tecnica_3d.js y escena3d.js).
//   A · la ilustración por capas (2D, en un lienzo; aquí mismo): el respaldo para los móviles sin WebGL.
//   C · el modelo de Blender con tinta y acuarela: retirada; su código sigue en tecnica_3d.js como referencia.
// Aquí está todo lo que no depende de la técnica: el estado y el recorrido, el ojo, la respiración, el humo y
// la luz, los sonidos, la interfaz, los toques y la técnica A.

// ---------------------------------------------------------------------------------------------
// Datos de la ilustración (píxeles del boceto de 1376 × 768; ver preparar_capas.py)
// ---------------------------------------------------------------------------------------------
const ANCHO = 1376, ALTO = 768;
const CAPAS = ['sala', 'sala_vacia', 'sala_mesa_vacia', 'sala_detras', 'tapa', 'incensario_abierto', 'incensario_vacio',
  'cuerno_brasas', 'llave', 'nota', 'cuerno', 'cuerno_puesto', 'despierta_ojos', 'despierta_trampilla',
  'despierta_humo', 'ojo_vacio', 'iris', 'silueta_mesa', 'silueta_caja', 'silueta_caja_detras', 'silueta_incensario',
  'silueta_te', 'laca_pared'];
const CAPAS_NIVEL2 = ['cajita', 'ojo2', 'iris2'];       // la cajita roja y el ojo nuevo (herramientas/nivel2_capas.py)
const SONIDOS = ['noche', 'fuego', 'trabado', 'recoger', 'encajar', 'despertar', 'final_caja_viva', 'suspiro', 'ojo_abre',
  'grunido', 'espiritu', 'papel', 'llave', 'candado_abre', 'tope_madera', 'clic_madera', 'acercar', 'pista', 'toque',
  'mecanismo', 'racha', 'bisagra', 'deslizar_madera', 'cajon', 'trampilla', 'cristal', 'viento', 'clic_metal',
  'holgura', 'clac', 'pestillo', 'desbloqueo'];                // el vocabulario (herramientas/sonidos_vocabulario.py)

// Encuadres de la técnica A: [x0, y0, x1, y1] de lo que debe verse en horizontal (h) y en vertical (v)
const VISTAS = {
  sala:       { h: [0, 70, 1376, 698],    v: [480, 140, 1250, 720] },
  caja:       { h: [668, 168, 1222, 620], v: [592, 168, 1232, 640] },
  cajones:    { h: [985, 196, 1240, 626], v: [990, 215, 1230, 565] },      // con sitio para los de abajo abiertos
  incensario: { h: [446, 392, 734, 664],  v: [440, 360, 740, 664] },
  cara:       { h: [705, 236, 1020, 560], v: [726, 228, 1000, 560] },      // de los huecos de la frente a la boca
  // nivel 2 (solo en la B): la caja hija sube de la trampilla y se mira de cerca en la mesa, con el ojo grande encima
  subida:     { h: [560, 0, 1300, 700],   v: [620, 40, 1240, 720] },
  hija:       { h: [240, 270, 1268, 745],  v: [618, 270, 903, 745] },     // solo cuenta su tamaño (ver tecnica_3d.js)
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
const TAPA_SUELTA = { x: 578, y: 515, ang: -0.035 };   // suelta, la tapa queda entreabierta: un poco alzada y torcida
let CAJA = [[686, 200], [790, 168], [1150, 178], [1205, 215], [1210, 530], [1180, 545], [1180, 600], [1160, 640],
  [1000, 690], [660, 615], [655, 585], [686, 545]];
const INCENSARIO = ['rect', 496, 426, 652, 612];
// Los nueve cajones del costado (su sitio está en capas/cajones.json): dos con cerradura, la llave y la nota
const CAJONES = {
  c1: { texto: 'Vacío. Huele a incienso viejo.' },
  c2: { cerradura: true },
  c3: { texto: 'Hilos de seda roja, enredados. Nada más.' },
  c4: { texto: 'Vacío, pero el fondo está tibio.' },
  c5: { texto: 'Ceniza fina y la punta de una varilla de incienso.' },
  c6: { cerradura: true },
  c7: { texto: 'Un papel quemado. Ya no se puede leer.' },
  c8: { contiene: 'llave' },
  c9: { contiene: 'nota' },
};
// Los niveles (NIVELES.md): cada uno devuelve una pieza a la cara, y la cara completa abrirá el nivel final
const NIVELES = {
  1: { titulo: 'El cuerno', pieza: 'cuerno', texto: 'La caja tiene otra vez su cuerno… y ya te ha visto.' },
  2: { titulo: 'La caja de dentro', pieza: 'ojo', texto: 'Ya tiene sus dos ojos. El nuevo mira donde el viejo no mira.' },
  3: { titulo: 'La caja del revés', pieza: 'voz' },
};
const CLAVE_PARTIDA = 'caja_viva_partida';
const MARCA_BORDE = -Math.PI / 2;            // la cajita: la marca dorada del borde, arriba
const PASO_TAPA = Math.PI / 6;               // su tapa gira a saltos de 30°

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
  mensaje: $('mensaje'), portada: $('portada'), entrar: $('boton-entrar'), nota: $('nota'),
  otra: $('boton-otra'), cargando: $('cargando'), inventario: $('inventario'), bandeja: $('bandeja'), etiqueta: $('etiqueta-objeto'),
  examinar: $('examinar'), examinarImg: $('examinar-img'), examinarNombre: $('examinar-nombre'), examinarTexto: $('examinar-texto'),
  aviso3d: $('aviso3d'), bolsillo: $('bolsillo'), examinarAyuda: $('examinar-ayuda'),
  tarjeta: $('tarjeta'), tarjetaHecho: $('tarjeta-hecho'), tarjetaTitulo: $('tarjeta-titulo'), tarjetaTexto: $('tarjeta-texto'),
  tarjetaSiguiente: $('tarjeta-siguiente'), seguir: $('boton-seguir'), quedarse: $('boton-quedarse'), continuar: $('boton-continuar'),
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
    llave: 'cajon',           // cajon | mano | cerradura (metida, sin girar) | usada
    tapa: 'puesta',           // puesta (cerrada con llave) | suelta (sin llave, aún encima) | abierta (en la mesa o en la mano)
    tapaEnMesa: false,
    cuerno: 'brasas',         // brasas | mano | puesto
    nota: 'cajon',            // cajon | mano (se guarda en el inventario)
    inventario: [],           // lo que llevas, en orden de llegada
    cajones: Object.fromEntries(Object.keys(CAJONES).map(id => [id, 'cerrado'])),
    seleccion: null,
    ocupado: false,
    intentosLlave: 0,
    insistencia: {},
    vistos: {},
    pistas: 0,
    nivel: 1,
    // en el nivel 2: { fase: dentro | subiendo | mesa, tablillas: [5 × sí/no], cajon: cerrado | abierto,
    //                  cajita: cajon | mano | abierta, ojo: cajita | mano | puesto }
    hija: null,
    pistasPaso: {},
    intentosMirada: 0,
  };
}
const hijaEnMesa = () => estado.nivel === 2 && !!estado.hija && estado.hija.fase === 'mesa';
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
  audio.bucles[nombre] = { fuente, g, base: Math.pow(10, db / 20) };
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
// El vocabulario de sonido y vibración (genero/05_gramatica_y_sistemas.md §7): cada cosa suena y vibra siempre igual,
// para que se entienda sin texto
const VOCABULARIO = {
  toque:      { sonido: 'toque', db: -14 },                                   // has tocado algo que responde
  holgura:    { sonido: 'holgura', db: -9, vibrar: 8 },                       // la pieza asoma: se puede mover
  roce:       { sonido: 'deslizar_madera', db: -14, tono: 1.2 },             // algo se está moviendo
  tope:       { sonido: 'tope_madera', db: -9, vibrar: 12 },                  // llegó al final
  clac:       { sonido: 'clac', db: -5, vibrar: [14, 45, 22] },               // posición correcta: encajó
  pestillo:   { sonido: 'pestillo', db: -6, vibrar: 10 },                     // un pestillo corre dentro
  muesca:     { sonido: 'clic_metal', db: -13, tono: 1.3, vibrar: 6 },        // un paso del mecanismo (la llave al girar)
  mecanismo:  { sonido: 'mecanismo', db: -8, vibrar: 20 },                    // algo se mueve dentro de la caja
  desbloqueo: { sonido: 'desbloqueo', db: -2, vibrar: [40, 70, 90] },         // gran desbloqueo
  trabado:    { sonido: 'trabado', db: -3, vibrar: 35 },                      // no se puede, ahora
};
function sentir(evento, { tono = 1, db = 0, sinVibrar = false } = {}) {
  const v = VOCABULARIO[evento];
  if (!v) return;
  sonar(v.sonido, (v.db || 0) + db, (v.tono || 1) * tono);
  if (v.vibrar && !sinVibrar) vibrar(v.vibrar);
}
// el silencio es tensión: mientras la caja contiene el aliento, el ambiente baja
function atenuarAmbiente(segundos, db = -11) {
  if (!audio.ctx) return;
  const ahora = audio.ctx.currentTime;
  for (const b of Object.values(audio.bucles)) {
    const base = b.base || b.g.gain.value;
    b.base = base;
    b.g.gain.cancelScheduledValues(ahora);
    b.g.gain.setValueAtTime(Math.max(0.0001, b.g.gain.value), ahora);
    b.g.gain.exponentialRampToValueAtTime(Math.max(0.0001, base * Math.pow(10, db / 20)), ahora + 0.25);
    b.g.gain.exponentialRampToValueAtTime(Math.max(0.0001, base * Math.pow(10, db / 20)), ahora + 0.25 + segundos);
    b.g.gain.exponentialRampToValueAtTime(base, ahora + 0.25 + segundos + 1.2);
  }
}

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
// el ojo nuevo del nivel 2, el de piedra de luna: va en la cuenca, parpadea a su aire y mira hacia otro lado
const ojo2 = { ox: 0, oy: 0, vx: 0, vy: 0, parpadoBase: 1, cerrado: 1, parpadeo: null, proximoParpadeo: 3, visible: 0,
  punto: null, proximoVagar: 0 };
let geoOjo = null, geoOjo2 = null, nivel2 = null;
function interpolar(linea, x) {
  for (let i = 1; i < linea.length; i++) {
    const [x0, y0] = linea[i - 1], [x1, y1] = linea[i];
    if (x <= x1) return y0 + (y1 - y0) * limitar((x - x0) / (x1 - x0 || 1), 0, 1);
  }
  return linea[linea.length - 1][1];
}
// la almendra de un ojo (19 puntos: los 10 de arriba de izquierda a derecha y los de abajo de vuelta), su párpado y su color
function geometriaOjo(A, color) {
  const almendra = new Path2D();
  A.forEach(([x, y], i) => (i ? almendra.lineTo(x, y) : almendra.moveTo(x, y)));
  almendra.closePath();
  const sup = A.slice(0, 10);
  const inf = [A[0], ...A.slice(10).reverse(), A[9]];
  const bordeSup = new Path2D();
  sup.forEach(([x, y], i) => (i ? bordeSup.lineTo(x, y) : bordeSup.moveTo(x, y)));
  const muestras = [];
  for (let x = sup[0][0]; x <= sup[sup.length - 1][0] + 0.01; x += 1.5) muestras.push({ x, s: interpolar(sup, x), i: interpolar(inf, x) });
  const ys = A.map(q => q[1]);
  return { almendra, bordeSup, muestras, color, y0: Math.min(...ys) - 8.5, y1: Math.max(...ys) + 3 };
}
function prepararOjo() {
  geoOjo = geometriaOjo(datos.almendra, colorMedio(img.sala, 770, 346, 30, 6));
  if (nivel2) {
    const v = nivel2.ojo2;
    // su párpado es de la misma madera que el del ojo viejo (el borde de la cuenca es más claro y cerrado parecería una mancha)
    geoOjo2 = geometriaOjo(nivel2.almendra2, geoOjo.color.map(v => Math.round(v * 0.95)));
    geoOjo2.capa = v;
  }
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

// El vistazo (la pista de dentro del mundo, el escalón 0 de genero/jugadores_y_principios.md §2): si pasa un rato
// sin avanzar, el ojo mira de reojo, un instante, hacia lo que más teme que encuentres. Nunca mientras tocas algo.
const PRIMER_VISTAZO = 35;
const progreso = { firma: '', desde: 0, proximoVistazo: 0 };
function firmaAvance() {
  const h = estado.hija;
  return [estado.nivel, estado.llave, estado.nota, estado.tapa, estado.cuerno, estado.inventario.length,
    Object.values(estado.cajones).join(''), h ? [h.fase, h.tablillas.join(''), h.cajon, h.cajita, h.ojo].join('') : ''].join('|');
}
// lo que la caja teme: el frente abierto ahora mismo (o nada, si ya lo vigila)
function frenteAbierto() {
  const h = estado.hija;
  if (estado.nivel === 2 && h) {
    if (h.fase === 'dentro') return TRAMPILLA;
    if (h.ojo === 'mano') return CUENCA;
    return null;                                          // la caja pequeña ya la vigila
  }
  if (estado.llave === 'cajon') return estado.cajones.c8 === 'abierto' ? LAMPARA : centroCajon('c8');
  if (estado.nota === 'cajon' && estado.llave === 'mano') return centroCajon('c9');
  if (estado.cuerno === 'brasas') return { x: 575, y: 520 };
  if (estado.cuerno === 'mano') return { x: HUECO_FRENTE.x, y: HUECO_FRENTE.y - 140 };  // hacia su propia frente
  return null;
}
function actualizarVistazo() {
  const f = firmaAvance();
  if (f !== progreso.firma) { progreso.firma = f; progreso.desde = reloj; progreso.proximoVistazo = reloj + PRIMER_VISTAZO; ojo.vistazo = null; }
  if (estado.fase !== 'jugando' || estado.ocupado || puntero || reloj < progreso.proximoVistazo) return;
  if (reloj - ojo.ultimoToque < 3 || reloj < ojo.distraidoHasta || ojo.parpadoBase > 0.5) return;
  const punto = frenteAbierto();
  progreso.proximoVistazo = reloj + azar(15, 24);
  if (punto) ojo.vistazo = { punto, hasta: reloj + azar(0.9, 1.3) };
}
function actualizarOjo(dt) {
  actualizarVistazo();
  let objetivo = { x: 0, y: 0 };
  const haciaPunto = p => ({ x: 13.5 * Math.tanh((p.x - OJO.x) / 240), y: 3.4 * Math.tanh((p.y - OJO.y) / 200) });
  // en el nivel 2 vigila la caja pequeña desde que asoma por la trampilla
  const vigilada = estado.nivel === 2 && estado.hija && estado.hija.fase !== 'dentro' && estado.hija.ojo !== 'puesto' && tec.hijaEnBoceto
    ? tec.hijaEnBoceto() : null;
  if (reloj < ojo.distraidoHasta) objetivo = haciaPunto(ojo.distraidoPor || LAMPARA);
  else if (ojo.punto && reloj - ojo.ultimoToque < 2.5) objetivo = haciaPunto(ojo.punto);
  else if (ojo.vistazo && reloj < ojo.vistazo.hasta) objetivo = haciaPunto(ojo.vistazo.punto);
  else if (vigilada) objetivo = haciaPunto(vigilada);
  else {
    if (reloj >= ojo.proximoVagar) {
      ojo.vagar = elegir([null, null, null, { x: 60, y: 260 }, { x: 1000, y: 70 }, { x: 1100, y: 40 }, { x: 1290, y: 560 }, { x: 700, y: 700 }]);
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
// El ojo de piedra de luna mira a su aire (la luna, el rollo, la puerta), casi nunca a ti, y parpadea a destiempo
function actualizarOjo2(dt) {
  if (ojo2.visible <= 0.001 || !nivel2) return;
  const ir = nivel2.iris2;
  if (reloj >= ojo2.proximoVagar) {
    ojo2.punto = elegir([{ x: 1100, y: 40 }, { x: 1250, y: 120 }, { x: 330, y: 160 }, { x: 60, y: 300 }, { x: 960, y: 10 }, { x: 1376, y: 360 }]);
    ojo2.proximoVagar = reloj + azar(2.2, 5.5);
  }
  const p = ojo2.punto || { x: 1100, y: 40 };
  const objetivo = { x: 11.5 * Math.tanh((p.x - ir.cx) / 260), y: 3 * Math.tanh((p.y - ir.cy) / 200) };
  const k = 300, amort = 2 * Math.sqrt(k) * 0.85;
  for (let r = dt; r > 0; r -= 1 / 120) {
    const h = Math.min(r, 1 / 120);
    ojo2.vx += ((objetivo.x - ojo2.ox) * k - ojo2.vx * amort) * h;
    ojo2.vy += ((objetivo.y - ojo2.oy) * k - ojo2.vy * amort) * h;
    ojo2.ox += ojo2.vx * h; ojo2.oy += ojo2.vy * h;
  }
  if (ojo2.parpadoBase < 0.5 && reloj >= ojo2.proximoParpadeo && !ojo2.parpadeo) {
    ojo2.parpadeo = { t: 0, cierre: 0.12, pausa: 0.1, apertura: 0.26 };
    ojo2.proximoParpadeo = reloj + azar(3.5, 8);
  }
  let cierre = 0;
  if (ojo2.parpadeo) {
    const q = ojo2.parpadeo; q.t += dt;
    if (q.t < q.cierre) cierre = q.t / q.cierre;
    else if (q.t < q.cierre + q.pausa) cierre = 1;
    else if (q.t < q.cierre + q.pausa + q.apertura) cierre = 1 - (q.t - q.cierre - q.pausa) / q.apertura;
    else ojo2.parpadeo = null;
  }
  ojo2.cerrado = Math.max(ojo2.parpadoBase, cierre);
}
// Dibuja los ojos en «c», que ya está en coordenadas del boceto: el de siempre y, desde el nivel 2, el de piedra de luna
export function dibujarOjo(c) {
  if (ojo.visible > 0.001 && geoOjo) {
    const v = datos.capas.ojo_vacio, ir = datos.capas.iris;
    pintarOjo(c, geoOjo, ojo, img.ojo_vacio, v, img.iris, ir, OJO, 3.4, 2.8, 1.25);
  }
  if (ojo2.visible > 0.001 && geoOjo2) {
    const ir = nivel2.iris2;
    pintarOjo(c, geoOjo2, ojo2, img.ojo2, geoOjo2.capa, img.iris2, ir, { x: ir.cx, y: ir.cy }, 4.4, 3.6, 1.6);
  }
}
function pintarOjo(c, geo, estadoOjo, imagenVacia, sitio, imagenIris, iris, centro, bx, by, br) {
  c.save();
  c.globalAlpha = estadoOjo.visible;
  c.drawImage(imagenVacia, sitio.x, sitio.y);
  c.save();
  c.clip(geo.almendra);
  c.drawImage(imagenIris, iris.x + estadoOjo.ox, iris.y + estadoOjo.oy);
  c.fillStyle = 'rgba(255, 246, 230, 0.6)';
  c.beginPath(); c.arc(centro.x + estadoOjo.ox - bx, centro.y + estadoOjo.oy - by, br, 0, Math.PI * 2); c.fill();
  c.lineJoin = 'round';
  c.strokeStyle = 'rgba(32, 17, 10, 0.3)'; c.lineWidth = 8; c.stroke(geo.bordeSup);
  c.strokeStyle = 'rgba(32, 17, 10, 0.3)'; c.lineWidth = 3.6; c.stroke(geo.bordeSup);
  c.restore();
  dibujarParpado(c, estadoOjo.cerrado, geo);
  c.restore();
}
function dibujarParpado(c, p, geo) {
  if (p <= 0.015) return;
  const muestras = geo.muestras;
  const borde = muestras.map(m => ({ x: m.x, y: m.s + (m.i - m.s) * p }));
  c.beginPath();
  muestras.forEach((m, i) => (i ? c.lineTo(m.x, m.s - 4.6) : c.moveTo(m.x, m.s - 4.6)));
  for (let i = borde.length - 1; i >= 0; i--) c.lineTo(borde[i].x, borde[i].y);
  c.closePath();
  const [r, g, b] = geo.color;
  const gr = c.createLinearGradient(0, geo.y0, 0, geo.y1);
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
function contenerAliento(segundos = 1.8) {
  if (reloj >= aliento.contenidoHasta) atenuarAmbiente(segundos);
  aliento.contenidoHasta = reloj + segundos;
}
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
      n.vx += empuje * this.rizo * dt - viento.rafaga * 16 * dt;
      apartarDelDedo(n, 55, 1500, dt);
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
// polvo fino que sale de un cajón viejo al abrirlo: poco, del color de la madera, y se posa enseguida
function polvoDeCajon(x, y) {
  for (let i = 0; i < 6; i++) {
    nubes.push({ x: x + azar(-6, 6), y: y + azar(-4, 4), ax: x, ay: y, objeto: 'caja', vx: azar(8, 22), vy: azar(-9, 2),
      r0: azar(2, 3.5), r1: azar(8, 14), t: -i * 0.04, vida: azar(0.7, 1.1), alfa: 0.2, color: '214,196,170' });
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
    : estado.tapa === 'suelta' && tapaVuelo
      ? [new Cinta(533, 458, { ritmo: 14, vida: 5, vel: 22, ancho: 3.4, alfa: 0.42, objeto: 'incensario' }),
         new Cinta(606, 513, { ritmo: 11, vida: 3.6, vel: 16, ancho: 2.6, alfa: 0.3, objeto: 'incensario' })]
      : [new Cinta(531, 462, { ritmo: 14, vida: 5, vel: 22, ancho: 3.4, alfa: 0.42, objeto: 'incensario' })];
}

// ---------------------------------------------------------------------------------------------
// Luz: lámpara andon, brasas, motas de polvo, ojos rojos y la trampilla
// ---------------------------------------------------------------------------------------------
const lampara = { agitadaHasta: 0, fuerza: 0, intensidad: 1, apagada: 0, proxima: 16 };
// en el nivel 2, mientras la caja pequeña está en la mesa sin su ojo, el ojo grande no se deja distraer
const vigilaLaPequena = () => !!(estado.nivel === 2 && estado.hija && estado.hija.fase === 'mesa' && estado.hija.ojo !== 'puesto');
function agitarLampara(segundos, fuerza) { lampara.agitadaHasta = reloj + segundos; lampara.fuerza = fuerza; }
function actualizarLampara() {
  let i = 1 + 0.035 * Math.sin(reloj * 7.3) + 0.025 * Math.sin(reloj * 11.9 + 1) + 0.02 * Math.sin(reloj * 23.1);
  if (reloj < lampara.agitadaHasta) i += lampara.fuerza * (0.55 * Math.sin(reloj * 31) * Math.sin(reloj * 7.7) - 0.15);
  lampara.intensidad = Math.max(0.15, i) * (1 - lampara.apagada);
  // de vez en cuando la llama tiembla sola y el ojo la mira un momento: así se aprende
  if (estado.fase === 'jugando' && reloj >= lampara.proxima) {
    lampara.proxima = reloj + azar(14, 24);
    agitarLampara(0.9, 0.6);
    if (reloj > ojo.distraidoHasta && !vigilaLaPequena()) { ojo.distraidoPor = LAMPARA; ojo.distraidoHasta = reloj + 1.3; }
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
    m.vx -= viento.rafaga * 6 * dt;                                    // la ráfaga entra por el shoji
    apartarDelDedo(m, 80, 1800, dt);
    const lenta = Math.hypot(m.vx, m.vy) > 6 ? 1 - 1.6 * dt : 1;        // lo que el dedo empujó se frena
    m.vx *= lenta; m.vy *= lenta;
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
// La decoración viva: lo que se mueve en la sala aunque no sea del puzle. El viento de fuera mece las sombras del
// bambú en el shoji, el rollo colgado, la llama y el humo; las polillas rondan la lámpara; la tapa de la tetera
// tiembla con el vapor y el té hace ondas cuando algo golpea la mesa. El dedo aparta el polvo, el humo y las polillas.
// Todo en píxeles del boceto: la técnica A lo pinta en sus capas y la B lo ancla en 3D (las sombras del bambú y el
// rollo van en sus paredes, detrás de la caja).
// ---------------------------------------------------------------------------------------------
const VENTANAS = [662, 0, 1376, 470];                    // el shoji con la luna
const ROLLO = { gancho: { x: 326, y: -46 }, rect: [234, 0, 418, 332],
  contorno: [[245, 0], [407, 0], [407, 300], [418, 302], [418, 331], [234, 331], [234, 302], [247, 300]] };
const TAPA_TETERA = { x: 1301, y: 508, rect: [1246, 470, 1356, 524] };
const TAZAS = [{ x: 1190, y: 615, rx: 25, ry: 6.5 }, { x: 1290, y: 631, rx: 25, ry: 6 }];
const viento = { base: 0, rafaga: 0, objetivo: 0, proxima: 40, t: 0 };
const dedo = { x: 0, y: 0, hasta: 0 };
const rollo = { a: 0, v: 0, lift: 0 };
const tetera = { t: 1, duracion: 0.6, fuerza: 1, proxima: 30 };
const ondas = [];
const polillas = [];
// una ráfaga de viento: el bambú se agita, el rollo se mece, la llama tiembla y las polillas se espantan
function soplar(fuerza = 1, conSonido = true) {
  viento.objetivo = Math.min(1.3, viento.objetivo + fuerza);
  if (conSonido) sonar('viento', -13 + 5 * Math.min(1, fuerza), azar(0.9, 1.08));
  agitarLampara(0.9, 0.3 * fuerza);
  rollo.v += (0.035 + 0.03 * fuerza) * (rollo.v >= 0 ? 1 : -1);
  for (const p of polillas) p.susto = Math.max(p.susto, 0.5 * fuerza);
}
// la tapa de la tetera: el vapor la levanta a golpecitos
function vaporTetera(fuerza = 1) {
  tetera.t = 0; tetera.fuerza = fuerza;
  for (let i = 0; i < 3; i++) setTimeoutReloj(i * 0.11, () => sonar('clic_metal', -21 + 3 * fuerza, azar(1.45, 1.8)));
  setTimeoutReloj(0.08, () => bocanada(TAPA_TETERA.x - 8, TAPA_TETERA.y - 10, -0.2, -1, 0.15, 'te'));
}
// ondas en el té: algo ha golpeado la mesa
function agitarTe(fuerza = 1) {
  TAZAS.forEach((_, i) => ondas.push({ i, t: -i * 0.05, f: Math.min(1, fuerza) }));
}
function prepararDecoracion() {
  polillas.length = 0;
  for (let i = 0; i < 3; i++) {
    polillas.push({ x: LAMPARA.x + azar(-40, 40), y: LAMPARA.y + azar(-50, 50), vx: 0, vy: 0, t: azar(0, 9), fase: azar(0, 6),
      giro: azar(1.1, 2) * (i % 2 ? 1 : -1), radio: azar(30, 64), aleteo: azar(0, 6), posada: 0, susto: 0, rumbo: 0 });
  }
  prepararBambu();
}
function actualizarDecoracion(dt) {
  // el viento: un vaivén lento y, de vez en cuando, una ráfaga
  viento.t += dt;
  viento.base = 0.5 + 0.5 * Math.sin(viento.t * 0.23) * Math.sin(viento.t * 0.071 + 1);
  viento.rafaga = mezclar(viento.rafaga, viento.objetivo, 1 - Math.exp(-dt * 3.2));
  viento.objetivo *= Math.exp(-dt * 0.55);
  if (estado.fase === 'jugando' && reloj > viento.proxima) { viento.proxima = reloj + azar(35, 60); soplar(azar(0.35, 0.7)); }
  // el rollo: un péndulo que el aire empuja un poco
  const empuje = (0.004 + 0.01 * viento.base) * Math.sin(viento.t * 0.9) + 0.03 * viento.rafaga * Math.sin(viento.t * 2.1);
  const rigidez = Math.pow(2 * Math.PI / 2.6, 2);
  rollo.v += (-rigidez * rollo.a - 0.55 * rollo.v + empuje) * dt;
  rollo.a += rollo.v * dt;
  rollo.lift = mezclar(rollo.lift, 0.05 * viento.rafaga, 1 - Math.exp(-dt * 2));
  // la tetera
  if (tetera.t < tetera.duracion) tetera.t += dt;
  if (estado.fase === 'jugando' && reloj > tetera.proxima) {
    tetera.proxima = reloj + azar(26, 46); vaporTetera(azar(0.5, 0.8));
    if (reloj > ojo.distraidoHasta && !vigilaLaPequena() && ojo.parpadoBase < 0.5) { ojo.distraidoPor = TAPA_TETERA; ojo.distraidoHasta = reloj + 1.1; }
  }
  for (let i = ondas.length - 1; i >= 0; i--) { ondas[i].t += dt; if (ondas[i].t > 1.5) ondas.splice(i, 1); }
  actualizarPolillas(dt);
  bambuAcum += dt;
  if (bambuAcum >= 1 / 24) { bambuAcum = 0; pintarBambu(); }
}
// el dedo: dónde está (en el boceto) mientras se toca o se arrastra
function moverDedo(p) { if (p) { dedo.x = p.x; dedo.y = p.y; dedo.hasta = reloj + 0.3; } }
// empuja algo que esté cerca del dedo; devuelve si estaba cerca
function apartarDelDedo(o, radio, fuerza, dt) {
  if (reloj >= dedo.hasta) return false;
  const dx = o.x - dedo.x, dy = o.y - dedo.y, d = Math.hypot(dx, dy);
  if (d >= radio) return false;
  const k = (1 - d / radio) * fuerza * dt / (d || 1);
  o.vx += dx * k; o.vy += dy * k;
  return true;
}

// Las polillas: vuelan alrededor de la lámpara, a veces se posan en el papel; el dedo, el viento o la llama las espantan
function actualizarPolillas(dt) {
  const L = LAMPARA, agitada = reloj < lampara.agitadaHasta;
  for (const p of polillas) {
    p.aleteo += dt * (p.posada > 0 ? 2 : 38 + 8 * Math.sin(p.fase));
    if (p.posada > 0) {
      p.posada -= dt;
      if (p.susto > 0.2 || agitada || (reloj < dedo.hasta && Math.hypot(p.x - dedo.x, p.y - dedo.y) < 90)) { p.posada = 0; p.susto = Math.max(p.susto, 0.6); }
      continue;
    }
    p.t += dt;
    let tx = L.x + Math.cos(p.t * p.giro + p.fase) * p.radio, ty = L.y - 14 + Math.sin(p.t * p.giro * 1.3 + p.fase) * p.radio * 0.85;
    if (p.susto > 0) {
      const dx = p.x - L.x, dy = p.y - L.y, d = Math.hypot(dx, dy) || 1;
      tx = L.x + dx / d * 190; ty = L.y + dy / d * 130 - 50;
      p.susto -= dt * 0.45;
    }
    if (apartarDelDedo(p, 95, 2600, dt)) p.susto = Math.max(p.susto, 0.7);
    const k = 16, am = 4.5;
    p.vx += ((tx - p.x) * k - p.vx * am + azar(-1, 1) * 900) * dt;
    p.vy += ((ty - p.y) * k - p.vy * am + azar(-1, 1) * 900) * dt;
    p.x += p.vx * dt; p.y += p.vy * dt;
    p.rumbo = Math.atan2(p.vy, p.vx);
    // a veces se posa en el papel de la lámpara
    if (!agitada && p.susto <= 0 && Math.random() < dt * 0.07 && Math.abs(p.x - L.x) < 48 && p.y > 228 && p.y < 410) {
      p.posada = azar(2.5, 6); p.vx = p.vy = 0; p.rumbo = -Math.PI / 2 + azar(-0.5, 0.5);
    }
  }
}
function dibujarPolillas(c) {
  for (const p of polillas) {
    const ab = p.posada > 0 ? 0.55 + 0.25 * Math.sin(p.aleteo) : 0.25 + 0.75 * Math.abs(Math.sin(p.aleteo));
    c.save(); c.translate(p.x, p.y); c.rotate(p.rumbo); c.scale(1.45, 1.45);
    c.fillStyle = 'rgba(34, 24, 16, 0.82)';
    for (const lado of [-1, 1]) {
      c.beginPath(); c.moveTo(0.8, 0);
      c.quadraticCurveTo(-0.6, lado * 6.2 * ab, -3.8, lado * 4.8 * ab);
      c.quadraticCurveTo(-3, lado * 1.4 * ab, -1.4, 0);
      c.fill();
    }
    c.beginPath(); c.ellipse(-0.8, 0, 2.6, 0.95, 0, 0, Math.PI * 2); c.fill();
    c.restore();
  }
}

// Las sombras del bambú en el shoji: tallos y hojas que el viento mece, en un lienzo a media resolución
let sombrasBambu = null, bambuAcum = 0;
const BAMBU = [
  { x0: 1236, x1: 1306, grueso: 9, fase: 0.3, hojas: [[0.42, -2.6], [0.45, 2.3], [0.62, -2.9], [0.66, 0.4], [0.8, -2.4], [0.83, 0.2], [0.95, -2.8]] },
  { x0: 1334, x1: 1352, grueso: 7, fase: 1.7, hojas: [[0.3, 2.9], [0.5, -0.3], [0.52, 2.6], [0.74, -0.1], [0.76, 2.8], [0.92, 0.3]] },
  { x0: 694, x1: 772, grueso: 6, fase: 2.9, hojas: [[0.55, 0.3], [0.58, -2.7], [0.78, 0.5], [0.8, -2.5], [0.93, 0.1], [0.96, 2.9]] },
];
function prepararBambu() {
  const [x0, y0, x1, y1] = VENTANAS;
  sombrasBambu = document.createElement('canvas');
  sombrasBambu.width = Math.round((x1 - x0) / 3); sombrasBambu.height = Math.round((y1 - y0) / 3);
  sombrasBambu.rect = VENTANAS;
  pintarBambu();
}
function pintarBambu() {
  const k = sombrasBambu.getContext('2d'), [x0, y0, , y1] = VENTANAS, t = viento.t;
  k.setTransform(1, 0, 0, 1, 0, 0); k.clearRect(0, 0, sombrasBambu.width, sombrasBambu.height);
  k.setTransform(1 / 3, 0, 0, 1 / 3, -x0 / 3, -y0 / 3);
  const fuerza = 0.35 + 0.45 * viento.base + 1.4 * viento.rafaga;
  const alto = y1 - y0 + 90;
  for (const b of BAMBU) {
    const vaiven = fuerza * (Math.sin(t * 0.8 + b.fase) * 0.7 + Math.sin(t * 1.9 + b.fase * 2) * 0.3);
    const punto = h => [b.x0 + (b.x1 - b.x0) * h + vaiven * 30 * h * h, y1 + 50 - alto * h];
    // el tallo, con sus nudos
    k.strokeStyle = 'rgba(14, 20, 40, 0.3)'; k.lineCap = 'round'; k.lineWidth = b.grueso;
    k.beginPath();
    for (let h = 0; h <= 1.001; h += 0.05) { const [x, y] = punto(h); h ? k.lineTo(x, y) : k.moveTo(x, y); }
    k.stroke();
    k.strokeStyle = 'rgba(14, 20, 40, 0.36)'; k.lineWidth = b.grueso + 3;
    for (let h = 0.12; h < 1; h += 0.16) {
      const [x, y] = punto(h);
      k.beginPath(); k.moveTo(x - (b.grueso + 2) / 2, y); k.lineTo(x + (b.grueso + 2) / 2, y + 1); k.stroke();
    }
    // las hojas: largas y caídas, aleteando con el aire
    k.fillStyle = 'rgba(14, 20, 40, 0.34)';
    b.hojas.forEach(([h, ang], i) => {
      const [x, y] = punto(h);
      const a = ang + (ang > -1.6 && ang < 1.6 ? 0.35 : -0.35) + (0.1 + 0.3 * fuerza) * Math.sin(t * 2.4 + i * 1.7 + b.fase);
      const largo = 52 + (i % 3) * 10, ancho = 10;
      k.save(); k.translate(x, y); k.rotate(a);
      k.beginPath(); k.moveTo(0, 0);
      k.quadraticCurveTo(largo * 0.45, -ancho, largo, 1.5);
      k.quadraticCurveTo(largo * 0.45, ancho * 0.9, 0, 0);
      k.fill(); k.restore();
    });
  }
  if (opciones3d && opciones3d.alPintarBambu) opciones3d.alPintarBambu();
}

// El rollo colgado (técnica A): su recorte, y la pared de detrás rellenada en la plancha
function prepararRollo() {
  const [x0, y0, x1, y1] = ROLLO.rect;
  const c = document.createElement('canvas'); c.width = x1 - x0; c.height = y1 - y0;
  const k = c.getContext('2d');
  k.beginPath(); ROLLO.contorno.forEach(([x, y], i) => (i ? k.lineTo(x - x0, y - y0) : k.moveTo(x - x0, y - y0))); k.closePath(); k.clip();
  k.drawImage(img.sala, -x0, -y0);
  c.sitio = { x: x0, y: y0 };
  capas2d.rollo = c;
  // su sombra en la pared, oscura y difusa (se hace una vez: el desenfoque es caro en el móvil)
  const so = document.createElement('canvas'); so.width = c.width + 24; so.height = c.height + 24;
  const ks = so.getContext('2d');
  ks.filter = 'blur(3px)'; ks.drawImage(c, 12, 12); ks.filter = 'none';
  ks.globalCompositeOperation = 'source-in'; ks.fillStyle = 'rgb(28, 18, 10)'; ks.fillRect(0, 0, so.width, so.height);
  so.sitio = { x: x0 - 12, y: y0 - 12 };
  capas2d.rolloSombra = so;
  // la pared de detrás: cada fila, del color de la pared a un lado y al otro del rollo
  const pk = planchas.sala.getContext('2d', { willReadFrequently: true }), m = 6;
  const ancho = x1 - x0 + 2 * m, d = pk.getImageData(x0 - m - 8, y0, ancho + 16, y1 - y0 + 6);
  const W = d.width;
  for (let y = 0; y < d.height; y++) {
    const media = xs => { const r = [0, 0, 0]; for (const x of xs) for (let c2 = 0; c2 < 3; c2++) r[c2] += d.data[(y * W + x) * 4 + c2] / xs.length; return r; };
    const izq = media([0, 1, 2, 3, 4, 5]), der = media([W - 6, W - 5, W - 4, W - 3, W - 2, W - 1]);
    for (let x = 8; x < W - 8; x++) {
      const f = (x - 8) / (W - 16), i = (y * W + x) * 4;
      for (let c2 = 0; c2 < 3; c2++) d.data[i + c2] = izq[c2] + (der[c2] - izq[c2]) * f;
    }
  }
  pk.putImageData(d, x0 - m - 8, y0);
}
function dibujarRollo(c) {
  const g = ROLLO.gancho, r = capas2d.rollo;
  if (!r) return;
  // la sombra en la pared (la lámpara está a la derecha) y el rollo, girando desde su gancho
  c.save(); c.translate(g.x, g.y); c.rotate(rollo.a * 0.8); c.scale(1, Math.cos(rollo.lift)); c.translate(-g.x, -g.y);
  const so = capas2d.rolloSombra;
  c.globalAlpha = 0.3; c.drawImage(so, so.sitio.x - 7, so.sitio.y + 3); c.globalAlpha = 1;
  c.restore();
  c.save(); c.translate(g.x, g.y); c.rotate(rollo.a); c.scale(1, Math.cos(rollo.lift)); c.translate(-g.x, -g.y);
  c.drawImage(r, r.sitio.x, r.sitio.y);
  c.restore();
}
// La tapa de la tetera (un recorte que salta un poco) y las ondas del té, en la capa del té
function prepararTapaTetera() {
  const [x0, y0, x1, y1] = TAPA_TETERA.rect;
  const c = document.createElement('canvas'); c.width = x1 - x0; c.height = y1 - y0;
  const k = c.getContext('2d');
  k.beginPath(); k.ellipse(TAPA_TETERA.x - x0, TAPA_TETERA.y - y0, 51, 13, 0, 0, Math.PI * 2);
  k.roundRect(1287 - x0, 474 - y0, 27, 28, 9); k.clip();
  k.drawImage(img.sala, -x0, -y0);
  c.sitio = { x: x0, y: y0 };
  capas2d.tapaTetera = c;
}
function tapaTeteraActiva() { return tetera.t < tetera.duracion; }
function dibujarTapaTetera(c) {
  if (!tapaTeteraActiva() || !capas2d.tapaTetera) return;
  const k = tetera.t / tetera.duracion, f = tetera.fuerza * (1 - k);
  const salto = 2.6 * f * Math.abs(Math.sin(k * Math.PI * 5)), giro = 0.035 * f * Math.sin(k * Math.PI * 7);
  const t = capas2d.tapaTetera, T = TAPA_TETERA;
  // la junta oscura que asoma al levantarse
  c.fillStyle = `rgba(30, 16, 8, ${Math.min(0.7, salto * 0.4)})`;
  c.beginPath(); c.ellipse(T.x, T.y + 3, 48, 9, 0, 0, Math.PI); c.fill();
  c.save(); c.translate(T.x, T.y); c.rotate(giro); c.translate(-T.x, -T.y - salto);
  c.drawImage(t, t.sitio.x, t.sitio.y);
  c.restore();
}
function dibujarOndas(c) {
  for (const o of ondas) {
    if (o.t < 0) continue;
    const z = TAZAS[o.i];
    c.save();
    c.beginPath(); c.ellipse(z.x, z.y, z.rx, z.ry, 0, 0, Math.PI * 2); c.clip();
    for (const desfase of [0, 0.22, 0.44]) {
      const k = (o.t - desfase) / 1.1;
      if (k <= 0 || k >= 1) continue;
      const a = o.f * Math.pow(1 - k, 1.5) * 0.55, r = 0.12 + 0.88 * k;
      c.lineWidth = 0.9;
      c.strokeStyle = `rgba(255, 236, 196, ${a})`;
      c.beginPath(); c.ellipse(z.x, z.y, z.rx * r, z.ry * r, 0, 0, Math.PI * 2); c.stroke();
      c.strokeStyle = `rgba(48, 28, 12, ${a * 0.6})`;
      c.beginPath(); c.ellipse(z.x, z.y + 0.9, z.rx * r, z.ry * r, 0, 0, Math.PI); c.stroke();
    }
    c.restore();
  }
}

// ---------------------------------------------------------------------------------------------
// Los cajones del costado: cerrados al empezar; se abren y se cierran deslizándose. Los que tienen cerradura
// resisten sin moverse, como todo lo bloqueado. Su forma está en metros (capas/cajones.json) y cada técnica la
// dibuja a su manera: A los proyecta en 2D con la cámara del boceto; B y C los mueven en 3D.
// ---------------------------------------------------------------------------------------------
let cajonesDatos = null;
// Cada cajón: cuánto ha salido (k: 0 cerrado … 1 abierto), su velocidad y adónde va. Un muelle lo lleva a su sitio
// (con un rebote al abrirse y un golpe seco al cerrarse); mientras el dedo lo agarra, va donde lo lleve el dedo.
const cajonAnim = Object.fromEntries(Object.keys(CAJONES).map(id => [id, { k: 0, v: 0, objetivo: 0, agarrado: false, golpe: 0 }]));
function actualizarCajones(dt) {
  for (const a of Object.values(cajonAnim)) {
    if (a.agarrado) continue;
    if (Math.abs(a.objetivo - a.k) < 0.0004 && Math.abs(a.v) < 0.004) { a.k = a.objetivo; a.v = 0; continue; }
    for (let r = dt; r > 0; r -= 1 / 120) {
      const h = Math.min(r, 1 / 120), kk = 170, am = 2 * Math.sqrt(kk) * 0.55;
      a.v += ((a.objetivo - a.k) * kk - a.v * am) * h;
      a.k += a.v * h;
      if (a.k < 0) {                                   // el fondo: cierra de golpe, sin rebotar hacia dentro
        if (a.v < -0.7 && reloj > a.golpe) { a.golpe = reloj + 0.25; sonar('tope_madera', -9, 1.15); vibrar(10); agitarTe(0.3); }
        a.k = 0; a.v = 0;
      }
      if (a.k > 1.06) { a.k = 1.06; a.v = Math.min(a.v, 0); }      // el tope de fuera
    }
  }
}
const geometriaCajon = id => cajonesDatos.cajones.find(c => c.id === id);
const aBoceto = ([x, y, z]) => proyectarBoceto(x, y, z);
function centroCajon(id) {
  const p = geometriaCajon(id).poligono;
  return { x: (p[0][0] + p[1][0] + p[2][0] + p[3][0]) / 4, y: (p[0][1] + p[1][1] + p[2][1] + p[3][1]) / 4 };
}
// las esquinas del frente, abierto «s» metros (arriba-delante, arriba-atrás, abajo-atrás, abajo-delante)
function frenteCajon(g, s) {
  const X = cajonesDatos.x + s, [y0, y1] = g.y, [z0, z1] = g.z;
  return [[X, y0, z1], [X, y1, z1], [X, y1, z0], [X, y0, z0]];
}
// su contorno en el boceto según lo abierto que esté (los toques de la técnica A)
function contornoCajon(id) {
  const g = geometriaCajon(id), s = cajonAnim[id].k * cajonesDatos.sale;
  return s < 0.001 ? g.poligono : envolvente([...g.poligono, ...frenteCajon(g, s).map(aBoceto)]);
}
function cajonEn(p) {
  if (!cajonesDatos) return null;
  const orden = Object.keys(CAJONES).sort((a, b) => cajonAnim[b].k - cajonAnim[a].k);
  for (const id of orden) if (dentro(['poli', contornoCajon(id)], p)) return id;
  return null;
}
// dónde está lo que guarda un cajón (en el boceto): cerca de su frente, en el fondo
function puntoDentro(id) {
  const g = geometriaCajon(id), s = cajonAnim[id].k * cajonesDatos.sale;
  return aBoceto([cajonesDatos.x + s - 0.026, (g.y[0] + g.y[1]) / 2, g.z[0] + 0.006]);
}
function textoCajon(id) {
  const def = CAJONES[id];
  if (def.contiene === 'llave') return estado.llave === 'cajon' ? 'Dentro, una llave de bambú diminuta.' : 'El cajón de la llave. Ahora, vacío.';
  if (def.contiene === 'nota') return estado.nota === 'cajon' ? 'Un papel doblado, con letra fina.' : 'Vacío. Aquí estaba la nota.';
  return def.texto;
}
function abrirCajon(id, callado = false, sinSonido = false) {
  const a = cajonAnim[id];
  estado.cajones[id] = 'abierto';
  a.objetivo = 1;
  if (callado) return;
  if (!sinSonido) { sonar('cajon', -5, azar(0.95, 1.06)); vibrar(12); }
  const c = centroCajon(id);
  mirarA(c, 1.6);
  setTimeoutReloj(0.25, () => polvoDeCajon(c.x + 10, c.y + 2));
  setTimeoutReloj(0.35, () => mensaje(textoCajon(id)));
  // si guarda algo, la cámara se asoma para que se vea dentro (la consecuencia siempre se ve)
  const guarda = CAJONES[id].contiene;
  if (guarda && estado[guarda] === 'cajon' && estado.vista === 'cajones' && tec.inclinar) setTimeoutReloj(0.2, () => tec.inclinar(0.12, 0.42));
}
function cerrarCajon(id, sinSonido = false) {
  const a = cajonAnim[id];
  estado.cajones[id] = 'cerrado';
  a.objetivo = 0;
  if (!sinSonido) { sonar('deslizar_madera', -15, 1.3); a.v = Math.min(a.v, -1.2); }
}
// Un toque en un cajón no lo abre: asoma un poco y vuelve, para enseñar que se tira de él (los de cerradura ni eso)
function tocarCajon(id) {
  const def = CAJONES[id];
  if (def.cerradura) {
    const c = centroCajon(id);
    cajonCerrado(id, c.x, c.y, 1, -0.6, 'Tiene una cerradura pequeña. No cede.');
    return;
  }
  const a = cajonAnim[id];
  if (estado.cajones[id] !== 'abierto') {
    a.v += 1.9;
    sentir('holgura', { tono: 1.1 });
    mensaje(primeraVez('tirar') ? 'Tira del cajón hacia fuera: arrastra el dedo.' : 'Tira de él.');
    return;
  }
  if (a.k < 0.7) return;                                // todavía se está abriendo
  if (def.contiene === 'llave' && estado.llave === 'cajon') { tocarLlave(id); return; }
  if (def.contiene === 'nota' && estado.nota === 'cajon') { cogerNota(id); return; }
  a.v -= 1.3;
  mensaje(primeraVez('empujar') ? 'Para cerrarlo, empújalo hacia dentro.' : textoCajon(id));
}
// Al despertar, la caja se sacude y todos sus cajones traquetean
function sacudirCajones() {
  agitarTe(0.8);
  Object.keys(CAJONES).forEach((id, i) => {
    const a = cajonAnim[id];
    setTimeoutReloj(i * 0.07, () => {
      sonar('clic_madera', -14, azar(0.8, 1.2));
      if (!a.agarrado) a.v += a.objetivo > 0.5 ? -1.4 : 2.1;
    });
  });
}
// Técnica A: un cajón abierto, pintado con la cámara del boceto (dentro de la capa de la caja). Las paredes llevan
// la laca pintada de un cajón abierto del boceto original; el interior, la misma laca en sombra.
let lacaSombra = null;
function prepararLaca() {
  const l = img.laca_pared;
  lacaSombra = document.createElement('canvas'); lacaSombra.width = l.width; lacaSombra.height = l.height;
  const k = lacaSombra.getContext('2d');
  k.drawImage(l, 0, 0);
  k.globalCompositeOperation = 'multiply'; k.fillStyle = 'rgb(105, 70, 62)'; k.fillRect(0, 0, l.width, l.height);
}
// pinta una imagen entera dentro de un cuadrilátero [arriba-izq, arriba-der, abajo-der, abajo-izq] (afín)
function pintarCuadro(c, imagen, q) {
  const w = imagen.width, h = imagen.height;
  const ux = (q[1][0] - q[0][0]) / w, uy = (q[1][1] - q[0][1]) / w, vx = (q[3][0] - q[0][0]) / h, vy = (q[3][1] - q[0][1]) / h;
  c.save();
  c.beginPath(); q.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.closePath(); c.clip();
  c.transform(ux, uy, vx, vy, q[0][0], q[0][1]);
  c.drawImage(imagen, -1, -1, w + 2, h + 2);
  c.restore();
}
function dibujarCajon2D(c, id) {
  const k = cajonAnim[id].k;
  if (k < 0.002 || !cajonesDatos) return;
  const g = geometriaCajon(id), s = k * cajonesDatos.sale, X = cajonesDatos.x, t = 0.004;
  const [y0, y1] = g.y, [z0, z1] = g.z;
  const P = (x, y, z) => proyectarBoceto(x, y, z);
  const camino = pts => { c.beginPath(); pts.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.closePath(); };
  const tinta = (pts, a = 0.85, w = 1.1) => { camino(pts); c.strokeStyle = `rgba(28, 14, 8, ${a})`; c.lineWidth = w; c.stroke(); };
  const sombrear = (pts, a, b, desde, hasta) => {
    const gr = c.createLinearGradient(a[0], a[1], b[0], b[1]);
    gr.addColorStop(0, desde); gr.addColorStop(1, hasta);
    camino(pts); c.fillStyle = gr; c.fill();
  };
  // 1. el hueco que deja en el costado
  camino(g.poligono); c.fillStyle = 'rgb(18, 10, 6)'; c.fill();
  // 2. por dentro: el fondo y la pared de atrás, en sombra hacia dentro de la caja
  const xi0 = X - 0.015, xi1 = X + s - t;
  const suelo = [P(xi0, y0 + t, z0 + t), P(xi1, y0 + t, z0 + t), P(xi1, y1 - t, z0 + t), P(xi0, y1 - t, z0 + t)];
  const paredFondo = [P(xi0, y1 - t, z1), P(xi1, y1 - t, z1), P(xi1, y1 - t, z0 + t), P(xi0, y1 - t, z0 + t)];
  // (lo de dentro solo se ve por el hueco o fuera de la caja: se recorta con el contorno del cajón)
  c.save(); camino(contornoCajon(id)); c.clip();
  pintarCuadro(c, lacaSombra, paredFondo);
  pintarCuadro(c, lacaSombra, [suelo[3], suelo[2], suelo[1], suelo[0]]);
  sombrear(paredFondo, P(X - 0.01, y1, z1), P(X + s, y1, z1), 'rgba(12, 6, 4, 0.95)', 'rgba(12, 6, 4, 0.15)');
  sombrear(suelo, P(X - 0.01, y0, z0), P(X + s, y0, z0), 'rgba(12, 6, 4, 0.95)', 'rgba(12, 6, 4, 0.1)');
  c.restore();
  // 3. lo que guarda
  const def = CAJONES[id];
  const dentroDe = (def.contiene === 'llave' && estado.llave === 'cajon') ? 'llave' : (def.contiene === 'nota' && estado.nota === 'cajon') ? 'nota' : null;
  if (dentroDe && k > 0.25) {
    const q = puntoDentro(id), im = img[dentroDe];
    c.save(); c.globalAlpha = Math.min(1, (k - 0.25) / 0.3);
    c.shadowColor = 'rgba(0, 0, 0, 0.55)'; c.shadowBlur = 4; c.shadowOffsetY = 2;
    c.drawImage(im, q[0] - im.width / 2, q[1] - im.height / 2);
    c.restore();
  }
  // 4. la pared que mira a la cámara: laca pintada, más oscura junto a la caja y abajo
  const pared = [P(X - 0.002, y0, z1), P(X + s, y0, z1), P(X + s, y0, z0), P(X - 0.002, y0, z0)];
  pintarCuadro(c, img.laca_pared, pared);
  sombrear(pared, P(X - 0.002, y0, z1), P(X + s, y0, z1), 'rgba(16, 8, 5, 0.6)', 'rgba(16, 8, 5, 0)');
  sombrear(pared, P(X, y0, z1), P(X, y0, z0), 'rgba(255, 210, 160, 0.06)', 'rgba(16, 8, 5, 0.25)');
  tinta(pared, 0.7, 1);
  // el canto de arriba de las paredes, a tinta
  c.beginPath(); const a1 = P(X, y0, z1), a2 = P(X + s, y0, z1), b1 = P(X, y1 - t, z1), b2 = P(X + s, y1 - t, z1);
  c.moveTo(a1[0], a1[1]); c.lineTo(a2[0], a2[1]); c.moveTo(b1[0], b1[1]); c.lineTo(b2[0], b2[1]);
  c.strokeStyle = 'rgba(28, 14, 8, 0.75)'; c.lineWidth = 1; c.stroke();
  // 5. el frente: la misma pintura del boceto, llevada a su sitio con una transformación afín
  const R = g.poligono, M = frenteCajon(g, s).map(aBoceto);
  const u = [R[1][0] - R[0][0], R[1][1] - R[0][1]], v = [R[3][0] - R[0][0], R[3][1] - R[0][1]];
  const u2 = [M[1][0] - M[0][0], M[1][1] - M[0][1]], v2 = [M[3][0] - M[0][0], M[3][1] - M[0][1]];
  const det = u[0] * v[1] - u[1] * v[0];
  const ia = v[1] / det, ib = -u[1] / det, ic = -v[0] / det, id_ = u[0] / det;   // inversa de [u v]
  const L00 = u2[0] * ia + v2[0] * ib, L10 = u2[1] * ia + v2[1] * ib, L01 = u2[0] * ic + v2[0] * id_, L11 = u2[1] * ic + v2[1] * id_;
  const e = M[0][0] - (L00 * R[0][0] + L01 * R[0][1]), f = M[0][1] - (L10 * R[0][0] + L11 * R[0][1]);
  const xs = R.map(q => q[0]), ys = R.map(q => q[1]);
  const bx = Math.floor(Math.min(...xs)) - 2, by = Math.floor(Math.min(...ys)) - 2;
  const bw = Math.ceil(Math.max(...xs)) + 2 - bx, bh = Math.ceil(Math.max(...ys)) + 2 - by;
  c.save();
  camino(M); c.clip();
  c.transform(L00, L10, L01, L11, e, f);
  c.drawImage(compuesto, bx, by, bw, bh, bx, by, bw, bh);
  c.restore();
  tinta(M, 0.8, 1.2);
}
// el orden de dibujo: primero los cajones más lejanos de la cámara del boceto
let ordenCajones = null;
function cajonesPorDistancia() {
  if (ordenCajones) return ordenCajones;
  const C = camaraBoceto.posicion, X = cajonesDatos.x;
  const distancia = id => { const g = geometriaCajon(id); return Math.hypot(X - C[0], (g.y[0] + g.y[1]) / 2 - C[1], (g.z[0] + g.z[1]) / 2 - C[2]); };
  ordenCajones = Object.keys(CAJONES).sort((a, b) => distancia(b) - distancia(a));
  return ordenCajones;
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
// la tapa que se mueve (suelta, levantada o en el aire); suelta, por la rendija se escapa la luz de las brasas
function dibujarTapaVuelo(c) {
  const t = tapaVuelo;
  if (estado.tapa !== 'abierta' && t.rendija > 0) {
    const parpadeo = 0.8 + 0.2 * Math.sin(reloj * 7.3) * Math.sin(reloj * 3.1 + 1), a = t.rendija * parpadeo;
    c.save(); c.globalCompositeOperation = 'lighter';
    c.translate(TAPA_ORIGEN.x + 1, TAPA_ORIGEN.y - 2); c.scale(1, 0.085);
    const g = c.createRadialGradient(0, 0, 0, 0, 0, 46);
    g.addColorStop(0, `rgba(255, 150, 60, ${0.5 * a})`); g.addColorStop(0.6, `rgba(255, 110, 40, ${0.2 * a})`);
    g.addColorStop(1, 'rgba(255, 90, 30, 0)');
    c.fillStyle = g; c.beginPath(); c.arc(0, 0, 46, 0, Math.PI * 2); c.fill();
    c.restore();
  }
  dibujarTapa(c, t.x, t.y, t.ang, t.sx, t.sy);
}
// donde estaba la tapa (y unos píxeles alrededor), la pintura del incensario abierto y sin el cuerno: la boca con
// sus brasas y la pared de detrás. El cuenco se queda como en el boceto (la pintura abierta lo tiñe de rojo)
const bocaLienzos = {};
function bocaSinTapa(c) {
  const t = datos.capas.tapa, v = datos.capas.incensario_vacio, m = 4, w = t.w + 2 * m, h = t.h + 2 * m;
  if (!bocaLienzos.boca) {
    for (const n of ['boca', 'mascara']) { bocaLienzos[n] = document.createElement('canvas'); bocaLienzos[n].width = w; bocaLienzos[n].height = h; }
    const k = bocaLienzos.mascara.getContext('2d');
    for (const [dx, dy] of [[0, 0], [-m, 0], [m, 0], [0, -m], [0, m], [-3, -3], [3, -3], [-3, 3], [3, 3]]) k.drawImage(img.tapa, m + dx, m + dy);
    const b = bocaLienzos.boca.getContext('2d');
    b.drawImage(img.incensario_vacio, v.x - (t.x - m), v.y - (t.y - m));
    b.globalCompositeOperation = 'destination-in';
    b.drawImage(bocaLienzos.mascara, 0, 0);
    b.globalCompositeOperation = 'source-over';
  }
  c.drawImage(bocaLienzos.boca, t.x - m, t.y - m);
}
const tapaSuelta = () => ({ x: TAPA_SUELTA.x, y: TAPA_SUELTA.y, ang: TAPA_SUELTA.ang, sx: 1, sy: 1, rendija: 1 });
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
// La forma de verdad de la tetera y las tazas: la silueta sacada de la pintura incluye trozos de mesa, que al moverse
// la cámara se veían como rectángulos pegados. Se recorta con esto (en píxeles del boceto), un poco más ancho.
const FORMAS_TE = {
  polis: [
    [[1151, 610], [1158, 602], [1190, 598], [1222, 602], [1230, 610], [1224, 640], [1212, 665], [1190, 673], [1168, 665], [1157, 640]],
    [[1246, 626], [1253, 618], [1287, 614], [1320, 618], [1327, 626], [1321, 655], [1310, 681], [1287, 690], [1265, 681], [1253, 655]],
    [[1203, 512], [1226, 505], [1250, 524], [1260, 590], [1243, 575], [1214, 535]],
    [[1333, 520], [1376, 510], [1376, 607], [1337, 600]],
  ],
  elipses: [[1297, 556, 80, 62], [1302, 487, 16, 14]],
};
function mascaraTe(dx = 0, dy = 0, ancho = ANCHO, alto = ALTO) {
  const m = document.createElement('canvas'); m.width = ancho; m.height = alto;
  const k = m.getContext('2d');
  k.translate(-dx, -dy); k.fillStyle = '#fff'; k.strokeStyle = '#fff'; k.lineWidth = 3; k.lineJoin = 'round';
  for (const poli of FORMAS_TE.polis) {
    k.beginPath(); poli.forEach(([x, y], i) => (i ? k.lineTo(x, y) : k.moveTo(x, y))); k.closePath(); k.fill(); k.stroke();
  }
  for (const [x, y, rx, ry] of FORMAS_TE.elipses) { k.beginPath(); k.ellipse(x, y, rx + 1.5, ry + 1.5, 0, 0, Math.PI * 2); k.fill(); }
  return m;
}
// su sombra en la mesa (técnica A; la B pone la suya en 3D)
function sombrasTe(c) {
  for (const [x, y, rx, ry, a] of [[1190, 668, 34, 8, 0.5], [1289, 684, 34, 8, 0.5], [1300, 612, 76, 13, 0.45]]) {
    c.save(); c.translate(x, y); c.scale(1, ry / rx);
    const g = c.createRadialGradient(0, 0, 0, 0, 0, rx);
    g.addColorStop(0, `rgba(12, 6, 3, ${a})`); g.addColorStop(0.6, `rgba(12, 6, 3, ${a * 0.45})`); g.addColorStop(1, 'rgba(12, 6, 3, 0)');
    c.fillStyle = g; c.fillRect(-rx, -rx, rx * 2, rx * 2); c.restore();
  }
}
function recortarTe(lienzo, dx = 0, dy = 0) {
  const k = lienzo.getContext('2d');
  k.globalCompositeOperation = 'destination-in';
  k.drawImage(mascaraTe(dx, dy, lienzo.width, lienzo.height), 0, 0);
  k.globalCompositeOperation = 'source-over';
}
let alHornear = [];     // las técnicas 3D se apuntan para actualizar sus texturas
function hornear() {
  const c = compuesto.getContext('2d');
  c.clearRect(0, 0, ANCHO, ALTO);
  c.drawImage(img.sala, 0, 0);
  if (estado.tapa === 'abierta') pintarCapa(c, estado.cuerno === 'brasas' ? 'incensario_abierto' : 'incensario_vacio');
  // suelta, la tapa se dibuja aparte (entreabierta); debajo, la boca sin el cuerno, que aún no se ve
  else if (tapaVuelo) bocaSinTapa(c);
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
function envolvente(puntos) {
  const p = puntos.slice().sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const cruz = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const abajo = [], arriba = [];
  for (const q of p) { while (abajo.length >= 2 && cruz(abajo[abajo.length - 2], abajo[abajo.length - 1], q) <= 0) abajo.pop(); abajo.push(q); }
  for (const q of p.reverse()) { while (arriba.length >= 2 && cruz(arriba[arriba.length - 2], arriba[arriba.length - 1], q) <= 0) arriba.pop(); arriba.push(q); }
  return abajo.slice(0, -1).concat(arriba.slice(0, -1));
}
function rellenarEnvolvente(k, puntos) {
  const h = envolvente(puntos);
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
  recortarTe(capas2d.te, capas2d.te.sitio.x, capas2d.te.sitio.y);
  recortar(capas2d.cajaDetras = document.createElement('canvas'), img.sala_detras, 'silueta_caja_detras');
  prepararRollo(); prepararTapaTetera();
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
  zoom: 1, zoomObjetivo: 1,                                           // pellizcar acerca o aleja (más de 1, más cerca)
  foco: { x: 0, y: 0 }, focoObjetivo: { x: 0, y: 0 },                 // y lleva el centro hacia los dedos
  camDibujo: { cx: ANCHO / 2, cy: ALTO / 2, s: 1 },
  activar() { lienzo3d.hidden = true; lienzo.classList.remove('encima'); this.transicion = null; Object.assign(this.cam, this.camaraDe(estado.vista)); },
  desactivar() {},
  medir() {},
  camaraDe(nombre, extra = 1, foco = null) {
    const v = VISTAS[nombre];
    const [x0, y0, x1, y1] = alto > ancho * 1.05 ? v.v : v.h;
    const s = Math.min(ancho / (x1 - x0), alto / (y1 - y0)) * extra;
    let cx = (x0 + x1) / 2 + (foco ? foco.x : 0), cy = (y0 + y1) / 2 + (foco ? foco.y : 0);
    const mx = ancho / (2 * s), my = alto / (2 * s);
    cx = 2 * mx >= ANCHO ? ANCHO / 2 : limitar(cx, mx, ANCHO - mx);
    cy = 2 * my >= ALTO ? ALTO / 2 : limitar(cy, my, ALTO - my);
    return { cx, cy, s };
  },
  irA(nombre, duracion = 0.75) {
    this.transicion = { desde: { ...this.cam }, t: 0, duracion };
    // al cambiar de vista la cámara vuelve a su sitio poco a poco (la transición ya sale de lo que se ve)
    this.mirada.objetivoX = 0; this.mirada.objetivoY = 0;
    this.zoom = this.zoomObjetivo = 1; this.foco = { x: 0, y: 0 }; this.focoObjetivo = { x: 0, y: 0 };
  },
  empezar(duracion) {
    this.transicion = { desde: { ...this.cam, s: this.cam.s * 1.07 }, t: 0, duracion };
  },
  actualizar(dt) {
    const e = 1 - Math.exp(-dt * 20);
    this.zoom = mezclar(this.zoom, this.zoomObjetivo, e);
    this.foco.x = mezclar(this.foco.x, this.focoObjetivo.x, e); this.foco.y = mezclar(this.foco.y, this.focoObjetivo.y, e);
    const destino = this.camaraDe(estado.vista, this.zoom, this.foco);
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
  // pellizcar: el punto que había bajo los dedos (m0) queda bajo ellos (m1). En la sala no se aleja más que el boceto.
  // Devuelve 'fuera' o 'dentro' si se ha querido pasar del margen (como la B)
  pellizcar(r, m0, m1) {
    if (this.transicion) return null;
    const l = estado.vista === 'sala' ? [1, 2.2] : [0.8, 2.2];
    m0 = m0 || { x: ancho / 2, y: alto / 2 }; m1 = m1 || m0;
    const pedido = this.zoomObjetivo * r, z1 = limitar(pedido, l[0], l[1]);
    const antes = this.camaraDe(estado.vista, this.zoomObjetivo, this.focoObjetivo);
    const bx = antes.cx + (m0.x - ancho / 2) / antes.s, by = antes.cy + (m0.y - alto / 2) / antes.s;
    const v = VISTAS[estado.vista], [x0, y0, x1, y1] = alto > ancho * 1.05 ? v.v : v.h, vx = (x0 + x1) / 2, vy = (y0 + y1) / 2;
    const s1 = this.camaraDe(estado.vista, z1).s;
    // el foco se guarda ya ajustado a los bordes de la ilustración
    const ajustada = this.camaraDe(estado.vista, z1, { x: bx - (m1.x - ancho / 2) / s1 - vx, y: by - (m1.y - alto / 2) / s1 - vy });
    this.zoomObjetivo = z1;
    this.focoObjetivo = { x: ajustada.cx - vx, y: ajustada.cy - vy };
    return pedido > l[1] + 1e-4 ? 'dentro' : pedido < l[0] - 1e-4 ? 'fuera' : null;
  },
  lupa() { return 1 / this.zoomObjetivo; },
  reiniciar() {
    this.giro = this.giroObjetivo = 0; this.zoomObjetivo = 1; this.focoObjetivo = { x: 0, y: 0 };
    Object.assign(this.mirada, { objetivoX: 0, objetivoY: 0 });
  },
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
    const cajon = cara === 'frente' ? cajonEn(enCaja) : null;
    if (cajon) return { ...enCaja, cara, cajon };
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
    // 1b. lo que vive en las paredes: las sombras del bambú en el shoji y el rollo colgado
    const dp = this.paralaje(this.profundidadFila(p.sala, 160)), [vx0, vy0, vx1, vy1] = VENTANAS;
    c.save(); c.translate(dp.x, dp.y);
    c.drawImage(sombrasBambu, vx0, vy0, vx1 - vx0, vy1 - vy0);
    dibujarRollo(c);
    c.restore();
    // 2. la mesa, también por franjas (el borde de delante está más cerca que el del fondo)
    const m = capas2d.mesa;
    this.porFranjas(c, m, m.franja[0], m.franja[1], y => this.profundidadFila(p.mesa, y), m.sitio, true);
    // 3. lo que hay en la mesa y la tapa del incensario
    const di = this.paralaje(p.incensario), dt_ = this.paralaje(p.te);
    c.save(); c.translate(dt_.x, dt_.y); sombrasTe(c); c.drawImage(capas2d.te, capas2d.te.sitio.x, capas2d.te.sitio.y);
    dibujarTapaTetera(c); dibujarOndas(c);
    dibujarHumo(c, 'te'); c.restore();
    c.save(); c.translate(di.x, di.y);
    c.drawImage(capas2d.incensario, capas2d.incensario.sitio.x, capas2d.incensario.sitio.y);
    if (estado.tapaEnMesa) tapaEnLaMesa(c);
    if (tapaVuelo) dibujarTapaVuelo(c);
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
    c.globalCompositeOperation = 'source-over'; dibujarPolillas(c);
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
    if (frente && cajonesDatos) for (const id of cajonesPorDistancia()) dibujarCajon2D(c, id);
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
  c.save(); c.globalAlpha = 1 - (llaveGirando.desvanece || 0);
  c.translate(CERRADURA.x, CERRADURA.y); c.rotate((llaveGirando.sentido || -1) * 1.2 * k + (llaveGirando.holgura || 0)); c.scale(0.8, 0.8 - 0.35 * k);
  c.drawImage(img.llave, -d.w / 2, -d.h / 2);
  c.restore();
}
function dibujarVueloEnCaja() {}

// ---------------------------------------------------------------------------------------------
// Cámara: sacudida común
// ---------------------------------------------------------------------------------------------
const sacudida = { fuerza: 0, hasta: 0 };
function sacudir(fuerza, duracion) { sacudida.fuerza = fuerza / duracion; sacudida.hasta = reloj + duracion; agitarTe(Math.min(1, fuerza / 5)); }

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
  $('juego').classList.toggle('mensaje-al-lado', nombre === 'hija' || nombre === 'cajones');
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
    if (tapaVuelo) conAncla(TAPA_ORIGEN.x, TAPA_ORIGEN.y, 'incensario', () => dibujarTapaVuelo(ctx));
  }
  if (llaveGirando) conAncla(CERRADURA.x, CERRADURA.y, 'incensario', () => dibujarLlaveGirando(ctx));
  c.setTransform(ppp, 0, 0, ppp, 0, 0);
  if (tapaTeteraActiva() || ondas.length) conAncla(TAPA_TETERA.x, TAPA_TETERA.y, 'te', () => { dibujarTapaTetera(ctx); dibujarOndas(ctx); });
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
  conAncla(LAMPARA.x, LAMPARA.y, 'sala', () => dibujarPolillas(ctx));
}

// ---------------------------------------------------------------------------------------------
// Vuelos: lo que se coge va al inventario, y lo que se usa sale de él
// ---------------------------------------------------------------------------------------------
const vuelos = [];
function volar(o) { return new Promise(ok => vuelos.push({ ...o, t: 0, ok })); }
// ---------------------------------------------------------------------------------------------
// El inventario: una bandeja lacada con cuatro huecos. Tocar un objeto lo elige y dice su nombre; tocarlo otra
// vez (o mantenerlo) lo examina en grande; arrastrarlo lo usa donde se suelte.
// ---------------------------------------------------------------------------------------------
const ICONO_NOTA = 'data:image/svg+xml,' + encodeURIComponent(
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><defs><linearGradient id="p" x1="0" y1="0" x2="1" y2="1">' +
  '<stop offset="0" stop-color="#f4ead6"/><stop offset="1" stop-color="#d9c8a6"/></linearGradient></defs>' +
  '<path d="M10 18 L44 10 L54 44 L20 54 Z" fill="url(#p)" stroke="#3a2618" stroke-width="2" stroke-linejoin="round"/>' +
  '<path d="M27 14 L37 49" stroke="#b9a47e" stroke-width="1.6"/><path d="M15 26 L29 23 M16 32 L30 29 M18 38 L31 35 M33 22 L44 19 M35 28 L46 25" ' +
  'stroke="#5a4330" stroke-width="1.6" stroke-linecap="round"/><circle cx="45" cy="40" r="4.5" fill="#b8442d"/></svg>');
const OBJETOS = {
  llave: { nombre: 'Llave de bambú', texto: 'Diminuta, tallada en una caña. Huele a incienso.', icono: 'capas/llave.webp', capa: 'llave' },
  nota: { nombre: 'Nota doblada', texto: '«Me falta un cuerno. Lo guarda el león que respira humo.»', icono: ICONO_NOTA, capa: 'nota' },
  cuerno: { nombre: 'Cuerno de marfil', texto: 'Todavía está tibio. Le falta su sitio.', icono: 'capas/cuerno.webp', capa: 'cuerno' },
  cajita: { nombre: 'Cajita de laca roja', texto: 'Cabe en la palma. En la tapa, un ojo cerrado entre olas.', icono: 'capas/cajita.webp', capa: 'cajita' },
  ojo: { nombre: 'Ojo de piedra de luna', texto: 'Frío y muy claro. Parece que mira hacia otro lado.', icono: '', capa: 'ojo_luna' },
};
const huecosBandeja = () => [...el.bandeja.querySelectorAll('.hueco')];
const huecoDe = objeto => huecosBandeja().find(h => h.dataset.objeto === objeto) || null;
function pintarInventario() {
  huecosBandeja().forEach((h, i) => {
    const id = estado.inventario[i] || '';
    h.dataset.objeto = id;
    if (id) h.id = 'hueco-' + id; else h.removeAttribute('id');
    h.classList.toggle('vacio', !id);
    h.classList.toggle('elegido', !!id && estado.seleccion === id);
    h.setAttribute('aria-label', id ? OBJETOS[id].nombre : 'Hueco vacío');
    h.tabIndex = id ? 0 : -1;
    const imagen = h.querySelector('img');
    if (id) { if (imagen.getAttribute('src') !== OBJETOS[id].icono) imagen.src = OBJETOS[id].icono; imagen.hidden = false; }
    else { imagen.hidden = true; imagen.removeAttribute('src'); imagen.style.opacity = ''; }
  });
}
let etiquetaHasta = 0;
function mostrarEtiqueta(objeto) {
  const h = huecoDe(objeto);
  if (!h) return;
  el.etiqueta.textContent = OBJETOS[objeto].nombre;
  const r = h.getBoundingClientRect(), j = $('juego').getBoundingClientRect();
  el.etiqueta.style.setProperty('--y', (r.top - j.top + r.height / 2) + 'px');
  el.etiqueta.style.setProperty('--x', (r.left - j.left + r.width / 2) + 'px');
  el.etiqueta.classList.add('visible');
  etiquetaHasta = reloj + 2;
}
function rectHueco(objeto) {
  const h = huecoDe(objeto) || huecosBandeja()[0];
  const r = h.getBoundingClientRect(), l = lienzo.getBoundingClientRect();
  return { x: r.left - l.left + r.width / 2, y: r.top - l.top + r.height / 2 };
}
async function alInventario(objeto, capa, ancla = 'caja', desdePunto = null) {
  const d = datos.capas[capa];
  if (!estado.inventario.includes(objeto)) estado.inventario.push(objeto);
  pintarInventario();
  const hueco = huecoDe(objeto), imagen = hueco.querySelector('img');
  imagen.style.opacity = 0;
  const centro = desdePunto || { x: d.x + d.w / 2, y: d.y + d.h / 2 };
  const pantalla = () => {
    if (centro.enPantalla) return centro;
    const m = tec.ancla(centro, ancla); return m || { x: ancho / 2, y: alto / 2, k: 1 };
  };
  await volar({ imagen: img[capa], w: d.w, h: d.h, desde: pantalla, hacia: () => rectHueco(objeto),
    sDesde: () => pantalla().k, sHacia: () => 40 / Math.max(d.w, d.h), duracion: 0.75, arco: 70 });
  imagen.style.opacity = 1;
  hueco.classList.remove('llega'); void hueco.offsetWidth; hueco.classList.add('llega');
  el.bandeja.classList.remove('brilla'); void el.bandeja.offsetWidth; el.bandeja.classList.add('brilla');
  sonar('clic_madera', -10, 1.35);
  mostrarEtiqueta(objeto);
}
async function desdeInventario(objeto, capa, destino, ancla, desde = null) {
  const d = datos.capas[capa];
  const inicio = desde || rectHueco(objeto);
  estado.inventario = estado.inventario.filter(o => o !== objeto);
  pintarInventario();
  const pantalla = () => { const m = tec.ancla(destino, ancla); return m || { x: ancho / 2, y: alto / 2, k: 1 }; };
  await volar({ imagen: img[capa], w: d.w, h: d.h, desde: () => inicio, hacia: pantalla,
    sDesde: () => 40 / Math.max(d.w, d.h), sHacia: () => pantalla().k, duracion: 0.7, arco: 50 });
}
function examinar(objeto) {
  if (objeto === 'nota') { leerNota(); return; }
  const o = OBJETOS[objeto];
  el.examinarImg.src = o.icono; el.examinarNombre.textContent = o.nombre; el.examinarTexto.textContent = o.texto;
  const bolsilloSi = objeto === 'cajita' && estado.hija && estado.hija.ojo === 'cajita';
  el.examinarImg.hidden = bolsilloSi; el.bolsillo.hidden = !bolsilloSi;
  el.bolsillo.parentElement.classList.toggle('grande', bolsilloSi);
  el.examinarAyuda.textContent = bolsilloSi ? 'Gira la tapa con el dedo · toca fuera para guardarla' : 'Toca para guardarlo';
  if (bolsilloSi) abrirBolsillo();
  // lo de detrás no se lee a través del velo
  el.mensaje.classList.remove('visible'); mensajeHasta = 0;
  el.etiqueta.classList.remove('visible'); etiquetaHasta = 0;
  el.examinar.hidden = false;
  requestAnimationFrame(() => el.examinar.classList.remove('oculta'));
  sonar('recoger', -16, 1.25);
}
let toqueEnExaminar = false;
function cerrarExaminar() {
  if (el.examinar.hidden) return;
  el.examinar.classList.add('oculta');
  bolsillo.activo = false;
  setTimeout(() => { el.examinar.hidden = true; }, 500);
}
el.examinar.addEventListener('pointerdown', e => { if (!el.bolsillo.contains(e.target)) toqueEnExaminar = true; });
el.examinar.addEventListener('pointerup', () => { if (toqueEnExaminar) cerrarExaminar(); toqueEnExaminar = false; });

// ---------------------------------------------------------------------------------------------
// El ojo de piedra de luna: una esfera clara con el iris a tinta, como el de la pintura (sala_dos_ojos.jpg). Se dibuja a
// cualquier tamaño: en la cajita, en la bandeja y en el vuelo hasta la cuenca. «mx, my» (−1…1) es adónde mira.
// ---------------------------------------------------------------------------------------------
function pintarOjoLuna(c, x, y, r, mx = 0, my = 0) {
  c.save();
  const esfera = c.createRadialGradient(x - r * 0.35, y - r * 0.4, r * 0.08, x, y, r);
  esfera.addColorStop(0, '#f7f9fb'); esfera.addColorStop(0.55, '#dae3eb'); esfera.addColorStop(1, '#8a99a9');
  c.fillStyle = esfera; c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.fill();
  c.save();
  c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.clip();
  const lejos = Math.min(1, Math.hypot(mx, my)), ang = Math.atan2(my, mx), ir = r * 0.44;
  c.translate(x + mx * r * 0.4, y + my * r * 0.4);
  c.rotate(ang); c.scale(1 - 0.3 * lejos, 1); c.rotate(-ang);           // el iris se aplasta hacia el canto
  const iris = c.createRadialGradient(0, 0, ir * 0.15, 0, 0, ir);
  iris.addColorStop(0, '#d2e0ec'); iris.addColorStop(0.7, '#adc3d8'); iris.addColorStop(1, '#7d95ae');
  c.fillStyle = iris; c.beginPath(); c.arc(0, 0, ir, 0, Math.PI * 2); c.fill();
  c.strokeStyle = 'rgba(64, 90, 122, 0.28)'; c.lineWidth = Math.max(0.6, r * 0.014);
  for (let i = 0; i < 28; i++) {
    const a = i / 28 * Math.PI * 2;
    c.beginPath(); c.moveTo(Math.cos(a) * ir * 0.36, Math.sin(a) * ir * 0.36); c.lineTo(Math.cos(a) * ir * 0.9, Math.sin(a) * ir * 0.9); c.stroke();
  }
  c.strokeStyle = '#1b2530'; c.lineWidth = Math.max(1, r * 0.05);
  c.beginPath(); c.arc(0, 0, ir, 0, Math.PI * 2); c.stroke();
  c.fillStyle = '#8d959e'; c.beginPath(); c.arc(0, 0, ir * 0.3, 0, Math.PI * 2); c.fill();
  c.strokeStyle = 'rgba(38, 46, 56, 0.85)'; c.lineWidth = Math.max(0.8, r * 0.026); c.stroke();
  c.restore();
  const canto = c.createRadialGradient(x, y, r * 0.62, x, y, r);
  canto.addColorStop(0, 'rgba(20, 30, 45, 0)'); canto.addColorStop(1, 'rgba(20, 30, 45, 0.38)');
  c.fillStyle = canto; c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.fill();
  c.fillStyle = 'rgba(255, 255, 255, 0.85)';
  c.beginPath(); c.ellipse(x - r * 0.38, y - r * 0.42, r * 0.17, r * 0.1, -0.6, 0, Math.PI * 2); c.fill();
  c.strokeStyle = 'rgba(22, 16, 12, 0.92)'; c.lineWidth = Math.max(1, r * 0.045);
  c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.stroke();
  c.restore();
}
// su imagen para la bandeja y los vuelos
function prepararOjoLuna() {
  const c = document.createElement('canvas'); c.width = c.height = 128;
  pintarOjoLuna(c.getContext('2d'), 64, 64, 58, 0.5, -0.25);
  img.ojo_luna = c;
  OBJETOS.ojo.icono = c.toDataURL('image/png');
  datos.capas.ojo_luna = { x: CUENCA.x - 20, y: CUENCA.y - 20, w: 40, h: 40 };   // en la cuenca, del tamaño del ojo
  datos.capas.cajita = { x: 0, y: 0, w: 58, h: 58 };                              // sale de la caja hija (punto 3D)
}

// ---------------------------------------------------------------------------------------------
// El puzle de bolsillo (nivel 2): la cajita roja en la mano. Su tapa gira con el dedo, a saltos de 30° con un clic en
// cada uno, y solo se suelta cuando su marca dorada toca la del borde. Dentro está el ojo, que no te mira: aparta la
// vista de tu dedo.
// ---------------------------------------------------------------------------------------------
const bolsillo = { activo: false, angulo: 0, objetivo: 0, v: 0, arrastre: null, encajada: false, abierta: 0, brillo: 0,
  dedo: null, mirada: { x: 0, y: 0 }, ultimoSalto: 0 };
const normalizarAngulo = a => Math.atan2(Math.sin(a), Math.cos(a));
const tapaEncaja = a => Math.abs(normalizarAngulo(a - MARCA_BORDE)) < PASO_TAPA * 0.3;
function abrirBolsillo() {
  bolsillo.activo = true;
  if (!bolsillo.encajada) {
    bolsillo.angulo = bolsillo.objetivo = bolsillo.inicio ?? (bolsillo.inicio = MARCA_BORDE + 5 * PASO_TAPA);
    bolsillo.ultimoSalto = Math.round(bolsillo.angulo / PASO_TAPA);
  }
  medirBolsillo();
}
function medirBolsillo() {
  const r = el.bolsillo.getBoundingClientRect(), p = Math.min(window.devicePixelRatio || 1, 2);
  const lado = Math.max(1, Math.round((r.width || 260) * p));
  if (el.bolsillo.width !== lado) { el.bolsillo.width = lado; el.bolsillo.height = lado; }
}
function puntoBolsillo(e) {
  const r = el.bolsillo.getBoundingClientRect();
  return { x: (e.clientX - r.left) / r.width * 2 - 1, y: (e.clientY - r.top) / r.height * 2 - 1 };
}
el.bolsillo.addEventListener('pointerdown', e => {
  e.stopPropagation();
  if (!bolsillo.activo) return;
  el.bolsillo.setPointerCapture(e.pointerId);
  const q = puntoBolsillo(e);
  bolsillo.dedo = q;
  bolsillo.arrastre = { id: e.pointerId, a0: Math.atan2(q.y, q.x), angulo0: bolsillo.angulo, movido: 0, x0: q.x, y0: q.y };
});
el.bolsillo.addEventListener('pointermove', e => {
  const q = puntoBolsillo(e);
  bolsillo.dedo = q;
  const a = bolsillo.arrastre;
  if (!a || e.pointerId !== a.id || bolsillo.encajada) return;
  a.movido = Math.max(a.movido, Math.hypot(q.x - a.x0, q.y - a.y0));
  if (Math.hypot(q.x, q.y) < 0.12) return;                  // en el centro no se sabe hacia dónde gira
  const d = normalizarAngulo(Math.atan2(q.y, q.x) - a.a0);
  bolsillo.angulo = a.angulo0 + d;
  bolsillo.objetivo = bolsillo.angulo;
  const salto = Math.round(bolsillo.angulo / PASO_TAPA);
  if (salto !== bolsillo.ultimoSalto) { bolsillo.ultimoSalto = salto; sonar('clic_madera', -16, 1.9); vibrar(6); }
});
function soltarTapa(e) {
  const a = bolsillo.arrastre;
  if (!a || e.pointerId !== a.id) return;
  bolsillo.arrastre = null;
  // un toque sobre el ojo, con la tapa ya fuera, lo coge
  if (bolsillo.abierta > 0.95 && a.movido < 0.08 && Math.hypot(a.x0, a.y0) < 0.45) { tomarOjoLuna(); return; }
  if (bolsillo.encajada) return;
  bolsillo.objetivo = Math.round(bolsillo.angulo / PASO_TAPA) * PASO_TAPA;
  if (tapaEncaja(bolsillo.objetivo)) encajarTapa();
}
el.bolsillo.addEventListener('pointerup', e => { e.stopPropagation(); soltarTapa(e); });
el.bolsillo.addEventListener('pointercancel', soltarTapa);
el.bolsillo.addEventListener('keydown', e => {
  if (!bolsillo.activo) return;
  if (bolsillo.abierta > 0.95 && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); tomarOjoLuna(); return; }
  if (bolsillo.encajada || (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight')) return;
  e.preventDefault();
  bolsillo.objetivo += e.key === 'ArrowRight' ? PASO_TAPA : -PASO_TAPA;
  sonar('clic_madera', -16, 1.9);
  if (tapaEncaja(bolsillo.objetivo)) encajarTapa();
});
async function encajarTapa() {
  bolsillo.encajada = true;
  sentir('clac', { tono: 1.2 });                     // posición correcta
  bolsillo.brillo = 1;
  await esperar(0.45);
  sentir('pestillo', { tono: 1.3 });                 // dentro, el pestillo de la tapa se retira
  el.examinarTexto.textContent = 'La tapa se suelta…';
  await animarPromesa(0.9, k => { bolsillo.abierta = salida(k); });
  sonar('cristal', -8, 1.3);
  el.examinarNombre.textContent = 'Un ojo de piedra de luna';
  el.examinarTexto.textContent = 'Frío y muy claro. No te mira: aparta la vista de tu dedo.';
  el.examinarAyuda.textContent = 'Toca el ojo para cogerlo';
}
async function tomarOjoLuna() {
  const h2 = estado.hija;
  if (!h2 || h2.ojo !== 'cajita') return;
  h2.ojo = 'mano'; h2.cajita = 'abierta';
  const r = el.bolsillo.getBoundingClientRect(), l = lienzo.getBoundingClientRect();
  const desde = { x: r.left - l.left + r.width / 2, y: r.top - l.top + r.height / 2, k: r.width * 0.36 / 40, enPantalla: true };
  cerrarExaminar();
  estado.inventario = estado.inventario.filter(o => o !== 'cajita');
  if (estado.seleccion === 'cajita') estado.seleccion = null;
  pintarInventario();
  sonar('recoger', -4, 1.2);
  await alInventario('ojo', 'ojo_luna', 'caja', desde);
  // la cámara se vuelve hacia la cara grande (de cerca de la caja pequeña, en vertical, la cuenca queda fuera)
  if (estado.fase === 'jugando' && !estado.ocupado) irA('cara', 1.1);
  mensaje('El ojo de piedra de luna. A la cara grande le falta uno.');
}
function dibujarBolsillo(dt) {
  if (!bolsillo.activo || el.examinar.hidden) return;
  medirBolsillo();
  // la tapa se asienta en su salto con un muelle
  if (!bolsillo.arrastre) {
    const k = 120, am = 2 * Math.sqrt(k) * 0.7;
    bolsillo.v += ((bolsillo.objetivo - bolsillo.angulo) * k - bolsillo.v * am) * dt;
    bolsillo.angulo += bolsillo.v * dt;
  } else bolsillo.v = 0;
  bolsillo.brillo = Math.max(0, bolsillo.brillo - dt * 0.9);
  const c = el.bolsillo.getContext('2d'), W = el.bolsillo.width, x = W / 2, y = W / 2, R = W * 0.38;
  c.setTransform(1, 0, 0, 1, 0, 0);
  c.clearRect(0, 0, W, W);
  // el fondo de la cajita: laca más oscura, algo mayor que la tapa, con su marca dorada arriba
  const base = c.createRadialGradient(x, y - R * 0.3, R * 0.2, x, y, R * 1.12);
  base.addColorStop(0, '#7a1a0c'); base.addColorStop(1, '#3a0905');
  c.fillStyle = base; c.beginPath(); c.arc(x, y, R * 1.1, 0, Math.PI * 2); c.fill();
  c.strokeStyle = 'rgba(214, 170, 92, 0.85)'; c.lineWidth = W * 0.006;
  c.beginPath(); c.arc(x, y, R * 1.085, 0, Math.PI * 2); c.stroke();
  c.strokeStyle = 'rgba(16, 6, 3, 0.9)'; c.lineWidth = W * 0.008;
  c.beginPath(); c.arc(x, y, R * 1.1, 0, Math.PI * 2); c.stroke();
  // una marca dorada en forma de flecha, en el ángulo «ang» a «radio» de (cx, cy), hacia fuera (1) o hacia dentro (−1)
  const marca = (cx, cy, ang, radio, hacia, tam) => {
    c.save(); c.translate(cx + Math.cos(ang) * radio, cy + Math.sin(ang) * radio); c.rotate(ang + (hacia > 0 ? 0 : Math.PI));
    c.beginPath(); c.moveTo(tam, 0); c.lineTo(-tam * 0.6, -tam * 0.75); c.lineTo(-tam * 0.6, tam * 0.75); c.closePath();
    const g = c.createLinearGradient(-tam, -tam, tam, tam); g.addColorStop(0, '#f7dc96'); g.addColorStop(1, '#b98a3a');
    c.fillStyle = g; c.fill(); c.lineWidth = W * 0.004; c.strokeStyle = 'rgba(40, 20, 6, 0.9)'; c.stroke();
    c.restore();
  };
  marca(x, y, MARCA_BORDE, R * 1.04, -1, W * 0.026);
  // dentro: terciopelo oscuro y el ojo, con un halo frío
  if (bolsillo.abierta > 0.01) {
    const dentroG = c.createRadialGradient(x, y, R * 0.1, x, y, R);
    dentroG.addColorStop(0, '#2a0c08'); dentroG.addColorStop(1, '#0e0403');
    c.fillStyle = dentroG; c.beginPath(); c.arc(x, y, R * 0.98, 0, Math.PI * 2); c.fill();
    const halo = c.createRadialGradient(x, y, R * 0.2, x, y, R * 0.75);
    halo.addColorStop(0, `rgba(190, 215, 245, ${0.35 * bolsillo.abierta})`); halo.addColorStop(1, 'rgba(190, 215, 245, 0)');
    c.fillStyle = halo; c.beginPath(); c.arc(x, y, R * 0.98, 0, Math.PI * 2); c.fill();
    // no te mira: aparta la vista del dedo (sin dedo, mira a lo lejos)
    const d = bolsillo.dedo, obj = d ? { x: -d.x, y: -d.y } : { x: Math.sin(reloj * 0.4) * 0.7, y: -0.35 };
    const n = Math.hypot(obj.x, obj.y), m = n > 0.85 ? 0.85 / n : 1;
    bolsillo.mirada.x = mezclar(bolsillo.mirada.x, obj.x * m, 1 - Math.exp(-dt * 6));
    bolsillo.mirada.y = mezclar(bolsillo.mirada.y, obj.y * m, 1 - Math.exp(-dt * 6));
    pintarOjoLuna(c, x, y, R * 0.42, bolsillo.mirada.x, bolsillo.mirada.y);
  }
  // la tapa: gira, y al soltarse se levanta y se aparta
  const ab = bolsillo.abierta;
  if (ab < 0.999) {
    c.save();
    c.globalAlpha = 1 - ab * ab;
    c.translate(x + ab * R * 0.55, y - ab * R * 0.95);
    c.scale(1 + ab * 0.18, 1 + ab * 0.18);
    c.shadowColor = 'rgba(0, 0, 0, 0.6)'; c.shadowBlur = W * (0.02 + ab * 0.05); c.shadowOffsetY = W * (0.01 + ab * 0.03);
    c.rotate(bolsillo.angulo);
    c.drawImage(img.cajita, -R, -R, R * 2, R * 2);
    c.shadowColor = 'transparent';
    marca(0, 0, 0, R * 0.9, 1, W * 0.024);
    c.restore();
  }
  if (bolsillo.brillo > 0) {
    const bx = x + Math.cos(MARCA_BORDE) * R, by = y + Math.sin(MARCA_BORDE) * R;
    const g = c.createRadialGradient(bx, by, 0, bx, by, R * 0.6);
    g.addColorStop(0, `rgba(255, 228, 160, ${0.8 * bolsillo.brillo})`); g.addColorStop(1, 'rgba(255, 228, 160, 0)');
    c.globalCompositeOperation = 'lighter'; c.fillStyle = g; c.fillRect(0, 0, W, W); c.globalCompositeOperation = 'source-over';
  }
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
  if (estado.nivel === 2) return pistaNivel2();
  if (estado.llave === 'cajon') {
    if (caraVisible() !== 'frente') return mensaje('Los cajones están junto a la cara. Gira la caja.');
    if (estado.cajones.c8 !== 'abierto') return mensaje(n % 2 ? 'Los cajones del costado se abren tirando de ellos. Prueba los de abajo.' : 'Algunos cajones tienen cerradura y otros no. Tira de ellos y mira dentro.');
    if (estado.intentosLlave === 0) return mensaje('En el cajón de abajo, junto a la cara, hay una llave.');
    return mensaje('Mientras el ojo te mira, la caja no deja tocar nada. Haz que mire la lámpara.');
  }
  if (estado.llave === 'cerradura') return mensaje('La llave está en la cerradura: gírala arrastrando el dedo en círculo a su alrededor.');
  if (estado.tapa === 'suelta') return mensaje('El león ya soltó la tapa: levántala arrastrando hacia arriba.');
  if (estado.nota === 'cajon' && estado.tapa === 'puesta' && n % 3 === 2) return mensaje('Otro cajón de abajo guarda un papel.');
  if (estado.tapa === 'puesta') return mensaje(n % 2 ? 'El incensario: la cerradura está bajo el león. Elige la llave y toca el incensario.' : 'La llave es diminuta. ¿Qué tiene una cerradura pequeña en esta sala?');
  if (estado.cuerno === 'brasas') return mensaje('Algo blanco asoma entre las brasas del incensario.');
  if (estado.cuerno === 'mano') return mensaje(caraVisible() === 'frente' ? 'A la cara le falta un cuerno. Elige el cuerno y toca el hueco de la frente.' : 'El hueco del cuerno está en la cara. Gira la caja.');
  return mensaje('Ya está despierta.');
}
// las pistas del nivel 2 van de vagas a claras, cada paso con su escalera (NIVELES.md §5)
function pistaNivel2() {
  const h2 = estado.hija;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4);
  };
  if (!h2 || h2.fase === 'dentro') return escalon('trampilla', ['La trampilla de arriba sigue dando luz.', 'Algo empuja dentro de la trampilla.', 'Pon el dedo en la trampilla y tira hacia arriba.']);
  if (h2.fase === 'subiendo') return mensaje('Mira.');
  const sig = h2.tablillas.indexOf(false);
  if (sig === 0) return escalon('t0', ['La tablilla de arriba de la caja pequeña: el ojo grande la está mirando.',
    'Arrastra para girar la caja pequeña en la mano.', 'Escóndele la tablilla de arriba: gírala hacia ti, de espaldas al ojo, y deslízala con el dedo.']);
  if (sig === 1) return escalon('t1', ['Sigue la flecha que dejó la primera tablilla.', 'La siguiente está en el costado al que apunta la flecha.',
    'Si el ojo ve esa cara, no se moverá: gírala hacia ti antes de deslizarla.']);
  if (sig === 2) return escalon('t2', ['Te falta una cara por mirar.', 'La de abajo.', 'Arrastra hacia arriba o hacia abajo para volcar la caja… sin dejarle esa cara al ojo.']);
  if (sig === 3) return escalon('t3', ['La flecha de abajo apunta a un costado.', 'Gira la caja hasta tener ese costado de frente.']);
  if (sig === 4) return escalon('t4', ['La flecha apunta hacia atrás: a la tapa.', 'El ojo grande ve la tapa de atrás.', 'Dale la vuelta a la caja pequeña y desliza la tapa de lado.']);
  if (h2.cajon !== 'abierto') return mensaje('Detrás de la tapa hay un cajoncito. Tira de él con el dedo, hacia fuera.');
  if (h2.cajita === 'cajon') return escalon('cajita', ['Una cajita roja, en el cajoncito.', 'Cógela… sin que el ojo lo vea.']);
  if (h2.ojo === 'cajita') return escalon('bolsillo', ['Mira la cajita de cerca: tócala dos veces en la bandeja.', 'Su tapa gira.',
    'Gira la tapa hasta que su marca dorada toque la del borde.']);
  if (h2.ojo === 'mano') return escalon('cuenca', ['A la cara grande le falta un ojo.', 'Elige el ojo y toca la cuenca vacía de la cara.']);
  return mensaje('Ya ve con los dos ojos.');
}

// ---------------------------------------------------------------------------------------------
// Lo que se puede tocar: en el boceto de frente (la sala y la cara de la caja) y en el de espaldas
// ---------------------------------------------------------------------------------------------
const ZONAS = [
  // la caja de frente: de cerca
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
  { grupo: 'sala', forma: ['rect', 1206, 476, 1376, 626], tocar: tocarTetera },
  { grupo: 'sala', forma: ['rect', 1140, 592, 1336, 698], tocar: () => { agitarTe(0.8); mensaje('Dos tazas servidas. Nadie vino a beberlas.'); } },
  { grupo: 'sala', forma: ['rect', 236, 0, 416, 336], tocar: tocarRollo },
  { grupo: 'sala', forma: ['rect', 0, 0, 138, 500], tocar: () => { sonar('tope_madera', -16, 0.8); mensaje('La puerta no se abre. Primero, la caja.'); } },
  { grupo: 'sala', forma: ['rect', 664, 0, 1376, 172], tocar: tocarVentana },
  { grupo: 'sala', forma: ['rect', 1210, 172, 1376, 470], tocar: tocarVentana },
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
  if (!p) return;                        // de cerca, la cámara se queda: se vuelve con «Sala», atrás o pellizcando
  if (estado.seleccion) { usarObjeto(estado.seleccion, p, null); return; }
  const v = estado.vista, deCerca = v === 'caja' || v === 'cara' || v === 'cajones' || v === 'hija';
  if (p.hija) { tocarHija(p); return; }
  if (p.cara === 'detras') {
    if (!deCerca) { irA('caja'); return; }
    for (const z of ZONAS_DETRAS) if (dentro(z.forma, p)) { sonar('toque', -14); z.tocar(p); return; }
    sonar('toque', -14); mensaje('La espalda de la caja: más cajones y un hueco extraño.');
    return;
  }
  // un cajón: de lejos, la cámara se acerca al costado y se queda allí; de cerca, se tira de ellos
  if (p.cajon) {
    if (v !== 'cajones') {
      irA('cajones', 0.85);
      if (primeraVez('costado')) setTimeoutReloj(0.9, () => mensaje('Los cajones se abren tirando de ellos: arrastra el dedo hacia fuera.', 4));
      return;
    }
    sonar('toque', -14); tocarCajon(p.cajon);
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
  }
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
function tocarLlave(id = 'c8') {
  const [qx, qy] = puntoDentro(id), q = { x: qx, y: qy };
  if (laCajaMira()) {
    estado.intentosLlave++;
    const veces = insistir('llave');
    resistir(q.x + 10, q.y - 8, 1, -0.7, q, veces);
    const n = estado.intentosLlave;
    mensaje(n === 1 ? 'No te deja cogerla mientras te mira.' : n === 2 ? 'Tendrías que hacer que mire a otra parte.' : 'La llama de la lámpara la distrae.');
    return;
  }
  estado.llave = 'mano';
  hornear();
  sonar('recoger', -2);
  alInventario('llave', 'llave', 'caja', q);
  mensaje('Una llave de bambú, diminuta.');
  setTimeoutReloj(1.1, () => {
    mirarA(q, 2.2); entornar(1.4);
    if (reloj < ojo.distraidoHasta + 2) mensaje('Lo ha visto. Ya es tarde.');
  });
}
// la nota: se lee al sacarla y se queda en el inventario para releerla
async function cogerNota(id = 'c9') {
  const [qx, qy] = puntoDentro(id);
  estado.nota = 'mano';
  sonar('papel', -4);
  await alInventario('nota', 'nota', 'caja', { x: qx, y: qy });
  leerNota();
}
function tocarRollo() {
  rollo.v += 0.11 * (rollo.v >= 0 ? 1 : -1) + 0.02;
  sonar('papel', -17, 0.8);
  mensaje(primeraVez('rollo') ? 'Una montaña entre la niebla, pintada a tinta. El rollo se mece.' : 'Una montaña entre la niebla.');
}
function tocarVentana() {
  soplar(1);
  mensaje(primeraVez('ventana') ? 'Fuera, el viento mueve el bambú. La llama se encoge.' : 'El viento entra por las rendijas del shoji.');
}
function tocarLampara() {
  for (const m of polillas) { m.susto = 1.3; m.posada = 0; }
  agitarLampara(1.5, 1);
  sonar('racha', -14, 1.25);
  if (hijaEnMesa() && estado.hija.ojo !== 'puesto') {
    mensaje(primeraVez('lampara2') ? 'La llama tiembla, pero el ojo no se aparta de la caja pequeña.' : 'Ya no se deja engañar por la llama.');
    return;
  }
  ojo.distraidoPor = LAMPARA; ojo.distraidoHasta = reloj + 5;
  ojo.punto = null;
  mensaje(primeraVez('lampara') ? 'La llama tiembla y el ojo se va hacia ella.' : 'La llama tiembla.');
}
// La caja también oye: el tintineo de la tapa de la tetera le aparta el ojo un momento. Es otra forma de distraerlo,
// además de la llama (genero/juegos_A y juegos_B: la regla del ojo crece con otro sentido). Mientras vigila la caja
// pequeña, no se deja
function tocarTetera() {
  vaporTetera(1);
  if (estado.fase !== 'jugando' || ojo.parpadoBase > 0.5) { mensaje('Té verde. La tapa tiembla: todavía está caliente.'); return; }
  if (vigilaLaPequena()) {
    mensaje(primeraVez('tetera2') ? 'La tapa tintinea, pero el ojo no se aparta de la caja pequeña.' : 'Tintinea. El ojo no se aparta.');
    return;
  }
  ojo.distraidoPor = TAPA_TETERA; ojo.distraidoHasta = reloj + 4.5;
  ojo.punto = null;
  mensaje(primeraVez('tetera') ? 'La tapa de la tetera tintinea y el ojo se va hacia el ruido.' : 'La tapa tintinea.');
}
function tocarOjo() { parpadear(true); entornar(1.2); sonar('suspiro', -16, 1.4); mensaje('Parpadea. No le gusta que la toquen.'); }
function tocarCuenca() {
  if (estado.hija && estado.hija.ojo === 'puesto') {
    ojo2.parpadeo = { t: 0, cierre: 0.14, pausa: 0.12, apertura: 0.3 };
    sonar('suspiro', -16, 1.6); mensaje('El ojo claro parpadea… y sigue mirando a otra parte.');
    return;
  }
  destello(CUENCA.x, CUENCA.y + 2, 26, '255,40,30', 0.55, 1.3); sonar('suspiro', -14, 0.8);
  mensaje(estado.nivel === 2 ? 'La cuenca vacía. Le falta un ojo.' : 'Una cuenca vacía. Dentro, algo rojo se apaga.');
}
function tocarFrente() {
  mirarA({ x: 912, y: 230 }, 2);
  mensaje(primeraVez('frente') ? 'Aquí había otro cuerno. La madera está astillada.' : 'El hueco del cuerno. La caja mira hacia arriba.');
}
function tocarTrampilla() {
  if (estado.nivel === 2 && estado.hija) {
    if (estado.hija.fase !== 'dentro') { mensaje('La trampilla está vacía. La luz se va apagando.'); return; }
    // algo empuja desde dentro: se saca tirando hacia arriba
    destello(TRAMPILLA.x, TRAMPILLA.y - 6, 90, '255,215,140', 0.4, 0.7);
    sentir('holgura', { tono: 0.9 });
    mensaje(primeraVez('trampilla2') ? 'Dentro hay algo que empuja. Tira de ello hacia arriba con el dedo.' : 'Tira hacia arriba.');
    return;
  }
  const veces = insistir('trampilla');
  destello(TRAMPILLA.x, TRAMPILLA.y, 70, '255,205,120', 0.45, 1.1);
  sonar('trabado', -4, 0.85); vibrar(25);
  contenerAliento(1.2); mirarA({ x: 930, y: 196 }, 2);
  if (veces >= 3) bocanada(980, 196, 0.6, -1, 2);
  mensaje(primeraVez('trampilla') ? 'La trampilla está fría. Algo late debajo.' : 'Late, pero no se abre.');
}
function tocarIncensario() {
  if (estado.tapa === 'abierta') { mensaje(estado.cuerno === 'brasas' ? 'Algo blanco asoma entre las brasas.' : 'Solo quedan brasas.'); return; }
  if (estado.llave === 'cerradura') {
    // la llave se mueve un poco en la cerradura: hay que girarla con el dedo
    animar(0.3, k => { if (llaveGirando) llaveGirando.holgura = 0.08 * Math.sin(k * Math.PI * 2); });
    sentir('holgura', { tono: 1.3 });
    mensaje(primeraVez('tocar-llave') ? 'La llave está en la cerradura. Gírala: arrastra el dedo en círculo a su alrededor.' : 'Gírala en círculo.');
    return;
  }
  if (estado.tapa === 'suelta') {
    // la tapa entreabierta asoma un poco y vuelve a caer: se mueve, pero hay que levantarla con el dedo
    if (tapaVuelo) {
      const y0 = TAPA_SUELTA.y;
      animar(0.32, k => { if (tapaVuelo && estado.tapa === 'suelta') tapaVuelo.y = y0 - 5 * Math.sin(k * Math.PI); });
      setTimeoutReloj(0.3, () => sentir('tope', { db: -6, tono: 1.3 }));
    }
    sentir('holgura', { tono: 0.9 }); bocanada(575, 512, 0, -1, 1, 'incensario');
    mensaje(primeraVez('tocar-tapa') ? 'La tapa está suelta. Levántala: pon el dedo en ella y arrastra hacia arriba.' : 'Arrastra hacia arriba.');
    return;
  }
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
// Nivel 2 · La caja de dentro. La caja hija sube de la trampilla y baja a la mesa. Sus cinco tablillas corren en
// orden (las flechas de debajo dicen cuál sigue) y la cara que ve el ojo grande no se mueve: hay que girarla en la
// mano para escondérsela. Detrás de la tapa, un cajoncito con la cajita roja; dentro de la cajita, el ojo.
// ---------------------------------------------------------------------------------------------
async function subirCajaHija() {
  const h2 = estado.hija;
  estado.ocupado = true;
  h2.fase = 'subiendo';
  irA('subida', 1.1);
  sonar('mecanismo', -6, 0.85); vibrar(30);
  destello(TRAMPILLA.x, TRAMPILLA.y - 10, 170, '255,215,140', 0.65, 1.5);
  contenerAliento(3.5);
  await esperar(0.6);
  sonar('deslizar_madera', -6, 0.7); sonar('espiritu', -12, 1.3);
  const llegada = new Promise(ok => tec.subirHija(3.6, ok));
  await esperar(1.9);
  irA('hija', 1.9);
  await llegada;
  h2.fase = 'mesa';
  sonar('tope_madera', -4, 0.95); vibrar(25); agitarTe(0.5);
  estado.ocupado = false;
  mensaje('Una caja pequeña, de la familia de la grande. Arrastra para girarla en la mano.', 4.5);
}
function tocarHija(p) {
  const h2 = estado.hija;
  if (!h2 || h2.fase !== 'mesa') return;
  if (estado.vista !== 'hija') { irA('hija'); return; }
  sonar('toque', -14);
  if (p.hija === 'tablilla') return tocarTablilla(p.tablilla);
  if (p.hija === 'cajon') return tirarCajoncito();
  if (p.hija === 'cajita') return cogerCajita();
  if (p.hija === 'frente') return mensaje(primeraVez('frente-hija') ? 'El frente no se mueve. Tiene un párpado tallado, cerrado: es de la familia.' : 'El párpado tallado. Duerme.');
  // la madera oscura que destapa una tablilla: una flecha (o, detrás, el hueco del cajoncito)
  mensaje(p.caraHija === 5 ? 'Un hueco con un cajoncito.' : 'Una flecha de marquetería: señala la tablilla que sigue.');
}
// ¿la ve el ojo grande? (si te mira y esa cara está vuelta hacia él)
const laVeElOjo = i => laCajaMira() && tec.tablillaVista && tec.tablillaVista(i);
// La tablilla a la que le toca se afloja un poco cuando el ojo grande no la ve y se aprieta cuando la mira: la regla del
// ojo, a la vista y sin texto. Al aflojarse suena la holgura
const HOLGURA_TABLILLA = 0.05;
const holguraHija = { i: -1, suelta: false, proxima: 0 };
function actualizarHolguraHija() {
  const h2 = estado.hija;
  if (estado.nivel !== 2 || !h2 || h2.fase !== 'mesa' || estado.fase !== 'jugando' || !tec.tablilla) return;
  const i = h2.tablillas.indexOf(false);
  if (i < 0 || reloj < holguraHija.proxima) return;
  const g = puntero && puntero.gesto;
  if (g && g.tipo === 'tablilla' && g.i === i && g.estado === 'activo') return;     // la lleva el dedo
  const t = tec.tablilla(i);
  if (!t || t.moviendo) return;
  const suelta = !laVeElOjo(i), meta = suelta ? HOLGURA_TABLILLA : 0;
  if (Math.abs(t.k - meta) > 0.002) {
    tec.correrTablilla(i, suelta ? 0.35 : 0.16, meta);
    if (suelta && !(holguraHija.i === i && holguraHija.suelta)) sentir('holgura', { db: -5, tono: 1.25, sinVibrar: true });
    holguraHija.proxima = reloj + 0.2;
  }
  holguraHija.i = i; holguraHija.suelta = suelta;
}
// un toque en una tablilla no la corre: si le toca y el ojo no la ve, asoma un poco hacia donde corre (el gesto es
// deslizarla con el dedo)
function tocarTablilla(i) {
  const h2 = estado.hija, siguiente = h2.tablillas.indexOf(false);
  if (h2.tablillas[i]) { mensaje('Ya ha corrido. Debajo, la flecha.'); return; }
  if (i !== siguiente) { tablillaTrabada(siguiente); return; }
  if (laVeElOjo(i)) { resistirMirada(); return; }
  tec.correrTablilla(i, 0.34, 0, 0.09);
  sentir('holgura', { tono: 1.2 });
  mensaje(primeraVez('correr') ? 'Cede un poco. Deslízala con el dedo hacia donde asoma.' : 'Deslízala con el dedo.');
}
// no le toca: madera contra madera, sin que la caja grande intervenga
function tablillaTrabada(siguiente) {
  sonar('tope_madera', -12, 1.5); vibrar(12);
  const veces = insistir('orden');
  if (siguiente === 0) mensaje(primeraVez('orden') ? 'Trabada. En las cajas secretas, las tablillas corren en orden: la primera es la de arriba.' : 'Esta no. La primera es la de arriba.');
  else mensaje(veces >= 2 ? 'Esta no. Sigue la flecha que dejó la anterior.' : 'Trabada. Le toca a otra.');
}
// la resistencia: la caja grande contiene el aliento y clava el ojo en la pequeña, y va a más si se insiste
function resistirMirada() {
  const veces = insistir('mirada');
  sonar('trabado', -3, 1.25); vibrar(35);
  contenerAliento(1.6 + 0.4 * Math.min(veces, 3));
  ojo.punto = null; ojo.ultimoToque = -99;
  entornar(1.6 + 0.4 * veces);
  bocanada(842, 490, -0.3, -1, Math.min(veces, 3));
  if (veces >= 3) { sonar('grunido', -8, 1.05); sacudir(2.5, 0.3); agitarLampara(0.6, 0.6); }
  const n = ++estado.intentosMirada;
  mensaje(n === 1 ? 'No se mueve. El ojo grande la está mirando.' : n === 2 ? 'Lo que el ojo ve, no se mueve.' : 'Gira la caja pequeña: escóndele esa cara.');
}
function correrTablilla(i, duracion = 0.5) {
  const h2 = estado.hija;
  h2.tablillas[i] = true;
  tec.correrTablilla(i, duracion);
  sentir('roce', { tono: 1.5 / 1.2, db: 9 }); vibrar(8);
  setTimeoutReloj(Math.max(0.16, duracion * 0.8), () => sentir('clac', { tono: 1.3, db: -2 }));     // encajó en su sitio
  const textos = [
    'Corre. Debajo hay una flecha de marquetería.',
    'Corre hacia abajo. Otra flecha.',
    'La de abajo corre. Su flecha señala un costado.',
    'Corre. La flecha apunta hacia atrás, a la tapa.',
    'La tapa corre de lado a lado. Detrás, un cajoncito.',
  ];
  mensaje(textos[i]);
}
// el cajoncito de detrás: un toque lo hace asomar; se abre tirando de él
function tirarCajoncito() {
  const h2 = estado.hija;
  if (h2.cajon === 'abierto') { mensaje(h2.cajita === 'cajon' ? 'Dentro, una cajita roja.' : 'Vacío.'); return; }
  if (laVeElOjo(4)) { resistirMirada(); return; }
  tec.abrirCajonHija(0.34, 0, 0.12);
  sentir('holgura', { tono: 1.15 });
  mensaje(primeraVez('cajoncito') ? 'Un cajoncito. Tira de él: arrastra hacia fuera.' : 'Tira de él.');
}
function abrirCajoncito(duracion = 0.6) {
  const h2 = estado.hija;
  h2.cajon = 'abierto';
  tec.abrirCajonHija(duracion);
  sonar('cajon', -5, 1.45); vibrar(15);
  mensaje('Un cajoncito. Dentro, una cajita de laca roja.');
}
function cogerCajita() {
  const h2 = estado.hija;
  if (h2.cajita !== 'cajon') return;
  if (laVeElOjo(4)) { resistirMirada(); return; }
  const punto = tec.puntoHija('cajita');
  h2.cajita = 'mano';
  sonar('recoger', -2, 1.1);
  alInventario('cajita', 'cajita', 'caja', punto);
  mensaje('Una cajita de laca roja. Tócala dos veces en la bandeja para mirarla de cerca.', 4);
}
// el ojo nuevo, en la cuenca: la caja cierra el ojo viejo y abre los dos
async function ponerOjo(desde) {
  estado.ocupado = true;
  if (estado.vista !== 'cara') { irA('cara', 0.9); await esperar(0.7); }
  mirarA(CUENCA, 3);
  await desdeInventario('ojo', 'ojo_luna', CUENCA, 'caja', desde);
  estado.hija.ojo = 'puesto';
  ojo2.visible = 1; ojo2.parpadoBase = 1; ojo2.cerrado = 1;
  sonar('encajar', -1); sentir('desbloqueo', { db: -4 }); sacudir(4, 0.3);
  destello(CUENCA.x, CUENCA.y, 80, '190,215,255', 0.75, 1.4);
  contenerAliento(2.2);
  await esperar(0.8);
  animar(0.35, k => { ojo.parpadoBase = suave(k); });
  sonar('suspiro', -8, 0.9);
  await esperar(1.2);
  sonar('ojo_abre', -3, 0.95);
  animar(0.9, k => { const e = 1 - salida(k); ojo.parpadoBase = e; ojo2.parpadoBase = e; });
  await esperar(1);
  ojo.parpadoBase = 0; ojo2.parpadoBase = 0;
  ojo2.punto = { x: 1100, y: 40 }; ojo2.proximoVagar = reloj + 3;
  sonar('espiritu', -6, 1.3);
  destello(CUENCA.x, CUENCA.y, 60, '190,215,255', 0.4, 2.4);
  mensaje('Abre los dos ojos. El nuevo es claro… y no mira lo mismo que el viejo.', 4);
  await esperar(4);
  estado.ocupado = false;
  terminarNivel(2);
}

// ---------------------------------------------------------------------------------------------
// Usar lo que llevas
// ---------------------------------------------------------------------------------------------
// un toque elige el objeto; otro toque sobre el elegido lo examina
function seleccionar(objeto) {
  if (estado.seleccion === objeto) { estado.seleccion = null; pintarInventario(); examinar(objeto); return; }
  estado.seleccion = objeto;
  pintarInventario();
  mostrarEtiqueta(objeto);
  sonar('toque', -12, 1.2);
  const textos = { llave: 'La llave de bambú. ¿Dónde la usas?', cuerno: 'El cuerno de marfil. ¿Dónde va?', nota: 'La nota. Tócala otra vez para leerla.',
    cajita: 'La cajita roja. Tócala otra vez para mirarla de cerca.', ojo: 'El ojo de piedra de luna. ¿Dónde va?' };
  mensaje(textos[objeto], 2.4);
}
function usarObjeto(objeto, p, desde = null) {
  const deseleccionar = () => { estado.seleccion = null; pintarInventario(); };
  const deFrente = p && p.cara !== 'detras';
  if (objeto === 'nota') { deseleccionar(); leerNota(); return; }
  if (p && p.cajon && deFrente) {
    deseleccionar(); sonar('trabado', -8, 1.2);
    mensaje(objeto === 'llave' ? (CAJONES[p.cajon].cerradura ? 'La cerradura de este cajón es aún más pequeña.' : 'Este cajón no tiene cerradura.') : 'Ahí no encaja.');
    return;
  }
  if (objeto === 'llave' && deFrente && dentro(INCENSARIO, p) && estado.tapa === 'puesta') { deseleccionar(); meterLlave(desde); return; }
  if (objeto === 'cuerno' && deFrente && dentro(['elipse', 912, 291, 40, 40], p)) { deseleccionar(); ponerCuerno(desde); return; }
  if (objeto === 'ojo' && deFrente && !p.hija && dentro(['elipse', CUENCA.x, CUENCA.y, 42, 28], p)) { deseleccionar(); ponerOjo(desde); return; }
  if (objeto === 'cajita') { deseleccionar(); sonar('trabado', -10, 1.3); mensaje('Primero habría que abrirla. Tócala dos veces en la bandeja para mirarla de cerca.'); return; }
  deseleccionar();
  sonar('trabado', -8, 1.2);
  const enCaja = p && (p.cara === 'detras' || dentro(['poli', CAJA], p));
  if (objeto === 'llave') mensaje(p && p.cara === 'detras' && dentro(['rect', 715, 474, 990, 558], p) ? 'No es esta llave: es demasiado pequeña.' : enCaja ? 'La llave no entra en la caja.' : 'La llave no entra ahí.');
  else if (objeto === 'ojo') mensaje(enCaja ? 'Ahí no encaja. ¿Dónde le falta un ojo a la cara?' : 'Ahí no encaja.');
  else mensaje(enCaja ? 'Ahí no encaja. ¿Dónde le falta un cuerno?' : 'Ahí no encaja.');
}

// La llave entra en la cerradura del león y se queda en ella: hay que girarla con el dedo (gesto «llave»)
async function meterLlave(desde) {
  estado.ocupado = true;
  irA('incensario');
  await desdeInventario('llave', 'llave', CERRADURA, 'incensario', desde);
  estado.llave = 'cerradura';
  llaveGirando = { t: 0, sentido: -1, desvanece: 0 };
  sonar('llave', -4, 1.15); vibrar(12);
  estado.ocupado = false;
  mensaje(primeraVez('girar-llave') ? 'La llave entra. Gírala: arrastra el dedo en círculo alrededor de la cerradura.' : 'Gírala.', 4.5);
}
// el giro completo, en cadena y a la vista: la llave encaja (clac), dentro corre un pestillo, la tapa salta y queda
// entreabierta, con la luz de las brasas por la rendija; la llave se queda en la cerradura (se desvanece)
async function abrirCerradura() {
  estado.ocupado = true;
  const t0 = llaveGirando.t;
  llaveGirando.holgura = (llaveGirando.sentido || -1) * 0.07;
  await animarPromesa(0.14, k => { llaveGirando.t = mezclar(t0, 1, k); });
  sentir('clac');
  await esperar(0.14);
  sentir('pestillo');
  await esperar(0.26);
  estado.llave = 'usada';
  estado.tapa = 'suelta';
  saltarTapa();
  await animarPromesa(0.5, k => { llaveGirando.desvanece = suave(k); }, 0.35);
  llaveGirando = null;
  estado.ocupado = false;
  if (primeraVez('tapa-suelta')) mensaje('El león suelta la tapa. Levántala: arrastra hacia arriba.', 4);
}
// la tapa salta al soltarla el león: sube, cae torcida y rebota; por la rendija sale humo y luz
function saltarTapa() {
  const s = TAPA_SUELTA, o = TAPA_ORIGEN;
  tapaVuelo = { x: o.x, y: o.y, ang: 0, sx: 1, sy: 1, rendija: 0 };
  hornear();
  sentir('mecanismo', { db: -2 });
  bocanada(546, 517, -0.9, -0.4, 1, 'incensario'); bocanada(604, 517, 0.9, -0.4, 1, 'incensario');
  agitarTe(0.2);
  animar(0.6, k => {
    const salto = k < 0.42 ? Math.sin(k / 0.42 * Math.PI) : 0.2 * Math.sin((k - 0.42) / 0.58 * Math.PI);
    const e = suave(Math.min(1, k / 0.42));
    tapaVuelo.x = mezclar(o.x, s.x, e);
    tapaVuelo.y = mezclar(o.y, s.y, e) - 9 * salto;
    tapaVuelo.ang = s.ang * e + 0.05 * salto;
    tapaVuelo.rendija = Math.min(1, k * 2.4);
  }, () => { if (tapaVuelo) Object.assign(tapaVuelo, tapaSuelta()); });
  setTimeoutReloj(0.27, () => sentir('tope', { db: -5, tono: 1.2 }));
  humoDelIncienso();
}
// la tapa, levantada con el dedo (gesto «tapa»), va a la mesa; si se suelta antes, cae en su sitio
function llevarTapaAMesa() {
  const b = TAPA_MESA, x0 = tapaVuelo.x, y0 = tapaVuelo.y, ang0 = tapaVuelo.ang;
  estado.ocupado = true;
  return new Promise(ok => {
    animar(0.6, k => {
      const e = curva(k);
      tapaVuelo.x = mezclar(x0, b.x, e);
      tapaVuelo.y = mezclar(y0, b.y, e) - Math.sin(e * Math.PI) * 24;
      tapaVuelo.ang = mezclar(ang0, 0.03, e);
      tapaVuelo.sx = tapaVuelo.sy = mezclar(1, 1.04, e);
    }, () => {
      sonar('tope_madera', -2); vibrar(20);
      polvareda(b.x, b.y - 6);
      animar(0.28, k => {
        const q = Math.sin(k * Math.PI);
        tapaVuelo.sy = 1.04 * (1 - 0.06 * q); tapaVuelo.sx = 1.04 * (1 + 0.03 * q); tapaVuelo.ang = 0.03 * (1 - k);
      }, () => {
        estado.tapaEnMesa = true; tapaVuelo = null; hornear();
        bucle('fuego', -21, 2);
        estado.ocupado = false;
        mensaje('Algo blanco asoma entre las brasas.');
        ok();
      });
    });
  });
}
// soltada antes de tiempo, la tapa cae y se queda otra vez entreabierta (la boca vuelve a tapar el cuerno)
function devolverTapa() {
  const x0 = tapaVuelo.x, y0 = tapaVuelo.y, ang0 = tapaVuelo.ang, s = TAPA_SUELTA;
  estado.tapa = 'suelta'; estado.ocupado = true; tapaVuelo.rendija = 0; hornear();
  animar(0.2, k => { const e = k * k; tapaVuelo.x = mezclar(x0, s.x, e); tapaVuelo.y = mezclar(y0, s.y, e); tapaVuelo.ang = mezclar(ang0, s.ang, e); }, () => {
    sentir('tope', { db: 1, tono: 1.25 });
    bocanada(575, 512, 0, -1, 1, 'incensario');
    Object.assign(tapaVuelo, tapaSuelta());
    estado.ocupado = false;
    humoDelIncienso();
  });
}
async function ponerCuerno(desde) {
  estado.ocupado = true;
  if (caraVisible() !== 'frente') { tec.girar(); await esperar(0.8); }
  if (estado.vista !== 'caja' && estado.vista !== 'cara' && estado.vista !== 'cajones') { irA('caja'); await esperar(0.6); }
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
  sonar('encajar', -1); sentir('desbloqueo', { db: -3 }); sacudir(5, 0.35);
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
  sacudirCajones();
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
  estado.ocupado = false;
  terminarNivel(1);
}

// ---------------------------------------------------------------------------------------------
// Los niveles: la tarjeta que cierra cada uno (con la cara como marcador: las piezas que ya ha recuperado), la
// partida guardada al terminarlo y el paso al siguiente
// ---------------------------------------------------------------------------------------------
function leerProgreso() {
  try { const g = JSON.parse(localStorage.getItem(CLAVE_PARTIDA)); return g && g.superado ? g : null; } catch (e) { return null; }
}
function guardarProgreso(superado) {
  try {
    const antes = leerProgreso();
    localStorage.setItem(CLAVE_PARTIDA, JSON.stringify({ superado: Math.max(superado, antes ? antes.superado : 0), fecha: Date.now() }));
  } catch (e) { /* sin almacenamiento: se juega igual */ }
}
const hay3D = () => tec.nombre !== 'A' && !!tec.hayHija && tec.hayHija();
function terminarNivel(n) {
  estado.fase = 'tarjeta';
  estado.ocupado = false;
  estado.seleccion = null; pintarInventario();
  el.volver.hidden = true;
  guardarProgreso(n);
  const nivel = NIVELES[n], siguiente = NIVELES[n + 1];
  el.tarjetaHecho.textContent = `Nivel ${n} superado`;
  el.tarjetaTitulo.textContent = nivel.titulo;
  el.tarjetaTexto.textContent = nivel.texto;
  for (const pieza of el.tarjeta.querySelectorAll('.pieza')) {
    const i = Object.values(NIVELES).findIndex(v => v.pieza === pieza.dataset.pieza) + 1;
    pieza.classList.toggle('recuperada', i <= n);
    pieza.classList.toggle('nueva', i === n);
  }
  el.tarjeta.querySelector('.marcador').setAttribute('aria-label', `La cara: ${n} de 3 piezas`);
  const puede = n === 1 && hay3D();
  el.tarjetaSiguiente.textContent = n === 1
    ? (puede ? `Nivel 2 · ${siguiente.titulo}` : 'El nivel 2 necesita la escena 3D, y este móvil no puede abrirla.')
    : `Nivel ${n + 1} · ${siguiente.titulo}: llega en la próxima entrega.`;
  el.seguir.hidden = !puede;
  el.quedarse.hidden = n < 2;
  el.tarjeta.hidden = false;
  requestAnimationFrame(() => el.tarjeta.classList.remove('oculta'));
  sonar('papel', -10, 0.9);
}
function ocultarTarjeta() {
  el.tarjeta.classList.add('oculta');
  setTimeout(() => { el.tarjeta.hidden = true; }, 900);
}
// el estado al final del nivel 1, para empezar el 2 sin jugarlo (seguir una partida guardada, o «?nivel=2»)
function estadoTrasNivel1() {
  Object.assign(estado, { llave: 'usada', tapa: 'abierta', tapaEnMesa: true, cuerno: 'puesto', nota: 'mano', inventario: ['nota'] });
  estado.vistos.espalda = true;
  Object.assign(despertar, { ojos: 1, humo: 1, trampilla: 1, oscuridad: 0.42 });
  ojo.visible = 0; lampara.apagada = 0.45;
  if (tec.abrirTrampilla) tec.abrirTrampilla(1);
  pintarInventario();
  hornear();
  bucle('fuego', -21, 2);
}
// el nivel 2: la caja se calma (se le apagan los ojos rojos y el humo, vuelve el ojo de siempre) y la trampilla
// sigue dando luz: dentro, algo se mueve
async function empezarNivel2() {
  ocultarTarjeta();
  estado.nivel = 2;
  estado.hija = { fase: 'dentro', tablillas: [false, false, false, false, false], cajon: 'cerrado', cajita: 'cajon', ojo: 'cajita' };
  estado.pistasPaso = {}; estado.intentosMirada = 0; estado.insistencia = {};
  estado.fase = 'jugando';
  el.girar.hidden = true;                  // la caja grande no se gira: no pierde de vista a la pequeña
  el.inventario.hidden = false;
  if (tec.ponerHija) tec.ponerHija(estado.hija);
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; ojo.entornado = 0;
  const humo0 = despertar.humo, oscuro0 = despertar.oscuridad, lampara0 = lampara.apagada, ojos0 = despertar.ojos;
  animar(1.8, k => {
    const e = suave(k);
    despertar.ojos = ojos0 * (1 - e); despertar.humo = humo0 * (1 - e);
    despertar.oscuridad = mezclar(oscuro0, 0.16, e); lampara.apagada = mezclar(lampara0, 0.1, e);
    ojo.visible = Math.max(ojo.visible, e);
    hornear();
  });
  bucle('noche', -13, 2);
  sonar('suspiro', -10, 0.8);
  irA('caja', 1.4);
  await esperar(2);
  mensaje('La caja se calma. Su trampilla sigue abierta y da luz: dentro, algo se mueve.', 4.5);
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
  actualizarCajones(dt);
  if (puntero && puntero.gesto) actualizarGesto(puntero.gesto, dt);
  actualizarHolguraHija();
  actualizarOjo(dt);
  actualizarOjo2(dt);
  actualizarAliento(dt);
  actualizarLampara();
  actualizarMotas(dt);
  actualizarNubes(dt);
  actualizarDecoracion(dt);
  for (const h of humos.incienso) h.actualizar(dt);
  for (const h of humos.te) h.actualizar(dt);
  for (let i = humos.sueltos.length - 1; i >= 0; i--) { const h = humos.sueltos[i]; h.actualizar(dt); if (!h.viva) humos.sueltos.splice(i, 1); }
  tec.actualizar(dt);
  if (estado.fase === 'jugando' && !estado.vistos.espalda && caraVisible() === 'detras') {
    estado.vistos.espalda = true;
    mensaje('La espalda: más cajones, una cerradura y un hueco con forma de ficha.');
  }
  if (mensajeHasta && reloj >= mensajeHasta) { el.mensaje.classList.remove('visible'); mensajeHasta = 0; }
  if (etiquetaHasta && reloj >= etiquetaHasta) { el.etiqueta.classList.remove('visible'); etiquetaHasta = 0; }
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
    dibujarBolsillo(dt);
  }
  requestAnimationFrame(cuadro);
}

// ---------------------------------------------------------------------------------------------
// Toques: tocar, arrastrar y pellizcar. De cerca, la cámara se queda quieta: arrastrar es la acción (tirar de un
// cajón, girar la llave, levantar la tapa, sacar la caja pequeña, correr una tablilla) o girar la caja; en la sala,
// arrastrar mira alrededor. Pellizcar acerca o aleja donde están los dedos; alejarse del todo vuelve a la vista de antes.
// ---------------------------------------------------------------------------------------------
const punteros = new Map();
let puntero = null, arrastre = null, pellizco = null;
const VISTA_PADRE = { cajones: 'caja', cara: 'caja', incensario: 'sala', caja: 'sala', hija: 'caja' };
function posicion(e) { const r = lienzo.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; }
lienzo.addEventListener('pointerdown', e => {
  desbloquearAudio();
  const q = posicion(e);
  punteros.set(e.pointerId, q);
  if (punteros.size >= 2) {
    // un segundo dedo: lo que movía el primero se suelta y empieza el pellizco
    if (puntero && puntero.gesto) soltarGesto(puntero.gesto, true);
    puntero = null;
    const [a, b] = [...punteros.values()];
    pellizco = { d: Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)), m: { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }, exceso: 1, salio: false };
    return;
  }
  const p = tec.aPintura(q.x, q.y);
  moverDedo(p);
  // la caja grande se gira arrastrándola desde la sala o la vista de la caja (de más cerca, se queda quieta para poder
  // tirar de sus cajones); en el nivel 2, con la caja pequeña en la mesa, no se gira: arrastrar gira la pequeña en la mano
  const v = estado.vista;
  puntero = { ...q, x0: q.x, y0: q.y, inicio: performance.now(), id: e.pointerId, movido: 0, gesto: gestoEn(p, q),
    enCaja: (v === 'sala' || v === 'caja') && !hijaEnMesa() && !!(p && (p.cara === 'detras' || p.cajon || dentro(['poli', CAJA], p))),
    enHija: hijaEnMesa() && v === 'hija' };
  if (estado.fase === 'jugando' && p && p.cara === 'frente') mirarA(p);
});
lienzo.addEventListener('pointermove', e => {
  const q = posicion(e);
  if (punteros.has(e.pointerId)) punteros.set(e.pointerId, q);
  if (pellizco && punteros.size >= 2) { moverPellizco(); return; }
  if ((e.pointerType === 'mouse' || puntero) && estado.fase === 'jugando') {
    const p = tec.aPintura(q.x, q.y);
    moverDedo(p);
    if (p && p.cara === 'frente') mirarA(p);
  }
  if (!puntero || e.pointerId !== puntero.id) return;
  const dx = q.x - puntero.x, dy = q.y - puntero.y;
  puntero.movido = Math.max(puntero.movido, Math.hypot(q.x - puntero.x0, q.y - puntero.y0));
  // la velocidad del dedo (px/s): al soltar con impulso, la caja sigue girando un poco
  const ahoraMov = performance.now(), pasoMov = Math.max(0.008, (ahoraMov - (puntero.tMov || puntero.inicio)) / 1000);
  puntero.vx = mezclar(puntero.vx || 0, dx / pasoMov, 0.5); puntero.tMov = ahoraMov;
  if (puntero.gesto && moverGesto(puntero.gesto, q)) { puntero.x = q.x; puntero.y = q.y; return; }
  if (puntero.movido > 10 && estado.fase !== 'portada' && !estado.ocupado) {
    if (puntero.enHija) tec.girarHija(dx, dy);
    else if (puntero.enCaja) tec.arrastrar(dx, dy, true);
    // en la sala se mira alrededor; de cerca, la vista sigue anclada a su sitio, pero gira a su alrededor
    else if (estado.vista !== 'subida') tec.arrastrar(dx, dy, false);
    if (tec.nombre !== 'A' && (puntero.enCaja || puntero.enHija) && !puntero.sonoGiro && puntero.movido > 24) {
      puntero.sonoGiro = true; sonar('deslizar_madera', puntero.enHija ? -17 : -14, puntero.enHija ? 1.5 : 1.1);
    }
  }
  puntero.x = q.x; puntero.y = q.y;
  // en la técnica A, deslizar la caja de lado la gira
  if (tec.nombre === 'A' && puntero.enCaja && Math.abs(q.x - puntero.x0) > 90 && !puntero.giro && !estado.ocupado && estado.fase === 'jugando') {
    puntero.giro = true; girarCaja();
  }
});
function finToque(e) {
  punteros.delete(e.pointerId);
  if (pellizco) {
    if (punteros.size < 2) pellizco = null;
    return;
  }
  if (!puntero || e.pointerId !== puntero.id) return;
  const q = posicion(e), g = puntero.gesto;
  if (g && g.estado) soltarGesto(g, e.type === 'pointercancel');
  else if (puntero.movido < 16 && performance.now() - puntero.inicio < 900 && e.type === 'pointerup') tocarEscena(q.x, q.y);
  else {
    if (puntero.enHija && tec.soltarHija) { tec.soltarHija(); if (puntero.movido >= 16) sentir('tope', { db: -9, tono: 1.6, sinVibrar: true }); }
    const conImpulso = puntero.enCaja && performance.now() - (puntero.tMov || 0) < 80;
    tec.soltar(conImpulso ? puntero.vx : 0, puntero.enCaja);
  }
  puntero = null;
}
lienzo.addEventListener('pointerup', finToque);
lienzo.addEventListener('pointercancel', finToque);
// sin el clic fantasma que el móvil manda tras un toque (caería en lo que se acaba de abrir)
lienzo.addEventListener('touchend', e => { if (e.cancelable) e.preventDefault(); }, { passive: false });

// el pellizco: acerca o aleja alrededor de los dedos (y se desplaza con ellos); si se sigue alejando cuando ya no
// se puede más, se vuelve a la vista de antes (del costado a la caja, de la caja a la sala…)
function moverPellizco() {
  const [a, b] = [...punteros.values()];
  const d = Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)), m = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
  const r = d / pellizco.d;
  pellizco.d = d;
  const m0 = pellizco.m; pellizco.m = m;
  if (pellizco.salio || estado.fase !== 'jugando') return;
  const limite = tec.pellizcar(r, m0, m);
  if (limite === 'fuera' && r < 1) pellizco.exceso *= r;
  else if (r > 1.004) pellizco.exceso = 1;
  if (pellizco.exceso < 0.8) alejarseDelTodo() && (pellizco.salio = true);
}
function alejarseDelTodo() {
  const padre = VISTA_PADRE[estado.vista];
  if (!padre || estado.ocupado || estado.fase !== 'jugando') return false;
  irA(padre);
  return true;
}
// la rueda del ratón hace lo mismo que el pellizco, alrededor del puntero
let ruedaFuera = 0;
lienzo.addEventListener('wheel', e => {
  e.preventDefault();
  if (estado.fase !== 'jugando') return;
  const m = posicion(e), r = e.deltaY < 0 ? 1.08 : 1 / 1.08;
  const limite = tec.pellizcar(r, m, m);
  if (limite === 'fuera' && r < 1) { if (++ruedaFuera >= 3) { ruedaFuera = 0; alejarseDelTodo(); } }
  else ruedaFuera = 0;
}, { passive: false });

// ---------------------------------------------------------------------------------------------
// Los gestos: lo que se mueve con el dedo. Al apoyar el dedo se mira qué hay debajo (gestoEn); el gesto empieza
// cuando el dedo se mueve (empezarGesto) y, si no era para eso, el arrastre hace lo de siempre (girar la caja o
// mirar). Un toque sin mover solo avisa: la pieza asoma un poco y el mensaje dice qué gesto hace falta.
// ---------------------------------------------------------------------------------------------
// la línea por la que sale un cajón del costado, en la pantalla: su frente cerrado (a) y abierto (b)
function ejeCajon(id) {
  if (tec.pantallaCajon) return { a: tec.pantallaCajon(id, 0), b: tec.pantallaCajon(id, 1) };
  const g = geometriaCajon(id), y = (g.y[0] + g.y[1]) / 2, z = (g.z[0] + g.z[1]) / 2, X = cajonesDatos.x;
  const enPantalla = s => { const [bx, by] = aBoceto([X + s, y, z]); return tec.ancla({ x: bx, y: by }, 'caja'); };
  return { a: enPantalla(0), b: enPantalla(cajonesDatos.sale) };
}
// cuánto avanza el dedo por esa línea (en fracciones de ella); si en la pantalla es muy corta, cuenta como de 40 px
function avanceEnEje(eje, dx, dy) {
  const ax = eje.b.x - eje.a.x, ay = eje.b.y - eje.a.y;
  return (dx * ax + dy * ay) / Math.max(ax * ax + ay * ay, 1600);
}
const cosenoConEje = (eje, dx, dy) => {
  const ax = eje.b.x - eje.a.x, ay = eje.b.y - eje.a.y;
  return (dx * ax + dy * ay) / (Math.hypot(ax, ay) * Math.hypot(dx, dy) || 1);
};
const cerraduraEnPantalla = () => tec.ancla(CERRADURA, 'incensario');
function gestoEn(p, q) {
  if (estado.fase !== 'jugando' || estado.ocupado) return null;
  const v = estado.vista;
  // la llave metida en el león: se gira en círculo alrededor de la cerradura
  if (estado.llave === 'cerradura' && llaveGirando && v === 'incensario') {
    const c = cerraduraEnPantalla();
    if (c && ((p && dentro(INCENSARIO, p)) || Math.hypot(q.x - c.x, q.y - c.y) < 120)) return { tipo: 'llave' };
  }
  if (!p) return null;
  if (p.cajon && v === 'cajones') return { tipo: 'cajon', id: p.cajon };
  if (p.hija && v === 'hija' && hijaEnMesa()) {
    if (p.hija === 'tablilla') return { tipo: 'tablilla', i: p.tablilla };
    if (p.hija === 'cajon') return { tipo: 'cajoncito' };
    return null;
  }
  // la tapa suelta del incensario: se levanta tirando hacia arriba
  if (estado.tapa === 'suelta' && v === 'incensario' && dentro(INCENSARIO, p)) return { tipo: 'tapa' };
  // la caja pequeña, dentro de la trampilla: se saca tirando hacia arriba
  if (estado.nivel === 2 && estado.hija && estado.hija.fase === 'dentro' && p.cara === 'frente' && v !== 'sala'
    && dentro(['elipse', TRAMPILLA.x, TRAMPILLA.y, 90, 40], p)) return { tipo: 'trampilla' };
  return null;
}
// el dedo se ha movido: ¿empieza el gesto? (false: no era un gesto, el arrastre hace lo de siempre)
function empezarGesto(g, dx, dy) {
  if (estado.ocupado || estado.fase !== 'jugando') return false;
  const h2 = estado.hija;
  switch (g.tipo) {
    case 'cajon': {
      if (CAJONES[g.id].cerradura) {
        const c = centroCajon(g.id);
        cajonCerrado(g.id, c.x, c.y, 1, -0.6, 'Tiene una cerradura pequeña. No cede.');
        g.estado = 'bloqueado';
        return true;
      }
      const a = cajonAnim[g.id];
      g.eje = ejeCajon(g.id); g.k0 = a.k; g.kAntes = a.k; g.t = performance.now();
      g.asentado = a.k < 0.02;              // cerrado, está asentado: cede tras un poco de tirón
      a.agarrado = true; a.v = 0;
      if (!g.asentado) sentir('roce', { tono: 1.05 });
      break;
    }
    case 'tablilla': case 'cajoncito': {
      g.eje = tec.ejeHija(g.tipo === 'cajoncito' ? 'cajon' : 'tablilla', g.i);
      // por su línea, corre; en otra dirección, el dedo gira la caja pequeña. Solo se desliza la tablilla a la que le
      // toca (las demás, al arrastrarlas, giran la caja: un toque dice que están trabadas)
      if (!g.eje || cosenoConEje(g.eje, dx, dy) < 0.72) return false;
      if (g.tipo === 'tablilla') {
        if (h2.tablillas[g.i] || g.i !== h2.tablillas.indexOf(false)) return false;
        if (laVeElOjo(g.i)) { resistirMirada(); g.estado = 'bloqueado'; return true; }
      } else {
        if (h2.cajon === 'abierto') return false;
        if (laVeElOjo(4)) { resistirMirada(); g.estado = 'bloqueado'; return true; }
      }
      // empieza donde esté (la que toca puede estar ya aflojada)
      g.base = g.tipo === 'tablilla' && tec.tablilla ? Math.min(0.2, tec.tablilla(g.i)?.k || 0) : 0;
      g.k = g.base; g.v = 0; g.t = performance.now(); g.visto = g.base; g.asentado = true;
      break;
    }
    case 'llave': {
      const c = cerraduraEnPantalla();
      g.centro = { x: c.x, y: c.y };
      g.angulo = Math.atan2(puntero.y0 - c.y, puntero.x0 - c.x);
      g.giro = 0; g.sentido = 0; g.clics = 0; g.objetivo = llaveGirando.t; g.cedio = false;
      break;
    }
    case 'tapa': {
      if (dy > -Math.abs(dx) * 0.4) return false;          // solo hacia arriba
      estado.tapa = 'abierta';
      tapaVuelo = tapaVuelo || tapaSuelta();
      g.base = { x: tapaVuelo.x, y: tapaVuelo.y, ang: tapaVuelo.ang }; g.objetivo = { ...g.base }; g.vx = 0;
      hornear();
      humoDelIncienso();
      sentir('roce', { tono: 0.8, db: 3 }); vibrar(10);
      bocanada(560, 508, -0.6, -1, 1, 'incensario'); bocanada(592, 508, 0.6, -1, 1, 'incensario');
      break;
    }
    case 'trampilla': {
      if (dy > -Math.abs(dx) * 0.4) return false;
      sonar('mecanismo', -14, 1.25); vibrar(12);
      destello(TRAMPILLA.x, TRAMPILLA.y - 6, 110, '255,215,140', 0.45, 0.8);
      break;
    }
  }
  g.estado = 'activo';
  return true;
}
// mientras el dedo se mueve; devuelve true si el gesto se queda con el movimiento
function moverGesto(g, q) {
  const dx = q.x - puntero.x0, dy = q.y - puntero.y0;
  if (!g.estado) {
    if (Math.hypot(dx, dy) < 9) return true;
    if (!empezarGesto(g, dx, dy)) { puntero.gesto = null; return false; }
  }
  if (g.estado !== 'activo') return true;
  const ahora = performance.now(), paso = Math.max(0.004, (ahora - g.t) / 1000);
  switch (g.tipo) {
    case 'cajon': {
      let avance = avanceEnEje(g.eje, dx, dy);
      if (g.asentado) {
        if (avance < 0.08) avance = avance * 0.15;
        else { g.asentado = false; g.cede = 0.08 * 0.85; sentir('holgura'); sentir('roce', { tono: 1.05, db: 2 }); }
      }
      if (g.cede) avance -= g.cede;
      const a = cajonAnim[g.id], k = limitar(g.k0 + avance, 0, 1.04);
      a.v = mezclar(a.v, (k - a.k) / paso, 0.5); a.k = k; g.t = ahora;
      if (k <= 0 && g.kAntes > 0.015 && reloj > a.golpe) {                  // cerrado de un empujón
        a.golpe = reloj + 0.25; sonar('tope_madera', -9, 1.15); vibrar(10); agitarTe(0.3);
      }
      if (k >= 1 && g.kAntes < 1) sentir('tope', { db: -4, tono: 1.1 });       // el tope de fuera
      g.kAntes = k;
      break;
    }
    case 'tablilla': case 'cajoncito': {
      let avance = avanceEnEje(g.eje, dx, dy);
      if (g.asentado && avance >= 0.07) { g.asentado = false; sentir('holgura', { tono: 1.15 }); sentir('roce', { tono: 1.6, db: 2 }); }
      if (g.asentado) avance *= 0.2;
      const k = limitar(Math.max(avance, g.base || 0), 0, 1);
      g.v = mezclar(g.v, (k - g.k) / paso, 0.5); g.k = k; g.t = ahora;
      break;
    }
    case 'llave': {
      const c = g.centro, r = Math.hypot(q.x - c.x, q.y - c.y), ang = Math.atan2(q.y - c.y, q.x - c.x);
      let d = ang - g.angulo;
      if (d > Math.PI) d -= 2 * Math.PI; else if (d < -Math.PI) d += 2 * Math.PI;
      g.angulo = ang;
      if (r < 14) break;                          // en el centro mismo, el ángulo salta: no cuenta
      g.giro += d;
      if (!g.sentido) {
        llaveGirando.holgura = limitar(g.giro, -0.12, 0.12) * 0.6;          // la holgura: se mueve en su hueco
        if (Math.abs(g.giro) > 0.12) { g.sentido = Math.sign(g.giro); llaveGirando.sentido = g.sentido; }
        break;
      }
      const avance = g.giro * g.sentido - 0.12;
      llaveGirando.holgura = g.sentido * 0.07;
      if (avance > 0.02 && !g.cedio) { g.cedio = true; sentir('holgura', { tono: 0.85 }); }
      // las muescas: la llave se frena en cada una y salta a la siguiente
      const x = limitar(avance / 1.08, 0, 1);
      g.objetivo = limitar(x - 0.03 * Math.sin(2 * Math.PI * x / 0.2), 0, 1);
      if (x >= 0.75) { g.estado = 'hecho'; abrirCerradura(); }
      break;
    }
    case 'tapa': {
      const m = tec.ancla(TAPA_ORIGEN, 'incensario'), k = Math.max(0.2, m ? m.k : 1);
      const alzada = limitar(-dy / k, 0, 40), lado = limitar(dx / k, -40, 40) * 0.4;
      g.vx = mezclar(g.vx, (lado - (g.objetivo.x - g.base.x)) / paso, 0.4);
      g.objetivo = { x: g.base.x + lado, y: g.base.y - alzada, ang: g.base.ang * (1 - Math.min(1, alzada / 12)) + lado * 0.003 - 0.06 * Math.min(1, alzada / 30) };
      g.alzada = alzada;
      if (alzada >= 34) { g.estado = 'hecho'; llevarTapaAMesa(); }
      break;
    }
    case 'trampilla': {
      if (dy < -40) { g.estado = 'hecho'; subirCajaHija(); }
      break;
    }
  }
  return true;
}
// en cada cuadro, mientras el dedo mueve algo: la pieza lo sigue con un poco de retraso (pesa), se frena en sus
// muescas y suena al llegar a su tope
function actualizarGesto(g, dt) {
  if (g.estado !== 'activo') return;
  const seguir = rapidez => 1 - Math.exp(-dt * rapidez);
  switch (g.tipo) {
    case 'tablilla': case 'cajoncito': {
      g.visto += (g.k - g.visto) * seguir(20);
      if (g.tipo === 'tablilla') tec.ponerTablilla(g.i, g.visto); else tec.ponerCajonHija(g.visto);
      if (g.visto >= 0.985 && !g.tope) { g.tope = true; sentir('tope', { db: -6, tono: 1.6 }); }
      else if (g.visto < 0.9) g.tope = false;
      break;
    }
    case 'llave': {
      if (!llaveGirando) break;
      llaveGirando.t += (g.objetivo - llaveGirando.t) * seguir(16);
      const muescas = Math.min(3, Math.floor(llaveGirando.t * 5 + 0.02));
      if (muescas > g.clics) sentir('muesca', { tono: 1 + 0.06 * muescas });
      g.clics = muescas;
      break;
    }
    case 'tapa': {
      if (!tapaVuelo) break;
      const o = g.objetivo, e = seguir(14);
      g.vx *= Math.exp(-dt * 6);
      tapaVuelo.x += (o.x - tapaVuelo.x) * e; tapaVuelo.y += (o.y - tapaVuelo.y) * e;
      tapaVuelo.ang += (o.ang - limitar(g.vx * 0.0015, -0.08, 0.08) - tapaVuelo.ang) * seguir(10);     // se mece al moverla de lado
      break;
    }
  }
}
// el dedo se levanta (o llega otro dedo: «cancelado»)
function soltarGesto(g, cancelado = false) {
  if (g.estado !== 'activo') return;
  g.estado = 'suelto';
  switch (g.tipo) {
    case 'cajon': {
      const a = cajonAnim[g.id];
      a.agarrado = false;
      const final = a.k + limitar(a.v, -6, 6) * 0.12;
      if (!cancelado && final > 0.5) {
        if (estado.cajones[g.id] !== 'abierto') { abrirCajon(g.id, false, true); sonar('clic_madera', -10, 1.05); }
        else a.objetivo = 1;
      } else {
        if (estado.cajones[g.id] === 'abierto') cerrarCajon(g.id, true);
        a.objetivo = 0;
        if (a.k > 0.02) a.v = Math.min(a.v, -1.2);           // vuelve solo, con su golpe al cerrar
      }
      break;
    }
    case 'tablilla': {
      const final = g.k + limitar(g.v, -6, 6) * 0.1;
      if (!cancelado && final > 0.55) correrTablilla(g.i, 0.22);
      else { tec.correrTablilla(g.i, 0.22, 0); if (g.visto > 0.03) sentir('tope', { db: -9, tono: 1.7, sinVibrar: true }); }
      break;
    }
    case 'cajoncito': {
      const final = g.k + limitar(g.v, -6, 6) * 0.1;
      if (!cancelado && final > 0.5) abrirCajoncito(0.25);
      else { tec.abrirCajonHija(0.22, 0); if (g.visto > 0.03) sentir('tope', { db: -9, tono: 1.7, sinVibrar: true }); }
      break;
    }
    case 'llave': {
      const t0 = llaveGirando.t, h0 = llaveGirando.holgura || 0;
      animar(0.25, k => { if (llaveGirando) { llaveGirando.t = t0 * (1 - suave(k)); llaveGirando.holgura = h0 * (1 - suave(k)); } });
      if (t0 > 0.02) sentir('muesca', { db: -4, tono: 0.85, sinVibrar: true });
      if (!cancelado && g.giro === 0) mensaje(primeraVez('girar-en-circulo') ? 'Gírala: arrastra el dedo en círculo alrededor de la cerradura.' : 'Gírala en círculo.');
      break;
    }
    case 'tapa': {
      if (!cancelado && (g.alzada || 0) > 16) llevarTapaAMesa();
      else devolverTapa();
      break;
    }
    case 'trampilla': {
      if (!cancelado) mensaje('Algo empuja desde dentro. Tira más hacia arriba.');
      break;
    }
  }
}

function girarCaja() {
  if (estado.fase !== 'jugando' || estado.ocupado || estado.nivel === 2) return;
  sonar('deslizar_madera', -10, 1.1);
  tec.girar();
  // desde la sala o desde el costado de los cajones, la cámara se aparta para ver la caja entera girar
  if (estado.vista === 'sala' || estado.vista === 'cajones') irA('caja');
  setTimeoutReloj(0.45, () => bocanada(EJE_CAJA, 600, 0, -1, 0.5));
}

for (const hueco of huecosBandeja()) {
  let mantener = null;
  hueco.addEventListener('pointerdown', e => {
    const objeto = hueco.dataset.objeto;
    if (!objeto || estado.ocupado || estado.fase !== 'jugando') return;
    desbloquearAudio();
    hueco.setPointerCapture(e.pointerId);
    arrastre = { objeto, id: e.pointerId, x: e.clientX, y: e.clientY, movido: false, fantasma: null, examinado: false };
    // mantenerlo pulsado lo examina
    clearTimeout(mantener);
    mantener = setTimeout(() => { if (arrastre && !arrastre.movido && arrastre.objeto === objeto) { arrastre.examinado = true; examinar(objeto); } }, 480);
  });
  hueco.addEventListener('pointermove', e => {
    if (!arrastre || e.pointerId !== arrastre.id) return;
    if (!arrastre.movido && Math.hypot(e.clientX - arrastre.x, e.clientY - arrastre.y) > 12) {
      arrastre.movido = true; clearTimeout(mantener);
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
    clearTimeout(mantener);
    if (!arrastre || e.pointerId !== arrastre.id) return;
    const a = arrastre; arrastre = null;
    const imagen = hueco.querySelector('img'); if (imagen) imagen.style.opacity = 1;
    if (a.fantasma) a.fantasma.remove();
    if (e.type === 'pointercancel' || a.examinado) return;
    if (!a.movido) { seleccionar(a.objeto); return; }
    const q = posicion(e); q.y -= 30;
    usarObjeto(a.objeto, tec.aPintura(q.x, q.y), q);
  };
  hueco.addEventListener('pointerup', soltar);
  hueco.addEventListener('pointercancel', soltar);
  hueco.addEventListener('keydown', e => { if ((e.key === 'Enter' || e.key === ' ') && hueco.dataset.objeto) { e.preventDefault(); seleccionar(hueco.dataset.objeto); } });
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
// La técnica: la B (DECISIÓN 29, 03-10-2026), que trae Three.js. Se prepara en cuanto carga la sala, mientras se
// ve la portada. La A está aquí y es el respaldo para los móviles sin WebGL. «?tecnica=A» (o C, la retirada, sin sus
// modelos en la página publicada) abre otra para comparar.
// ---------------------------------------------------------------------------------------------
const pedida = new URLSearchParams(location.search).get('tecnica');
const nivelPedido = Number(new URLSearchParams(location.search).get('nivel')) || 1;
const eleccion = ['A', 'B', 'C'].includes(pedida) ? pedida : 'B';
let modulo3d = null, opciones3d = null;
const preparando = {};
function prepararTecnica(letra) {
  if (tecnicas[letra]) return Promise.resolve(tecnicas[letra]);
  if (!preparando[letra]) {
    preparando[letra] = (async () => {
      modulo3d = modulo3d || await import('./tecnica_3d.js');
      opciones3d = opciones3d || { lienzo3d, camaraBoceto, escena3d, img, datos, compuesto, planchas, dibujarOjo, vistas: VISTAS, ojo: () => ojo,
        cajones: cajonesDatos, CAJONES, cajonAbertura: id => cajonAnim[id].k,
        decoracion: { sombrasBambu, rollo, ROLLO, VENTANAS }, recortarTe, nivel2,
        estado: () => estado, reloj: () => reloj, aliento: () => aliento.valor, despertar, alHornear,
        tapa: () => tapaVuelo, conTapaEnMesa: () => estado.tapaEnMesa, llaveGirando: () => llaveGirando,
        sacudida: () => (reloj < sacudida.hasta ? sacudida.fuerza * (sacudida.hasta - reloj) : 0), quieto };
      tecnicas[letra] = await modulo3d.crearTecnica(letra, opciones3d);
      return tecnicas[letra];
    })();
    preparando[letra].catch(() => { delete preparando[letra]; });
  }
  return preparando[letra];
}
async function usarTecnica(letra) {
  if (tecnicas[letra] && tec === tecnicas[letra]) return true;
  if (!tecnicas[letra]) {
    el.aviso3d.hidden = false; el.aviso3d.textContent = 'Preparando la escena 3D…';
    try {
      await prepararTecnica(letra);
    } catch (e) {
      console.error(e);
      el.aviso3d.textContent = 'Este móvil no puede abrir la escena 3D: se juega con la ilustración por capas.';
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
  return true;
}

// ---------------------------------------------------------------------------------------------
// Empezar, despertar el ojo y volver a empezar
// ---------------------------------------------------------------------------------------------
// en un móvil, al entrar: pantalla completa y en horizontal, si el navegador lo deja (si no, el aviso de girar el móvil
// lo pide). En el APK no hace falta: la app ya va a pantalla completa y en horizontal
function ponerEnHorizontal() {
  if (!matchMedia('(pointer: coarse)').matches || navigator.webdriver || location.hostname === 'appassets.androidplatform.net') return;
  const raiz = document.documentElement;
  try {
    const p = raiz.requestFullscreen ? raiz.requestFullscreen({ navigationUI: 'hide' }) : null;
    if (p && p.then) p.then(() => screen.orientation && screen.orientation.lock && screen.orientation.lock('landscape')).catch(() => {});
  } catch (e) { /* sin pantalla completa: se queda el aviso */ }
}
async function entrar(nivel = 1) {
  desbloquearAudio();
  ponerEnHorizontal();
  el.entrar.disabled = true; el.continuar.disabled = true;
  if (!(await usarTecnica(eleccion))) await usarTecnica('A');
  el.entrar.disabled = false; el.continuar.disabled = false;
  el.portada.classList.add('oculta');
  setTimeout(() => { el.portada.hidden = true; }, 950);
  bucle('noche', -13, 3);
  estado.fase = 'jugando';
  estado.vista = 'sala';
  tec.empezar ? tec.empezar(3.2) : tec.irA('sala', 3.2);
  el.volver.hidden = true;
  el.girar.hidden = false; el.inventario.hidden = false;
  if (nivel === 2 && hay3D()) {
    estadoTrasNivel1();
    await esperar(1.2);
    empezarNivel2();
    return;
  }
  lampara.proxima = reloj + 12;
  await esperar(1.3);
  sonar('ojo_abre', -4);
  animar(0.7, k => { ojo.parpadoBase = 1 - 0.65 * salida(k); }, null);
  animar(0.25, k => { ojo.parpadoBase = 0.35 + 0.25 * k; }, null, 0.85);
  animar(0.6, k => { ojo.parpadoBase = 0.6 * (1 - salida(k)); }, null, 1.25);
  await esperar(1.9);
  ojo.parpadoBase = 0;
  if (estado.vista === 'sala') mensaje('Toca la caja para acercarte. Pellizca para acercar o alejar; desliza la caja para girarla.', 5);
}
function reiniciar(nivel = 1) {
  estado = estadoInicial();
  for (const a of Object.values(cajonAnim)) Object.assign(a, { k: 0, v: 0, objetivo: 0, agarrado: false });
  pintarInventario();
  cerrarExaminar();
  Object.assign(despertar, { ojos: 0, humo: 0, trampilla: 0, oscuridad: 0 });
  ojo.visible = 1; ojo.parpadoBase = 1; ojo.entornado = 0; ojo.distraidoHasta = 0; ojo.punto = null;
  Object.assign(ojo2, { visible: 0, parpadoBase: 1, cerrado: 1, parpadeo: null, ox: 0, oy: 0, vx: 0, vy: 0 });
  Object.assign(bolsillo, { activo: false, encajada: false, abierta: 0, brillo: 0, arrastre: null, dedo: null, inicio: undefined });
  lampara.apagada = 0; tapaVuelo = null; humos.sueltos.length = 0; nubes.length = 0;
  pararBucle('fuego', 1);
  humoDelIncienso();
  hornear();
  for (const t of Object.values(tecnicas)) if (t.reiniciar) t.reiniciar();
  if (!el.tarjeta.hidden) ocultarTarjeta();
  entrar(nivel);
}
el.entrar.addEventListener('click', () => entrar(1));
el.continuar.addEventListener('click', () => entrar(2));
el.otra.addEventListener('click', () => reiniciar(1));
el.seguir.addEventListener('click', () => { desbloquearAudio(); empezarNivel2(); });
el.quedarse.addEventListener('click', () => {
  ocultarTarjeta();
  estado.fase = 'jugando';
  el.volver.hidden = estado.vista === 'sala';
  mensaje('La caja te mira con sus dos ojos. Lo demás, en la próxima entrega.', 4);
});

// Si la página se actualiza con alguien jugando, conserva por dónde iba
function restaurar(guardado) {
  if (!guardado || !guardado.estado || guardado.estado.fase === 'portada') return false;
  const g = guardado.estado;
  estado = { ...estadoInicial(), ...g, ocupado: false, seleccion: null, vista: 'sala' };
  if (estado.fase === 'despertar' || estado.fase === 'fin' || estado.fase === 'tarjeta') estado.fase = estado.nivel === 2 ? 'jugando' : 'fin';
  if (estado.tapa === 'abierta') estado.tapaEnMesa = true;
  if (estado.llave === 'cerradura') llaveGirando = { t: 0, sentido: -1, desvanece: 0 };
  tapaVuelo = estado.tapa === 'suelta' ? tapaSuelta() : null;
  if (estado.nivel === 2 && estado.hija) {
    if (estado.hija.fase === 'subiendo') estado.hija.fase = 'mesa';
    Object.assign(despertar, { ojos: 0, humo: 0, trampilla: 1, oscuridad: 0.16 });
    lampara.apagada = 0.1;
    if (estado.hija.ojo === 'puesto') Object.assign(ojo2, { visible: 1, parpadoBase: 0, cerrado: 0 });
    el.girar.hidden = true; el.inventario.hidden = false;
    el.portada.hidden = true;
    ojo.parpadoBase = 0;
    pintarInventario();
    return true;
  }
  for (const [id, st] of Object.entries(estado.cajones)) if (cajonAnim[id]) cajonAnim[id].k = cajonAnim[id].objetivo = st === 'abierto' ? 1 : 0;
  pintarInventario();
  ojo.parpadoBase = 0;
  if (estado.fase === 'fin') {
    estado.cuerno = 'puesto';
    Object.assign(despertar, { ojos: 1, humo: 1, trampilla: 1, oscuridad: 0.42 });
    ojo.visible = 0; lampara.apagada = 0.45;           // la tarjeta sale cuando esté la técnica (arrancar)
  }
  el.portada.hidden = true;
  el.girar.hidden = false; el.inventario.hidden = false;
  return true;
}

async function arrancar(guardado) {
  medir();
  el.cargando.hidden = false; el.cargando.textContent = 'Preparando la sala…';
  prepararAudio();
  try {
    const [d, cam, esc, caj, n2, ...imagenes] = await Promise.all([
      fetch('capas/capas.json').then(r => r.json()),
      fetch('capas/camara.json').then(r => r.json()),
      fetch('capas/escena.json').then(r => r.json()),
      fetch('capas/cajones.json').then(r => r.json()),
      fetch('capas/nivel2.json').then(r => r.json()),
      ...[...CAPAS, ...CAPAS_NIVEL2].map(n => new Promise((ok, mal) => {
        const i = new Image();
        i.onload = () => ok(i);
        i.onerror = () => mal(new Error(n));
        i.src = 'capas/' + n + '.webp';
      })),
    ]);
    [...CAPAS, ...CAPAS_NIVEL2].forEach((n, i) => { img[n] = imagenes[i]; });
    datos = d; camaraBoceto = cam; escena3d = esc; cajonesDatos = caj; nivel2 = n2;
    if (datos.caja) CAJA = datos.caja;
  } catch (e) {
    el.cargando.textContent = 'No se pudo cargar la ilustración. Recarga la página.';
    return;
  }
  compuesto.width = ANCHO; compuesto.height = ALTO;
  prepararOjo(); prepararOjoLuna(); prepararMotas(); prepararPuntoLuz(); prepararCapasFijas(); prepararLaca(); prepararDecoracion();
  pintarInventario();
  const restaurado = restaurar(guardado);
  hornear();
  humoDelIncienso();
  humos.te = [new Cinta(1188, 611, { ritmo: 9, vida: 2.8, vel: 13, ancho: 2.4, alfa: 0.14, tinta: 0.05, rizo: 0.8, objeto: 'te' }),
              new Cinta(1287, 627, { ritmo: 9, vida: 2.6, vel: 12, ancho: 2.2, alfa: 0.12, tinta: 0.05, rizo: 0.8, objeto: 'te' })];
  tecnicaA.activar();
  el.cargando.hidden = true;
  el.entrar.disabled = false; el.entrar.textContent = 'Entrar en la sala';
  // seguir donde se dejó: el nivel 2, si el 1 está superado (o si se pide con «?nivel=2»)
  const progreso = leerProgreso();
  if ((progreso || nivelPedido === 2) && eleccion !== 'A') {
    el.continuar.hidden = false;
    el.continuar.textContent = `Seguir: nivel 2 · ${NIVELES[2].titulo}`;
    el.entrar.textContent = 'Empezar desde el principio';
    el.entrar.classList.add('secundario');
  }
  if (restaurado) {
    if (eleccion !== 'A' && !(await usarTecnica(eleccion))) await usarTecnica('A');
    if (estado.nivel === 2 && tec.ponerHija) tec.ponerHija(estado.hija);
    if (estado.fase === 'jugando') bucle('noche', -13, 2);
    if (estado.fase === 'fin' && estado.nivel === 1) terminarNivel(1);
  } else if (eleccion !== 'A') prepararTecnica(eleccion).catch(() => {});      // mientras se mira la portada
}

const caliente = window.claude && window.claude.hot;
if (caliente && caliente.snapshot) caliente.snapshot(() => ({ estado: { ...estado, ocupado: false, seleccion: null }, tecnica: tec.nombre }));
requestAnimationFrame(cuadro);
if (caliente && caliente.ready) caliente.ready(arrancar); else arrancar((caliente && caliente.data) || {});

// En el APK (apk/): el botón «atrás» de Android cierra lo que esté abierto o vuelve a la sala, y devuelve si hizo algo
// (si no, la app pasa a segundo plano); al salir de la app el sonido se para y al volver sigue
window.__atras = () => {
  if (!el.examinar.hidden) { cerrarExaminar(); return true; }
  if (!el.nota.hidden) { cerrarNota(); return true; }
  if (estado.fase === 'jugando' && !estado.ocupado && estado.vista !== 'sala') { irA('sala'); return true; }
  return false;
};
window.__pausa = pausada => {
  if (!audio.ctx) return;
  if (pausada) audio.ctx.suspend().catch(() => {});
  else audio.ctx.resume().catch(() => {});
  ultimo = performance.now();
};

// Para la prueba automática (no hace nada si nadie la usa)
window.__prueba = {
  estado: () => estado, ojo: () => ojo, tecnica: () => tec.nombre, cara: () => tec.cara(), reloj: () => reloj,
  aPantalla: (x, y, objeto = 'caja') => { const m = tec.pantallaDe ? tec.pantallaDe(x, y, objeto) : tec.ancla({ x, y }, objeto); return m ? { x: m.x, y: m.y } : null; },
  usarTecnica: letra => usarTecnica(letra), girar: () => girarCaja(), irA: nombre => irA(nombre),
  distraer: () => { ojo.distraidoHasta = reloj + 5; },
  // la llama tiembla sola cada 14-24 s y distrae al ojo un momento: para comprobar algo con el ojo mirando, se aparta
  calmarLampara: () => { lampara.proxima = reloj + 30; tetera.proxima = Math.max(tetera.proxima, reloj + 30); if (ojo.distraidoHasta > reloj) ojo.distraidoHasta = reloj; },
  distraidoPor: () => (reloj < ojo.distraidoHasta ? { ...(ojo.distraidoPor || LAMPARA) } : null),
  centroCajon: id => centroCajon(id), cajon: id => ({ estado: estado.cajones[id], k: cajonAnim[id].k }),
  // los gestos: por dónde se tira de un cajón, dónde está la cerradura y la tapa, cuánto ha girado la llave, la lupa
  ejeCajon: id => { const e = ejeCajon(id); return { a: { x: e.a.x, y: e.a.y }, b: { x: e.b.x, y: e.b.y } }; },
  pantallaBoceto: (x, y, objeto) => { const m = tec.ancla({ x, y }, objeto); return m ? { x: m.x, y: m.y } : null; },
  llave: () => (llaveGirando ? { ...llaveGirando } : null),
  lupa: () => (tec.lupa ? tec.lupa() : 1),
  ejeHija: (parte, i) => (tec.ejeHija ? tec.ejeHija(parte, i) : null),
  inventario: () => [...estado.inventario],
  // nivel 2
  hija: () => (estado.hija ? JSON.parse(JSON.stringify(estado.hija)) : null),
  pantallaHija: (parte, i) => (tec.pantallaHija ? tec.pantallaHija(parte, i) : null),
  tablillaVista: i => !!(tec.tablillaVista && tec.tablillaVista(i)),
  tablillaHaciaCamara: i => (tec.tablillaHaciaCamara ? tec.tablillaHaciaCamara(i) : -1),
  bolsillo: () => ({ angulo: bolsillo.angulo, encajada: bolsillo.encajada, abierta: bolsillo.abierta, activo: bolsillo.activo }),
  ojo2: () => ojo2,
  examinar: objeto => examinar(objeto),
  // las señales sin texto: el vistazo del ojo hacia el frente abierto y la holgura de la tablilla que toca
  adelantarVistazo: () => { progreso.proximoVistazo = reloj; },
  vistazo: () => (ojo.vistazo && reloj < ojo.vistazo.hasta ? { ...ojo.vistazo.punto } : null),
  tablillaPos: i => (tec.tablilla ? tec.tablilla(i) : null),
  mirada: () => (tec.mirada ? tec.mirada() : null),
  // ¿el incensario se ve en (x, y) del boceto? (la máscara de su silueta en la técnica B)
  incensarioVisible: (x, y) => (tec.alfaIncensario ? tec.alfaIncensario(x, y) : 1),
  usar: (objeto, x, y, o = 'caja') => { const m = tec.ancla({ x, y }, o); usarObjeto(objeto, tec.aPintura(m.x, m.y), null); },
};
window.__tec = () => tec;

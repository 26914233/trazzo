// La caja viva ilustrada. El juego va con la técnica B (DECISIÓN 29, cerrada el 03-10-2026): la pintura del boceto
// proyectada sobre una caja 3D (Three.js, tecnica_3d.js y escena3d.js).
//   A · la ilustración por capas (2D, en un lienzo; aquí mismo): el respaldo para los móviles sin WebGL.
//   C · el modelo de Blender con tinta y acuarela: retirada; su código sigue en tecnica_3d.js como referencia.
// Aquí está todo lo que no depende de la técnica: el estado y el recorrido, el ojo, la respiración, el humo y
// la luz, los sonidos, la interfaz, los toques y la técnica A.
import { dibujarFicha, dibujarCampanilla, dibujarBadajo, tintaRollo, tintaTe, tintaSuelo, icono } from './nivel3_arte.js';
import { maderaMejilla, pintarEsquirla, pintarLaca, pintarOro, dibujarTarroLaca, dibujarSobreOro, iconoEsquirlas, muestrear } from './nivel4_arte.js';
import { dibujarTarjetaLazo, dibujarTsukegi, parteDeBorla } from './nivel5_arte.js';

// ---------------------------------------------------------------------------------------------
// Datos de la ilustración (píxeles del boceto de 1376 × 768; ver preparar_capas.py)
// ---------------------------------------------------------------------------------------------
const ANCHO = 1376, ALTO = 768;
const CAPAS = ['sala', 'sala_vacia', 'sala_mesa_vacia', 'sala_detras', 'tapa', 'incensario_abierto', 'incensario_vacio',
  'cuerno_brasas', 'llave', 'nota', 'cuerno', 'cuerno_puesto', 'despierta_ojos', 'despierta_trampilla',
  'despierta_humo', 'ojo_vacio', 'iris', 'silueta_mesa', 'silueta_caja', 'silueta_caja_detras', 'silueta_incensario',
  'silueta_te', 'laca_pared'];
const CAPAS_NIVEL2 = ['cajita', 'ojo2', 'iris2', 'hija_frente'];   // la cajita roja, el ojo nuevo y la cara de la caja pequeña
const CAPAS_NIVEL4 = ['mejilla'];                                    // la mejilla sin el hueco (herramientas/nivel4_capas.py)
const CAPAS_NIVEL5 = ['secreto'];                                    // su secreto, a tinta (herramientas/nivel5_capas.py)
const CAPAS_NIVEL6 = ['lampara_apagada'];                            // la lámpara apagada (herramientas/nivel6_capas.py)
const SONIDOS = ['noche', 'fuego', 'trabado', 'recoger', 'encajar', 'despertar', 'final_caja_viva', 'suspiro', 'ojo_abre',
  'grunido', 'espiritu', 'papel', 'llave', 'candado_abre', 'tope_madera', 'clic_madera', 'acercar', 'pista', 'toque',
  'mecanismo', 'racha', 'bisagra', 'deslizar_madera', 'cajon', 'trampilla', 'cristal', 'viento', 'clic_metal',
  'holgura', 'clac', 'pestillo', 'desbloqueo',                 // el vocabulario (herramientas/sonidos_vocabulario.py)
  'campanilla', 'campanilla_muda', 'tin', 'vertido', 'tarareo', 'canto', 'latido', 'anillo',   // niveles 3 y final
  'crac', 'pincel', 'oro',                                     // nivel 4 (herramientas/sonidos_nivel4.py)
  'toc', 'toc_hueco', 'clinc', 'ronquido', 'seda', 'azufre', 'soplo', 'mecha'];   // niveles 5 y 6 (sonidos_nivel5.py)

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
  // nivel 3 (solo en la B): la tetera y las tazas, de cerca, para volcar el té
  te:         { h: [1110, 430, 1376, 705], v: [1130, 400, 1376, 720] },
  // nivel 3: el cajón largo de la espalda, de cerca (con sitio delante para cuando sale)
  largo:      { h: [690, 380, 1020, 640], v: [700, 360, 1010, 660] },
  // nivel final: el corazón en la tapa, mirado desde arriba, con la cara debajo (sus ojos ayudan)
  corazon:    { h: [660, 40, 1200, 520], v: [690, 40, 1170, 560] },
  // nivel 4: la peana de cerca, con sus tres olas de oro y el cajón del centro
  zocalo:     { h: [672, 528, 988, 690], v: [690, 520, 970, 700] },
  // nivel 5: la espalda de cerca (sus cajones) y el costado de la borla (solo cuenta su tamaño: ver tecnica_3d.js)
  espalda:    { h: [690, 222, 1012, 572], v: [700, 216, 1002, 580] },
  borla:      { h: [770, 250, 1010, 580], v: [760, 230, 1020, 610] },      // la borla entera, también tirada hacia abajo
  // nivel 6: la lámpara de cerca (un recorte del boceto, como la sala), con su puertecilla
  lampara:    { h: [446, 196, 766, 444], v: [500, 190, 710, 450] },
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
  3: { titulo: 'La voz', pieza: 'voz', texto: 'Ya tiene el cuerno, los ojos y la voz. Canta, muy bajo.' },
  4: { titulo: 'El oro', pieza: 'oro', texto: 'Su mejilla, curada con oro. No esconde la grieta: la luce.' },
  5: { titulo: 'La cómoda', pieza: 'secreto', texto: 'Te ha enseñado lo que guarda: le teme a la noche.' },
  6: { titulo: 'La noche', pieza: 'luz', texto: 'Ya no le teme a la oscuridad.' },
  7: { titulo: 'El corazón', texto: 'Late tranquila, con la cara entera. Te ha abierto su corazón.' },
};
const ULTIMO_NIVEL = 7;
const NIVEL_FINAL = ULTIMO_NIVEL;
const nombreNivel = n => (n >= ULTIMO_NIVEL ? 'Nivel final' : `Nivel ${n}`);
const CLAVE_PARTIDA = 'caja_viva_partida';
const CLAVE_EN_CURSO = 'caja_viva_en_curso';      // el nivel a medias (si Android cierra la app, «Seguir» vuelve ahí)
// Nivel 3 · La voz (NIVELES.md §6): la luz fría del ojo de piedra de luna, la ficha del rollo, el cajón largo de la
// espalda, la tetera y la boca. En píxeles del boceto (los de la espalda, en el boceto de espaldas)
const HUECO_FICHA = { x: 846, y: 368 };              // el hueco con forma de ficha, en la espalda
const LARGO = ['rect', 715, 474, 990, 558];           // el cajón largo, en la espalda
const BOCA = { x: 848, y: 483, ang: 0.135, ancho: 82 };    // la raya entre los labios
const VARILLA_ROLLO = { x: 414, y: 322 };             // el extremo de la varilla del rollo, por donde sale la ficha
const FICHA_SUELO = { x: 386, y: 474 };               // donde cae, en el tatami
const PICO_TETERA = { x: 1207, y: 511 };
const UMBRAL_ROLLO = 0.1;                              // cuánto tiene que mecerse el rollo para que caiga la ficha (rad)
const NOTAS = {
  1: 'Me falta un cuerno.<br>Lo guarda el león<br>que respira humo.',
  3: 'Me falta la voz.<br>Duerme a mi espalda,<br>sin lengua.',
};
// las tintas que solo se ven a la luz fría (nivel3_arte.js): dónde están y qué dicen al descubrirlas
const TINTAS = {
  rollo: { x: 326, y: 196, objeto: 'sala', escala: 0.85, dibujar: tintaRollo,
    texto: 'A la luz fría, en el rollo: una ficha de shōgi en rojo… y una flecha que baja a la varilla.' },
  te: { x: 1306, y: 392, objeto: 'sala', escala: 0.78, dibujar: tintaTe,
    texto: 'En la madera, junto a la tetera: alguien vierte el té, y algo pequeño cae en la taza.' },
  suelo: { x: 250, y: 562, objeto: 'sala', escala: 0.9, dibujar: tintaSuelo,
    texto: 'En el tatami, tres trazos como una respiración. La campanilla está en el que baja.' },
};
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
  volver: $('volver'), pista: $('boton-pista'), botonMenu: $('boton-menu'), girar: $('boton-girar'),
  mensaje: $('mensaje'), portada: $('portada'), entrar: $('boton-entrar'), nota: $('nota'),
  otra: $('boton-otra'), cargando: $('cargando'), inventario: $('inventario'), bandeja: $('bandeja'), etiqueta: $('etiqueta-objeto'),
  examinar: $('examinar'), examinarImg: $('examinar-img'), examinarNombre: $('examinar-nombre'), examinarTexto: $('examinar-texto'),
  aviso3d: $('aviso3d'), bolsillo: $('bolsillo'), examinarAyuda: $('examinar-ayuda'), vitrina3d: $('vitrina3d'),
  tarjeta: $('tarjeta'), tarjetaHecho: $('tarjeta-hecho'), tarjetaTitulo: $('tarjeta-titulo'), tarjetaTexto: $('tarjeta-texto'),
  tarjetaSiguiente: $('tarjeta-siguiente'), seguir: $('boton-seguir'), quedarse: $('boton-quedarse'), continuar: $('boton-continuar'),
  // los menús (inicio, pausa, niveles, opciones y la confirmación) y «Mirar»
  botonNiveles: $('boton-niveles'), botonOpciones: $('boton-opciones'), botonSalir: $('boton-salir'), portadaNota: $('portada-nota'),
  menu: $('menu'), menuNivel: $('menu-nivel'), menuSeguir: $('menu-seguir'), menuReiniciar: $('menu-reiniciar'), menuInicio: $('menu-inicio'),
  menuSalir: $('menu-salir'), niveles: $('niveles'), listaNiveles: $('lista-niveles'), nivelesVolver: $('niveles-volver'),
  opciones: $('opciones'), opcionesVolver: $('opciones-volver'), confirmar: $('confirmar'), confirmarTexto: $('confirmar-texto'),
  confirmarDetalle: $('confirmar-detalle'), confirmarSi: $('confirmar-si'), confirmarNo: $('confirmar-no'), mirar: $('boton-mirar'),
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
    // en el nivel 3: { nota: boca | mano, tintas: {rollo, te, suelo}, ficha: rollo | cayendo | suelo | mano | puesta,
    //                  fichaCara: peon | promovida, largo: cerrado | suelto | abierto, campanilla: cajon | mano | puesta,
    //                  badajo: tetera | taza | mano | puesto, completa, toques (respuestas de la caja), labios (0…1) }
    n3: null,
    // en el nivel final: { fase: subiendo | anillos | centro | abierto, subida, angulos [3], bloqueados [3], ranura, marca,
    //                      voz (los sitios de los anillos, en octavos de vuelta), hija: mesa | mano | puesta, giroHija,
    //                      centro, latido, luz (donde alumbra el ojo nuevo, en el corazón) }
    fin: null,
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
  audio.maestro.gain.value = audio.mudo ? 0 : 0.9;
  // un limitador a la salida: el clímax del final (canto, desbloqueo y latidos a la vez) llegaba a saturar
  const limite = audio.ctx.createDynamicsCompressor ? audio.ctx.createDynamicsCompressor() : null;
  if (limite) {
    limite.threshold.value = -6; limite.knee.value = 3; limite.ratio.value = 4; limite.attack.value = 0.003; limite.release.value = 0.25;
    audio.maestro.connect(limite); limite.connect(audio.ctx.destination);
  } else audio.maestro.connect(audio.ctx.destination);
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
  if (!audio.ctx) return;
  // si ya suena, va al volumen nuevo (cada nivel pone el suyo: el 6, a oscuras, más alto)
  const ya = audio.bucles[nombre];
  if (ya) {
    const ahora = audio.ctx.currentTime;
    ya.base = Math.pow(10, db / 20);
    ya.g.gain.cancelScheduledValues(ahora); ya.g.gain.setValueAtTime(Math.max(0.0001, ya.g.gain.value), ahora);
    ya.g.gain.linearRampToValueAtTime(ya.base, ahora + Math.max(0.05, fundido));
    return;
  }
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
// los ajustes del jugador (menú de opciones): se guardan en el móvil
const ajustes = (() => {
  const d = { sonido: true, vibracion: true };
  try { return { ...d, ...JSON.parse(localStorage.getItem('caja_viva_ajustes') || '{}') }; } catch (e) { return d; }
})();
function guardarAjustes() { try { localStorage.setItem('caja_viva_ajustes', JSON.stringify(ajustes)); } catch (e) { /* nada */ } }
function vibrar(ms) { if (!ajustes.vibracion) return; try { if (navigator.vibrate) navigator.vibrate(ms); } catch (e) { /* sin vibración */ } }
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
  trabado:    { sonido: 'trabado', db: -7, vibrar: 35 },                      // no se puede, ahora
};
function sentir(evento, { tono = 1, db = 0, sinVibrar = false } = {}) {
  const v = VOCABULARIO[evento];
  if (!v) return;
  // cada vez un poco distinto (±3 % de tono, ±1 dB): el mismo sonido para lo mismo, pero sin sonar a disco rayado
  sonar(v.sonido, (v.db || 0) + db + azar(-1, 1), (v.tono || 1) * tono * azar(0.97, 1.03));
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
  const h = estado.hija, n3 = estado.n3;
  return [estado.nivel, estado.llave, estado.nota, estado.tapa, estado.cuerno, estado.inventario.length,
    Object.values(estado.cajones).join(''), h ? [h.fase, h.tablillas.join(''), h.cajon, h.cajita, h.ojo].join('') : '',
    n3 ? [n3.nota, Object.keys(n3.tintas).join(''), n3.ficha, n3.fichaCara, n3.largo, n3.campanilla, n3.badajo, n3.toques].join('') : '',
    estado.n4 ? [estado.n4.esquirlas.join(''), estado.n4.zocalo, estado.n4.laca, estado.n4.oro, estado.n4.pieza, estado.n4.oida].join('') : '',
    estado.n5 ? [Object.values(estado.n5.cajones).join(''), ...['m1', 'c', 'p', 'tarjeta', 'llave', 'cordon', 'lazo', 'borla', 'c6', 'tsukegi', 'secreto'].map(k => estado.n5[k])].join('') : '',
    estado.n6 ? [...['lampara', 'puerta', 'tinta', 'mecha', 'brasas'].map(k => estado.n6[k]), Math.round(noche.shoji * 3)].join('') : '',
    estado.fin ? [estado.fin.fase, estado.fin.bloqueados.join(''), estado.fin.hija].join('') : ''].join('|');
}
// lo que la caja teme: el frente abierto ahora mismo (o nada, si ya lo vigila)
function frenteAbierto() {
  const h = estado.hija, n3 = estado.n3, n4 = estado.n4, n5 = estado.n5;
  if (estado.nivel === 6) return null;                    // (a oscuras no ve)
  if (estado.nivel === 5 && n5) {
    if (n5.pasador === 'quitado' && n5.tsukegi === 'c2') return centroCajon('c2');
    if (n5.secreto === 'c6' && n5.c6 === 'suelto') return centroCajon('c6');
    return null;                                          // lo demás está a su espalda y en el otro costado
  }
  if (estado.nivel === 4 && n4 && nivel4) {
    if (n4.esquirlas[0] === 'peana') return ESQUIRLA_PEANA;
    if (n4.esquirlas[1] === 'lampara') return { x: nivel4.lampara.sombra[0], y: nivel4.lampara.sombra[1] };
    if (n4.zocalo !== 'abierto' || n4.esquirlas[2] === 'zocalo') return { x: nivel4.olas[1].x, y: nivel4.olas[1].y };
    return null;                                          // lo demás es su propia cara
  }
  if (estado.nivel === 3 && n3) {
    if (n3.nota === 'boca') return null;                  // (se lo ofrece ella)
    if (n3.ficha === 'rollo') return VARILLA_ROLLO;
    if (n3.ficha === 'suelo') return FICHA_SUELO;
    if (n3.badajo === 'tetera' && n3.campanilla !== 'cajon') return TAPA_TETERA;
    if (n3.badajo === 'taza') return TAZAS[0];
    return null;                                          // lo demás está a su espalda, o en su boca
  }
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
  if (f !== progreso.guardada && estado.fase === 'jugando' && !estado.ocupado && guardarEnCurso()) progreso.guardada = f;
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
  // en el nivel final ya no vigila: señala la ranura donde va el cuerno
  const f = estado.fin, ranura = estado.nivel === NIVEL_FINAL && f && f.fase === 'anillos' && !f.bloqueados[0] && tec.corazonEnBoceto
    ? tec.corazonEnBoceto(0.1045, f.ranura * Math.PI / 4) : null;
  if (ranura) objetivo = haciaPunto(ranura);
  else if (reloj < ojo.distraidoHasta) objetivo = haciaPunto(ojo.distraidoPor || LAMPARA);
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
    // (desde el nivel 3 su mirada da luz: vaga por sitios donde no hay tinta, para que la descubras tú)
    ojo2.punto = elegir(estado.nivel >= 3
      ? [{ x: 1100, y: 40 }, { x: 1250, y: 120 }, { x: 330, y: 70 }, { x: 60, y: 300 }, { x: 960, y: 10 }, { x: 560, y: 120 }]
      : [{ x: 1100, y: 40 }, { x: 1250, y: 120 }, { x: 330, y: 160 }, { x: 60, y: 300 }, { x: 960, y: 10 }, { x: 1376, y: 360 }]);
    ojo2.proximoVagar = reloj + azar(2.2, 5.5);
  }
  const p = (reloj < luzFria.guiadaHasta && luzFria.punto) || ojo2.punto || { x: 1100, y: 40 };
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
// La luz fría (nivel 3): el ojo de piedra de luna alumbra lo que mira, y su luz descubre tinta que no se ve. Como no te
// mira, va al revés de tu dedo: para que alumbre algo, pon el dedo al otro lado de la cara (la regla, invertida: ahora
// conviene que mire). Sin dedo, la luz vaga con su mirada.
// ---------------------------------------------------------------------------------------------
const luzFria = { x: 1100, y: 40, vx: 0, vy: 0, fuerza: 0, guiadaHasta: 0, punto: null };
const espejoLuz = p => ({ x: limitar(CUENCA.x + (CUENCA.x - p.x) * 1.6, 10, ANCHO - 10), y: limitar(CUENCA.y + (CUENCA.y - p.y) * 1.6, 10, ALTO - 10) });
const luzActiva = () => (estado.nivel === 3 || estado.nivel === 6 || estado.nivel >= NIVEL_FINAL) && estado.fase === 'jugando' && ojo2.visible > 0.5
  && caraVisible() === 'frente' && !(estado.nivel === 6 && estado.n6 && estado.n6.lampara === 'encendida');
function guiarLuz(p) {
  if (estado.nivel === 6 || !luzActiva() || !p || p.cara === 'detras' || p.hija) return;      // (en el 6 la mueve moverLuz6)
  // (en el nivel final la caja ya no se defiende: el ojo nuevo alumbra lo que tocas)
  luzFria.punto = estado.nivel >= NIVEL_FINAL ? { x: p.x, y: p.y } : espejoLuz(p);
  luzFria.guiadaHasta = reloj + 4;
  ojo2.proximoVagar = Math.max(ojo2.proximoVagar, reloj + 4);
  // (se da por vista cuando sale de verdad: si había otro mensaje, se intenta otra vez la próxima vez)
  if (!estado.vistos['luz-guiada']) setTimeoutReloj(1.2, () => { if (!mensajeHasta && primeraVez('luz-guiada')) mensaje('La luz fría se va al otro lado de tu dedo.', 3.2); });
}
// dónde cae la luz: en qué se ancla (la tetera, el incensario, la caja o la sala)
function objetoBajo(p) {
  if (dentro(['rect', 1140, 470, 1376, 700], p)) return 'te';
  if (dentro(INCENSARIO, p)) return 'incensario';
  if (dentro(['poli', CAJA], p)) return 'caja';
  return 'sala';
}
function actualizarLuzFria(dt) {
  luzFria.fuerza = mezclar(luzFria.fuerza, luzActiva() ? 1 : 0, 1 - Math.exp(-dt * 3));
  const guiada = reloj < luzFria.guiadaHasta && luzFria.punto;
  const p = guiada ? luzFria.punto : (ojo2.punto || { x: 1100, y: 40 });
  const k = 30, am = 2 * Math.sqrt(k) * 0.92;
  for (let r = dt; r > 0; r -= 1 / 120) {
    const h = Math.min(r, 1 / 120);
    luzFria.vx += ((p.x - luzFria.x) * k - luzFria.vx * am) * h;
    luzFria.vy += ((p.y - luzFria.y) * k - luzFria.vy * am) * h;
    luzFria.x += luzFria.vx * h; luzFria.y += luzFria.vy * h;
  }
  const n3 = estado.n3, f = luzFria.fuerza * (1 - ojo2.cerrado);
  if (estado.nivel !== 3) return;
  for (const [id, t] of Object.entries(TINTAS)) {
    const d = Math.hypot(luzFria.x - t.x, luzFria.y - t.y);
    const alumbrada = limitar(1 - (d - 45) / 85, 0, 1) * f;
    t.vis = Math.max(alumbrada, n3 && n3.tintas[id] ? 0.16 : 0);
    // se descubre si la luz se queda encima (guiada por ti) un momento
    t.acum = alumbrada > 0.6 && guiada ? (t.acum || 0) + dt : Math.max(0, (t.acum || 0) - dt);
    if (n3 && !n3.tintas[id] && t.acum > 1.1) revelarTinta(id);
  }
}
function revelarTinta(id) {
  estado.n3.tintas[id] = true;
  sonar('cristal', -14, 0.8); sonar('espiritu', -20, 1.5);
  mensaje(TINTAS[id].texto, 5.5);
}
// en la B, encima de la escena: las tintas (con su visibilidad) y la luz, del ojo a donde mira
function dibujarTintas(conAncla) {
  for (const [id, t] of Object.entries(TINTAS)) {
    if (!t.lienzo || !(t.vis > 0.01)) continue;
    conAncla(t.x, t.y, t.objeto, () => {
      ctx.save();
      if (id === 'rollo') { const g = ROLLO.gancho; ctx.translate(g.x, g.y); ctx.rotate(rollo.a); ctx.translate(-g.x, -g.y); }
      const w = t.lienzo.width * t.escala, h = t.lienzo.height * t.escala;
      ctx.globalAlpha = t.vis;
      ctx.drawImage(t.lienzo, t.x - w / 2, t.y - h / 2, w, h);
      ctx.restore();
    });
  }
}
function dibujarLuzFria(conAncla) {
  const f = luzFria.fuerza * (1 - ojo2.cerrado);
  if (f < 0.01) return;
  const objeto = objetoBajo(luzFria);
  const a = tec.ancla(CUENCA, 'caja');
  let b = tec.ancla({ x: luzFria.x, y: luzFria.y }, objeto);
  // en el final la luz cae en el corazón, encima de la tapa: donde se toca o, si no, en su centro
  const fin = estado.fin, enCorazon = estado.nivel === NIVEL_FINAL && fin && fin.subida > 0.5 && tec.corazonEnPantalla;
  if (enCorazon && a) {
    const L = fin.luz && reloj < fin.luz.hasta ? fin.luz : { r: 0, alfa: 0 }, q = tec.corazonEnPantalla(L.r, L.alfa);
    b = q ? { x: q.x, y: q.y, k: a.k * 0.8, visible: true } : null;
  }
  if (!a || !b || !a.visible || !b.visible) return;
  const dx = b.x - a.x, dy = b.y - a.y, L = Math.hypot(dx, dy) || 1, nx = -dy / L, ny = dx / L, w0 = 3 * a.k, w1 = 46 * b.k;
  ctx.setTransform(ppp, 0, 0, ppp, 0, 0);
  const g = ctx.createLinearGradient(a.x, a.y, b.x, b.y);
  g.addColorStop(0, `rgba(185, 212, 255, ${0.34 * f})`); g.addColorStop(1, `rgba(170, 200, 255, ${0.1 * f})`);
  ctx.fillStyle = g;
  ctx.beginPath(); ctx.moveTo(a.x + nx * w0, a.y + ny * w0); ctx.lineTo(b.x + nx * w1, b.y + ny * w1);
  ctx.lineTo(b.x - nx * w1, b.y - ny * w1); ctx.lineTo(a.x - nx * w0, a.y - ny * w0); ctx.closePath(); ctx.fill();
  if (enCorazon) { ctx.setTransform(ppp, 0, 0, ppp, 0, 0); brillo(ctx, b.x, b.y, 60 * b.k, '150,190,255', 0.42 * f); return; }
  conAncla(luzFria.x, luzFria.y, objeto, () => { brillo(ctx, luzFria.x, luzFria.y, 84, '150,190,255', 0.5 * f); brillo(ctx, luzFria.x, luzFria.y, 30, '225,238,255', 0.4 * f); });
}

// ---------------------------------------------------------------------------------------------
// Respiración de la caja (contiene el aliento cuando la fuerzan)
// ---------------------------------------------------------------------------------------------
const aliento = { fase: 0, valor: 0, contenidoHasta: 0, soltando: 0, soplo: 0, seno: 0 };
function contenerAliento(segundos = 1.8) {
  if (reloj >= aliento.contenidoHasta) atenuarAmbiente(segundos);
  aliento.contenidoHasta = reloj + segundos;
}
// ¿está soltando el aire? (en el nivel 3, es cuando contesta a la campanilla)
const exhalando = () => reloj >= aliento.contenidoHasta && (aliento.soltando > 0 || Math.sin(aliento.fase) < -0.05);
function actualizarAliento(dt) {
  const antes = aliento.valor;
  if (reloj < aliento.contenidoHasta) {
    aliento.valor = mezclar(aliento.valor, 1, 1 - Math.exp(-dt * 6));
    aliento.soltando = 0.6;
  } else if (aliento.soltando > 0) {
    aliento.soltando -= dt;
    aliento.valor = mezclar(aliento.valor, 0, 1 - Math.exp(-dt * 9));
    if (aliento.soltando <= 0) aliento.fase = 0;            // vuelve a tomar aire desde vacía (sin saltos)
  } else {
    aliento.fase += dt * (Math.PI * 2 / 4.8) * (1 + 0.15 * Math.sin(reloj * 0.21)) * (sueno.dormida ? 0.62 : 1);
    aliento.valor = 0.5 - 0.5 * Math.cos(aliento.fase);
  }
  // cuánto aire mueve (positivo al tomarlo): en el nivel 3 tira del humo del incienso, y al empezar a soltarlo sale vaho
  aliento.soplo = mezclar(aliento.soplo, (aliento.valor - antes) / Math.max(dt, 1e-3), 1 - Math.exp(-dt * 6));
  const seno = Math.sin(aliento.fase), n3 = estado.n3;
  if (estado.nivel === 3 && n3 && n3.labios < 1 && estado.fase === 'jugando' && aliento.seno >= 0 && seno < 0 && reloj >= aliento.contenidoHasta) {
    vaho();
    if (n3.completa) sonar('suspiro', -26, 1.3);
  }
  aliento.seno = seno;
}
// un poco de vaho entre los labios: la caja suelta el aire
function vaho() {
  for (let i = 0; i < 4; i++) {
    nubes.push({ x: BOCA.x + azar(-14, 14), y: BOCA.y + 4, ax: BOCA.x, ay: BOCA.y, objeto: 'caja', vx: azar(-8, 8), vy: azar(4, 12),
      r0: azar(3, 5), r1: azar(16, 26), t: -i * 0.1, vida: azar(1.4, 2), alfa: 0.2, color: '236,236,240' });
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
      // en el nivel 3 la caja respira más hondo y el humo del incienso va hacia ella al tomar aire (y se aparta al soltarlo)
      if (this.objeto === 'incensario' && estado.nivel === 3) n.vx += aliento.soplo * 40 * dt;
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
function polvareda(x, y, objeto = 'incensario') {
  for (let i = 0; i < 7; i++) {
    const lado = i % 2 ? 1 : -1;
    nubes.push({ x: x + lado * azar(20, 50), y: y + azar(-4, 2), ax: x, ay: y, objeto, vx: lado * azar(14, 30),
      vy: azar(-10, -3), r0: azar(3, 5), r1: azar(12, 20), t: -i * 0.03, vida: azar(0.8, 1.3), alfa: 0.26, color: '214,196,170' });
  }
}
// polvo fino que sale de un cajón viejo al abrirlo: poco, del color de la madera, y se posa enseguida
function polvoDeCajon(x, y, objeto = 'caja') {
  for (let i = 0; i < 6; i++) {
    nubes.push({ x: x + azar(-6, 6), y: y + azar(-4, 4), ax: x, ay: y, objeto, vx: azar(8, 22), vy: azar(-9, 2),
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
    if (reloj > ojo.distraidoHasta && !vigilaLaPequena() && estado.nivel < 4) { ojo.distraidoPor = LAMPARA; ojo.distraidoHasta = reloj + 1.3; }
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
function destello(x, y, r, color, alfa, duracion, objeto = 'caja') { destellos.push({ x, y, r, color, alfa: quieto ? alfa * 0.4 : alfa, duracion, t: 0, objeto }); }
const despertar = { ojos: 0, humo: 0, trampilla: 0, oscuridad: 0 };

// Las luces y el humo de un objeto, en coordenadas del boceto (las usa cada técnica a su manera)
function luces(objeto) {
  const l = [];
  const li = lampara.intensidad;
  if (objeto === 'sala') {
    l.push([LAMPARA.x, LAMPARA.y, 230, '255,176,96', 0.12 * li], [LAMPARA.x, LAMPARA.y - 6, 70, '255,214,150', 0.16 * li]);
  }
  if (objeto === 'incensario' && estado.tapa === 'abierta') {
    const f = (0.75 + 0.25 * Math.sin(reloj * 5.1) * Math.sin(reloj * 2.3 + 1)) * (enLaNoche() ? 0.25 + 1.2 * noche.brasa : 1);
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
  if (tetera3.inclinacion > 0.02) return;                 // volcada, la tapa no salta
  tetera.t = 0; tetera.fuerza = fuerza;
  for (let i = 0; i < 3; i++) setTimeoutReloj(i * 0.11, () => sonar('clic_metal', -21 + 3 * fuerza, azar(1.45, 1.8)));
  setTimeoutReloj(0.08, () => bocanada(TAPA_TETERA.x - 8, TAPA_TETERA.y - 10, -0.2, -1, 0.15, 'te'));
  // nivel 3: con la tapa, dentro tintinea el badajo
  if (estado.nivel === 3 && estado.n3 && estado.n3.badajo === 'tetera') setTimeoutReloj(0.17, () => sonar('tin', -21 + 4 * fuerza, 1.45));
}
// nivel 3: la tetera volcada con el dedo (0 de pie … 1 del todo) y el té que cae
const tetera3 = { inclinacion: 0, vertido: 0, chorro: 0, sonandoHasta: 0 };
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
    if (reloj > ojo.distraidoHasta && !vigilaLaPequena() && ojo.parpadoBase < 0.5 && estado.nivel < 4) { ojo.distraidoPor = TAPA_TETERA; ojo.distraidoHasta = reloj + 1.1; }
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
  const oscuras = enLaNoche(), L = oscuras ? { x: luzFria.x, y: luzFria.y + 14 } : LAMPARA, agitada = reloj < lampara.agitadaHasta;
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
    if (!oscuras && !agitada && p.susto <= 0 && Math.random() < dt * 0.07 && Math.abs(p.x - L.x) < 48 && p.y > 228 && p.y < 410) {
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
cajonAnim.largo = { k: 0, v: 0, objetivo: 0, agarrado: false, golpe: 0 };      // el cajón largo de la espalda (nivel 3)
cajonAnim.zocalo = { k: 0, v: 0, objetivo: 0, agarrado: false, golpe: 0 };     // el cajón de la peana (nivel 4)
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
  const def = CAJONES[id], n5 = estado.n5;
  if (estado.nivel >= 5 && n5 && id === 'c2') return n5.tsukegi === 'c2' ? 'Dentro, un manojo de tiras de ciprés con la punta amarilla.' : 'Vacío. Huele a azufre.';
  if (estado.nivel >= 5 && n5 && id === 'c6') return n5.secreto === 'c6' ? 'Dentro, un papel doblado. Lo más guardado de la caja.' : 'Vacío.';
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
  const def = CAJONES[id], n5 = estado.nivel >= 5 ? estado.n5 : null, en5 = estado.nivel === 5 && !!n5;
  // nivel 5: la llave metida en c6 se empuja tocándola
  if (en5 && id === 'c6' && n5.llave === 'metida') { empujarLlave5(); return; }
  if (tieneCerradura(id)) {
    const c = centroCajon(id);
    cajonCerrado(id, c.x, c.y, 1, -0.6, n5 && id === 'c6' && n5.c6 === 'suelto' ? 'Ya no tiene cerradura, pero algo lo sujeta por dentro.' : 'Tiene una cerradura pequeña. No cede.');
    return;
  }
  const a = cajonAnim[id];
  if (en5 && id === 'c6' && estado.cajones.c6 !== 'abierto' && !sueno.dormida) { guardarSecreto(); return; }
  if (n5 && estado.cajones[id] === 'abierto' && a.k >= 0.7) {
    if (id === 'c2' && n5.tsukegi === 'c2' && estado.nivel <= 6) { cogerTsukegi(); return; }
    if (en5 && id === 'c6' && n5.secreto === 'c6') { cogerSecreto(); return; }
  }
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
// (soloTetera: sin las tazas, para la tetera que se vuelca en el nivel 3)
function mascaraTe(dx = 0, dy = 0, ancho = ANCHO, alto = ALTO, soloTetera = false) {
  const m = document.createElement('canvas'); m.width = ancho; m.height = alto;
  const k = m.getContext('2d');
  k.translate(-dx, -dy); k.fillStyle = '#fff'; k.strokeStyle = '#fff'; k.lineWidth = 3; k.lineJoin = 'round';
  for (const poli of soloTetera ? FORMAS_TE.polis.slice(2) : FORMAS_TE.polis) {
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
function recortarTe(lienzo, dx = 0, dy = 0, soloTetera = false) {
  const k = lienzo.getContext('2d');
  k.globalCompositeOperation = 'destination-in';
  k.drawImage(mascaraTe(dx, dy, lienzo.width, lienzo.height, soloTetera), 0, 0);
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
  // nivel 4: la mejilla, curada con oro (el oro del borde y de la grieta, cuando ya ha corrido)
  if (estado.n4 && estado.n4.pieza === 'puesta' && img.mejilla && nivel4) {
    const m = nivel4.mejilla;
    c.drawImage(img.mejilla, m.x, m.y);
    for (const j of nivel4.juntas) pintarOro(c, j, null, 1.55, { hasta: 1 });
    if (oroBorde >= 1) {
      pintarOro(c, [...nivel4.contorno, nivel4.contorno[0]], null, 1.8, { hasta: 1 });
      pintarOro(c, nivel4.grieta, null, 1.55, { hasta: 1 });
    }
  }
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
  // (de cerca, el mensaje va a un lado para no tapar lo que se toca: la boca, los cajones, la tetera…)
  $('juego').classList.toggle('mensaje-al-lado', ['hija', 'cajones', 'te', 'largo', 'corazon', 'zocalo', 'espalda', 'borla'].includes(nombre) || (nombre === 'cara' && estado.nivel >= 3));
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
  if (estado.nivel >= 3) { dibujarNivel3Encima(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
  if (estado.nivel >= 4) { dibujarNivel4Encima(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
  if (estado.nivel === 5) { dibujarNivel5Encima(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
  if (estado.nivel === 6) { dibujarNivel6Debajo(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); dibujarNoche(); }
  if (despertar.oscuridad > 0) {
    c.setTransform(ppp, 0, 0, ppp, 0, 0);
    c.fillStyle = `rgba(6, 4, 8, ${despertar.oscuridad})`; c.fillRect(0, 0, ancho, alto);
  }
  c.globalCompositeOperation = 'lighter';
  if (estado.nivel >= 3) { dibujarLuzFria(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
  if (estado.nivel === 4) { dibujarLuzOlas(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
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
  if (estado.nivel === 6) { dibujarNivel6Encima(conAncla); c.setTransform(ppp, 0, 0, ppp, 0, 0); }
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
  // nivel 3 (los iconos se dibujan por código: prepararNivel3)
  ficha: { nombre: 'Ficha de shōgi', texto: 'Un peón de madera, 歩. Por detrás tiene otra cara.', icono: '', capa: 'ficha' },
  campanilla: { nombre: 'Campanilla de bronce', texto: 'Pequeña y pesada. No tiene badajo: no suena.', icono: '', capa: 'campanilla' },
  badajo: { nombre: 'Badajo de bronce', texto: 'Mojado de té. La lengua de una campanilla.', icono: '', capa: 'badajo' },
  // nivel 4 (los iconos se dibujan por código: prepararNivel4)
  esquirlas: { nombre: 'Esquirlas de la mejilla', texto: 'Madera clara, con la veta de su cara.', icono: '', capa: 'esquirla' },
  mejilla: { nombre: 'El pedazo de la mejilla', texto: 'Las tres esquirlas, montadas.', icono: '', capa: 'mejilla_pieza' },
  laca: { nombre: 'Laca de urushi', texto: 'Negra y espesa, con su pincel en la tapa. Pega lo roto… cuando cura.', icono: '', capa: 'laca' },
  oro: { nombre: 'Polvo de oro', texto: 'Un sobre de papel con el sello 金. Pesa casi nada.', icono: '', capa: 'oro' },
  // nivel 5 (los iconos se dibujan por código: prepararNivel5)
  tarjeta: { nombre: 'Tarjeta del lazo', texto: 'Un lazo dibujado a tinta. Una flecha tira de la cola de la punta negra.', icono: '', capa: 'tarjeta' },
  tsukegi: { nombre: 'Manojo de tsukegi', texto: 'Tiras finas de ciprés con la punta de azufre. Prenden con una brasa.', icono: '', capa: 'tsukegi' },
  secreto: { nombre: 'Su secreto', texto: 'Un dibujo a tinta: esta sala, de noche, con la lámpara apagada. En el dibujo, la caja tiembla.',
    icono: 'capas/secreto.webp', capa: 'secreto' },
  // nivel final
  hija: { nombre: 'La caja pequeña', texto: 'Cerrada otra vez. Cabe justa en la mano… y en algún hueco.', icono: 'capas/hija_frente.webp', capa: 'hija' },
};
const huecosBandeja = () => [...el.bandeja.querySelectorAll('.hueco')];
const huecoDe = objeto => huecosBandeja().find(h => h.dataset.objeto === objeto) || null;
// «Mirar» (o «Leer», con la nota): junto al objeto elegido de la bandeja
function pintarMirar() {
  const id = estado.seleccion, h = id && huecoDe(id);
  const ver = !!h && estado.fase === 'jugando' && !el.inventario.hidden;
  el.mirar.hidden = !ver;
  if (!ver) return;
  el.mirar.querySelector('span').textContent = id === 'nota' ? 'Leer' : 'Mirar';
  el.mirar.setAttribute('aria-label', id === 'nota' ? 'Leer la nota' : `Mirar de cerca: ${OBJETOS[id].nombre}`);
  const r = h.getBoundingClientRect(), j = $('juego').getBoundingClientRect();
  el.mirar.style.setProperty('--y', (r.top - j.top + r.height / 2) + 'px');
  el.mirar.style.setProperty('--x', (r.left - j.left + r.width / 2) + 'px');
}
function pintarInventario() {
  // la bandeja tiene cuatro huecos; si se lleva más, se añade otro (si no, el objeto no se vería ni se podría usar)
  while (huecosBandeja().length < estado.inventario.length) {
    const nuevo = huecosBandeja()[0].cloneNode(true);
    el.bandeja.appendChild(nuevo); prepararHueco(nuevo);
  }
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
  pintarMirar();
}
el.mirar.addEventListener('click', () => {
  const id = estado.seleccion;
  if (!id || estado.ocupado || estado.fase !== 'jugando') return;
  desbloquearAudio();
  estado.seleccion = null; pintarInventario();
  examinar(id);
});
window.addEventListener('resize', () => pintarMirar());
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
  // en la mano se mueven: la cajita (su tapa gira) y la ficha de shōgi (se le da la vuelta)
  const cajitaSi = objeto === 'cajita' && estado.hija && estado.hija.ojo === 'cajita';
  const fichaSi = objeto === 'ficha' && !!estado.n3;
  const manoSi = (objeto === 'esquirlas' || objeto === 'mejilla') && !!estado.n4 && !!madera4;
  const bolsilloSi = cajitaSi || fichaSi || manoSi;
  // lo demás se mira en 3D y se gira por todos los lados (en la técnica A, sin WebGL, su dibujo, como antes)
  const en3d = !bolsilloSi && tec.nombre !== 'A' && !vitrinaRota;
  bolsillo.modo = fichaSi ? 'ficha' : manoSi ? 'esquirlas' : 'cajita';
  el.examinarImg.hidden = bolsilloSi; el.bolsillo.hidden = !bolsilloSi; el.vitrina3d.hidden = true;
  el.bolsillo.parentElement.classList.toggle('grande', bolsilloSi || en3d);
  el.examinarAyuda.textContent = cajitaSi ? 'Gira la tapa con el dedo · toca fuera para guardarla'
    : fichaSi ? 'Deslízala de lado para darle la vuelta · toca fuera para guardarla' : manoSi ? ayudaMano4()
      : en3d ? 'Arrastra para girarlo · pellizca para acercarlo · toca fuera para guardarlo' : 'Toca para guardarlo';
  if (en3d) abrirVitrina(objeto);
  el.bolsillo.setAttribute('aria-label', fichaSi ? 'La ficha en la mano: deslízala de lado o usa las flechas para darle la vuelta'
    : 'La cajita en la mano: gira su tapa con el dedo o con las flechas del teclado');
  if (cajitaSi) abrirBolsillo();
  if (fichaSi) { bolsillo.activo = true; fichaGiro.giro = fichaGiro.objetivo = 0; fichaGiro.inicio = null; medirBolsillo(); }
  if (manoSi) abrirMano4();
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
  if (vitrina) vitrina.cerrar();
  setTimeout(() => { if (el.examinar.classList.contains('oculta')) el.examinar.hidden = true; }, 500);   // (si no se ha vuelto a abrir)
}
el.examinar.addEventListener('pointerdown', e => { if (!el.bolsillo.contains(e.target) && e.target !== el.vitrina3d) toqueEnExaminar = true; });
// la vitrina 3D (vitrina3d.js): se carga la primera vez que se mira algo; si este móvil no puede, se queda el dibujo
let vitrina = null, vitrinaRota = false;
async function abrirVitrina(objeto) {
  try {
    if (!vitrina) vitrina = (await import('./vitrina3d.js')).crearVitrina(el.vitrina3d, { quieto });
    if (el.examinar.hidden || el.examinar.classList.contains('oculta')) return;
    const n3 = estado.n3;
    el.vitrina3d.hidden = false;                       // (para medirla; el dibujo sigue delante hasta que esté)
    const hecho = await vitrina.mostrar(objeto, { icono: OBJETOS[objeto].icono, completa: !!(n3 && n3.completa) });
    if (!hecho || el.examinar.hidden || el.examinar.classList.contains('oculta')) { if (hecho) vitrina.cerrar(); return; }
    vitrina.medir();
    el.examinarImg.hidden = true;
  } catch (e) {
    vitrinaRota = true; el.vitrina3d.hidden = true; el.examinarImg.hidden = false;
    console.warn('Sin vitrina 3D:', e);
  }
}
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
  if (bolsillo.modo === 'ficha') { fichaGiro.inicio = { id: e.pointerId, x0: q.x, y0: q.y, volteada: false, movido: 0 }; return; }
  if (bolsillo.modo === 'esquirlas') { manoPulsar(q, e.pointerId); return; }
  bolsillo.dedo = q;
  bolsillo.arrastre = { id: e.pointerId, a0: Math.atan2(q.y, q.x), angulo0: bolsillo.angulo, movido: 0, x0: q.x, y0: q.y };
});
el.bolsillo.addEventListener('pointermove', e => {
  const q = puntoBolsillo(e);
  if (bolsillo.modo === 'esquirlas') { if (bolsillo.activo) manoMover(q, e.pointerId); return; }
  if (bolsillo.modo === 'ficha') {
    // la ficha se voltea deslizándola de lado (hacia donde vaya el dedo)
    const f = fichaGiro.inicio;
    if (!f || e.pointerId !== f.id) return;
    f.movido = Math.max(f.movido, Math.hypot(q.x - f.x0, q.y - f.y0));
    if (!f.volteada && Math.abs(q.x - f.x0) > 0.28) { f.volteada = true; voltearFicha(Math.sign(q.x - f.x0)); }
    return;
  }
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
  if (bolsillo.modo === 'esquirlas') { manoSoltar(puntoBolsillo(e), e.pointerId); return; }
  if (bolsillo.modo === 'ficha') {
    const f = fichaGiro.inicio;
    if (f && e.pointerId === f.id && !f.volteada && f.movido < 0.08 && e.type === 'pointerup') voltearFicha(1);   // un toque también la voltea
    fichaGiro.inicio = null;
    return;
  }
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
  if (bolsillo.modo === 'ficha') {
    if (e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'Enter' || e.key === ' ') { e.preventDefault(); voltearFicha(e.key === 'ArrowLeft' ? -1 : 1); }
    return;
  }
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
  if (bolsillo.modo === 'ficha') { dibujarFichaEnMano(dt); return; }
  if (bolsillo.modo === 'esquirlas') { dibujarMano4(dt); return; }
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
  // el tiempo que hace falta para leerlo es el mínimo, aunque se pida menos
  mensajeHasta = reloj + Math.max(segundos || 0, 2.6, 1.3 + texto.length * 0.055);
}
function primeraVez(clave) { if (estado.vistos[clave]) return false; estado.vistos[clave] = true; return true; }
function insistir(clave) {
  const r = estado.insistencia[clave] || { n: 0, t: -99 };
  r.n = reloj - r.t < 6 ? r.n + 1 : 1; r.t = reloj;
  estado.insistencia[clave] = r;
  return r.n;
}
// volver a pulsar «?» poco después repite la misma pista (para releerla) en vez de adelantar la siguiente, más clara
let pistaAnterior = { texto: '', firma: '', t: -99 };
function pista() {
  const firma = firmaAvance();
  if (pistaAnterior.texto && pistaAnterior.firma === firma && reloj - pistaAnterior.t < 15) {
    sonar('pista', -8); mensaje(pistaAnterior.texto, 4); return;
  }
  pistaNueva();
  pistaAnterior = { texto: el.mensaje.textContent, firma, t: reloj };
}
function pistaNueva() {
  sonar('pista', -8);
  const n = estado.pistas++;
  if (estado.nivel === 2) return pistaNivel2();
  if (estado.nivel === 3) return pistaNivel3();
  if (estado.nivel === NIVEL_FINAL) return pistaFinal();
  if (estado.nivel === 4) return pistaNivel4();
  if (estado.nivel === 5) return pistaNivel5();
  if (estado.nivel === 6) return pistaNivel6();
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
  if (h2.ojo === 'cajita') return escalon('bolsillo', ['Mira la cajita de cerca: elígela en la bandeja y pulsa «Mirar».', 'Su tapa gira.',
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
  { grupo: 'caja', forma: ['elipse', 842, 484, 52, 24], tocar: tocarLabios },
  { grupo: 'caja', forma: ['elipse', 930, 196, 66, 18], tocar: tocarTrampilla },
  // el incensario: de cerca
  { grupo: 'incensario', forma: ['rect', 566, 444, 620, 516], si: () => estado.tapa === 'abierta' && estado.cuerno === 'brasas', tocar: cogerCuerno },
  { grupo: 'incensario', forma: ['rect', 462, 600, 580, 650], si: () => estado.tapaEnMesa, tocar: () => mensaje('La tapa del león. Ya no guarda nada.') },
  { grupo: 'incensario', forma: INCENSARIO, tocar: tocarIncensario },
  // la sala: desde cualquier vista
  { grupo: 'sala', forma: ['rect', 535, 212, 676, 434], tocar: tocarLampara },
  { grupo: 'sala', forma: ['rect', 1206, 476, 1376, 626], tocar: tocarTetera },
  { grupo: 'sala', forma: ['rect', 1140, 592, 1336, 698], tocar: tocarTazas },
  // nivel 3: la ficha caída en el tatami
  { grupo: 'sala', forma: ['elipse', FICHA_SUELO.x, FICHA_SUELO.y, 46, 34], si: () => !!estado.n3 && estado.n3.ficha === 'suelo', tocar: cogerFicha },
  { grupo: 'sala', forma: ['rect', 236, 0, 416, 336], tocar: tocarRollo },
  { grupo: 'sala', forma: ['rect', 0, 0, 138, 500], tocar: () => { sonar('tope_madera', -16, 0.8); mensaje('La puerta no se abre. Primero, la caja.'); } },
  { grupo: 'sala', forma: ['rect', 664, 0, 1376, 172], tocar: tocarVentana },
  { grupo: 'sala', forma: ['rect', 1210, 172, 1376, 470], tocar: tocarVentana },
];
// la espalda de la caja (en el boceto de espaldas)
const ZONAS_DETRAS = [
  { forma: ['rect', 687, 300, 787, 368], tocar: () => mensaje('Vacío. En el fondo, una muesca con forma de ficha.') },
  { forma: ['rect', 815, 328, 878, 408], tocar: tocarHuecoFicha },
  { forma: LARGO, tocar: tocarLargo },
  { forma: ['rect', 1050, 195, 1122, 552], tocar: () => mensaje('Una borla de seda roja. El nudo está muy apretado.') },
  { forma: ['rect', 715, 233, 990, 495], tocar: () => cajonCerrado('detras', 900, 330, 0.4, -1, null, 'caja_detras') },
];

// de la sala a la caja: la primera vez, cómo se mira por encima (la tapa y su trampilla)
function acercarCaja() {
  irA('caja');
  if (tec.nombre !== 'A' && estado.nivel !== NIVEL_FINAL && primeraVez('vista-arriba')) {
    // (si hay otro mensaje a la vista, espera a que se vaya)
    const avisar = (intentos) => {
      if (estado.vista !== 'caja' || estado.fase !== 'jugando') { estado.vistos['vista-arriba'] = false; return; }   // otra vez
      if (reloj < mensajeHasta && intentos > 0) { setTimeoutReloj(1.5, () => avisar(intentos - 1)); return; }
      mensaje('Desliza la caja hacia abajo para verla por encima; de lado, para girarla.', 4.5);
    };
    setTimeoutReloj(0.9, () => avisar(4));
  }
}

function tocarEscena(sx, sy) {
  if (estado.fase !== 'jugando' || estado.ocupado) return;
  const p = tec.aPintura(sx, sy);
  if (!p) return;                        // de cerca, la cámara se queda: se vuelve con «Sala», atrás o pellizcando
  if (estado.seleccion) { usarObjeto(estado.seleccion, p, null, { x: sx, y: sy }); return; }
  const v = estado.vista, deCerca = ['caja', 'cara', 'cajones', 'hija', 'largo', 'corazon', 'zocalo', 'espalda', 'borla'].includes(v);
  if (p.hija) { tocarHija(p); return; }
  // nivel 6, a oscuras: solo se encuentra lo alumbrado; la caja, sin ver, se asusta
  if (enLaNoche()) {
    if (!iluminado(p)) { tocarANoche(p); return; }
    if (dentro(INCENSARIO, p)) { if (v !== 'incensario') irA('incensario'); else { sonar('toque', -14); tocarBrasas6(); } return; }
    if (dentro(zonaShoji6(), p)) { sonar('toque', -14); tocarShoji6(); return; }
    if (dentro(zonaLampara6(), p)) {
      if (v !== 'lampara') { irA('lampara', 0.9); if (!estado.n6.mecha) setTimeoutReloj(1, () => tocarLampara6(p)); return; }
      sonar('toque', -14); tocarLampara6(p); return;
    }
    if (!p.cajon && dentro(['poli', CAJA], p)) { tocarANoche(p); return; }
    if (!p.cajon && dentro(['rect', ...VENTANAS], p)) { sonar('toque', -16); mensaje('El shoji, a la luz de la luna. Su hoja de la derecha se desliza.', 3); return; }
  }
  // nivel 5: la borla (o su costado) y la espalda con sus cajones
  if (estado.nivel === 5 && estado.n5) {
    // dormida, tocarle la cara la despierta
    if (sueno.dormida && deCerca && p.cara === 'frente' && !p.cajon && dentro(['rect', 720, 240, 980, 540], p)) {
      despertarse(); mensaje('La has despertado. Abre los ojos… y te mira.', 3.5); return;
    }
    if (p.borla || p.izquierda) { tocarBorla5(p); return; }
    if (p.cara === 'detras' && !p.largo) {
      if (!deCerca) { acercarCaja(); return; }
      const id = p.detras5 || cajonDetrasEn(p);
      if (id) { sonar('toque', -14); tocarDetras5(id); return; }
      if (v === 'espalda' && !dentro(LARGO, p)) { golpearEspalda(); return; }
    }
  }
  if (p.zocalo) { sonar('toque', -14); tocarZocalo(p); return; }        // el cajón de la peana (nivel 4)
  if (p.corazon) { sonar('toque', -14); tocarCorazon(p, { x: sx, y: sy }); return; }
  if (p.cara === 'detras') {
    if (!deCerca) { acercarCaja(); return; }
    if (p.largo) { sonar('toque', -14); tocarLargo(p); return; }          // el cajón largo abierto (o lo que guarda)
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
    if (z.grupo === 'caja' && !deCerca) { acercarCaja(); return; }
    if (z.grupo === 'incensario' && v !== 'incensario') { irA('incensario'); return; }
    if (z.grupo === 'zocalo' && v !== 'zocalo') { irA('zocalo', 0.85); return; }
    sonar('toque', -14);
    z.tocar(p);
    return;
  }
  if (dentro(['poli', CAJA], p)) {
    if (!deCerca) acercarCaja();
    else { sonar('toque', -14); mensaje(elegir(['La madera está tibia, como si respirara.', 'Mosaico de maderas claras y oscuras. Ni una junta se mueve.'])); }
  }
}

// La resistencia creativa: no se mueve ni se marca; reacciona la caja entera y va a más
let gruñidoHasta = 0;
function resistir(x, y, dx, dy, punto, veces, objeto = 'caja') {
  sonar('trabado', -7); vibrar(35);
  contenerAliento(1.4 + 0.4 * Math.min(veces, 3));
  if (objeto === 'caja') mirarA(punto, 3);
  entornar(1.6 + 0.4 * veces);
  bocanada(x, y, dx, dy, Math.min(veces, 3), objeto);
  if (veces >= 3) {
    if (reloj >= gruñidoHasta) { sonar('grunido', -11, 0.9); gruñidoHasta = reloj + 4.5; }
    sacudir(3, 0.35);
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
  // nivel 3: dentro de la varilla de abajo hay algo suelto que golpea la madera
  if (estado.nivel === 3 && estado.n3 && estado.n3.ficha === 'rollo') {
    setTimeoutReloj(0.18, () => sonar('clic_madera', -12, 0.75));
    setTimeoutReloj(0.42, () => sonar('clic_madera', -16, 0.7));
    const n = insistir('rollo3');
    mensaje(n === 1 ? (primeraVez('rollo3') ? 'El rollo se mece… y dentro de la varilla de abajo algo suelto golpea la madera.' : 'Algo suelto golpea dentro de la varilla.')
      : n === 2 ? 'Se mece más. Lo de dentro golpea más fuerte.' : 'Más… ');
    return;
  }
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
  if (estado.nivel === 4 && estado.n4) { tocarLampara4(); return; }
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
  // nivel 3: la tetera se mira de cerca, para volcarla (dentro tintinea algo)
  if (estado.nivel === 3 && estado.n3 && tec.inclinarTetera) {
    if (estado.vista !== 'te') {
      irA('te', 0.85);
      if (estado.n3.badajo === 'tetera') vaporTetera(0.8);
      ojo.distraidoPor = TAPA_TETERA; ojo.distraidoHasta = reloj + 3;
      return;
    }
    vaporTetera(1);
    if (estado.n3.badajo === 'tetera') {
      mensaje(primeraVez('tetera3') ? 'La tapa tiembla y, dentro, algo pequeño tintinea contra la porcelana. Vuélcala: arrastra hacia abajo.' : 'Dentro tintinea algo. Arrastra hacia abajo para volcarla.', 4.5);
    } else mensaje('Té verde. Ya no tintinea nada.');
    return;
  }
  vaporTetera(1);
  if (estado.nivel >= 4) { mensaje(estado.nivel === 4 ? 'Té tibio. La caja ni lo mira: está pendiente de su cara.' : 'Té tibio.'); return; }
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
  setTimeout(() => { if (el.nota.classList.contains('oculta')) el.nota.hidden = true; }, 600);
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
  if (estado.nivel === NIVEL_FINAL && estado.fin) {
    const f = estado.fin;
    if (f.hija === 'mesa') { cogerHija(); return; }
    if (f.hija === 'puesta') { sentir('holgura', { tono: 0.9 }); mensaje(f.fase === 'abierto' ? 'Late.' : 'Gírala con el dedo, en círculo, como una llave.'); }
    return;
  }
  if (estado.nivel >= 3) { sonar('toque', -14); mensaje('La caja pequeña, abierta. Ya no guarda nada… por ahora.'); return; }
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
  mensaje('Una cajita de laca roja. Elígela en la bandeja y pulsa «Mirar» para verla de cerca.', 4);
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
// Nivel 3 · La voz (solo en la B). La caja ya ve con dos ojos, pero no puede hablar: le falta la voz, una campanilla de
// bronce sin badajo que duerme en el cajón largo de su espalda. La regla se invierte: ahora conviene que mire, porque
// la luz fría del ojo nuevo descubre tinta que no se ve (en el rollo, junto a la tetera y en el tatami). Pasos:
//   la nota entre los labios → la tinta del rollo → mecer el rollo hasta que caiga la ficha → coger la ficha → darle la
//   vuelta (coronada, と) → meterla en el hueco de la espalda → tirar del cajón largo → la campanilla → la tinta de la
//   tetera → volcar la tetera → el badajo de la taza → el badajo en la campanilla → la tinta del tatami → tocar la
//   campanilla cuando la caja suelta el aire, tres veces → los labios se abren → la campanilla en la boca: canta.
// ---------------------------------------------------------------------------------------------
const fichaCae = { t: 0, x: VARILLA_ROLLO.x, y: VARILLA_ROLLO.y, ang: 0 };
let notaSale = 0;                    // el papel entre los labios, al salir (0 … 1)
let labiosTiemblan = 0;
function prepararNivel3() {
  for (const [id, t] of Object.entries(TINTAS)) { t.lienzo = t.dibujar(); t.id = id; }
  img.ficha_peon = dibujarFicha('peon', 120, 140); img.ficha = img.ficha_suelo = img.ficha_peon;
  img.ficha_promovida = dibujarFicha('promovida', 120, 140);
  img.campanilla_muda = dibujarCampanilla(false, 96, 120); img.campanilla_completa = dibujarCampanilla(true, 96, 120);
  img.campanilla = img.campanilla_muda;
  img.badajo = dibujarBadajo(60, 90);
  // su tamaño en el boceto: la ficha, del tamaño del hueco; en el tatami, más lejos, más pequeña
  datos.capas.ficha = { x: HUECO_FICHA.x - 27, y: HUECO_FICHA.y - 32, w: 54, h: 64 };
  datos.capas.ficha_suelo = { x: FICHA_SUELO.x - 11, y: FICHA_SUELO.y - 13, w: 22, h: 26 };
  datos.capas.campanilla = { x: BOCA.x - 17, y: BOCA.y - 21, w: 34, h: 42 };
  datos.capas.badajo = { x: TAZAS[0].x - 8, y: TAZAS[0].y - 18, w: 16, h: 24 };
  OBJETOS.ficha.icono = icono(img.ficha); OBJETOS.ficha.iconoPromovida = icono(img.ficha_promovida);
  OBJETOS.campanilla.icono = icono(img.campanilla); OBJETOS.campanilla.iconoCompleta = icono(img.campanilla_completa);
  OBJETOS.badajo.icono = icono(img.badajo);
  OBJETOS.ficha.iconoPeon = OBJETOS.ficha.icono; OBJETOS.campanilla.iconoMuda = OBJETOS.campanilla.icono;
  // la caja pequeña (nivel final): su cara, para la bandeja y los vuelos
  img.hija = img.hija_frente;
  datos.capas.hija = { x: 900, y: 660, w: 60, h: 60 };
}
// la ficha, el icono y el texto según la cara que mira hacia arriba; la campanilla, con badajo o sin él
function ponerCaraFicha(cara) {
  estado.n3.fichaCara = cara;
  const o = OBJETOS.ficha;
  o.icono = cara === 'promovida' ? o.iconoPromovida : o.iconoPeon;
  o.texto = cara === 'promovida' ? 'Por esta cara, と en rojo: el peón coronado.' : 'Un peón de madera, 歩. Por detrás tiene otra cara.';
  img.ficha = cara === 'promovida' ? img.ficha_promovida : img.ficha_peon;
  pintarInventario();
}
function ponerCampanillaCompleta(si) {
  const o = OBJETOS.campanilla;
  o.icono = si ? o.iconoCompleta : o.iconoMuda;
  o.nombre = 'Campanilla de bronce';
  o.texto = si ? 'Con su badajo. Suena clara y larga.' : 'Pequeña y pesada. No tiene badajo: no suena.';
  img.campanilla = si ? img.campanilla_completa : img.campanilla_muda;
  pintarInventario();
}
function ponerTextoNota(n) { const t = $('nota-texto'); if (t) t.innerHTML = NOTAS[n]; OBJETOS.nota.texto = '«' + NOTAS[n].replace(/<br>/g, ' ') + '»'; }

// el estado al final del nivel 2, para empezar el 3 sin jugarlo (seguir una partida guardada, o «?nivel=3»)
function estadoTrasNivel2() {
  estado.hija = { fase: 'mesa', tablillas: [true, true, true, true, true], cajon: 'abierto', cajita: 'abierta', ojo: 'puesto' };
  Object.assign(despertar, { ojos: 0, humo: 0, trampilla: 1, oscuridad: 0.16 });
  lampara.apagada = 0.1;
  ojo.visible = 1; ojo.parpadoBase = 0;
  Object.assign(ojo2, { visible: 1, parpadoBase: 0, cerrado: 0 });
  if (tec.ponerHija) tec.ponerHija(estado.hija);
  hornear();
}
async function empezarNivel3() {
  ocultarTarjeta();
  if (tec.enderezar) tec.enderezar();             // la caja de frente, aunque se dejara a medio girar
  estado.nivel = 3;
  estado.n3 = { nota: 'boca', tintas: {}, ficha: 'rollo', fichaCara: 'peon', largo: 'cerrado', campanilla: 'cajon', badajo: 'tetera',
    completa: false, toques: 0, labios: 0 };
  estado.pistasPaso = {}; estado.intentosMirada = 0; estado.insistencia = {};
  estado.fase = 'jugando';
  el.girar.hidden = false; el.inventario.hidden = false;
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  ponerCaraFicha('peon'); ponerCampanillaCompleta(false);
  cajonAnim.largo.k = cajonAnim.largo.objetivo = 0;
  notaSale = 0;
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; ojo.entornado = 0;
  Object.assign(ojo2, { visible: 1, parpadoBase: 0 });
  luzFria.x = 1100; luzFria.y = 40; luzFria.guiadaHasta = 0;
  // la trampilla se apaga poco a poco: la caja pequeña ya está fuera
  const tr0 = despertar.trampilla;
  animar(2.2, k => { despertar.trampilla = tr0 * (1 - suave(k)); hornear(); if (tec.abrirTrampilla) tec.abrirTrampilla(1 - suave(k)); });
  bucle('noche', -13, 2);
  if (tec.cara() !== 'frente') tec.girar();
  irA('cara', 1.6);
  await esperar(2.2);
  // la caja suelta el aire y, entre los labios, asoma un papel
  vaho(); sonar('suspiro', -9, 0.9); sonar('papel', -12, 1.1);
  animar(1.2, k => { notaSale = salida(k); });
  mirarA(BOCA, 2);
  await esperar(1.3);
  mensaje('Abre los dos ojos y te mira con el viejo. Entre sus labios asoma un papel.', 4.5);
}
async function cogerNota3() {
  const n3 = estado.n3;
  n3.nota = 'mano';
  ponerTextoNota(3);
  sonar('papel', -4);
  await alInventario('nota', 'nota', 'caja', { x: BOCA.x + 8, y: BOCA.y + 10 });
  leerNota();
  // la primera vez, la luz fría del ojo nuevo se deja ver: barre la sala un momento
  setTimeoutReloj(2.5, () => { if (estado.nivel === 3) { ojo2.punto = { x: 560, y: 120 }; ojo2.proximoVagar = reloj + 3; } });
}
function tocarLabios() {
  const n3 = estado.n3;
  if (estado.nivel === 4 && estado.n4 && n3 && n3.campanilla === 'puesta') { cantar4Caja(); return; }
  if (estado.nivel === 3 && n3) {
    if (n3.nota === 'boca') { cogerNota3(); return; }
    if (n3.campanilla === 'puesta') { sonar('campanilla', -12, 1.02); mensaje('La campanilla, en su boca. Canta bajito.'); return; }
    if (n3.labios >= 1) { mensaje('Los labios, entreabiertos. Dentro, un hueco oscuro y tibio, del tamaño de una campanilla.'); return; }
    if (n3.toques > 0) { labiosTiemblan = reloj + 0.8; mensaje('Los labios tiemblan, pero siguen cerrados.'); return; }
  }
  mensaje('Los labios están tallados, pero parecen tibios.');
}
// ---- la ficha del rollo ----
function actualizarNivel3(dt) {
  const n3 = estado.n3;
  if (estado.nivel !== 3 || !n3) return;
  // con el rollo muy mecido, la ficha se sale de la varilla
  if (n3.ficha === 'rollo' && estado.fase === 'jugando' && Math.abs(rollo.a) > UMBRAL_ROLLO) caerFicha();
  // lo de dentro de la varilla golpea en cada vaivén
  if (n3.ficha === 'rollo') {
    const signo = Math.sign(rollo.v);
    if (signo !== rollo.signo && Math.abs(rollo.a) > 0.035) sonar('clic_madera', -24 + 120 * Math.abs(rollo.a), 0.72);
    rollo.signo = signo;
  }
}
function caerFicha() {
  const n3 = estado.n3;
  n3.ficha = 'cayendo';
  sonar('clic_madera', -6, 0.8); vibrar(10);
  const a = VARILLA_ROLLO, b = FICHA_SUELO;
  animar(0.55, k => {
    // cae (con un poco de impulso del vaivén), da un bote y rueda un poco
    if (k < 0.7) { const q = k / 0.7; fichaCae.x = mezclar(a.x, b.x + 6, q); fichaCae.y = a.y + (b.y - a.y) * q * q; fichaCae.ang = q * 4.2; }
    else { const q = (k - 0.7) / 0.3; fichaCae.x = mezclar(b.x + 6, b.x, q); fichaCae.y = b.y - Math.sin(q * Math.PI) * 9; fichaCae.ang = 4.2 + q * 2.08; }
  }, () => {
    n3.ficha = 'suelo'; fichaCae.x = b.x; fichaCae.y = b.y; fichaCae.ang = 2 * Math.PI;
    sentir('tope', { db: -2, tono: 1.4 }); sonar('clac', -12, 1.4);
    polvareda(b.x, b.y + 2);
    mirarA(b, 2.5);
    mensaje('De la varilla del rollo cae algo pequeño al tatami: una ficha de shōgi.', 4);
  });
  setTimeoutReloj(0.38, () => sentir('tope', { db: -8, tono: 1.6, sinVibrar: true }));
}
function cogerFicha() {
  const n3 = estado.n3;
  if (n3.ficha !== 'suelo') return;
  n3.ficha = 'mano';
  sonar('recoger', -3, 1.1);
  alInventario('ficha', 'ficha_suelo', 'sala', FICHA_SUELO);
  mensaje(primeraVez('ficha') ? 'Una ficha de shōgi: un peón, 歩. Elígela en la bandeja y pulsa «Mirar».' : 'La ficha de shōgi.', 4.5);
}
// darle la vuelta a la ficha, en la mano (examinar): en el shōgi, una pieza que corona se vuelve del revés
const fichaGiro = { giro: 0, objetivo: 0, inicio: null };
function voltearFicha(sentido = 1) {
  if (Math.abs(fichaGiro.objetivo - fichaGiro.giro) > 0.01) return;      // ya está girando
  fichaGiro.objetivo = fichaGiro.giro + Math.PI * sentido;
  sonar('deslizar_madera', -14, 1.6); vibrar(8);
}
function dibujarFichaEnMano(dt) {
  const n3 = estado.n3;
  const c = el.bolsillo.getContext('2d'), W = el.bolsillo.width;
  const antes = fichaGiro.giro;
  fichaGiro.giro += (fichaGiro.objetivo - fichaGiro.giro) * (1 - Math.exp(-dt * 9));
  if (Math.abs(fichaGiro.objetivo - fichaGiro.giro) < 0.004) fichaGiro.giro = fichaGiro.objetivo;
  // al pasar de canto, cambia la cara que se ve
  const vueltas = g => Math.round(g / Math.PI);
  if (vueltas(antes) !== vueltas(fichaGiro.giro)) {
    ponerCaraFicha(n3.fichaCara === 'promovida' ? 'peon' : 'promovida');
    el.examinarTexto.textContent = OBJETOS.ficha.texto;
    sentir('tope', { db: -10, tono: 1.8, sinVibrar: true });
    if (n3.fichaCara === 'promovida' && primeraVez('coronada')) el.examinarAyuda.textContent = 'Coronada. Toca fuera para guardarla';
  }
  const cara = img.ficha, s = Math.cos(fichaGiro.giro - vueltas(fichaGiro.giro) * Math.PI);
  c.setTransform(1, 0, 0, 1, 0, 0); c.clearRect(0, 0, W, W);
  c.save(); c.translate(W / 2, W / 2); c.scale(Math.max(0.04, Math.abs(s)), 1);
  c.shadowColor = 'rgba(0, 0, 0, 0.6)'; c.shadowBlur = W * 0.04; c.shadowOffsetY = W * 0.025;
  const h = W * 0.78, w = h * cara.width / cara.height;
  c.drawImage(cara, -w / 2, -h / 2, w, h);
  c.restore();
}
// la ficha en su hueco de la espalda: solo encaja coronada
async function ponerFicha(desde) {
  const n3 = estado.n3;
  estado.ocupado = true;
  if (estado.vista !== 'caja') { irA('caja', 0.8); await esperar(0.6); }
  if (caraVisible() !== 'detras') { tec.girar(); await esperar(0.9); }
  await desdeInventario('ficha', 'ficha', HUECO_FICHA, 'caja_detras', desde);
  if (n3.fichaCara !== 'promovida') {
    // entra, pero el hueco la devuelve: madera contra madera, sin que la caja haga nada
    sentir('tope', { db: -2, tono: 1.2 }); await esperar(0.25); sentir('trabado', { db: -4 });
    bocanada(HUECO_FICHA.x, HUECO_FICHA.y - 20, 0, -1, 0.6, 'caja_detras');
    await alInventario('ficha', 'ficha', 'caja_detras', HUECO_FICHA);
    estado.ocupado = false;
    const n = insistir('hueco-ficha');
    mensaje(n === 1 ? 'Entra, pero el hueco la devuelve. Por esa cara, no.' : n === 2 ? 'En el rollo, la ficha era roja.' : 'Dale la vuelta: elígela, pulsa «Mirar» y deslízala de lado.', 4);
    return;
  }
  n3.ficha = 'puesta';
  sentir('clac'); await esperar(0.35);
  sentir('pestillo'); await esperar(0.3);
  sentir('mecanismo'); sacudir(2, 0.25);
  bocanada(860, 478, 0.2, -1, 1, 'caja_detras');
  n3.largo = 'suelto';
  irA('largo', 0.9);
  setTimeoutReloj(0.5, () => { cajonAnim.largo.objetivo = 0.12; cajonAnim.largo.v = 2.2; });
  estado.ocupado = false;
  mensaje('Encaja. Dentro corre un pestillo largo: el cajón de abajo se ha soltado.', 4.5);
}
function tocarHuecoFicha() {
  const n3 = estado.n3;
  if (n3 && n3.ficha === 'puesta') { mensaje('La ficha coronada, en su hueco. Encaja justa.'); return; }
  if (n3 && n3.ficha === 'mano') { mensaje('Un hueco con forma de ficha de shōgi. Elige la ficha en la bandeja y toca el hueco.'); return; }
  mensaje('Un hueco con forma de ficha de shōgi. Falta la ficha.');
}
// ---- el cajón largo de la espalda ----
function tocarLargo(p = {}) {
  const n3 = estado.n3;
  if (estado.nivel !== 3 || !n3 || n3.largo === 'cerrado') {
    const texto = estado.nivel === 3 ? 'Cerrado. Dentro se oye un pestillo largo, que va hasta el hueco de la ficha.' : 'Tiene cerradura, pero no es la de la llave de bambú.';
    cajonCerrado('largo', 860, 478, 0.2, -1, texto, 'caja_detras');
    return;
  }
  const a = cajonAnim.largo;
  // suelto o abierto, la cámara se acerca a él y se queda allí (como en el costado)
  if (estado.vista !== 'largo') { irA('largo', 0.85); return; }
  if (n3.largo === 'suelto') {
    a.v += 1.6;
    sentir('holgura', { tono: 1.05 });
    mensaje(primeraVez('tirar-largo') ? 'Se ha soltado. Tira de él hacia fuera: arrastra el dedo.' : 'Tira de él.');
    return;
  }
  if (n3.campanilla === 'cajon' && (p.largo === 'campanilla' || a.k > 0.7)) { cogerCampanilla(); return; }
  mensaje(n3.campanilla === 'cajon' ? 'Dentro, algo de bronce.' : 'Vacío. Huele a bronce viejo.');
}
function abrirLargo() {
  const n3 = estado.n3, a = cajonAnim.largo;
  n3.largo = 'abierto';
  a.objetivo = 1;
  sonar('cajon', -4, 0.85); vibrar(15);
  setTimeoutReloj(0.3, () => polvoDeCajon(860, 500));
  if (n3.campanilla === 'cajon') {
    setTimeoutReloj(0.35, () => mensaje('Dentro del cajón largo, una campanilla de bronce. No tiene badajo.', 4));
    if (tec.inclinar) setTimeoutReloj(0.25, () => tec.inclinar(0, 0.4));
  }
}
function cogerCampanilla() {
  const n3 = estado.n3;
  n3.campanilla = 'mano';
  const v = tec.puntoCampanillaLargo ? tec.puntoCampanillaLargo() : null, m = v ? tec.ancla(v) : null;
  sonar('recoger', -2, 0.95); sonar('campanilla_muda', -10);
  alInventario('campanilla', 'campanilla', 'caja_detras', m && m.visible ? { x: m.x, y: m.y, k: 1.4, enPantalla: true } : { x: 860, y: 510 });
  mensaje(primeraVez('campanilla') ? 'Una campanilla de bronce, pequeña y pesada. Sin badajo, no suena: es la voz dormida.' : 'La campanilla.', 4.5);
}
// ---- la tetera y el badajo ----
const teteraInclinada = () => tetera3.inclinacion > 0.02;
// mientras se vuelca: el chorro sale cuando está bastante inclinada; con el té cae el badajo
function actualizarTetera3(dt) {
  const n3 = estado.n3;
  const vierte = tetera3.inclinacion > 0.62;
  tetera3.chorro = mezclar(tetera3.chorro, vierte ? 1 : 0, 1 - Math.exp(-dt * (vierte ? 10 : 6)));
  if (!vierte) return;
  if (reloj > tetera3.sonandoHasta) { sonar('vertido', -6, azar(0.95, 1.05)); tetera3.sonandoHasta = reloj + 1.35; }
  tetera3.vertido += dt;
  if (Math.random() < dt * 8) ondas.push({ i: 0, t: 0, f: 0.5 });
  if (n3 && n3.badajo === 'tetera' && tetera3.vertido > 1) caerBadajo();
}
function caerBadajo() {
  const n3 = estado.n3;
  n3.badajo = 'taza';
  setTimeoutReloj(0.12, () => { sonar('tin', -2); vibrar([12, 30, 8]); agitarTe(1); });
  mirarA(TAZAS[0], 2);
  mensaje('Con el té cae algo pequeño en la taza: tin.', 3.5);
}
function tocarTazas(p) {
  const n3 = estado.n3;
  if (estado.nivel === 3 && n3) {
    if (n3.badajo === 'taza' && p && Math.hypot(p.x - TAZAS[0].x, p.y - TAZAS[0].y) < 60) { cogerBadajo(); return; }
    if (estado.vista !== 'te' && tec.inclinarTetera) { irA('te', 0.85); return; }
  }
  agitarTe(0.8);
  mensaje(estado.nivel === 3 && n3 && n3.badajo !== 'tetera' ? 'Té tibio. Lo bebió la caja, o nadie.' : 'Dos tazas servidas. Nadie vino a beberlas.');
}
function cogerBadajo() {
  const n3 = estado.n3;
  n3.badajo = 'mano';
  agitarTe(0.6);
  sonar('recoger', -3, 1.3);
  alInventario('badajo', 'badajo', 'te', { x: TAZAS[0].x + 4, y: TAZAS[0].y - 8 });
  mensaje('Un badajo de bronce, mojado de té. La lengua de una campanilla.', 4);
}
// ---- juntar el badajo y la campanilla (en la bandeja) ----
const COMBINACIONES = [['badajo', 'campanilla']];
const combinan = (a, b) => COMBINACIONES.some(([x, y]) => (a === x && b === y) || (a === y && b === x));
function combinar(a, b) {
  if (!combinan(a, b)) { sonar('trabado', -10, 1.3); mensaje('No encajan.'); return; }
  const n3 = estado.n3;
  n3.badajo = 'puesto'; n3.completa = true;
  estado.inventario = estado.inventario.filter(o => o !== 'badajo');
  if (estado.seleccion === 'badajo') estado.seleccion = null;
  ponerCampanillaCompleta(true);
  sentir('clac', { tono: 1.25 });
  setTimeoutReloj(0.35, () => sonar('campanilla', -5));
  const h = huecoDe('campanilla');
  if (h) { h.classList.remove('llega'); void h.offsetWidth; h.classList.add('llega'); }
  mensaje('El badajo encaja dentro de la campanilla. Ya tiene lengua: suena clara.', 4);
}
// ---- la campanilla: suena; la caja solo contesta mientras suelta el aire ----
function usarCampanilla(p, desde) {
  const n3 = estado.n3;
  const delante = p && p.cara !== 'detras' && !p.hija;
  if (!n3.completa) {
    sonar('campanilla_muda', -6); vibrar(8);
    mensaje(primeraVez('muda') ? 'Sin badajo no suena: solo roza el bronce.' : 'Sin badajo, muda.');
    return;
  }
  if (delante && n3.labios >= 1 && dentro(['elipse', BOCA.x, BOCA.y, 56, 30], p)) { ponerCampanilla(desde); return; }
  if (!delante || !dentro(['poli', CAJA], p)) {
    sonar('campanilla', -8);
    if (p && p.cara === 'frente') mirarA(p, 1.5);
    mensaje(primeraVez('campanilla-fuera') ? 'Suena clara. La caja vuelve un poco el ojo hacia el sonido.' : 'Suena clara.');
    return;
  }
  if (n3.labios >= 1) { sonar('campanilla', -8); mensaje('Ya ha abierto la boca: dale la campanilla.'); return; }
  tocarCampanillaACaja();
}
function tocarCampanillaACaja() {
  const n3 = estado.n3;
  sonar('campanilla', -4); vibrar(12);
  if (exhalando()) {
    const n = ++n3.toques;
    setTimeoutReloj(0.55, () => {
      sonar('tarareo', -6 + n, 0.94 + 0.05 * n);
      bocanada(BOCA.x, BOCA.y + 10, 0, -1, 0.3 + 0.2 * n);
      labiosTiemblan = reloj + 1.4;
    });
    if (n >= 3 && !n3.abriendo) { n3.abriendo = true; setTimeoutReloj(1.7, abrirLabios); }
    else if (n >= 3) return;
    else mensaje(n === 1 ? 'Mientras suelta el aire, la caja contesta: un murmullo, con la boca cerrada.' : 'Otro murmullo, más hondo. Los labios tiemblan.', 4);
  } else {
    contenerAliento(1.6); entornar(1.2);
    if (n3.toques > 0) n3.toques--;
    mensaje(primeraVez('campanilla-dentro') ? 'Estaba tomando aire: lo contiene, y no contesta.' : 'Lo contiene. No contesta.', 3.5);
  }
}
async function abrirLabios() {
  const n3 = estado.n3;
  estado.ocupado = true;
  if (estado.vista !== 'cara') { irA('cara', 0.9); await esperar(0.8); }
  sonar('suspiro', -6, 0.85); sentir('mecanismo', { db: -6 });
  await animarPromesa(1.4, k => { n3.labios = suave(k); });
  vaho();
  estado.ocupado = false;
  mensaje('Al tercer murmullo, los labios se entreabren. Dentro hay un hueco oscuro, del tamaño de la campanilla.', 5);
}
async function ponerCampanilla(desde) {
  const n3 = estado.n3;
  estado.ocupado = true;
  if (estado.seleccion === 'campanilla') { estado.seleccion = null; pintarInventario(); }
  if (estado.vista !== 'cara') { irA('cara', 0.9); await esperar(0.7); }
  mirarA(BOCA, 3);
  await desdeInventario('campanilla', 'campanilla', BOCA, 'caja', desde);
  n3.campanilla = 'puesta';
  sonar('encajar', -2); sentir('desbloqueo', { db: -4 }); sacudir(3, 0.3);
  destello(BOCA.x, BOCA.y, 90, '255,215,150', 0.7, 1.6);
  contenerAliento(1.8);
  await esperar(1.3);
  // canta: cierra un poco los ojos, respira hondo y suena su voz
  animar(0.5, k => { ojo.parpadoBase = 0.62 * suave(k); ojo2.parpadoBase = 0.62 * suave(k); });
  sonar('canto', -2);
  for (let i = 0; i < 6; i++) setTimeoutReloj(0.3 + i * 1.05, () => bocanada(BOCA.x + azar(-8, 8), BOCA.y + 8, azar(-0.3, 0.3), -1, 0.6));
  destello(BOCA.x, BOCA.y, 150, '255,210,140', 0.5, 6.5);
  agitarLampara(2, 0.4);
  await esperar(6.6);
  animar(0.6, k => { ojo.parpadoBase = 0.62 * (1 - salida(k)); ojo2.parpadoBase = 0.62 * (1 - salida(k)); });
  await esperar(1.2);
  estado.ocupado = false;
  terminarNivel(3);
}
// lo que se dibuja encima de la escena en el nivel 3 (B): el papel entre los labios, los labios, la campanilla en la
// boca, la ficha que cae y en el tatami, el badajo en la taza, el chorro de té, las tintas y la luz fría
function dibujarNivel3Encima(conAncla) {
  const n3 = estado.n3;
  if (!n3) return;
  const deFrente = tec.cara() === 'frente';
  if (estado.nivel === 3) dibujarTintas(conAncla);
  if (deFrente && n3.nota === 'boca' && notaSale > 0.01) conAncla(BOCA.x, BOCA.y, 'caja', () => {
    // un papel doblado que asoma entre los labios, torcido, con su doblez y un sello rojo
    ctx.save(); ctx.translate(BOCA.x - 6, BOCA.y + 1); ctx.rotate(BOCA.ang + 0.22);
    const sale = 4 + 10 * notaSale;
    ctx.fillStyle = 'rgba(30, 16, 8, 0.3)';
    ctx.beginPath(); ctx.moveTo(-11, 1.5); ctx.lineTo(12, 1.5); ctx.lineTo(10, sale + 1.5); ctx.lineTo(-13, sale + 1.5); ctx.closePath(); ctx.fill();
    const g = ctx.createLinearGradient(0, 0, 0, sale); g.addColorStop(0, '#bfae8c'); g.addColorStop(0.35, '#e6d8bb'); g.addColorStop(1, '#f1e6cd');
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.moveTo(-12, 0); ctx.lineTo(11, 0); ctx.lineTo(9, sale); ctx.lineTo(-14, sale); ctx.closePath(); ctx.fill();
    ctx.strokeStyle = 'rgba(40, 24, 12, 0.75)'; ctx.lineWidth = 0.7; ctx.stroke();
    ctx.strokeStyle = 'rgba(120, 96, 64, 0.6)'; ctx.beginPath(); ctx.moveTo(-1, 0); ctx.lineTo(-3, sale); ctx.stroke();
    if (sale > 8) { ctx.fillStyle = 'rgba(184, 68, 45, 0.85)'; ctx.beginPath(); ctx.arc(5, sale - 3.5, 1.8, 0, Math.PI * 2); ctx.fill(); }
    ctx.restore();
  });
  if (deFrente && (n3.labios > 0.01 || reloj < labiosTiemblan)) conAncla(BOCA.x, BOCA.y, 'caja', () => {
    const tiembla = reloj < labiosTiemblan ? 0.9 * Math.abs(Math.sin(reloj * 31)) * (labiosTiemblan - reloj) : 0;
    const h = 6.5 * n3.labios + tiembla;
    if (h < 0.15) return;
    ctx.save(); ctx.translate(BOCA.x, BOCA.y); ctx.rotate(BOCA.ang);
    const w = BOCA.ancho / 2 * 0.84;
    ctx.beginPath(); ctx.moveTo(-w, 0); ctx.quadraticCurveTo(0, -h * 0.9, w, 0); ctx.quadraticCurveTo(0, h * 1.25, -w, 0); ctx.closePath();
    const g = ctx.createRadialGradient(0, 0, 1, 0, 0, w);
    g.addColorStop(0, 'rgba(8, 3, 2, 0.95)'); g.addColorStop(1, 'rgba(40, 16, 8, 0.85)');
    ctx.fillStyle = g; ctx.fill();
    // la campanilla, dentro
    if (n3.campanilla === 'puesta') {
      ctx.clip();
      const c = img.campanilla_completa, ch = 30, cw = ch * c.width / c.height;
      ctx.drawImage(c, -cw / 2, -ch * 0.62, cw, ch);
    }
    ctx.restore();
  });
  if (n3.ficha === 'cayendo' || n3.ficha === 'suelo') conAncla(fichaCae.x, fichaCae.y, 'sala', () => {
    const d = datos.capas.ficha_suelo;
    ctx.save(); ctx.translate(fichaCae.x, fichaCae.y);
    ctx.fillStyle = 'rgba(20, 10, 4, 0.3)'; ctx.beginPath(); ctx.ellipse(1, d.h * 0.42, d.w * 0.55, 3, 0, 0, Math.PI * 2); ctx.fill();
    ctx.rotate(fichaCae.ang);
    ctx.drawImage(img.ficha_suelo, -d.w / 2, -d.h / 2, d.w, d.h);
    ctx.restore();
  });
  if (n3.badajo === 'taza') conAncla(TAZAS[0].x, TAZAS[0].y, 'te', () => {
    ctx.save(); ctx.translate(TAZAS[0].x + 5, TAZAS[0].y - 4); ctx.rotate(0.55);
    ctx.drawImage(img.badajo, -6, -16, 12, 18);
    ctx.restore();
  });
  if (tetera3.chorro > 0.02) {
    const a = tec.ancla(PICO_TETERA, 'tetera'), b = tec.ancla({ x: TAZAS[0].x, y: TAZAS[0].y - 2 }, 'te');
    if (a && b && a.visible && b.visible) {
      ctx.setTransform(ppp, 0, 0, ppp, 0, 0);
      ctx.strokeStyle = `rgba(150, 112, 44, ${0.85 * tetera3.chorro})`; ctx.lineCap = 'round';
      ctx.lineWidth = Math.max(1.2, 3.2 * a.k * tetera3.chorro);
      ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.quadraticCurveTo(a.x - 6 * a.k, (a.y + b.y) / 2, b.x, b.y); ctx.stroke();
      ctx.strokeStyle = `rgba(255, 230, 170, ${0.35 * tetera3.chorro})`; ctx.lineWidth = Math.max(0.6, 1 * a.k);
      ctx.stroke();
    }
  }
}
// las pistas del nivel 3, de vagas a claras
function pistaNivel3() {
  const n3 = estado.n3;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4.5);
  };
  if (!n3) return mensaje('Mira.');
  if (n3.nota === 'boca') return escalon('nota', ['Entre los labios de la caja asoma algo.', 'Un papel. Tócalo.']);
  if (n3.ficha === 'rollo') {
    if (!n3.tintas.rollo) return escalon('luz', ['El ojo nuevo da una luz fría. Lo que alumbra se ve distinto.',
      'No te mira: si pones el dedo a un lado de su cara, la luz se va al otro.', 'Deja el dedo quieto en la tetera: la luz irá al rollo colgado.']);
    return escalon('rollo', ['La tinta del rollo señala abajo, a la varilla.', 'Algo suelto suena dentro de la varilla.',
      'Mécelo fuerte: tócalo varias veces seguidas.']);
  }
  if (n3.ficha === 'cayendo' || n3.ficha === 'suelo') return escalon('suelo', ['La ficha cayó al tatami, bajo el rollo.', 'Tócala para cogerla.']);
  if (n3.ficha === 'mano') {
    if (n3.fichaCara !== 'promovida') return escalon('coronar', ['¿Dónde encaja una ficha de shōgi?', 'En la espalda de la caja hay un hueco con su forma… pero la ficha del rollo era roja.',
      'Dale la vuelta: elígela, pulsa «Mirar» y deslízala de lado.']);
    return escalon('hueco', ['En la espalda hay un hueco con forma de ficha.', 'Gira la caja, elige la ficha y toca el hueco.']);
  }
  if (n3.largo === 'suelto') return escalon('largo', ['El cajón largo de la espalda se ha soltado.', 'Tira de él hacia fuera con el dedo.']);
  if (n3.campanilla === 'cajon') return escalon('campanilla', ['Dentro del cajón largo hay algo de bronce.', 'Tócalo para cogerlo.']);
  if (n3.badajo === 'tetera') {
    if (!n3.tintas.te) return escalon('te-luz', ['A la campanilla le falta la lengua: el badajo.', 'La luz fría encontrará tinta en la madera, junto a la tetera.',
      'Deja el dedo quieto junto a la lámpara: la luz irá a la madera de la derecha.']);
    return escalon('tetera', ['¿Qué tintinea en esta sala cuando nadie lo toca?', 'La tetera. Acércate (tócala).', 'Vuélcala sobre la taza: arrastra hacia abajo y no sueltes hasta que caiga el té.']);
  }
  if (n3.badajo === 'taza') return escalon('taza', ['Algo cayó en la taza.', 'Tócala para sacarlo.']);
  if (!n3.completa) return escalon('juntar', ['El badajo va dentro de la campanilla.', 'En la bandeja, arrastra el badajo encima de la campanilla.']);
  if (n3.labios < 1) {
    if (!n3.tintas.suelo) return escalon('suelo-luz', ['La caja escucha la campanilla, pero no siempre contesta.', 'Queda tinta en el tatami. Llévale la luz.',
      'Deja el dedo quieto en la ventana de la derecha: la luz irá al tatami.']);
    return escalon('aliento', ['La tinta del tatami: sube, se queda, baja. La campanilla está en el que baja.',
      'Mira el humo del incienso: va hacia la caja cuando toma aire y se aparta cuando lo suelta.',
      'Toca la caja con la campanilla mientras suelta el aire (cuando se encoge). Tres veces.']);
  }
  return escalon('boca', ['Los labios se han abierto.', 'Pon la campanilla en la boca.']);
}

// ---------------------------------------------------------------------------------------------
// Nivel 4 · El oro (solo en la B). La cara ya tiene cuerno, ojos y voz, pero su mejilla derecha está rota (se ve en el
// boceto desde el principio). Se cura con kintsugi: tres esquirlas, laca en las juntas, el aliento de la caja para
// curarla y polvo de oro. La regla del ojo varía: ahora defiende su cara, y ni la llama ni la tetera lo distraen; pero
// cuando canta, cierra los ojos. Pasos:
//   canta → se le suelta una esquirla a la peana → cogerla → probarla en la mejilla (faltan dos) → la sombra en la
//   pared → la esquirla de encima de la lámpara → la frase que canta (con los ojos cerrados), en las tres olas de oro
//   de la peana → el cajón de la peana (la tercera esquirla, la laca y el oro) → montar las esquirlas en la mano →
//   trazar la laca en las juntas → curarla con su aliento (el té ya no echa vapor) → espolvorear el oro → ponerla en la
//   mejilla mientras canta con los ojos cerrados → el oro corre por el borde y la grieta.
// ---------------------------------------------------------------------------------------------
let nivel4 = null;                              // capas/nivel4.json: la mejilla, las olas, el cajón y la lámpara
const NOTAS_OLAS = [0.8909, 1, 1.3348];         // las olas de la peana, de izquierda a derecha: grave, media y aguda
const ESQUIRLA_PEANA = { x: 958, y: 567 };      // donde cae la primera esquirla: en el reborde de la peana
const ESCALA4 = 4;                              // las esquirlas en la bandeja y en los vuelos: 4 píxeles por píxel del boceto
const MUESTRAS_JUNTA = 16;                      // cada junta se repasa (laca, oro) por trozos
const DURA_CANTO = 4.8;                         // lo que canta con los ojos cerrados
// dónde empiezan las esquirlas en la mano (el bolsillo es redondo: dentro del círculo y fuera del hueco)
const SITIOS_MANO = [{ x: -12.5, y: 33.5 }, { x: 0, y: -30 }, { x: 30, y: 25 }];
const cantar4 = { hasta: 0 };
const olas4 = { hundida: [0, 0, 0], brillo: [0, 0, 0] };
const esquirlaCae = { x: 0, y: 0, ang: 0, activa: false };
let oroBorde = 0;                               // el oro que corre por el borde y la grieta al poner el pedazo (0 … 1)
let madera4 = null;                             // la madera de la mejilla, ampliada (bandeja y vuelos) y la de la mano
const centroDe = poli => ({ x: poli.reduce((a, q) => a + q[0], 0) / poli.length, y: poli.reduce((a, q) => a + q[1], 0) / poli.length });
const centroMejilla = () => centroDe(nivel4.contorno);
const enMano4 = () => (estado.n4 ? estado.n4.esquirlas.map((e, i) => (e === 'mano' ? i : -1)).filter(i => i >= 0) : []);
const cantando4 = () => reloj < cantar4.hasta;
function barajar(lista) {
  const r = [...lista];
  for (let i = r.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [r[i], r[j]] = [r[j], r[i]]; }
  return r;
}
function n4Inicial() {
  // la frase: tres notas que no suenan de grave a aguda (eso sería demasiado fácil de adivinar)
  let frase;
  do { frase = barajar([0, 1, 2]); } while (frase.join('') === '012' || frase.join('') === '210');
  return {
    esquirlas: ['mejilla', 'lampara', 'zocalo'],   // dónde está cada una: mejilla (aún sin caer) | cayendo | peana | mano
    frase, oida: false, pulsadas: [],
    zocalo: 'cerrado',                             // el cajón de la peana: cerrado | suelto | abierto
    laca: 'zocalo', oro: 'zocalo',
    pieza: 'sueltas',                              // sueltas | montada | lacada | curada | dorada | puesta
    // en la mano, cada esquirla empieza lejos de su sitio y girada (x, y: cuánto se ha movido su centro, en píxeles del boceto)
    montaje: nivel4.esquirlas.map((p, i) => {
      const cc = centroDe(relativo(p, centroMejilla())), sitio = SITIOS_MANO[i];
      return { x: sitio.x - cc.x, y: sitio.y - cc.y, a: [2 * Math.PI / 3, -Math.PI / 3, Math.PI][i], puesta: false };
    }),
    juntas: [Array(MUESTRAS_JUNTA).fill(false), Array(MUESTRAS_JUNTA).fill(false)],
    dorado: [Array(MUESTRAS_JUNTA).fill(false), Array(MUESTRAS_JUNTA).fill(false)],
    probada: false,
  };
}
// las imágenes: las esquirlas con la madera de la cara (bandeja, vuelos y la mano), el tarro de laca y el sobre de oro
function prepararNivel4() {
  if (!nivel4 || !img.mejilla) return;
  const m = nivel4.mejilla;
  madera4 = { origen: [m.x, m.y], bandeja: maderaMejilla(img.mejilla, ESCALA4), mano: null, ladoMano: 0 };
  img.esquirla = imagenEsquirla(0);
  img.laca = dibujarTarroLaca(100, 120); img.oro = dibujarSobreOro(110, 100);
  const c = centroMejilla();
  datos.capas.esquirla = { x: ESQUIRLA_PEANA.x - 6, y: ESQUIRLA_PEANA.y - 5, w: 12, h: 10 };
  datos.capas.laca = { x: 0, y: 0, w: 20, h: 24 };
  datos.capas.oro = { x: 0, y: 0, w: 22, h: 20 };
  datos.capas.mejilla_pieza = { x: c.x - 26, y: c.y - 19, w: 52, h: 38 };
  OBJETOS.laca.icono = icono(img.laca); OBJETOS.oro.icono = icono(img.oro);
  // las zonas del nivel 4 (con las formas de nivel4.json), delante de las demás
  const enN4 = () => estado.nivel === 4 && !!estado.n4;
  ZONAS.unshift(
    { grupo: 'caja', forma: ['elipse', ESQUIRLA_PEANA.x + 3, ESQUIRLA_PEANA.y, 26, 16], si: () => enN4() && estado.n4.esquirlas[0] === 'peana',
      tocar: () => cogerEsquirla(0, { x: ESQUIRLA_PEANA.x + 3, y: ESQUIRLA_PEANA.y }) },
    { grupo: 'caja', forma: ['poli', nivel4.contorno], si: () => estado.nivel >= 4, tocar: tocarMejilla },
    ...nivel4.olas.map((o, i) => ({ grupo: 'zocalo', forma: ['elipse', o.x, o.y, o.r * 1.7, o.r * 1.3], si: enN4, tocar: () => pulsarOla(i) })),
    { grupo: 'zocalo', forma: ['rect', 668, 552, 1000, 684], si: enN4, tocar: p => tocarZocalo(p) },
    { grupo: 'sala', forma: ['elipse', nivel4.lampara.sombra[0], nivel4.lampara.sombra[1], 60, 45], si: enN4, tocar: tocarSombra4 },
  );
  ponerPiezaMejilla();
}
// una esquirla sola (o el pedazo entero, con sus juntas como estén), recortada a su tamaño
function imagenEsquirla(i, s = ESCALA4) {
  const p = nivel4.esquirlas[i], xs = p.map(q => q[0]), ys = p.map(q => q[1]);
  const x0 = Math.min(...xs) - 2, y0 = Math.min(...ys) - 2, w = Math.max(...xs) + 2 - x0, h = Math.max(...ys) + 2 - y0;
  const c = document.createElement('canvas'); c.width = Math.ceil(w * s); c.height = Math.ceil(h * s);
  pintarEsquirla(c.getContext('2d'), p.map(([x, y]) => [x - x0, y - y0]), madera4.bandeja, [madera4.origen[0] - x0, madera4.origen[1] - y0], s, { sombra: false });
  return c;
}
function imagenPedazo(s = ESCALA4) {
  const n4 = estado.n4, cont = nivel4.contorno, xs = cont.map(q => q[0]), ys = cont.map(q => q[1]);
  const x0 = Math.min(...xs) - 2, y0 = Math.min(...ys) - 2, w = Math.max(...xs) + 2 - x0, h = Math.max(...ys) + 2 - y0;
  const c = document.createElement('canvas'); c.width = Math.ceil(w * s); c.height = Math.ceil(h * s);
  const k = c.getContext('2d'), mover = pts => pts.map(([x, y]) => [(x - x0) * s, (y - y0) * s]);
  for (const p of nivel4.esquirlas) pintarEsquirla(k, p.map(([x, y]) => [x - x0, y - y0]), madera4.bandeja, [madera4.origen[0] - x0, madera4.origen[1] - y0], s, { sombra: false });
  if (n4) {
    nivel4.juntas.forEach((j, i) => {
      pintarLaca(k, mover(j), n4.juntas[i], s * 1.1);
      pintarOro(k, mover(j), n4.dorado[i], s * 0.9);
    });
  }
  return c;
}
// el icono y el texto de lo que llevas: las esquirlas (las que tengas) o el pedazo montado, según cómo vaya
function ponerPiezaMejilla() {
  if (!madera4) return;
  const n4 = estado.n4, cuales = n4 ? enMano4() : [0];
  OBJETOS.esquirlas.icono = icono(iconoEsquirlas(nivel4.esquirlas, cuales.length ? cuales : [0], madera4.bandeja, madera4.origen, ESCALA4));
  OBJETOS.esquirlas.texto = cuales.length >= 3 ? 'Las tres esquirlas de su mejilla. Encajan entre ellas: móntalas en la mano.'
    : `Madera clara, con la veta de su cara. ${cuales.length === 1 ? 'Una esquirla' : 'Dos esquirlas'}: faltan pedazos.`;
  const pieza = n4 ? n4.pieza : 'montada';
  img.mejilla_pieza = imagenPedazo();
  OBJETOS.mejilla.icono = icono(img.mejilla_pieza);
  OBJETOS.mejilla.texto = { montada: 'Las tres esquirlas, montadas. Las juntas están abiertas: así no se sostiene.',
    lacada: 'Laca en las juntas, todavía fresca. La laca no seca al aire: cura con humedad.',
    curada: 'La laca, tibia y pegajosa: es el momento del oro.',
    dorada: 'Oro en las juntas. Un solo pedazo otra vez: el de su mejilla.' }[pieza] || OBJETOS.mejilla.texto;
  pintarInventario();
}

// el estado al final del nivel 3, para empezar el 4 sin jugarlo, y al final del 4, para el final
function estadoTrasNivel4() {
  const n4 = estado.n4 = n4Inicial();
  Object.assign(n4, { esquirlas: ['mano', 'mano', 'mano'], oida: true, pulsadas: [...n4.frase], zocalo: 'abierto', laca: 'mano', oro: 'mano',
    pieza: 'puesta', juntas: n4.juntas.map(j => j.map(() => true)), dorado: n4.dorado.map(j => j.map(() => true)) });
  n4.montaje.forEach(m => Object.assign(m, { x: 0, y: 0, a: 0, puesta: true }));
  estado.inventario = estado.inventario.filter(o => !['esquirlas', 'mejilla', 'laca', 'oro'].includes(o));
  oroBorde = 1;
  cajonAnim.zocalo.k = cajonAnim.zocalo.objetivo = 0;
  ponerPiezaMejilla();
  hornear();
}
async function empezarNivel4() {
  ocultarTarjeta();
  if (tec.enderezar) tec.enderezar();             // la caja de frente, aunque se dejara a medio girar
  estado.nivel = 4;
  estado.n4 = n4Inicial();
  estado.pistasPaso = {}; estado.intentosMirada = 0; estado.insistencia = {};
  estado.fase = 'jugando'; estado.ocupado = true;
  el.girar.hidden = false; el.inventario.hidden = false;
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  if (estado.n3 && estado.n3.largo === 'abierto') { estado.n3.largo = 'suelto'; cajonAnim.largo.objetivo = 0.12; }
  cajonAnim.zocalo.k = cajonAnim.zocalo.objetivo = 0;
  olas4.hundida = [0, 0, 0]; olas4.brillo = [0, 0, 0]; oroBorde = 0; cantar4.hasta = 0; esquirlaCae.activa = false;
  if (tec.cara() !== 'frente') tec.girar();
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; ojo.entornado = 0;
  Object.assign(ojo2, { visible: 1, parpadoBase: 0 });
  ponerPiezaMejilla();
  bucle('noche', -13, 2);
  irA('cara', 1.4);
  await esperar(1.8);
  // canta… y la voz se le quiebra en la mejilla rota: se suelta una esquirla, que cae a la peana
  animar(0.4, k => { ojo.parpadoBase = 0.7 * suave(k); ojo2.parpadoBase = 0.7 * suave(k); });
  sonar('tarareo', -5, 1); sonar('campanilla', -13, 1.02);
  bocanada(BOCA.x, BOCA.y + 8, 0, -1, 0.5);
  await esperar(1.1);
  sonar('crac', -1); sacudir(2.5, 0.25); vibrar([18, 30, 10]);
  const c = centroMejilla();
  bocanada(c.x + 4, c.y + 4, 0.6, 0.2, 0.6);
  animar(0.25, k => { ojo.parpadoBase = 0.7 + 0.3 * k; ojo2.parpadoBase = 0.7 + 0.3 * k; });
  caerEsquirla();
  irA('caja', 1.1);                                // (la cámara se aparta para que se vea dónde cae)
  await esperar(1.3);
  animar(0.5, k => { ojo.parpadoBase = 1 - salida(k); ojo2.parpadoBase = 1 - salida(k); });
  await esperar(0.5);
  estado.ocupado = false;
  mensaje('Canta… y la voz se le quiebra en la mejilla rota. Se le ha soltado una esquirla.', 4.5);
}
function caerEsquirla() {
  const n4 = estado.n4, a = centroMejilla(), b = ESQUIRLA_PEANA;
  n4.esquirlas[0] = 'cayendo';
  Object.assign(esquirlaCae, { x: a.x, y: a.y, ang: 0, activa: true });
  animar(0.6, k => {
    if (k < 0.75) { const q = k / 0.75; esquirlaCae.x = mezclar(a.x, b.x, q); esquirlaCae.y = a.y + (b.y - a.y) * q * q; esquirlaCae.ang = q * 5.2; }
    else { const q = (k - 0.75) / 0.25; esquirlaCae.x = b.x + 3 * q; esquirlaCae.y = b.y - Math.sin(q * Math.PI) * 6; esquirlaCae.ang = 5.2 + q * 1.1; }
  }, () => {
    n4.esquirlas[0] = 'peana';
    Object.assign(esquirlaCae, { x: b.x + 3, y: b.y, ang: 6.3 });
    sentir('tope', { db: -6, tono: 1.7 }); sonar('clic_madera', -10, 1.5);
    polvareda(b.x, b.y);
    mirarA(b, 2);
  });
}
async function cogerEsquirla(i, punto, ancla = 'caja') {
  const n4 = estado.n4;
  n4.esquirlas[i] = 'mano';
  if (i === 0) esquirlaCae.activa = false;
  ponerPiezaMejilla();
  sonar('recoger', -3, 1.3);
  await alInventario('esquirlas', 'esquirla', ancla, punto);
  const n = enMano4().length;
  mensaje(n === 1 ? 'Una esquirla de madera clara, con la veta de su cara.' : n === 2 ? 'Otra esquirla de su mejilla.'
    : 'La tercera esquirla. Encajan entre ellas: elígelas en la bandeja y pulsa «Mirar» para montarlas.', 4);
}
// la mejilla: lo que pasa al tocarla, según cómo vaya
function tocarMejilla() {
  const n4 = estado.n4;
  if (estado.nivel !== 4 || !n4) {
    mensaje(n4 && n4.pieza === 'puesta' ? 'La mejilla, curada con oro. La grieta brilla.' : 'La mejilla está rota: le falta un pedazo.');
    return;
  }
  if (n4.pieza === 'puesta') { mensaje('La mejilla, curada con oro.'); return; }
  if (laCajaMira()) {
    const c = centroMejilla(), veces = insistir('cara4');
    resistir(c.x, c.y - 4, 0.3, -1, c, veces);
    mensaje(veces === 1 ? 'Le duele: no deja que le toques la cara mientras te mira.' : veces === 2 ? 'Te sigue la mano con el ojo.' : 'Ni la llama la distrae: es su cara.');
    return;
  }
  mensaje('El hueco de la mejilla: la madera, rota y astillada.');
}
// cantar (tocándole la boca, con la campanilla dentro): solo mientras suelta el aire; canta tres notas con los ojos
// cerrados, y en la peana brillan tres olas de oro con ellas
function cantar4Caja() {
  const n4 = estado.n4;
  if (cantando4()) { mensaje('Está cantando, con los ojos cerrados.', 2.5); return; }
  if (!exhalando()) {
    contenerAliento(1.6); entornar(1.2);
    mensaje(primeraVez('cantar4-aire') ? 'Estaba tomando aire: lo contiene, y no canta.' : 'Lo contiene. No canta.', 3.5);
    return;
  }
  cantar4.hasta = reloj + DURA_CANTO;
  sonar('campanilla', -12, 1.02);
  animar(0.35, k => { ojo.parpadoBase = Math.max(ojo.parpadoBase, suave(k)); ojo2.parpadoBase = Math.max(ojo2.parpadoBase, suave(k)); });
  setTimeoutReloj(DURA_CANTO - 0.5, () => animar(0.5, k => { if (estado.n4.pieza !== 'puesta') { ojo.parpadoBase = 1 - salida(k); ojo2.parpadoBase = 1 - salida(k); } }));
  n4.frase.forEach((i, j) => setTimeoutReloj(0.45 + j * 0.7, () => {
    sonar('tarareo', -4, NOTAS_OLAS[i] * 0.98); sonar('campanilla', -13, NOTAS_OLAS[i] * 1.5);
    olas4.brillo[i] = 1;
    bocanada(BOCA.x + (j - 1) * 6, BOCA.y + 8, 0, -1, 0.35);
  }));
  const primera = !n4.oida;
  n4.oida = true;
  if (estado.seleccion === 'mejilla' && n4.pieza === 'dorada') mensaje('Canta con los ojos cerrados. Ahora: su mejilla.', 3);
  else mensaje(primera ? 'Canta tres notas con los ojos cerrados. Abajo, en la peana, tres olas de oro brillan con ellas.'
    : 'Canta con los ojos cerrados, y las tres olas de la peana brillan con su voz.', 4.5);
}
// las tres olas de la peana: cada una, una nota; en el orden de su canto, sueltan el cajón
function pulsarOla(i) {
  const n4 = estado.n4;
  if (estado.vista !== 'zocalo') { irA('zocalo', 0.85); return; }
  sonar('campanilla', -9, NOTAS_OLAS[i] * 1.5);
  if (n4.zocalo !== 'cerrado') { olas4.brillo[i] = 0.6; mensaje('La ola suena. El cajón ya está suelto.', 2.5); return; }
  sonar('clic_madera', -16, 1.4); vibrar(8);
  if (n4.pulsadas.includes(i)) { mensaje('Esa ola ya está hundida.', 2.5); return; }
  n4.pulsadas.push(i);
  const k = n4.pulsadas.length - 1;
  if (n4.pulsadas[k] !== n4.frase[k]) {
    setTimeoutReloj(0.35, () => {
      n4.pulsadas = [];
      sentir('trabado', { db: -6 });
      const veces = insistir('olas');
      mensaje(!n4.oida ? 'Las olas vuelven a subir. ¿En qué orden suenan?' : veces === 1 ? 'Las olas vuelven a subir: no es ese orden.' : 'No es el orden de su canto.', 3.5);
    });
    return;
  }
  if (n4.pulsadas.length === 3) soltarZocalo();
  else if (primeraVez('ola')) mensaje('La ola cede un poco y suena: una nota. Tres olas de la peana brillan más que las demás.', 4);
}
async function soltarZocalo() {
  const n4 = estado.n4;
  estado.ocupado = true;
  await esperar(0.35);
  sentir('pestillo'); await esperar(0.25);
  sentir('mecanismo', { db: -4 }); sacudir(2, 0.2);
  n4.zocalo = 'suelto';
  olas4.brillo = [1, 1, 1];
  cajonAnim.zocalo.objetivo = 0.14; cajonAnim.zocalo.v = 2.2;
  bocanada(830, 600, 0, -1, 0.6);
  estado.ocupado = false;
  mensaje('En el orden de su canto. Clac: el centro de la peana es un cajón, y se ha soltado.', 4.5);
}
function tocarZocalo(p = {}) {
  const n4 = estado.n4;
  if (estado.vista !== 'zocalo') { irA('zocalo', 0.85); return; }
  if (!n4 || n4.zocalo === 'cerrado') {
    sonar('tope_madera', -12, 0.9);
    mensaje(primeraVez('peana4') ? 'La peana suena hueca. Tres de sus olas de oro brillan más que las demás.' : 'Suena hueca.');
    return;
  }
  const a = cajonAnim.zocalo;
  if (n4.zocalo === 'suelto') {
    a.v += 1.6; sentir('holgura', { tono: 1.05 });
    mensaje(primeraVez('tirar-zocalo') ? 'Se ha soltado. Tira de él hacia fuera: arrastra el dedo.' : 'Tira de él.');
    return;
  }
  if (a.k < 0.7) return;
  // abierto: lo que se toca, o lo siguiente que quede
  const parte = p.zocalo && p.zocalo !== 'cajon' ? p.zocalo
    : n4.esquirlas[2] === 'zocalo' ? 'esquirla' : n4.laca === 'zocalo' ? 'laca' : n4.oro === 'zocalo' ? 'oro' : null;
  if (!parte) { mensaje('Vacío. Huele a laca vieja.'); return; }
  cogerDelZocalo(parte);
}
function abrirZocalo() {
  const n4 = estado.n4, a = cajonAnim.zocalo;
  n4.zocalo = 'abierto';
  a.objetivo = 1;
  sonar('cajon', -4, 0.8); vibrar(15);
  setTimeoutReloj(0.3, () => polvoDeCajon(830, 620));
  setTimeoutReloj(0.35, () => mensaje('Dentro: una esquirla, un tarro de laca con su pincel y un sobre de papel con el sello 金.', 4.5));
  if (tec.inclinar) setTimeoutReloj(0.25, () => tec.inclinar(0, 0.45));
}
function cogerDelZocalo(parte) {
  const n4 = estado.n4;
  const v = tec.puntoZocalo ? tec.puntoZocalo(parte) : null, m = v ? tec.ancla(v) : null;
  const desde = m && m.visible ? { x: m.x, y: m.y, k: 1.6, enPantalla: true } : { x: 830, y: 615 };
  if (parte === 'esquirla') { cogerEsquirla(2, desde, 'caja'); return; }
  n4[parte] = 'mano';
  sonar('recoger', -3, parte === 'laca' ? 0.9 : 1.4);
  if (parte === 'oro') sonar('oro', -12);
  alInventario(parte, parte, 'caja', desde);
  mensaje(parte === 'laca' ? 'Laca de urushi, negra y espesa, con su pincel en la tapa. Pega lo roto… cuando cura.' : 'Un sobre de papel, con el sello 金. Dentro, polvo de oro.', 4);
}
// la lámpara, en el nivel 4: encima de su marco está la segunda esquirla (su sombra la delata en la pared); ya no
// distrae al ojo, que no aparta la vista de su cara
function tocarLampara4() {
  const n4 = estado.n4;
  if (n4.esquirlas[1] === 'lampara') {
    const q = nivel4.lampara.esquirla;
    cogerEsquirla(1, { x: q[0], y: q[1] }, 'sala');
    setTimeoutReloj(0.2, () => mensaje(primeraVez('lampara4') ? 'Encima del marco de la lámpara había otra esquirla: era su sombra la de la pared.' : 'Otra esquirla.', 4));
    return;
  }
  mensaje(primeraVez('lampara4-ojo') ? 'La llama tiembla, pero ya no la distrae: no aparta los ojos de su cara.' : 'La llama tiembla.', 3.5);
}
function tocarSombra4() {
  const n4 = estado.n4;
  if (n4 && n4.esquirlas[1] === 'lampara') { mirarA({ x: 604, y: 214 }, 1.5); mensaje('Una sombra extraña en la pared, sobre la lámpara. Algo pequeño está encima de su marco.', 4); }
  else mensaje('La pared, tibia de la lámpara.');
}

// ---- en la mano: montar las esquirlas, trazar la laca y espolvorear el oro (el bolsillo, modo «esquirlas») ----
// Las coordenadas de la mano: píxeles del boceto, con el centro del hueco en el (0, 0); en el lienzo, el hueco va en el
// centro, un poco arriba (abajo quedan la laca y el oro)
const mano4 = { arrastre: null, trazo: null, herramienta: null, motas: [], brillo: 0, ultimoPincel: 0, ultimoOro: 0 };
function escalaMano() { return el.bolsillo.width / 100; }
function aMano(q) {                                       // de −1…1 del bolsillo a coordenadas de la mano
  const W = el.bolsillo.width, s = escalaMano();
  return { x: (q.x + 1) / 2 * W / s - W / 2 / s, y: (q.y + 1) / 2 * W / s - W * 0.44 / s };
}
const relativo = (poli, c) => poli.map(([x, y]) => [x - c.x, y - c.y]);
function girarPunto(p, a) { const s = Math.sin(a), c = Math.cos(a); return [p[0] * c - p[1] * s, p[0] * s + p[1] * c]; }
// el polígono de la esquirla i tal como está en la mano (movida y girada alrededor de su centro)
function esquirlaEnMano(i) {
  const c = centroMejilla(), poli = relativo(nivel4.esquirlas[i], c), cc = centroDe(poli), m = estado.n4.montaje[i];
  return poli.map(p => { const q = girarPunto([p[0] - cc.x, p[1] - cc.y], m.a); return [q[0] + cc.x + m.x, q[1] + cc.y + m.y]; });
}
const herramientas4 = () => {
  const n4 = estado.n4, r = [];
  if (!n4 || n4.pieza === 'sueltas') return r;
  if (estado.inventario.includes('laca')) r.push({ id: 'laca', x: -0.5, y: 0.64 });
  if (estado.inventario.includes('oro')) r.push({ id: 'oro', x: 0.5, y: 0.64 });
  return r;
};
function ayudaMano4() {
  const n4 = estado.n4;
  if (!n4) return '';
  if (n4.pieza === 'sueltas') return enMano4().length < 3 ? `Faltan ${3 - enMano4().length === 1 ? 'una esquirla' : 'dos esquirlas'} · toca fuera para guardarlas`
    : 'Arrastra cada esquirla a su sitio · tócala para girarla';
  if (n4.pieza === 'montada') return estado.inventario.includes('laca') ? 'Toca la laca y repasa las juntas con el dedo' : 'Las juntas están abiertas: hace falta con qué pegarlas';
  if (n4.pieza === 'lacada') return 'La laca cura con humedad, no al aire · toca fuera para guardarlo';
  if (n4.pieza === 'curada') return estado.inventario.includes('oro') ? 'Toca el oro y espolvoréalo sobre las juntas' : 'La laca está pegajosa: falta el oro';
  return 'Oro en las juntas · toca fuera para guardarlo';
}
function abrirMano4() {
  bolsillo.activo = true; bolsillo.modo = 'esquirlas';
  mano4.arrastre = null; mano4.trazo = null; mano4.motas.length = 0;
  mano4.herramienta = null;                     // (al abrirla, nada elegido: se elige con un toque)
  medirBolsillo();
}
function manoPulsar(q, id) {
  const n4 = estado.n4;
  // las herramientas (con el pedazo montado)
  for (const h of herramientas4()) {
    if (Math.hypot(q.x - h.x, q.y - h.y) < 0.19) {
      mano4.herramienta = mano4.herramienta === h.id ? null : h.id;
      sonar(h.id === 'laca' ? 'pincel' : 'oro', -14, 1.1); vibrar(6);
      el.examinarAyuda.textContent = mano4.herramienta === 'laca' ? 'Repasa con el dedo las dos juntas del pedazo'
        : mano4.herramienta === 'oro' ? 'Espolvorea: mueve el dedo de un lado a otro sobre las juntas' : ayudaMano4();
      return;
    }
  }
  if (n4.pieza !== 'sueltas') {
    if (mano4.herramienta) { mano4.trazo = { id }; aplicarHerramienta(q); }
    return;
  }
  // una esquirla suelta (la de encima primero)
  const p = aMano(q), orden = [...enMano4()].reverse();
  for (const i of orden) {
    const m = n4.montaje[i];
    if (m.puesta) continue;
    if (dentro(['poli', esquirlaEnMano(i)], p)) {
      mano4.arrastre = { i, id, x0: q.x, y0: q.y, mx: m.x, my: m.y, movido: 0 };
      sentir('roce', { tono: 1.6, db: -6 });
      return;
    }
  }
}
function manoMover(q, id) {
  const n4 = estado.n4, a = mano4.arrastre;
  if (a && a.id === id) {
    const W = el.bolsillo.width, s = escalaMano(), m = n4.montaje[a.i];
    a.movido = Math.max(a.movido, Math.hypot(q.x - a.x0, q.y - a.y0));
    m.x = a.mx + (q.x - a.x0) / 2 * W / s; m.y = a.my + (q.y - a.y0) / 2 * W / s;
    return;
  }
  if (mano4.trazo && mano4.trazo.id === id) aplicarHerramienta(q);
}
function manoSoltar(q, id) {
  const n4 = estado.n4, a = mano4.arrastre;
  if (mano4.trazo && mano4.trazo.id === id) mano4.trazo = null;
  if (!a || a.id !== id) return;
  mano4.arrastre = null;
  const m = n4.montaje[a.i];
  if (a.movido < 0.05) {                       // un toque: la esquirla gira un sexto de vuelta
    m.a = (m.a + Math.PI / 3) % (2 * Math.PI);
    sonar('clic_madera', -12, 1.6); vibrar(5);
  }
  // cerca de su sitio y bien girada, encaja
  const giroBien = Math.abs(Math.atan2(Math.sin(m.a), Math.cos(m.a))) < 0.05;
  if (Math.hypot(m.x, m.y) < 6 && giroBien) {
    Object.assign(m, { x: 0, y: 0, a: 0, puesta: true });
    sentir('clac', { tono: 1.35 }); mano4.brillo = 1;
    if (n4.montaje.every((mm, i) => mm.puesta || n4.esquirlas[i] !== 'mano') && enMano4().length === 3) montarPedazo();
    else el.examinarAyuda.textContent = enMano4().length < 3 ? 'Encaja. Faltan esquirlas' : 'Encaja. Sigue con las otras';
  } else if (Math.hypot(m.x, m.y) < 10 && !giroBien && a.movido >= 0.05) {
    sentir('tope', { db: -10, tono: 1.5, sinVibrar: true });
    el.examinarAyuda.textContent = 'Casi: gírala (tócala) hasta que encaje';
  }
}
function montarPedazo() {
  const n4 = estado.n4;
  n4.pieza = 'montada';
  estado.inventario = estado.inventario.map(o => (o === 'esquirlas' ? 'mejilla' : o));
  if (estado.seleccion === 'esquirlas') estado.seleccion = null;
  ponerPiezaMejilla();
  sonar('encajar', -6, 1.2);
  el.examinarNombre.textContent = OBJETOS.mejilla.nombre;
  el.examinarTexto.textContent = OBJETOS.mejilla.texto;
  el.examinarAyuda.textContent = ayudaMano4();
}
// la herramienta, donde está el dedo: la laca marca las juntas que repasa; el oro cae y se pega a la laca curada
function aplicarHerramienta(q) {
  const n4 = estado.n4, p = aMano(q), c = centroMejilla();
  if (mano4.herramienta === 'laca') {
    if (n4.pieza === 'curada' || n4.pieza === 'dorada') { el.examinarAyuda.textContent = 'La laca ya está puesta'; return; }
    let alguna = false;
    nivel4.juntas.forEach((j, i) => {
      muestrear(relativo(j, c), MUESTRAS_JUNTA).forEach(([x, y], k) => {
        if (!n4.juntas[i][k] && Math.hypot(x - p.x, y - p.y) < 4) { n4.juntas[i][k] = true; alguna = true; }
      });
    });
    if (alguna && reloj > mano4.ultimoPincel) { sonar('pincel', -10, azar(0.9, 1.1)); mano4.ultimoPincel = reloj + 0.3; }
    if (n4.juntas.every(j => j.every(Boolean)) && n4.pieza === 'montada') {
      n4.pieza = 'lacada'; ponerPiezaMejilla();
      mano4.herramienta = null;
      el.examinarTexto.textContent = OBJETOS.mejilla.texto; el.examinarAyuda.textContent = ayudaMano4();
      sentir('tope', { db: -10, tono: 1.4, sinVibrar: true });
    }
    return;
  }
  if (mano4.herramienta === 'oro') {
    // las motas caen desde el dedo y se quedan donde haya laca curada
    for (let i = 0; i < 3; i++) mano4.motas.push({ x: p.x + azar(-2, 2), y: p.y - azar(0, 2.5), vy: azar(5, 14), suelo: p.y + azar(0, 1.6), t: 0, vida: azar(0.6, 1.2), pega: n4.pieza === 'curada' });
    if (reloj > mano4.ultimoOro) { sonar('oro', -16, azar(0.95, 1.1)); mano4.ultimoOro = reloj + 0.8; }
    if (n4.pieza !== 'curada' && primeraVez('oro-no-pega')) el.examinarAyuda.textContent = n4.pieza === 'lacada' ? 'El oro resbala: la laca aún está fresca. Tiene que curar' : 'El oro no se pega a la madera: necesita laca';
  }
}
function actualizarMano4(dt) {
  const n4 = estado.n4, c = centroMejilla();
  for (const m of mano4.motas) {
    m.t += dt;
    if (m.y < m.suelo) { m.vy += 60 * dt; m.y = Math.min(m.suelo, m.y + m.vy * dt); }
    else if (!m.posada) {
      m.posada = true;
      if (m.pega) nivel4.juntas.forEach((j, i) => muestrear(relativo(j, c), MUESTRAS_JUNTA).forEach(([x, y], k) => {
        if (n4.juntas[i][k] && Math.hypot(x - m.x, y - m.y) < 3) n4.dorado[i][k] = true;
      }));
    }
  }
  for (let i = mano4.motas.length - 1; i >= 0; i--) if (mano4.motas[i].t > mano4.motas[i].vida + (mano4.motas[i].pega ? 0.5 : 0)) mano4.motas.splice(i, 1);
  if (n4.pieza === 'curada' && n4.dorado.every(j => j.every(Boolean))) {
    n4.pieza = 'dorada'; ponerPiezaMejilla();
    mano4.herramienta = null; mano4.brillo = 1;
    sonar('campanilla', -10, 1.5); sentir('desbloqueo', { db: -10 });
    el.examinarTexto.textContent = OBJETOS.mejilla.texto; el.examinarAyuda.textContent = ayudaMano4();
  }
  mano4.brillo = Math.max(0, mano4.brillo - dt * 0.8);
}
function dibujarMano4(dt) {
  const n4 = estado.n4;
  if (!n4 || !madera4) return;
  actualizarMano4(dt);
  const c = el.bolsillo.getContext('2d'), W = el.bolsillo.width, s = escalaMano(), cx = W / 2, cy = W * 0.44;
  // la madera de la mano, a su tamaño (se rehace si cambia el lienzo)
  if (madera4.ladoMano !== W) { madera4.mano = maderaMejilla(img.mejilla, s); madera4.ladoMano = W; }
  c.setTransform(1, 0, 0, 1, 0, 0); c.clearRect(0, 0, W, W);
  // un paño de seda oscuro (fukusa), donde se trabaja
  const r = W * 0.04;
  c.fillStyle = '#1d2433';
  c.beginPath(); c.roundRect ? c.roundRect(W * 0.03, W * 0.03, W * 0.94, W * 0.94, r) : c.rect(W * 0.03, W * 0.03, W * 0.94, W * 0.94); c.fill();
  const v = c.createRadialGradient(cx, cy, W * 0.1, cx, cy, W * 0.7);
  v.addColorStop(0, 'rgba(70, 86, 120, 0.35)'); v.addColorStop(1, 'rgba(0, 0, 0, 0.4)');
  c.fillStyle = v; c.fill();
  c.translate(cx, cy);
  const cen = centroMejilla(), origen = [madera4.origen[0] - cen.x, madera4.origen[1] - cen.y];
  // el hueco donde van: la forma de la mejilla, en sombra (hasta que está montado)
  if (n4.pieza === 'sueltas') {
    const hueco = relativo(nivel4.contorno, cen).map(([x, y]) => [x * s, y * s]);
    c.beginPath(); hueco.forEach(([x, y], i) => (i ? c.lineTo(x, y) : c.moveTo(x, y))); c.closePath();
    c.fillStyle = 'rgba(8, 10, 16, 0.55)'; c.fill();
    c.setLineDash([W * 0.012, W * 0.01]); c.strokeStyle = 'rgba(214, 190, 140, 0.45)'; c.lineWidth = W * 0.004; c.stroke(); c.setLineDash([]);
  }
  // las esquirlas: primero las puestas, luego las sueltas (la que se arrastra, encima)
  const orden = enMano4().sort((a, b) => (n4.montaje[b].puesta - n4.montaje[a].puesta) || (mano4.arrastre && a === mano4.arrastre.i ? 1 : mano4.arrastre && b === mano4.arrastre.i ? -1 : 0));
  for (const i of orden) {
    const m = n4.montaje[i], poli = relativo(nivel4.esquirlas[i], cen), cc = centroDe(poli);
    c.save();
    c.translate((cc.x + m.x) * s, (cc.y + m.y) * s); c.rotate(m.a); c.translate(-cc.x * s, -cc.y * s);
    pintarEsquirla(c, poli, madera4.mano, origen, s, { sombra: !m.puesta, brillo: m.puesta ? mano4.brillo : 0 });
    c.restore();
  }
  // las juntas: abiertas (oscuras), con laca y con oro
  if (n4.pieza !== 'sueltas') {
    nivel4.juntas.forEach((j, i) => {
      const pts = relativo(j, cen).map(([x, y]) => [x * s, y * s]);
      if (n4.pieza === 'montada') {
        c.save(); c.strokeStyle = 'rgba(18, 9, 4, 0.85)'; c.lineWidth = s * 0.5; c.lineCap = 'round';
        c.beginPath(); pts.forEach(([x, y], k) => (k ? c.lineTo(x, y) : c.moveTo(x, y))); c.stroke(); c.restore();
      }
      pintarLaca(c, pts, n4.juntas[i], s * 0.9);
      if (n4.pieza === 'curada' || n4.pieza === 'dorada') {
        // la laca curada brilla un poco más (pegajosa)
        c.save(); c.globalAlpha = 0.35; pintarLaca(c, pts, n4.juntas[i], s * 1.15); c.restore();
      }
      pintarOro(c, pts, n4.dorado[i], s * 0.75, { chispa: n4.pieza === 'dorada' ? (reloj * 0.35) % 1 : 0 });
    });
  }
  // las motas de oro
  for (const m of mano4.motas) {
    const a = m.posada ? Math.max(0, 1 - (m.t - m.vida) * 2) : 1;
    c.fillStyle = `rgba(${m.pega ? '246, 214, 140' : '230, 200, 130'}, ${a})`;
    c.fillRect(m.x * s - s * 0.12, m.y * s - s * 0.12, s * 0.24, s * 0.24);
  }
  c.setTransform(1, 0, 0, 1, 0, 0);
  // las herramientas, abajo
  for (const h of herramientas4()) {
    const x = (h.x + 1) / 2 * W, y = (h.y + 1) / 2 * W, rr = W * 0.075, elegida = mano4.herramienta === h.id;
    c.save();
    c.fillStyle = elegida ? 'rgba(214, 170, 92, 0.35)' : 'rgba(10, 12, 20, 0.55)';
    c.beginPath(); c.arc(x, y, rr, 0, Math.PI * 2); c.fill();
    c.strokeStyle = elegida ? 'rgba(246, 222, 160, 0.95)' : 'rgba(214, 190, 140, 0.5)'; c.lineWidth = W * 0.005; c.stroke();
    const im = h.id === 'laca' ? img.laca : img.oro, e = rr * 1.4 / Math.max(im.width, im.height);
    c.drawImage(im, x - im.width * e / 2, y - im.height * e / 2, im.width * e, im.height * e);
    c.restore();
  }
  if (mano4.trazo && mano4.herramienta === 'laca') { /* (el pincel se nota en el sonido y en la laca que aparece) */ }
}

// la boca, en el nivel 4: canta (con la campanilla dentro), y con el pedazo lacado, le echa el aliento
function usarMejillaEnBoca(desde) {
  const n4 = estado.n4;
  if (n4.pieza === 'dorada') { cantar4Caja(); return; }
  if (n4.pieza === 'sueltas') { mensaje('Primero, monta las esquirlas.'); return; }
  if (n4.pieza === 'montada') { vaho(); mensaje('Le echa el aliento, pero sin laca no hay nada que curar.', 3.5); return; }
  if (n4.pieza === 'curada') { mensaje('Ya está curada: la laca, tibia y pegajosa. Es el momento del oro.', 3.5); return; }
  if (!exhalando()) {
    contenerAliento(1.6); entornar(1.2);
    mensaje(primeraVez('curar-aire') ? 'Estaba tomando aire: lo contiene.' : 'Lo contiene.', 3);
    return;
  }
  curarPedazo(desde);
}
async function curarPedazo(desde) {
  const n4 = estado.n4;
  estado.ocupado = true;
  if (estado.seleccion === 'mejilla') { estado.seleccion = null; pintarInventario(); }
  if (estado.vista !== 'cara') { irA('cara', 0.7); await esperar(0.6); }
  const delante = { x: BOCA.x + 4, y: BOCA.y + 18 };
  await desdeInventario('mejilla', 'mejilla_pieza', delante, 'caja', desde);
  pedazoEnBoca = { x: delante.x, y: delante.y };
  vaho(); sonar('suspiro', -8, 1.05);
  setTimeoutReloj(0.9, () => vaho());
  await esperar(1.9);
  n4.pieza = 'curada';
  ponerPiezaMejilla();
  pedazoEnBoca = null;
  await alInventario('mejilla', 'mejilla_pieza', 'caja', delante);
  estado.ocupado = false;
  mensaje('Le echa el aliento, tibio y húmedo: la laca se pone pegajosa. Es el momento del oro.', 4.5);
}
let pedazoEnBoca = null;
// el pedazo dorado, en su sitio: solo si la caja no mira (cierra los ojos cuando canta)
async function ponerMejilla(desde) {
  const n4 = estado.n4, c = centroMejilla();
  if (laCajaMira()) {
    const veces = insistir('mejilla');
    resistir(c.x, c.y - 4, 0.3, -1, c, veces);
    mensaje(veces === 1 ? 'Te mira la mano: no deja que le toques la cara.' : veces === 2 ? 'Ni la llama la distrae: es su cara.' : 'Cuando canta, cierra los ojos.', 4);
    return;
  }
  estado.ocupado = true;
  if (estado.seleccion) { estado.seleccion = null; pintarInventario(); }
  if (estado.vista !== 'cara') { irA('cara', 0.6); await esperar(0.5); }
  await desdeInventario('mejilla', 'mejilla_pieza', c, 'caja', desde);
  n4.pieza = 'puesta';
  estado.inventario = estado.inventario.filter(o => o !== 'laca' && o !== 'oro');
  pintarInventario();
  hornear();
  sentir('clac', { tono: 1.1 }); sonar('encajar', -4);
  await esperar(0.45);
  // el oro corre por el borde del pedazo y baja por la grieta
  sonar('oro', -3);
  await animarPromesa(2.4, k => { oroBorde = suave(k); });
  oroBorde = 1;
  hornear();
  destello(c.x, c.y, 100, '255,215,140', 0.8, 1.8);
  // y canta, con los ojos abiertos
  cantar4.hasta = 0;
  animar(0.6, k => { ojo.parpadoBase = Math.min(ojo.parpadoBase, 1 - salida(k)); ojo2.parpadoBase = Math.min(ojo2.parpadoBase, 1 - salida(k)); });
  sonar('canto', -2);
  for (let i = 0; i < 5; i++) setTimeoutReloj(0.3 + i * 1.1, () => bocanada(BOCA.x + azar(-8, 8), BOCA.y + 8, azar(-0.3, 0.3), -1, 0.6));
  destello(c.x, c.y, 140, '255,215,150', 0.45, 6);
  agitarLampara(2, 0.4);
  await esperar(6.6);
  estado.ocupado = false;
  terminarNivel(4);
}
// lo que se dibuja encima en el nivel 4 (y después): la esquirla que cae y la de la peana, la sombra de la pared, las
// olas de oro, el pedazo delante de la boca y el oro que corre (luego, un brillo de vez en cuando)
function dibujarNivel4Encima(conAncla) {
  const n4 = estado.n4;
  if (!n4 || !nivel4) return;
  const deFrente = tec.cara() === 'frente';
  if (estado.nivel === 4 && (n4.esquirlas[0] === 'cayendo' || n4.esquirlas[0] === 'peana') && img.esquirla) conAncla(esquirlaCae.x, esquirlaCae.y, 'caja', () => {
    const d = datos.capas.esquirla;
    ctx.save(); ctx.translate(esquirlaCae.x, esquirlaCae.y); ctx.rotate(esquirlaCae.ang);
    ctx.drawImage(img.esquirla, -d.w / 2, -d.h / 2, d.w, d.h);
    ctx.restore();
  });
  if (estado.nivel === 4 && n4.esquirlas[1] === 'lampara') {
    const [sx, sy] = nivel4.lampara.sombra, cen = centroDe(nivel4.esquirlas[1]);
    conAncla(sx, sy, 'sala', () => {
      // la sombra de la esquirla, grande y temblando con la llama (al revés: la luz viene de abajo)
      const tiembla = 0.75 + 0.25 * Math.sin(reloj * 9.1) * Math.sin(reloj * 3.7);
      ctx.save(); ctx.translate(sx + Math.sin(reloj * 7.3) * 1.2, sy + Math.sin(reloj * 5.1) * 0.8); ctx.scale(3.3, -3.3);
      ctx.beginPath(); nivel4.esquirlas[1].forEach(([x, y], i) => (i ? ctx.lineTo(x - cen.x, y - cen.y) : ctx.moveTo(x - cen.x, y - cen.y))); ctx.closePath();
      ctx.filter = 'blur(0.5px)';
      ctx.fillStyle = `rgba(34, 18, 9, ${0.55 * tiembla * (1 - lampara.apagada)})`; ctx.fill();
      ctx.restore();
    });
  }
  if (deFrente && estado.nivel === 4) {
    // las tres olas: brillan con su nota (y, cuando la caja suelta el aire, un poco, para que se distingan)
    nivel4.olas.forEach((o, i) => {
      const hundida = olas4.hundida[i];
      // tres olas de oro más vivo, incrustadas: arcos concéntricos sobre las pintadas
      conAncla(o.x, o.y, 'caja', () => {
        ctx.save(); ctx.lineCap = 'round';
        for (let k = 0; k < 3; k++) {
          const r = o.r * (1 - k * 0.3);
          ctx.strokeStyle = `rgba(${k ? '236, 200, 120' : '250, 222, 150'}, ${0.85 - 0.15 * k - 0.4 * hundida})`;
          ctx.lineWidth = k ? 0.9 : 1.3;
          ctx.beginPath(); ctx.arc(o.x, o.y + o.r * 0.35 + 1.5 * hundida, r, Math.PI * 1.08, Math.PI * 1.92); ctx.stroke();
        }
        ctx.restore();
      });
      if (hundida > 0.01) conAncla(o.x, o.y, 'caja', () => {
        ctx.save(); ctx.fillStyle = `rgba(6, 3, 2, ${0.38 * hundida})`;
        ctx.beginPath(); ctx.ellipse(o.x, o.y + 1, o.r * 1.15, o.r * 0.7, 0, 0, Math.PI * 2); ctx.fill(); ctx.restore();
      });
    });
  }
  if (pedazoEnBoca && img.mejilla_pieza) conAncla(pedazoEnBoca.x, pedazoEnBoca.y, 'caja', () => {
    const d = datos.capas.mejilla_pieza;
    ctx.drawImage(img.mejilla_pieza, pedazoEnBoca.x - d.w / 2, pedazoEnBoca.y - d.h / 2, d.w, d.h);
  });
  if (deFrente && n4.pieza === 'puesta') {
    const cerrado = [...nivel4.contorno, nivel4.contorno[0]], c = centroMejilla();
    if (oroBorde < 1) conAncla(c.x, c.y, 'caja', () => {
      pintarOro(ctx, cerrado, null, 1.8, { hasta: Math.min(1, oroBorde / 0.7) });
      pintarOro(ctx, nivel4.grieta, null, 1.55, { hasta: Math.max(0, (oroBorde - 0.6) / 0.4) });
    });
    else {
      const t = reloj % 7;
      if (t < 1.4) conAncla(c.x, c.y, 'caja', () => pintarOro(ctx, cerrado, null, 1.8, { hasta: 1, chispa: t / 1.4 }));
    }
  }
}
// el brillo de las olas (con luz: se dibuja en modo «lighter»)
function dibujarLuzOlas(conAncla) {
  const n4 = estado.n4;
  if (!n4 || !nivel4 || estado.nivel !== 4 || tec.cara() !== 'frente') return;
  const pulso = n4.zocalo === 'cerrado' ? 0.1 + 0.08 * Math.sin(reloj * 1.7) : 0;
  nivel4.olas.forEach((o, i) => {
    const a = Math.max(olas4.brillo[i], pulso);
    if (a < 0.02) return;
    conAncla(o.x, o.y, 'caja', () => brillo(ctx, o.x, o.y, o.r * 2.2, '255,215,140', a * 0.9));
  });
}
function actualizarNivel4(dt) {
  if (!estado.n4) return;
  for (let i = 0; i < 3; i++) {
    olas4.brillo[i] = Math.max(0, olas4.brillo[i] - dt * 1.1);
    const meta = estado.n4.pulsadas.includes(i) && estado.n4.zocalo === 'cerrado' ? 1 : 0;
    olas4.hundida[i] = mezclar(olas4.hundida[i], meta, 1 - Math.exp(-dt * 14));
  }
}
// las pistas del nivel 4, de vagas a claras
function pistaNivel4() {
  const n4 = estado.n4;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4.5);
  };
  if (!n4) return mensaje('Mira.');
  if (n4.esquirlas[0] === 'peana' || n4.esquirlas[0] === 'cayendo') return escalon('peana', ['Algo pequeño cayó de su mejilla.', 'Está en el reborde de la peana, bajo la cara. Tócalo.']);
  if (n4.esquirlas[1] === 'lampara') return escalon('sombra', ['Faltan más pedazos de su mejilla. Mira las sombras de la sala.', 'Sobre la lámpara, en la pared, hay una sombra que no es de la lámpara.', 'Toca la lámpara: encima de su marco hay algo.']);
  if (n4.zocalo === 'cerrado') return escalon('olas', ['La peana suena hueca. Tres de sus olas de oro brillan más.', 'Cuando la caja canta, esas olas brillan, una con cada nota.',
    'Tócale la boca mientras suelta el aire: canta tres notas. Luego toca las tres olas en ese orden.']);
  if (n4.zocalo === 'suelto') return escalon('zocalo', ['El centro de la peana se ha soltado.', 'Tira de él hacia fuera con el dedo.']);
  if (n4.esquirlas[2] === 'zocalo' || n4.laca === 'zocalo' || n4.oro === 'zocalo') return escalon('dentro', ['En el cajón de la peana queda algo.', 'Tócalo para cogerlo.']);
  if (n4.pieza === 'sueltas') return escalon('montar', ['Tres esquirlas que encajan entre ellas.', 'Elígelas en la bandeja y pulsa «Mirar» para tenerlas en la mano.', 'Arrastra cada una a la sombra con su forma; tócala para girarla.']);
  if (n4.pieza === 'montada') return escalon('laca', ['Las juntas están abiertas: ¿con qué se pega la madera?', 'Con el pedazo en la mano, toca la laca y repasa las juntas con el dedo.']);
  if (n4.pieza === 'lacada') return escalon('curar', ['La laca japonesa no seca al aire: cura con humedad.', 'El té ya está tibio. ¿Qué más da humedad en esta sala?', 'Su aliento. Lleva el pedazo a su boca mientras suelta el aire.']);
  if (n4.pieza === 'curada') return escalon('oro', ['La laca está pegajosa: es el momento del oro.', 'Con el pedazo en la mano, toca el oro y espolvoréalo moviendo el dedo sobre las juntas.']);
  if (n4.pieza === 'dorada') return escalon('poner', ['El pedazo va en su mejilla, pero no deja que le toques la cara mientras te mira.', 'La llama ya no la distrae. Cuando canta, cierra los ojos.',
    'Tócale la boca mientras suelta el aire y, mientras canta, pon el pedazo en la mejilla.']);
  return mensaje('Mira cómo brilla el oro.');
}

// ---------------------------------------------------------------------------------------------
// Nivel 5 · La cómoda (solo en la B; NIVELES.md §8). Con la cara entera, la caja enseña su cuerpo: la cómoda de su
// espalda es un mecanismo (cajones que se bloquean, uno de empujar, un panel hueco que es un cajón escondido) y la borla
// de su costado, un cerrojo: su cordón cruza la caja y sujeta un pasador que traba los dos cajones con cerradura del otro
// costado. La regla del ojo varía otra vez: tiene sueño; si no la tocas, se duerme, y un ruido la despierta. Pasos:
//   bosteza y suena «clac» detrás (m1 sale solo) → con m1 fuera, t2 no sale: empujarlo → t2: la tarjeta del lazo → c no
//   se tira: se empuja → la llave de bambú → golpear el panel del hueco de la ficha (suena hueco; a la tercera cae un
//   pasador) → el hueco es un tirador: el cajón escondido y el cordón → en el costado, la cola de punta negra deshace el
//   lazo → tirar de la borla: el pasador sube y la cómoda se suelta (c2: las tsukegi) → c6: la llave no gira, empuja →
//   esperar a que se duerma → tirar despacio → su secreto.
// ---------------------------------------------------------------------------------------------
let nivel5 = null;                                   // capas/nivel5.json: los cajones de la espalda y la borla
const CAJONES5 = ['t1', 't2', 't3', 'm1', 'm2', 'c', 'r1', 'r2', 'r3'];
const TEXTOS5 = {
  t1: 'Vacío. Huele a alcanfor.',
  t3: 'Un ovillo de seda roja: la misma de la borla del otro costado.',
  m1: 'Vacío. En el fondo, una muesca con forma de ficha.',
  m2: 'Serrín fino, como si alguien hubiera trabajado la madera por dentro.',
  r1: 'Un frasquito que huele a aceite de colza. Casi vacío.',
  r2: 'Papeles de incienso, doblados.',
  r3: 'Un dedal de bronce.',
};
const M1_FUERA = 0.35;                               // lo que sale m1 solo, al empezar
const VELOCIDAD_RUIDO = 1.6;                         // un cajón que corre más deprisa (fracción por segundo) hace ruido
for (const id of [...CAJONES5, 'p']) cajonAnim['espalda_' + id] = { k: 0, v: 0, objetivo: 0, agarrado: false, golpe: 0 };
const anim5 = id => cajonAnim['espalda_' + id];
// la borla: cómo se dibuja ahora (tecnica_3d.js la pinta en el costado)
const borla5 = { desatado: 0, aprieto: 0, bajada: 0, objetivoBajada: 0, vBajada: 0, meneo: 0, vMeneo: 0 };
const estadoBorla = () => ({ desatado: borla5.desatado, aprieto: borla5.aprieto, bajada: borla5.bajada, meneo: borla5.meneo, colaNegra: 'der' });
// el sueño: sube si nadie la toca; dormida, un ruido la despierta
const sueno = { nivel: 0, dormida: false, toque: -99, ruido: -99, avisado: false, seno: 0 };
function n5Inicial() {
  return {
    cajones: Object.fromEntries([...CAJONES5, 'p'].map(id => [id, 'cerrado'])),   // cerrado | abierto (m1, al empezar, fuera)
    m1: 'dentro',          // dentro | fuera (sale solo al empezar)
    c: 'trabado',          // trabado (la argolla fija: se empuja) | suelto
    p: 'escondido',        // escondido (atascado) | suelto | abierto
    golpes: 0,
    tarjeta: 't2',         // t2 | mano
    llave: 'c',            // c | mano | metida (en c6, sin empujar) | usada
    cordon: false,         // si se ha visto el cordón del cajón escondido
    lazo: 'atado',         // atado | suelto
    borla: 'arriba',       // arriba | abajo
    pasador: 'puesto',     // puesto | quitado (la cómoda se suelta)
    c6: 'cerrado',         // cerrado | suelto (la llave empujada)
    tsukegi: 'c2',         // c2 | mano
    secreto: 'c6',         // c6 | mano
  };
}
// ¿tiene cerradura este cajón del costado? (c2 y c6, desde el nivel 1; en el 5 se sueltan)
function tieneCerradura(id) {
  if (!CAJONES[id].cerradura) return false;
  const n5 = estado.n5;
  if (estado.nivel >= 5 && n5) {
    if (id === 'c2') return n5.pasador === 'puesto';
    if (id === 'c6') return n5.pasador === 'puesto' || n5.c6 === 'cerrado';
  }
  return true;
}
function prepararNivel5() {
  if (!nivel5) return;
  img.tarjeta = dibujarTarjetaLazo(240, 170);
  img.tsukegi = dibujarTsukegi(200, 150);
  datos.capas.tarjeta = { x: 0, y: 0, w: 34, h: 24 };
  datos.capas.tsukegi = { x: 0, y: 0, w: 30, h: 22 };
  datos.capas.secreto = { x: 0, y: 0, w: 40, h: 22 };
  OBJETOS.tarjeta.icono = icono(img.tarjeta); OBJETOS.tsukegi.icono = icono(img.tsukegi);
}
// el estado al final del nivel 4 está en estadoTrasNivel4; al final del 5, para empezar el 6 sin jugarlo
function estadoTrasNivel5() {
  const n5 = estado.n5 = n5Inicial();
  Object.assign(n5, { c: 'suelto', p: 'suelto', golpes: 3, tarjeta: 'mano', llave: 'usada', cordon: true, lazo: 'suelto', borla: 'abajo',
    pasador: 'quitado', c6: 'suelto', secreto: 'mano' });
  estado.inventario = estado.inventario.filter(o => !['tarjeta', 'llave', 'secreto', 'tsukegi'].includes(o));
  n5.tsukegi = 'c2';
  for (const id of [...CAJONES5, 'p']) { const a = anim5(id); a.k = a.objetivo = 0; a.v = 0; }
  Object.assign(borla5, { desatado: 1, aprieto: 0, bajada: 1, objetivoBajada: 1, meneo: 0 });
  for (const id of ['c2', 'c6']) { estado.cajones[id] = 'cerrado'; cajonAnim[id].k = cajonAnim[id].objetivo = 0; }
  sueno.dormida = false; sueno.nivel = 0;
}
async function empezarNivel5() {
  ocultarTarjeta();
  if (tec.enderezar) tec.enderezar();             // la caja de frente, aunque se dejara a medio girar
  estado.nivel = 5;
  estado.n5 = n5Inicial();
  estado.pistasPaso = {}; estado.intentosMirada = 0; estado.insistencia = {};
  estado.fase = 'jugando'; estado.ocupado = true;
  el.girar.hidden = false; el.inventario.hidden = false;
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  if (estado.n3 && estado.n3.largo === 'abierto') { estado.n3.largo = 'suelto'; cajonAnim.largo.objetivo = 0.12; }
  for (const id of [...CAJONES5, 'p']) { const a = anim5(id); a.k = a.objetivo = 0; a.v = 0; }
  Object.assign(borla5, { desatado: 0, aprieto: 0, bajada: 0, objetivoBajada: 0, vBajada: 0, meneo: 0, vMeneo: 0 });
  Object.assign(sueno, { nivel: 0, dormida: false, toque: reloj, ruido: reloj, avisado: false });
  cajonAnim.zocalo.objetivo = 0;                    // el cajón del zócalo (nivel 4) vuelve a su sitio
  if (tec.cara() !== 'frente') tec.girar();
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; ojo.entornado = 0;
  Object.assign(ojo2, { visible: 1, parpadoBase: 0 });
  bucle('noche', -13, 2);
  irA('cara', 1.4);
  await esperar(1.7);
  // bosteza: los párpados le pesan
  animar(1.1, k => { const e = Math.sin(k * Math.PI); ojo.parpadoBase = 0.65 * e; ojo2.parpadoBase = 0.65 * e; });
  sonar('suspiro', -5, 0.7);
  bocanada(BOCA.x, BOCA.y + 8, 0, -1, 0.8);
  await esperar(1.5);
  animar(0.5, k => { ojo.parpadoBase = 0.2 * suave(k); ojo2.parpadoBase = 0.2 * suave(k); });
  // y detrás, un «clac»: un cajón de su espalda sale solo
  sonar('clac', -6, 0.9); sonar('tope_madera', -12, 1.1); sacudir(1.4, 0.2); vibrar(14);
  estado.n5.m1 = 'fuera'; estado.n5.cajones.m1 = 'abierto';
  const a = anim5('m1'); a.objetivo = M1_FUERA; a.v = 2.4;
  await esperar(0.6);
  estado.ocupado = false;
  sueno.toque = reloj;
  mensaje('Bosteza… le pesan los párpados. Y a su espalda, algo ha hecho «clac».', 5);
}

// ---- el sueño ----
function ruido(fuerza = 1) {
  sueno.ruido = reloj;
  if (estado.nivel !== 5) return;
  if (sueno.dormida && fuerza >= 1) despertarse();
  else sueno.nivel = Math.max(0, sueno.nivel - 0.4 * fuerza);
}
function dormirse() {
  sueno.dormida = true;
  bucle('ronquido', -22, 1.5);
  if (!sueno.avisado) { sueno.avisado = true; mensaje('Se ha dormido. Respira despacio, con un ronquido muy bajo.', 4); }
}
function despertarse(fuerte = true) {
  sueno.dormida = false; sueno.nivel = 0;
  pararBucle('ronquido', 0.3);
  sonar('ojo_abre', -6, 1.1);
  ojo.parpadoBase = 0; ojo2.parpadoBase = 0; ojo.parpadeo = null;
  if (fuerte) { contenerAliento(1.4); sacudir(1.5, 0.2); }
  // si su cajón está abierto, lo cierra de golpe
  const n5 = estado.n5;
  if (n5 && n5.secreto === 'c6' && estado.cajones.c6 === 'abierto') {
    setTimeoutReloj(0.35, () => {
      if (cajonAnim.c6.agarrado) return;
      cerrarCajon('c6', true); cajonAnim.c6.v = -5;
      mirarA(centroCajon('c6'), 2.5);
      mensaje('Se despierta… y cierra su cajón de golpe.', 3.5);
    });
  }
}
function actualizarSueno(dt) {
  const en5 = estado.nivel === 5 && !!estado.n5 && estado.fase === 'jugando';
  if (!en5) { if (sueno.dormida) { sueno.dormida = false; pararBucle('ronquido', 0.5); } sueno.nivel = 0; return; }
  if (estado.ocupado || estado.n5.secreto === 'mano') return;
  const quieto = reloj - sueno.toque > 1.4 && reloj - sueno.ruido > 1.4 && !puntero && el.examinar.hidden;
  if (!sueno.dormida) {
    sueno.nivel = quieto ? Math.min(1, sueno.nivel + dt / 5) : Math.max(0, sueno.nivel - dt / 2.5);
    if (sueno.nivel >= 1) dormirse();
  }
  // los párpados: pesados mientras tiene sueño (aún mira), cerrados dormida
  const objetivo = sueno.dormida ? 1 : 0.16 + 0.32 * suave(sueno.nivel);
  ojo.parpadoBase = mezclar(ojo.parpadoBase, objetivo, 1 - Math.exp(-dt * 3));
  ojo2.parpadoBase = mezclar(ojo2.parpadoBase, objetivo, 1 - Math.exp(-dt * 3));
  // dormida, al soltar el aire, un poco de vaho entre los labios
  const seno = Math.sin(aliento.fase);
  if (sueno.dormida && sueno.seno >= 0 && seno < 0) bocanada(BOCA.x, BOCA.y + 6, 0, -1, 0.25);
  sueno.seno = seno;
}

// ---- los cajones de la espalda ----
function cajonDetrasEn(p) {
  if (!nivel5 || !p) return null;
  const en = ([x0, y0, x1, y1]) => p.x >= x0 && p.x <= x1 && p.y >= y0 && p.y <= y1;
  for (const id of CAJONES5) if (en(nivel5.cajones[id])) return id;
  return en(nivel5.panel) ? 'p' : null;
}
const centroDetras = id => { const [x0, y0, x1, y1] = id === 'p' ? nivel5.panel : nivel5.cajones[id]; return { x: (x0 + x1) / 2, y: (y0 + y1) / 2 }; };
// quién bloquea a un cajón: con m1 fuera, t2 no sale (comparten un pasador por dentro)
function bloqueaA(id) { return id === 't2' && anim5('m1').k > 0.06 ? 'm1' : null; }
function trabadoPor(id, culpable) {
  const a = anim5(id), b = anim5(culpable);
  a.v += 0.9;                                          // sale un pelo y se traba
  b.v += b.k > 0.1 ? -1.6 : 1.6;                        // el culpable tiembla
  sonar('trabado', -6, 1.2); vibrar(20); ruido(0.5);
  const veces = insistir('trabado5');
  mensaje(veces === 1 ? 'Sale un pelo y se traba. Algo dentro lo sujeta… y el cajón que salió solo tiembla.'
    : veces === 2 ? 'Cada vez que tiras, tiembla el de la izquierda.' : 'Mientras el de la izquierda esté fuera, este no sale.', 4.5);
}
function tocarDetras5(id) {
  const n5 = estado.n5, a = anim5(id);
  if (estado.vista !== 'espalda') { irA('espalda', 0.85); return; }
  if (id === 'p') { if (n5.p === 'abierto' && a.k > 0.6) tocarDentroP(); else golpearPanel(); return; }
  if (n5.cajones[id] === 'abierto' && a.k > 0.6) { cogerDeDetras(id); return; }
  if (id === 'c' && n5.c === 'trabado') {
    sonar('toc', -8, 1.1); ruido(1);
    mensaje(insistir('argolla') === 1 ? 'Su argolla no se mueve ni un poco. Los otros cajones tienen juego; este, no.' : 'No tiene juego.', 4);
    return;
  }
  const b = bloqueaA(id);
  if (b) { trabadoPor(id, b); return; }
  if (id === 'm1' && n5.m1 === 'fuera') { a.v -= 1.2; sentir('holgura'); mensaje(primeraVez('m1-fuera') ? 'Ha salido solo, un poco. Se puede empujar… o tirar de él.' : 'Está un poco fuera.'); return; }
  a.v += 1.6; sentir('holgura', { tono: 1.15 });
  mensaje(primeraVez('tirar5') ? 'Tira del cajón hacia fuera: arrastra el dedo.' : 'Tira de él.');
}
// tocar la espalda donde no hay cajón: se golpea la madera (y hace ruido)
function golpearEspalda() {
  sonar('toc', -6, azar(0.95, 1.05)); vibrar(8); ruido(1);
  mensaje(primeraVez('toc5') ? 'Toc. Madera maciza.' : 'Toc.', 2);
}
function golpearPanel() {
  const n5 = estado.n5, a = anim5('p');
  n5.golpes++;
  ruido(1);
  sonar('toc_hueco', -4, 1); vibrar(12);
  a.v += 0.5;
  const c = centroDetras('p');
  polvareda(c.x, c.y + 20, 'caja_detras');
  if (n5.p !== 'escondido') { mensaje('Suena hueco.', 2.5); return; }
  if (n5.golpes === 1) mensaje('Toc… suena hueco. Y dentro, algo suelto tintinea.', 4);
  else if (n5.golpes === 2) mensaje('Otra vez: algo pequeño salta dentro, como un pasador atascado.', 4);
  else {
    n5.p = 'suelto';
    setTimeoutReloj(0.35, () => {
      sonar('clinc', -4); sentir('pestillo', { db: -6 });
      a.objetivo = 0.05; a.v = 1.2;
      mensaje('Clinc: algo ha caído dentro. El panel tiene juego… y el hueco de la ficha sirve de tirador.', 5);
    });
  }
}
function abrirDetras(id) {
  const n5 = estado.n5, a = anim5(id);
  n5.cajones[id] = 'abierto';
  if (id === 'p') n5.p = 'abierto';
  a.objetivo = 1;
  sonar('cajon', -6, id === 'p' ? 0.85 : 1.1); vibrar(10);
  const c = centroDetras(id);
  setTimeoutReloj(0.25, () => polvoDeCajon(c.x, c.y + 10, 'caja_detras'));
  if (tec.inclinar) setTimeoutReloj(0.2, () => tec.inclinar(0, id === 'p' ? 0.55 : 0.4));
  setTimeoutReloj(0.35, () => {
    if (id === 't2' && n5.tarjeta === 't2') mensaje('Dentro, una tarjeta de papel con un lazo dibujado.');
    else if (id === 'c' && n5.llave === 'c') mensaje('Dentro: la llave de bambú del león. Alguien la ha guardado aquí.');
    else if (id === 'p') tocarDentroP();
    else mensaje(TEXTOS5[id] || 'Vacío.');
  });
}
function cerrarDetras(id) {
  const n5 = estado.n5, a = anim5(id);
  const estaba = n5.cajones[id] === 'abierto';
  a.objetivo = 0;
  if (id === 'p' && n5.p === 'abierto') n5.p = 'suelto';
  n5.cajones[id] = 'cerrado';
  if (a.k > 0.02) a.v = Math.min(a.v, -1.2);
  // m1, al entrar del todo, suelta el pasador que comparte con t2 (cada vez suena; el aviso, la primera)
  if (id === 'm1' && (estaba || n5.m1 === 'fuera') && n5.tarjeta === 't2') {
    n5.m1 = 'dentro';
    setTimeoutReloj(0.3, () => { sentir('clac', { tono: 1.3, db: -6 }); if (primeraVez('m1-clic')) mensaje('Clic. Al entrar del todo, algo ha cambiado por dentro.', 3); });
  } else if (estaba) sonar('deslizar_madera', -15, 1.3);
}
// el cajón de la argolla fija: no se tira, se empuja; un muelle lo saca
function soltarArgolla() {
  const n5 = estado.n5, a = anim5('c');
  n5.c = 'suelto';
  sentir('pestillo'); sonar('clic_madera', -6, 1.2); vibrar(16); ruido(0.5);
  a.objetivo = 0.45; a.v = 3;
  mensaje('Clic. No se tiraba: se empujaba. Ha salido solo, con un muelle.', 4);
}
function cogerDeDetras(id) {
  const n5 = estado.n5;
  if (id === 't2' && n5.tarjeta === 't2') { cogerTarjeta(); return; }
  if (id === 'c' && n5.llave === 'c') { cogerLlave5(); return; }
  if (id === 'p') { tocarDentroP(); return; }
  mensaje(TEXTOS5[id] || 'Vacío.');
}
function desdeDetras(parte) {
  const v = tec.puntoDetras ? tec.puntoDetras(parte) : null, m = v ? tec.ancla(v) : null;
  return m && m.visible ? { x: m.x, y: m.y, k: 1.4, enPantalla: true } : null;
}
function cogerTarjeta() {
  const n5 = estado.n5;
  const desde = desdeDetras('tarjeta');
  n5.tarjeta = 'mano';
  sonar('papel', -6, 1.1);
  alInventario('tarjeta', 'tarjeta', 'caja_detras', desde || centroDetras('t2'));
  mensaje('Una tarjeta con un lazo dibujado. Una de sus colas, la de la punta negra, lleva una flecha.', 4.5);
}
function cogerLlave5() {
  const n5 = estado.n5;
  const desde = desdeDetras('llave');
  n5.llave = 'mano';
  sonar('recoger', -3, 1.3);
  alInventario('llave', 'llave', 'caja_detras', desde || centroDetras('c'));
  mensaje('La llave de bambú del león, otra vez. Tallada en una caña: es hueca y muy fina.', 4);
}
function tocarDentroP() {
  const n5 = estado.n5;
  n5.cordon = true;
  mensaje('Dentro, un cordón rojo cruza la caja de lado a lado, tirante, y sujeta un pasador que baja hacia el costado de los cajones. Es el cordón de la borla.', 6);
}

// ---- la borla del costado ----
function irBorla() {
  irA('borla', 0.9);
  if (tec.girarA) tec.girarA(Math.PI / 2);
  if (primeraVez('borla5')) setTimeoutReloj(1.1, () => mensaje('La borla del costado. Su cordón sube por la esquina… y entra en la caja.', 4.5));
}
function mecerBorla(fuerza = 0.06) { borla5.vMeneo += fuerza * (Math.random() < 0.5 ? -1 : 1) * 6; }
function tocarBorla5(p) {
  const n5 = estado.n5;
  if (estado.vista !== 'borla') { irBorla(); return; }
  const parte = p && p.borla ? parteDeBorla(nivel5.borla, estadoBorla(), p.bx, p.by) : null;
  mecerBorla(0.05);
  sonar('seda', -16, 1.2);
  if (!parte) { mensaje('El costado de la borla: mosaico de madera.', 2.5); return; }
  if (n5.lazo === 'atado') {
    if (parte === 'nudo') mensaje('Un lazo de seda, muy apretado.');
    else if (parte.startsWith('lazo')) mensaje('Un lazo. Tirar de él lo aprieta.');
    else if (parte === 'cola_der') mensaje('Una cola del lazo, con la punta envuelta en hilo negro.');
    else if (parte === 'cola_izq') mensaje('Una cola del lazo, deshilachada.');
    else mensaje('La borla pesa. El lazo no deja que baje.');
    return;
  }
  mensaje(n5.borla === 'arriba' ? 'El cordón está suelto. Tira de la borla hacia abajo.' : 'El cordón ha corrido. La borla se queda abajo.');
}
function apretarLazo(texto) {
  borla5.aprieto = Math.min(1, borla5.aprieto + 0.34);
  sonar('seda', -6, 0.8); vibrar(10); mecerBorla(0.04);
  mensaje(texto, 3);
}
function desatarLazo() {
  const n5 = estado.n5;
  n5.lazo = 'suelto';
  sonar('seda', -2, 1); vibrar([12, 30, 12]);
  const a0 = borla5.aprieto;
  animar(0.9, k => { borla5.desatado = suave(k); borla5.aprieto = a0 * (1 - k); });
  mecerBorla(0.1);
  // la tarjeta ya ha servido: se queda en el costado, junto a la borla (deja sitio en la bandeja)
  if (estado.inventario.includes('tarjeta')) { estado.inventario = estado.inventario.filter(o => o !== 'tarjeta'); if (estado.seleccion === 'tarjeta') estado.seleccion = null; pintarInventario(); }
  mensaje('La cola de la punta negra deshace el lazo: el cordón se suelta.', 4);
}
async function tirarBorla() {
  const n5 = estado.n5;
  estado.ocupado = true;
  borla5.objetivoBajada = 1;
  sonar('seda', -1, 0.75); vibrar(25);
  await esperar(0.5);
  sonar('clinc', -6, 0.8);                           // dentro, el pasador sube
  n5.borla = 'abajo'; n5.pasador = 'quitado';
  await esperar(0.6);
  // la cómoda se suelta: en el otro costado, los cajones dan un golpe uno tras otro
  irA('caja', 1.0);
  if (tec.girarA) tec.girarA(0);
  await esperar(1.1);
  ruido(1);
  Object.keys(CAJONES).forEach((id, i) => setTimeoutReloj(i * 0.09, () => {
    sonar('clac', -10, azar(0.9, 1.2));
    const a = cajonAnim[id]; if (!a.agarrado) a.v += 1.6;
  }));
  await esperar(1.0);
  sentir('desbloqueo', { db: -4 });
  cajonAnim.c2.objetivo = 0.24; cajonAnim.c2.v = 2;  // el de la cerradura de adorno asoma
  agitarTe(0.4);
  await esperar(0.4);
  estado.ocupado = false;
  mensaje('El cordón corre por dentro… y en el otro costado: clac, clac, clac. La cómoda entera se ha soltado. Arriba, un cajón asoma.', 5.5);
}
function actualizarBorla(dt) {
  // la bajada sigue al dedo con un muelle (pesa) y el meneo se apaga solo
  const k = 60, am = 2 * Math.sqrt(k) * 0.7;
  for (let r = dt; r > 0; r -= 1 / 120) {
    const h = Math.min(r, 1 / 120);
    borla5.vBajada += ((borla5.objetivoBajada - borla5.bajada) * k - borla5.vBajada * am) * h;
    borla5.bajada = limitar(borla5.bajada + borla5.vBajada * h, 0, 1.02);
    borla5.vMeneo += (-borla5.meneo * 40 - borla5.vMeneo * 2.2) * h;
    borla5.meneo += borla5.vMeneo * h;
  }
}
// cuánto mide en la pantalla un píxel del boceto de la sala (para leer los arrastres del nivel 6)
function escalaSala() {
  const a = tec.ancla({ x: 600, y: 300 }, 'sala'), b = tec.ancla({ x: 700, y: 300 }, 'sala');
  return a && b ? Math.max(0.05, Math.hypot(b.x - a.x, b.y - a.y) / 100) : 0.6;
}
// cuánto mide en la pantalla un píxel del costado (para leer el arrastre en la borla)
function escalaBorla() {
  if (!tec.pantallaBorla) return 1;
  const a = tec.pantallaBorla(600, 600), b = tec.pantallaBorla(600, 700);
  return a && b ? Math.max(0.05, Math.hypot(b.x - a.x, b.y - a.y) / 100) : 1;
}

// ---- los cajones del costado en el nivel 5: c2 (las tsukegi) y c6 (su secreto, con la llave como varilla) ----
function usarLlave5(id, desde) {
  const n5 = estado.n5;
  if (id === 'c6' && n5.llave === 'mano') { meterLlave5(desde); return; }
  sonar('trabado', -8, 1.2);
  mensaje(id === 'c2' ? (n5.pasador === 'puesto' ? 'No entra: esa cerradura es de adorno, no tiene agujero.' : 'Ya está suelto.') : 'Este cajón no tiene cerradura.');
}
async function meterLlave5(desde) {
  const n5 = estado.n5;
  estado.ocupado = true;
  if (estado.vista !== 'cajones') irA('cajones', 0.7);
  await desdeInventario('llave', 'llave', centroCajon('c6'), 'caja', desde);
  n5.llave = 'metida';
  sonar('llave', -4, 1.25); vibrar(10);
  estado.ocupado = false;
  mensaje('Entra en el agujero… pero no gira. Al fondo, algo cede si empujas.', 4.5);
}
function empujarLlave5() {
  const n5 = estado.n5;
  n5.llave = 'usada'; n5.c6 = 'suelto';
  sentir('pestillo'); sonar('clic_madera', -6, 1.3); vibrar(15); ruido(0.5);
  mirarA(centroCajon('c6'), 2.5);
  mensaje(n5.pasador === 'puesto' ? 'Empujas la llave como una varilla: ¡clic! Algo ha cedido al fondo… pero el cajón sigue sujeto por dentro.'
    : 'Empujas la llave como una varilla: ¡clic! Ya no lo sujeta nada… salvo su mirada.', 5);
}
// c6, suelto: es lo que más guarda; mientras mira no deja
function guardarSecreto() {
  const c = centroCajon('c6'), veces = insistir('c6');
  resistir(c.x, c.y, 1, -0.6, c, veces);
  sueno.nivel = 0;
  mensaje(veces === 1 ? 'Abre el ojo y mira tu mano: es lo que más guarda. Mientras mire, no deja.'
    : veces === 2 ? 'No aparta el ojo de ese cajón.' : 'Tiene sueño… Si esperas sin tocar nada, quizá se duerma.', 4.5);
}
// un tirón fuerte de c6 con ella dormida: hace ruido, se despierta y lo cierra de golpe
function tironFuerte(g) {
  const a = cajonAnim.c6;
  g.estado = 'suelto';
  a.agarrado = false;
  despertarse();
  a.objetivo = 0; a.v = -5;
  estado.cajones.c6 = 'cerrado';
  sonar('tope_madera', -3, 1); sacudir(2, 0.25); vibrar(40);
  mensaje(insistir('tiron') === 1 ? 'Demasiado deprisa: el cajón hace ruido, se despierta… y lo cierra de golpe.' : 'Más despacio. Que no se despierte.', 4.5);
}
function cogerTsukegi() {
  const n5 = estado.n5;
  n5.tsukegi = 'mano';
  sonar('recoger', -4, 1.2);
  const q = puntoDentro('c2');
  alInventario('tsukegi', 'tsukegi', 'caja', { x: q[0], y: q[1] });
  mensaje('Un manojo de tsukegi: tiras finas de ciprés con la punta de azufre. Sirven para encender el fuego.', 5);
}
async function cogerSecreto() {
  const n5 = estado.n5;
  n5.secreto = 'mano';
  estado.ocupado = true;
  const q = puntoDentro('c6');
  sonar('papel', -4, 0.95);
  await alInventario('secreto', 'secreto', 'caja', { x: q[0], y: q[1] });
  examinar('secreto');
  await esperar(2.6);
  // se despierta despacio, ve su secreto en tu mano… y baja los ojos
  if (sueno.dormida) { sueno.dormida = false; pararBucle('ronquido', 1); }
  animar(1.2, k => { ojo.parpadoBase = 1 - 0.55 * suave(k); ojo2.parpadoBase = 1 - 0.55 * suave(k); });
  sonar('suspiro', -8, 0.75);
  agitarLampara(1.4, 0.9);                           // la llama tiembla: se acerca la noche
  await esperar(3.6);
  cerrarExaminar();
  estado.ocupado = false;
  terminarNivel(5);
}
// lo que se ve encima en el nivel 5: la llave metida en el agujero de c6
function dibujarNivel5Encima(conAncla) {
  const n5 = estado.n5;
  if (!n5 || estado.nivel !== 5 || n5.llave !== 'metida' || !img.llave) return;
  const c = centroCajon('c6'), im = img.llave, s = 0.42;
  conAncla(c.x, c.y, 'caja', () => {
    ctx.save(); ctx.translate(c.x + 2, c.y - 2); ctx.rotate(-0.5); ctx.scale(s, s);
    ctx.drawImage(im, -im.width * 0.15, -im.height / 2);
    ctx.restore();
  });
}
function actualizarNivel5(dt) {
  actualizarSueno(dt);
  if (estado.nivel >= 5) actualizarBorla(dt);
}
function pistaNivel5() {
  const n5 = estado.n5;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4.5);
  };
  if (!n5) return mensaje('Mira.');
  const algunoAbierto = Object.entries(n5.cajones).some(([id, e]) => e === 'abierto' && id !== 'm1');
  if (!algunoAbierto && n5.tarjeta === 't2') return escalon('espalda', ['Algo ha hecho «clac» a su espalda.', 'Gira la caja para ver su espalda.', 'Un cajón de la espalda ha salido solo. Tira de los otros.']);
  if (n5.tarjeta === 't2') return escalon('t2', ['El de arriba, en el centro, no sale. ¿Qué tiembla cuando tiras de él?', 'Mientras el de la izquierda esté fuera, no sale.',
    'Empuja hacia dentro el cajón que salió solo, y luego tira del de arriba.']);
  if (n5.llave === 'c') return escalon('c', ['El cajón de debajo del hueco tiene la argolla fija.', 'Si no se tira, quizá se empuje.', 'Arrástralo hacia dentro con el dedo.']);
  if (n5.p === 'escondido') return escalon('golpes', ['El panel del hueco de la ficha suena distinto que lo demás.', 'Golpéalo: tócalo varias veces.', 'Tócalo tres veces seguidas.']);
  if (n5.p === 'suelto' && !n5.cordon) return escalon('p', ['El hueco de la ficha sirve de tirador.', 'Arrastra el panel hacia fuera desde el hueco.']);
  if (n5.lazo === 'atado') return escalon('lazo', ['El cordón del cajón escondido es el de la borla.', 'Gira la caja: la borla cuelga del otro costado.',
    'La tarjeta: tira de la cola de la punta negra.']);
  if (n5.borla === 'arriba') return escalon('borla', ['El lazo está suelto.', 'Tira de la borla hacia abajo, hasta el fondo.']);
  if (n5.tsukegi === 'c2' && cajonAnim.c2.k < 0.5) return escalon('c2', ['Un cajón de arriba ha asomado en el costado.', 'Tira de él.']);
  if (n5.llave === 'mano') return escalon('llave5', ['La otra cerradura del costado no es una cerradura: es un agujero.', 'Elige la llave de bambú y tócala en ese cajón.']);
  if (n5.llave === 'metida') return escalon('empujar', ['La llave no gira.', 'Tócala otra vez para empujarla, como una varilla.']);
  if (n5.secreto === 'c6') return escalon('c6', ['Es lo que más guarda: mientras mira, no deja.', 'Tiene sueño. Si no tocas nada un rato, se dormirá.',
    'Cuando duerma, tira de ese cajón muy despacio.']);
  return mensaje('Mira lo que guardaba.');
}

// ---------------------------------------------------------------------------------------------
// Nivel 6 · La noche (solo en la B; NIVELES.md §9). Una ráfaga apaga la lámpara: a oscuras, el ojo viejo no ve… y tú
// tampoco. Solo alumbra la luz fría del ojo nuevo, que se mueve arrastrando el dedo (al revés, como en el nivel 3) y se
// queda donde la dejas; solo se encuentra lo que está alumbrado. La luna da una penumbra por el shoji y las brasas se
// ven siempre. Para encender la lámpara: una tsukegi (del cajón de arriba del costado: lo marca una llamita de tinta
// fría), las brasas avivadas por el viento del shoji entreabierto, y llevar la llama con el shoji cerrado (si no, una
// ráfaga la apaga) hasta la mecha, con la puertecilla de papel de la lámpara abierta.
// ---------------------------------------------------------------------------------------------
let nivel6 = null;                                   // capas/nivel6.json: la lámpara, su puertecilla, el shoji y las brasas
const noche = { oscuridad: 0, brasa: 0.25, shoji: 0, puerta: 0, tinta: 0, proximaRafaga: 0, proximoVagar: 0, proximoTemblor: 0, humo: null };
const DURA_LLAMA = 25;                               // lo que arde una tsukegi (s)
const RADIO_LUZ6 = 105;                              // lo que alumbra la luz fría (px del boceto)
const BRASA_BASE = 0.22;                             // las brasas, casi apagadas, sin aire
function n6Inicial() {
  return { lampara: 'apagada', puerta: 'cerrada', shoji: 0, llama: 0, tinta: false, mecha: false, brasas: false, apagadas: 0 };
}
const enLaNoche = () => estado.nivel === 6 && !!estado.n6 && estado.n6.lampara !== 'encendida';
const llamaEnMano = () => enLaNoche() && estado.n6.llama > reloj && estado.inventario.includes('tsukegi');
const zonaShoji6 = () => { const [x0, y0, x1, y1] = nivel6.shoji.hueco; return ['rect', x0 - 46, y0, x1, y1]; };
const zonaLampara6 = () => ['rect', ...nivel6.lampara.zona];
// ¿se ve ese punto (del boceto)? Las brasas y el shoji, siempre; lo demás, si lo alumbra la luz fría
function iluminado(p) {
  if (!enLaNoche() || !p) return true;
  if (dentro(INCENSARIO, p) || dentro(zonaShoji6(), p)) return true;
  // (un parpadeo del ojo nuevo apaga la luz un instante, pero lo alumbrado no se pierde por eso)
  return luzFria.fuerza > 0.4 && Math.hypot(p.x - luzFria.x, p.y - luzFria.y) < RADIO_LUZ6;
}
// la luz fría en el nivel 6: solo la mueve un arrastre (un toque no), al revés del dedo, como en un espejo (se aleja
// por donde el dedo viene), y se queda donde se deja. Así se apunta también de cerca, en cualquier vista
function moverLuz6(dx, dy) {
  if (!luzActiva()) return;
  const base = luzFria.punto || { x: luzFria.x, y: luzFria.y };
  const m = tec.ancla(base, 'sala'), k = m && m.k > 0.05 ? m.k : 0.6;
  luzFria.punto = { x: limitar(base.x - dx / k, 10, ANCHO - 10), y: limitar(base.y - dy / k, 10, ALTO - 10) };
  luzFria.guiadaHasta = Infinity;
  if (primeraVez('luz6')) setTimeoutReloj(1.4, () => mensaje('La luz va al revés de tu dedo y se queda donde la dejas. Lo que no alumbra, no se encuentra.', 4.5));
}
function prepararNivel6() {
  if (!nivel6) return;
  const [x0, y0, x1, y1] = nivel6.lampara.recorte;
  datos.capas.lampara_apagada = { x: x0, y: y0, w: x1 - x0, h: y1 - y0 };
  img.tsukegi_encendida = dibujarTsukegi(200, 150, { encendida: 1, t: 0.3 });
  OBJETOS.tsukegi.iconoApagada = OBJETOS.tsukegi.icono;
  OBJETOS.tsukegi.iconoEncendida = icono(img.tsukegi_encendida);
}
function ponerLlamaEnBandeja(arde) {
  const o = OBJETOS.tsukegi;
  if (o.iconoEncendida) o.icono = arde ? o.iconoEncendida : o.iconoApagada;
  pintarInventario();
  const h = huecoDe('tsukegi');
  for (const x of huecosBandeja()) x.classList.remove('arde');
  if (h && arde) h.classList.add('arde');
}
// el estado al final del nivel 6, para empezar el final sin jugarlo (o al seguir una partida)
function estadoTrasNivel6() {
  estado.n6 = Object.assign(n6Inicial(), { lampara: 'encendida', puerta: 'cerrada', tinta: true, mecha: true, brasas: true });
  estado.inventario = estado.inventario.filter(o => !['tsukegi', 'secreto', 'tarjeta'].includes(o));
  if (estado.n5) estado.n5.tsukegi = 'lampara';
  Object.assign(noche, { oscuridad: 0, brasa: BRASA_BASE, shoji: 0, puerta: 0, tinta: 0 });
  lampara.apagada = 0;
  ponerLlamaEnBandeja(false);
}
async function empezarNivel6() {
  ocultarTarjeta();
  estado.nivel = 6;
  const n6 = estado.n6 = n6Inicial();
  estado.pistasPaso = {}; estado.intentosMirada = 0; estado.insistencia = {};
  estado.inventario = estado.inventario.filter(o => o !== 'secreto' && o !== 'tarjeta');
  if (estado.n5 && estado.n5.tsukegi !== 'mano') estado.n5.tsukegi = 'c2';
  estado.fase = 'jugando'; estado.ocupado = true;
  el.girar.hidden = true; el.inventario.hidden = false;             // a oscuras, la caja no se gira
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  for (const id of [...CAJONES5, 'p']) { const a = anim5(id); a.objetivo = 0; }
  if (estado.n3 && estado.n3.largo === 'abierto') { estado.n3.largo = 'suelto'; cajonAnim.largo.objetivo = 0.12; }
  if (tec.cara() !== 'frente') tec.girar();
  if (tec.enderezar) tec.enderezar();
  Object.assign(noche, { oscuridad: 0, brasa: BRASA_BASE, shoji: 0, puerta: 0, tinta: 0, proximaRafaga: 0, proximoVagar: reloj + 3, proximoTemblor: reloj + 6 });
  luzFria.guiadaHasta = 0; luzFria.punto = null;
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; ojo.entornado = 0;
  Object.assign(ojo2, { visible: 1, parpadoBase: 0 });
  ponerLlamaEnBandeja(false);
  bucle('noche', -11, 2);
  irA('sala', 1.4);
  await esperar(1.8);
  // una ráfaga entra por el shoji y la llama de la lámpara se encoge… y se apaga
  soplar(1.3); sonar('soplo', -2, 0.9); sonar('racha', -8, 0.8);
  agitarLampara(0.9, 1);
  await esperar(0.7);
  sonar('soplo', -6, 1.2);
  const ap0 = lampara.apagada;
  animar(0.5, k => { lampara.apagada = mezclar(ap0, 1, suave(k)); });
  animar(1.4, k => { noche.oscuridad = suave(k); });
  pararBucle('fuego', 1);
  contenerAliento(3); sacudir(1.2, 0.3);
  await esperar(1.2);
  // la mecha humea
  noche.humo = new Cinta(nivel6.lampara.humo[0], nivel6.lampara.humo[1], { ritmo: 7, vida: 3.4, vel: 10, ancho: 2.4, alfa: 0.2,
    tinta: 0.06, rizo: 0.9, objeto: 'sala' });
  humos.sueltos.push(noche.humo);
  // solo queda la luz fría, hacia el suelo, delante de la caja
  luzFria.punto = { x: 760, y: 640 }; luzFria.guiadaHasta = Infinity;
  sonar('cristal', -16, 0.7);
  await esperar(1.2);
  estado.ocupado = false;
  mensaje('Una ráfaga ha apagado la lámpara. A oscuras, la caja no ve… y tú tampoco. Solo alumbra su ojo nuevo: arrastra el dedo para mover su luz.', 7);
}
// cada poco, a oscuras, tiembla (le teme a la noche) y su ojo viejo busca sin ver
function actualizarNivel6(dt) {
  const n6 = estado.n6, de6 = estado.nivel === 6 && !!n6;
  const oscura = de6 && n6.lampara !== 'encendida' && estado.fase === 'jugando';
  if (!de6) { noche.oscuridad = Math.max(0, noche.oscuridad - dt); return; }
  // a oscuras la caja no se gira; si algo la dejara de espaldas, la luz fría se apagaría y no habría salida
  if (oscura && tec.cara && tec.cara() !== 'frente' && tec.enderezar) tec.enderezar();
  // las brasas: casi apagadas; cada ráfaga las aviva un momento
  noche.brasa = mezclar(noche.brasa, BRASA_BASE, 1 - Math.exp(-dt * 0.55));
  // la tinta de la llamita (en el cajón de arriba del costado): solo bajo la luz fría
  const f = luzFria.fuerza * (1 - ojo2.cerrado), c = frenteCajonEnBoceto('c2');
  const vis = oscura && c ? limitar(1 - (Math.hypot(luzFria.x - c.x, luzFria.y - c.y) - 40) / 70, 0, 1) * f : 0;
  noche.tinta = mezclar(noche.tinta, vis, 1 - Math.exp(-dt * 6));
  if (oscura && noche.tinta > 0.6 && !n6.tinta) {
    n6.tinta = true; sonar('cristal', -14, 0.9); sonar('espiritu', -20, 1.4);
    mensaje(estado.n5 && estado.n5.tsukegi === 'mano' ? 'En el cajón de arriba del costado brilla una tinta fría: una llamita. Es el de las tsukegi… y ya las llevas.'
      : 'En el cajón de arriba del costado brilla una tinta fría: una llamita.', 4.5);
  }
  if (!oscura) return;
  // el viento: con el shoji entreabierto entra a ráfagas
  if (noche.shoji > 0.3) {
    if (!noche.proximaRafaga) noche.proximaRafaga = reloj + azar(1.2, 2);
    if (reloj >= noche.proximaRafaga) { noche.proximaRafaga = reloj + azar(2.4, 3.8) / (0.6 + 0.4 * noche.shoji); rafaga6(); }
  } else noche.proximaRafaga = 0;
  // la tsukegi encendida se consume
  // mientras se mira algo de cerca (examinar o la nota), la tsukegi no se gasta
  if (n6.llama && (!el.examinar.hidden || !el.nota.hidden)) n6.llama += dt;
  if (n6.llama && reloj >= n6.llama) apagarLlama('La tsukegi se ha consumido. El manojo trae más.');
  // el ojo viejo no ve: busca, perdido
  if (reloj >= noche.proximoVagar) {
    noche.proximoVagar = reloj + azar(1.6, 3.4);
    ojo.punto = { x: azar(300, 1300), y: azar(120, 620) }; ojo.ultimoToque = reloj;
  }
  // y tiembla de vez en cuando
  if (reloj >= noche.proximoTemblor) {
    noche.proximoTemblor = reloj + azar(7, 12);
    sacudir(0.5, 0.35); if (Math.random() < 0.5) sonar('suspiro', -24, 1.3);
  }
}
function rafaga6() {
  const n6 = estado.n6;
  soplar(0.45 + 0.5 * noche.shoji); sonar('soplo', -12 + 4 * noche.shoji, azar(0.9, 1.1));
  noche.brasa = 1;
  setTimeoutReloj(0.15, () => sonar('fuego', -20, 1.3));
  if (llamaEnMano()) setTimeoutReloj(0.25, () => apagarLlama('Una ráfaga entra por el shoji… y apaga la llama.'));
  else if (!n6.brasas && reloj > 2) { n6.brasas = true; mensaje('Con el aire, las brasas del incensario se avivan un momento.', 3.5); }
}
// dónde está ahora el frente de un cajón del costado (en el boceto), abierto lo que esté
function frenteCajonEnBoceto(id) {
  if (!cajonesDatos) return null;
  const g = geometriaCajon(id), s = cajonAnim[id].k * cajonesDatos.sale;
  const [x, y] = aBoceto([cajonesDatos.x + s, (g.y[0] + g.y[1]) / 2, (g.z[0] + g.z[1]) / 2]);
  return { x, y };
}
// tocar a oscuras: lo no alumbrado no se encuentra; la caja, sin ver, se asusta
function tocarANoche(p) {
  if (p && (dentro(['poli', CAJA], p) || p.cajon) && !p.hija) {
    contenerAliento(1.6); sacudir(1.4, 0.25); sonar('trabado', -12, 1.4); vibrar(20);
    const veces = insistir('noche-caja');
    mensaje(veces === 1 ? 'Da un respingo: no ve nada, y algo la ha tocado.' : veces === 2 ? 'Tiembla. A oscuras, todo la asusta.'
      : 'Alumbra antes con su luz lo que quieras tocar.', 3.5);
    return;
  }
  sonar('toque', -22, 0.7);
  const veces = insistir('noche');
  mensaje(veces === 1 ? 'A oscuras no encuentras nada.' : veces === 2 ? 'Mueve su luz: arrastra el dedo, al otro lado de lo que quieras ver.'
    : 'Solo lo alumbrado se encuentra.', 3);
}
function tocarLampara6(p) {
  const n6 = estado.n6;
  if (dentro(['rect', ...nivel6.lampara.puerta], p) && n6.puerta !== 'abierta') {
    noche.puerta = Math.max(noche.puerta, 0.12); setTimeoutReloj(0.25, () => { if (n6.puerta !== 'abierta') noche.puerta = 0; });
    sentir('holgura', { tono: 1.3, db: -4 }); sonar('papel', -16, 1.4);
    mensaje(primeraVez('puerta6') ? 'Una puertecilla de papel, abajo. Se desliza hacia un lado.' : 'Deslízala con el dedo.', 3.5);
    return;
  }
  if (!n6.mecha) { n6.mecha = true; mensaje('La lámpara: la mecha aún humea, pero no queda fuego. ¿Dónde queda algo encendido?', 4.5); return; }
  mensaje(n6.puerta === 'abierta' ? 'Dentro, la mecha humea. Le falta una llama.' : 'La mecha humea dentro. Abajo, en el papel, hay una puertecilla.', 3.5);
}
function tocarBrasas6() {
  const n6 = estado.n6;
  sonar('fuego', -18, 1.2);
  if (noche.brasa > 0.55) { mensaje('Las brasas brillan con el aire.', 2.5); return; }
  mensaje(n6.brasas ? 'Las brasas, otra vez casi apagadas. Necesitan aire.' : 'Unas brasas casi apagadas, sin fuerza para prender nada. Les falta aire.', 3.5);
}
function tocarShoji6() {
  mensaje(noche.shoji > 0.3 ? 'Fuera, la noche y el bambú. El viento entra a ráfagas.' : 'El shoji. Fuera, la luna. Se desliza.', 3);
  if (primeraVez('shoji6')) soplar(0.25, false);
}
// la tsukegi en las brasas: prende si están avivadas (azufre, una chispa azul y la llama)
function prenderTsukegi() {
  const n6 = estado.n6;
  if (llamaEnMano()) { mensaje('Ya arde.'); return; }
  if (noche.brasa < 0.55) {
    sonar('trabado', -12, 1.3); sonar('fuego', -20, 0.9);
    mensaje(insistir('prender') === 1 ? 'La punta de azufre toca las brasas… y no prende. Están casi apagadas.' : 'No prende. Las brasas necesitan aire.', 3.5);
    return;
  }
  n6.llama = reloj + DURA_LLAMA;
  sonar('azufre', -3); vibrar([10, 30, 16]);
  destello(nivel6.brasas[0], nivel6.brasas[1] - 6, 46, '140,180,255', 0.9, 0.35, 'incensario');
  setTimeoutReloj(0.3, () => destello(nivel6.brasas[0], nivel6.brasas[1] - 10, 70, '255,190,90', 0.7, 0.8, 'incensario'));
  ponerLlamaEnBandeja(true);
  const abierto = noche.shoji > 0.3;
  mensaje(abierto ? 'Azufre: una chispa azul… y una llama. Pero con el shoji abierto, el viento la apagará.'
    : 'Azufre: una chispa azul… y una llama. Arde poco: llévala deprisa.', 4.5);
}
function apagarLlama(texto) {
  const n6 = estado.n6;
  if (!n6 || !n6.llama) return;
  n6.llama = 0; n6.apagadas++;
  sonar('soplo', -8, 1.6);
  ponerLlamaEnBandeja(false);
  mensaje(texto, 4);
}
// la llama a la mecha: la lámpara se enciende y vuelve la luz cálida
async function encenderLampara() {
  const n6 = estado.n6;
  if (n6.puerta !== 'abierta') { sonar('papel', -12, 1.2); mensaje('La puertecilla de papel está cerrada: así no llegas a la mecha.', 3.5); return; }
  estado.ocupado = true;
  estado.seleccion = null;
  n6.lampara = 'encendida'; n6.llama = 0;
  estado.inventario = estado.inventario.filter(o => o !== 'tsukegi');
  if (estado.n5) estado.n5.tsukegi = 'lampara';
  ponerLlamaEnBandeja(false);
  sonar('mecha', -2); vibrar([12, 40, 20]);
  if (noche.humo) { noche.humo.duracion = noche.humo.edad; noche.humo = null; }
  const ap0 = lampara.apagada, os0 = noche.oscuridad;
  animar(1.6, k => { lampara.apagada = ap0 * (1 - suave(k)); });
  animar(2.6, k => { noche.oscuridad = os0 * (1 - suave(k)); });
  bucle('fuego', -21, 2);
  setTimeoutReloj(0.9, () => { const p0 = noche.puerta; animar(0.6, k => { noche.puerta = p0 * (1 - suave(k)); }); n6.puerta = 'cerrada'; sonar('papel', -16, 1.3); });
  await esperar(1.4);
  // el ojo viejo vuelve a ver: busca la llama… y se calma
  mirarA({ x: LAMPARA.x, y: LAMPARA.y }, 4);
  luzFria.guiadaHasta = 0;
  for (const m of polillas) { m.susto = 0; m.posada = 0; }
  await esperar(1.6);
  sonar('suspiro', -4, 0.85);
  await esperar(1.2);
  sonar('tarareo', -6);
  mensaje('La luz cálida vuelve a la sala. Su ojo busca la llama… y se calma.', 4.5);
  await esperar(4);
  estado.ocupado = false;
  terminarNivel(6);
}
// lo que se dibuja debajo de la oscuridad: la lámpara apagada, el hueco del shoji (la noche de fuera) y la puertecilla
function dibujarNivel6Debajo(conAncla) {
  if (estado.nivel !== 6 || !nivel6) return;
  const L = nivel6.lampara, apagada = lampara.apagada;
  if (apagada > 0.01 && img.lampara_apagada) {
    const d = datos.capas.lampara_apagada;
    conAncla(L.centro[0], L.centro[1], 'sala', () => { ctx.globalAlpha = apagada; ctx.drawImage(img.lampara_apagada, d.x, d.y, d.w, d.h); ctx.globalAlpha = 1; });
  }
  if (noche.shoji > 0.004) conAncla(nivel6.shoji.poste, 220, 'sala', dibujarShoji6);
  if (apagada > 0.01) conAncla(L.mecha[0], L.mecha[1], 'sala', () => { ctx.globalAlpha = apagada; dibujarPuerta6(); ctx.globalAlpha = 1; });
}
function dibujarShoji6() {
  const S = nivel6.shoji, [, y0, , y1] = S.hueco, x0 = S.poste, g = S.abre * noche.shoji, c = ctx;
  // fuera: la noche azul, la luna arriba y unas cañas de bambú que el viento mece
  const cielo = c.createLinearGradient(0, y0, 0, y1);
  cielo.addColorStop(0, 'rgb(96, 122, 176)'); cielo.addColorStop(0.45, 'rgb(52, 70, 112)'); cielo.addColorStop(1, 'rgb(20, 26, 44)');
  c.save();
  c.beginPath(); c.rect(x0, y0, g, y1 - y0); c.clip();
  c.fillStyle = cielo; c.fillRect(x0, y0, g, y1 - y0);
  brillo(c, x0 + 40, y0 + 70, 110, '215,228,255', 0.6);
  c.beginPath(); c.arc(x0 + 46, y0 + 64, 13, 0, Math.PI * 2); c.fillStyle = 'rgba(236, 240, 255, 0.92)'; c.fill();
  const mece = viento.rafaga * 9 + Math.sin(reloj * 0.9) * 2;
  for (const [bx, ancho] of [[x0 + 14, 7], [x0 + 46, 9], [x0 + 70, 6]]) {
    c.strokeStyle = 'rgba(8, 16, 14, 0.95)'; c.lineWidth = ancho;
    c.beginPath(); c.moveTo(bx, y1); c.quadraticCurveTo(bx + mece * 0.3, (y0 + y1) / 2, bx + mece, y0); c.stroke();
    for (let y = y1 - 60; y > y0; y -= 70) {
      const dx = mece * (1 - (y - y0) / (y1 - y0));
      c.strokeStyle = 'rgba(30, 44, 40, 0.9)'; c.lineWidth = 1.6;
      c.beginPath(); c.moveTo(bx + dx - ancho / 2 - 1, y); c.lineTo(bx + dx + ancho / 2 + 1, y); c.stroke();
      c.fillStyle = 'rgba(10, 20, 18, 0.9)';
      c.beginPath(); c.ellipse(bx + dx + 14, y - 8, 15, 3.2, -0.5 + viento.rafaga * 0.4, 0, Math.PI * 2); c.fill();
    }
  }
  c.restore();
  // el canto de la hoja que se ha corrido
  c.fillStyle = 'rgba(44, 30, 20, 0.95)'; c.fillRect(x0 + g - 3, y0, 6, y1 - y0);
  c.fillStyle = 'rgba(0, 0, 0, 0.35)'; c.fillRect(x0 + g + 3, y0, 6, y1 - y0);
}
function dibujarPuerta6() {
  const [x0, y0, x1, y1] = nivel6.lampara.puerta, c = ctx, k = noche.puerta, w = x1 - x0, s = k * (w - 8);
  const [mx, my] = nivel6.lampara.mecha;
  // dentro (lo que deja ver la puertecilla corrida): oscuro, con el platillo de aceite y la mecha
  if (s > 0.5) {
    c.save();
    c.beginPath(); c.rect(x1 - s, y0, s, y1 - y0); c.clip();
    c.fillStyle = 'rgba(22, 13, 8, 0.97)'; c.fillRect(x1 - s, y0, s, y1 - y0);
    c.fillStyle = 'rgba(88, 60, 38, 0.95)'; c.beginPath(); c.ellipse(mx, my + 4, 9, 3, 0, 0, Math.PI * 2); c.fill();
    c.strokeStyle = 'rgba(20, 12, 8, 1)'; c.lineWidth = 1.6; c.beginPath(); c.moveTo(mx, my + 3); c.lineTo(mx + 1, my - 1.5); c.stroke();
    if (enLaNoche()) brillo(c, mx + 1, my - 2, 4, '255,90,40', 0.8 * (0.7 + 0.3 * Math.sin(reloj * 3.3)));     // un rescoldo
    c.restore();
  }
  // la puertecilla: papel con su marquito, corrida hacia la izquierda (detrás del poste)
  c.save();
  c.beginPath(); c.rect(nivel6.lampara.recorte[0] + 13, y0 - 2, x1 - nivel6.lampara.recorte[0] - 13 + 1, y1 - y0 + 4); c.clip();
  c.fillStyle = 'rgba(150, 141, 124, 0.96)'; c.fillRect(x0 - s, y0, w, y1 - y0);
  c.strokeStyle = 'rgba(60, 40, 24, 0.95)'; c.lineWidth = 1.6; c.strokeRect(x0 - s + 0.8, y0 + 0.8, w - 1.6, y1 - y0 - 1.6);
  c.beginPath(); c.arc(x0 - s + w - 6, (y0 + y1) / 2, 1.6, 0, Math.PI * 2); c.fillStyle = 'rgba(60, 40, 24, 0.9)'; c.fill();
  c.restore();
}
// la oscuridad: una capa casi negra, con huecos donde hay luz (la luz fría y su ojo, las brasas, la luna y la mecha)
let lienzoNoche = null;
function lucesNoche() {
  const l = [], f = luzFria.fuerza * (1 - ojo2.cerrado);
  if (f > 0.01) {
    l.push({ x: luzFria.x, y: luzFria.y, objeto: objetoBajo(luzFria), r: RADIO_LUZ6 + 20, a: 0.95 * f });
    l.push({ x: CUENCA.x, y: CUENCA.y, objeto: 'caja', r: 34, a: 0.75 * f });
  }
  const b = noche.brasa, [bx, by] = nivel6.brasas;
  l.push({ x: bx, y: by, objeto: 'incensario', r: 42 + 70 * b, a: 0.4 + 0.5 * b });
  l.push({ x: 1300, y: 170, objeto: 'sala', r: 260, a: 0.48 });                 // la luna, por el papel del shoji
  if (noche.shoji > 0.02) l.push({ x: nivel6.shoji.poste + 30, y: 250, objeto: 'sala', r: 150 + 80 * noche.shoji, a: 0.55 * noche.shoji });
  const [mx, my] = nivel6.lampara.mecha;
  l.push({ x: mx, y: my - 30, objeto: 'sala', r: 30, a: 0.18 });
  return l;
}
function dibujarNoche() {
  const o = noche.oscuridad;
  if (o <= 0.002 || !nivel6) return;
  if (!lienzoNoche) lienzoNoche = document.createElement('canvas');
  const W = Math.max(1, Math.round(ancho * ppp)), H = Math.max(1, Math.round(alto * ppp));
  if (lienzoNoche.width !== W || lienzoNoche.height !== H) { lienzoNoche.width = W; lienzoNoche.height = H; }
  const k = lienzoNoche.getContext('2d');
  k.setTransform(1, 0, 0, 1, 0, 0);
  k.globalCompositeOperation = 'source-over';
  k.clearRect(0, 0, W, H);
  k.fillStyle = `rgba(3, 5, 12, ${0.92 * o})`; k.fillRect(0, 0, W, H);
  k.globalCompositeOperation = 'destination-out';
  for (const L of lucesNoche()) {
    const m = tec.ancla({ x: L.x, y: L.y }, L.objeto);
    if (!m || !m.visible) continue;
    const r = L.r * m.k * ppp, x = m.x * ppp, y = m.y * ppp;
    const g = k.createRadialGradient(x, y, 0, x, y, r);
    g.addColorStop(0, `rgba(0,0,0,${L.a})`); g.addColorStop(0.5, `rgba(0,0,0,${L.a * 0.72})`); g.addColorStop(1, 'rgba(0,0,0,0)');
    k.fillStyle = g; k.fillRect(x - r, y - r, 2 * r, 2 * r);
  }
  k.globalCompositeOperation = 'source-over';
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.drawImage(lienzoNoche, 0, 0);
  ctx.setTransform(ppp, 0, 0, ppp, 0, 0);
}
// encima de la oscuridad: la llamita de tinta fría del cajón de arriba del costado (solo bajo la luz fría)
function dibujarNivel6Encima(conAncla) {
  if (estado.nivel !== 6 || noche.tinta < 0.01) return;
  const c = frenteCajonEnBoceto('c2');
  if (!c) return;
  conAncla(c.x, c.y, 'caja', () => {
    const a = noche.tinta, x = c.x + 2, y = c.y - 1, h = 15;
    brillo(ctx, x, y, 26, '150,190,255', 0.35 * a);
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(x, y - h);
    ctx.bezierCurveTo(x + 6, y - h * 0.45, x + 7.5, y - 1, x, y + h * 0.42);
    ctx.bezierCurveTo(x - 7.5, y - 1, x - 6, y - h * 0.45, x, y - h);
    ctx.fillStyle = `rgba(170, 205, 255, ${0.28 * a})`; ctx.fill();
    ctx.strokeStyle = `rgba(200, 225, 255, ${0.95 * a})`; ctx.lineWidth = 1.7; ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x, y - h * 0.35); ctx.quadraticCurveTo(x + 2.5, y, x, y + h * 0.25);
    ctx.strokeStyle = `rgba(220, 235, 255, ${0.7 * a})`; ctx.lineWidth = 1.1; ctx.stroke();
    ctx.restore();
  });
}
function pistaNivel6() {
  const n6 = estado.n6, n5 = estado.n5;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4.5);
  };
  if (!n6) return mensaje('Mira.');
  if (!luzFria.punto || luzFria.guiadaHasta !== Infinity) return escalon('luz', ['Su ojo nuevo da luz. Arrastra el dedo para moverla.', 'La luz va al revés de tu dedo, como antes.']);
  const llevaTsukegi = estado.inventario.includes('tsukegi');
  if (!llevaTsukegi) return escalon('tsukegi', ['Para encender algo hace falta con qué. Recuerda lo que guardaba la cómoda.',
    'Alumbra los cajones del costado de la caja.', 'Una tinta fría marca el cajón de arriba: dentro están las tsukegi.']);
  if (!n6.mecha) return escalon('lampara', ['¿Qué daba luz en esta sala?', 'Alumbra la lámpara y tócala.']);
  if (llamaEnMano()) {
    if (noche.shoji > 0.3) return escalon('cerrar', ['Con el shoji abierto, el viento apagará la llama.', 'Ciérralo antes de llevarla: desliza la hoja otra vez.']);
    if (n6.puerta !== 'abierta') return escalon('puerta', ['¿Cómo llega la llama a la mecha?', 'La lámpara tiene una puertecilla de papel abajo: alúmbrala y deslízala.']);
    return escalon('llevar', ['Lleva la llama a la mecha: elige la tsukegi y toca la lámpara.']);
  }
  if (noche.shoji < 0.3) return escalon('aire', ['Las brasas del incensario están casi apagadas. Les falta aire.', 'El viento de fuera… El shoji se desliza.',
    'Entreabre el shoji: arrastra su hoja de la derecha.']);
  return escalon('prender', ['Con cada ráfaga, las brasas se avivan.', 'Elige la tsukegi y tócale las brasas justo cuando brillen.',
    n6.puerta !== 'abierta' ? 'Y antes de llevar la llama: abre la puertecilla de la lámpara y cierra el shoji.' : 'Luego, cierra el shoji antes de llevar la llama.']);
}

// ---------------------------------------------------------------------------------------------
// Nivel final · El corazón (solo en la B). Con la cara entera, la caja ya no se defiende: respira hondo y su corazón sube
// por la trampilla y se queda en la tapa, con tres anillos. Ayuda con lo que le has devuelto:
//   el anillo del cuerno: el ojo viejo mira la ranura donde va el cuerno (y la ranura late en rojo);
//   el anillo del ojo: su marca es tinta fría, y ahora el ojo nuevo alumbra lo que tocas;
//   el anillo de la voz: no tiene marca; la campanilla de la boca suena cuando pasa por su sitio.
// Con los tres en su sitio se abre el hueco del centro: la caja pequeña del nivel 2 es la última llave (se pone y se gira).
// ---------------------------------------------------------------------------------------------
const PASO_ANILLO = Math.PI / 4;
const RADIOS_ANILLOS = [[0.0855, 0.106], [0.0705, 0.0855], [0.054, 0.0705]];
const angular = a => Math.atan2(Math.sin(a), Math.cos(a));
const anilloEn = r => RADIOS_ANILLOS.findIndex(([a, b]) => r >= a && r < b);
// dónde tiene que quedar cada anillo: el cuerno (en el frente del suyo) en la ranura; la marca del ojo en la muesca
// de oro del frente; el de la voz, donde suena la campanilla
function sitioAnillo(f, i) { return i === 0 ? f.ranura * PASO_ANILLO : i === 1 ? -f.marca * PASO_ANILLO : f.voz * PASO_ANILLO; }
const enSitio = (f, i, a = f.angulos[i]) => Math.abs(angular(a - sitioAnillo(f, i))) < PASO_ANILLO * 0.3;
// el estado al final del nivel 3, para empezar el final sin jugarlo (seguir una partida guardada, o «?nivel=4»)
function estadoTrasNivel3() {
  estado.n3 = { nota: 'mano', tintas: { rollo: true, te: true, suelo: true }, ficha: 'puesta', fichaCara: 'promovida', largo: 'suelto',
    campanilla: 'puesta', badajo: 'puesto', completa: true, toques: 3, labios: 1 };
  cajonAnim.largo.k = cajonAnim.largo.objetivo = 0.12;
  ponerTextoNota(3); ponerCaraFicha('promovida'); ponerCampanillaCompleta(true);
  Object.assign(despertar, { trampilla: 0 });
  if (tec.abrirTrampilla) tec.abrirTrampilla(0);
  hornear();
}
async function empezarFinal() {
  ocultarTarjeta();
  if (tec.enderezar) tec.enderezar();             // la caja de frente, aunque se dejara a medio girar
  estado.nivel = NIVEL_FINAL;
  const paso = () => Math.floor(Math.random() * 8);
  const f = estado.fin = { fase: 'subiendo', subida: 0, angulos: [0, 0, 0], bloqueados: [false, false, false],
    ranura: 1 + Math.floor(Math.random() * 7), marca: paso(), voz: paso(), hija: 'mesa', giroHija: 0, centro: 0, latido: 0, luz: null };
  for (let i = 0; i < 3; i++) do { f.angulos[i] = paso() * PASO_ANILLO; } while (enSitio(f, i));      // ninguno empieza en su sitio
  estado.pistasPaso = {}; estado.insistencia = {};
  estado.fase = 'jugando'; estado.ocupado = true;
  el.girar.hidden = true; el.inventario.hidden = false; el.volver.hidden = true;
  for (const id of Object.keys(CAJONES)) if (estado.cajones[id] === 'abierto') cerrarCajon(id);
  if (estado.n3 && estado.n3.largo === 'abierto') { estado.n3.largo = 'suelto'; cajonAnim.largo.objetivo = 0.12; }
  if (tec.cara() !== 'frente') tec.girar();
  ojo.punto = null; ojo.distraidoHasta = 0; ojo.parpadoBase = 0; Object.assign(ojo2, { visible: 1, parpadoBase: 0 });
  // la caja pequeña se cierra sola, en la mesa: será la última llave
  if (estado.hija && tec.correrTablilla) {
    estado.hija.tablillas.forEach((_, i) => setTimeoutReloj(0.4 + 0.18 * (4 - i), () => { tec.correrTablilla(i, 0.4, 0); sonar('deslizar_madera', -18, 1.6); }));
    setTimeoutReloj(0.2, () => tec.abrirCajonHija(0.4, 0));
    estado.hija.tablillas = estado.hija.tablillas.map(() => false); estado.hija.cajon = 'cerrado';
  }
  bucle('noche', -14, 2);
  irA('caja', 1.4);
  await esperar(1.8);
  // respira hondo, suena su voz, y la trampilla deja salir el corazón
  contenerAliento(2.2); sonar('suspiro', -6, 0.8);
  await esperar(1.2);
  sonar('campanilla', -6); sonar('mecanismo', -4, 0.8); vibrar(30);
  destello(TRAMPILLA.x, TRAMPILLA.y - 10, 180, '255,215,140', 0.7, 1.5);
  irA('corazon', 2.4);
  if (tec.inclinar) tec.inclinar(0, 0.52);
  sonar('deslizar_madera', -6, 0.6);
  await animarPromesa(2.4, k => { f.subida = curva(k); });
  sentir('clac', { tono: 0.8 }); sonar('latido', -6);
  f.fase = 'anillos';
  estado.ocupado = false; el.volver.hidden = false;
  mensaje('Su corazón, con tres anillos. Ya no se defiende: el ojo viejo señala, el nuevo alumbra lo que tocas y su voz te avisa.', 6);
}
function actualizarFinal(dt) {
  const f = estado.fin;
  if (estado.nivel !== NIVEL_FINAL || !f) return;
  // abierto, el corazón late y sus anillos giran solos
  if (f.fase === 'abierto') { f.angulos[0] += 0.5 * dt; f.angulos[1] -= 0.8 * dt; f.angulos[2] += 1.2 * dt; }
}
// tocar el corazón le dice al ojo nuevo dónde alumbrar (la tinta del anillo del ojo solo se ve allí)
function alumbrarCorazon(q) {
  const f = estado.fin;
  if (!f || estado.vista !== 'corazon' || !tec.puntoEnCorazon || !q) return;
  const c = tec.puntoEnCorazon(q.x, q.y);
  if (c && c.r < 0.11) f.luz = { alfa: c.alfa, r: c.r, hasta: reloj + 3 };
}
function tocarCorazon(p, q) {
  const f = estado.fin;
  if (!f) return;
  if (estado.vista !== 'corazon') { irA('corazon', 0.9); if (tec.inclinar) tec.inclinar(0, 0.52); return; }
  const c = q && tec.puntoEnCorazon ? tec.puntoEnCorazon(q.x, q.y) : null, i = c ? anilloEn(c.r) : -1;
  if (f.fase === 'anillos' && i >= 0) {
    if (f.bloqueados[i]) { mensaje('Ese ya está en su sitio.'); return; }
    sentir('holgura', { tono: 0.8 + 0.1 * i });
    mensaje(primeraVez('anillo') ? 'Gira: arrastra el dedo en círculo sobre el anillo.' : ['El anillo del cuerno.', 'El anillo del ojo: su marca no se ve.', 'El anillo de la voz: no tiene marca.'][i], 3);
    return;
  }
  if (f.fase === 'centro' && f.hija !== 'puesta') { mensaje('Un hueco cuadrado, del tamaño de la caja pequeña.'); return; }
  mensaje(f.fase === 'anillos' ? 'En el centro, la madera está cerrada. Primero, sus tres anillos.' : 'Late.');
}
function bloquearAnillo(i) {
  const f = estado.fin;
  if (f.bloqueados[i]) return;
  f.bloqueados[i] = true;
  sentir('clac', { tono: 0.85 + 0.12 * i }); setTimeoutReloj(0.25, () => sentir('pestillo', { tono: 0.9 }));
  sonar('espiritu', -16, 1.15 + 0.1 * i);
  const textos = ['El cuerno, en la ranura que miraba el ojo viejo. El anillo queda firme.', 'La marca del ojo, frente a la muesca de oro. Encaja.',
    'Donde sonó la voz, el anillo encaja.'];
  mensaje(textos[i], 4);
  if (f.bloqueados.every(Boolean)) setTimeoutReloj(1.4, abrirCentro);
}
function avisarVoz() {
  if (estado.fin) estado.fin.vozHasta = reloj + 0.9;       // (el corazón también brilla un momento: se ve sin sonido)
  sonar('campanilla', -11, 1.02);
  destello(BOCA.x, BOCA.y, 60, '255,215,150', 0.6, 0.9);
  labiosTiemblan = reloj + 0.6;
}
async function abrirCentro() {
  const f = estado.fin;
  f.fase = 'centro';
  sentir('mecanismo'); sonar('latido', -8);
  await animarPromesa(1.2, k => { f.centro = suave(k); });
  mensaje(f.hija === 'mano' ? 'En el centro se abre un hueco cuadrado: el de la caja pequeña que llevas.'
    : 'En el centro se abre un hueco cuadrado… del tamaño de la caja pequeña que espera en la mesa.', 5);
}
function cogerHija() {
  const f = estado.fin;
  f.hija = 'mano';
  const v = tec.puntoHija ? tec.puntoHija() : null, m = v ? tec.ancla(v) : null;
  estado.hija.fase = 'mano';
  sonar('recoger', -2, 0.9);
  alInventario('hija', 'hija', 'caja', m && m.visible ? { x: m.x, y: m.y, k: 1, enPantalla: true } : { x: 930, y: 690 });
  mensaje(f.fase === 'centro' ? 'La caja pequeña, cerrada. Cabe justa en el hueco del corazón.' : 'La caja pequeña, cerrada otra vez. Cabe en la mano… y en algún hueco.', 4);
}
async function ponerHijaEnCorazon(desde) {
  const f = estado.fin;
  estado.ocupado = true;
  if (estado.vista !== 'corazon') { irA('corazon', 0.8); if (tec.inclinar) tec.inclinar(0, 0.52); await esperar(0.9); }
  await desdeInventario('hija', 'hija', tec.centroCorazon(), 'caja', desde);
  f.hija = 'puesta'; estado.hija.fase = 'corazon';
  sentir('clac', { tono: 0.8 }); sonar('tope_madera', -4, 0.9); sacudir(2, 0.25);
  estado.ocupado = false;
  mensaje('Encaja en el centro del corazón. Gírala con el dedo, en círculo.', 4.5);
}
// la caja pequeña, girada un cuarto de vuelta en el corazón: se asienta y abre
async function girarLlaveHija(signo) {
  const f = estado.fin;
  estado.ocupado = true;
  const desde = f.giroHija;
  await animarPromesa(0.22, k => { f.giroHija = mezclar(desde, signo * Math.PI / 2, suave(k)); });
  abrirCorazon();
}
// el final: la caja pequeña gira como una llave, los anillos se sueltan y el corazón late; la sala se aclara y la caja
// canta con los dos ojos abiertos
async function abrirCorazon() {
  const f = estado.fin;
  f.fase = 'abierto';
  estado.ocupado = true; el.volver.hidden = true;
  sentir('clac'); await esperar(0.35);
  sentir('desbloqueo'); sacudir(4, 0.4);
  ojo.parpadoBase = 0; ojo2.parpadoBase = 0; ojo.punto = null;
  for (let i = 0; i < 7; i++) setTimeoutReloj(0.4 + i * 1.15, () => {
    sonar('latido', -3 + Math.min(i, 3)); vibrar([30, 90, 20]);
    animar(0.9, k => { f.latido = Math.sin(Math.min(1, k * 3) * Math.PI / 2) * (1 - k) * 0.9 + 0.25; });
  });
  setTimeoutReloj(1.2, () => sonar('canto', 0));
  const oscuro0 = despertar.oscuridad, apagada0 = lampara.apagada;
  animar(4, k => { const e = suave(k); despertar.oscuridad = oscuro0 * (1 - e); lampara.apagada = apagada0 * (1 - e); });
  for (const [x, y] of [[OJO.x, OJO.y], [CUENCA.x, CUENCA.y]]) destello(x, y, 80, '255,220,160', 0.7, 2.5);
  for (const [x, y, dx] of [[880, 190, -0.4], [980, 190, 0.4], [930, 180, 0]]) {
    humos.sueltos.push(new Cinta(x, y, { ritmo: 14, vida: 5, vel: 18, ancho: 4, alfa: 0.3, dir: { x: dx, y: -1 }, duracion: 7, rizo: 1.2,
      color: [255, 236, 200], tinta: 0.1, objeto: 'caja' }));
  }
  await esperar(3);
  irA('caja', 3);
  await esperar(4);
  irA('sala', 4.5);
  await esperar(4.5);
  estado.ocupado = false;
  terminarNivel(NIVEL_FINAL);
}
function pistaFinal() {
  const f = estado.fin;
  const escalon = (clave, lista) => {
    const n = estado.pistasPaso[clave] = (estado.pistasPaso[clave] || 0) + 1;
    return mensaje(lista[Math.min(n, lista.length) - 1], 4.5);
  };
  if (!f || f.fase === 'subiendo' || f.fase === 'abierto') return mensaje('Mira.');
  if (f.fase === 'anillos') {
    if (!f.bloqueados[0]) return escalon('cuerno', ['El anillo de fuera lleva un cuerno. ¿Adónde mira el ojo viejo?',
      'Una ranura del marco late en rojo: ahí va el cuerno.', 'Gira el anillo de fuera (arrastra en círculo) hasta dejar el cuerno en la ranura roja, y suéltalo.']);
    if (!f.bloqueados[1]) return escalon('ojo', ['El anillo de en medio tiene una marca que no se ve.', 'El ojo nuevo alumbra lo que tocas: toca el anillo por varios sitios.',
      'Cuando veas 目, gira el anillo hasta la muesca de oro del frente.']);
    return escalon('voz', ['El anillo de dentro no tiene marca. Escucha.', 'Gíralo despacio: la campanilla de la boca suena cuando pasa por su sitio.',
      'Suéltalo justo donde suena la campanilla.']);
  }
  if (f.hija === 'mesa') return escalon('hija', ['El hueco del centro es cuadrado. ¿Qué tiene ese tamaño?', 'La caja pequeña, en la mesa. Cógela.']);
  if (f.hija === 'mano') return escalon('poner', ['Lleva la caja pequeña al centro del corazón.', 'Elígela en la bandeja y toca el hueco.']);
  return escalon('llave', ['Una llave se gira.', 'Gira la caja pequeña con el dedo, en círculo: un cuarto de vuelta.']);
}

// ---------------------------------------------------------------------------------------------
// Usar lo que llevas
// ---------------------------------------------------------------------------------------------
// un toque elige el objeto; otro toque sobre el elegido lo examina
function seleccionar(objeto) {
  if (estado.seleccion === objeto) { estado.seleccion = null; pintarInventario(); examinar(objeto); return; }
  // con otro objeto elegido, si encajan, se juntan (el badajo en la campanilla)
  if (estado.seleccion && combinan(estado.seleccion, objeto)) {
    const otro = estado.seleccion; estado.seleccion = null; pintarInventario(); combinar(otro, objeto); return;
  }
  estado.seleccion = objeto;
  pintarInventario();
  mostrarEtiqueta(objeto);
  sonar('toque', -12, 1.2);
  const n3 = estado.n3;
  // («Mirar», junto al objeto, lo enseña de cerca y en 3D; tocarlo otra vez, o mantenerlo pulsado, también)
  const textos = { llave: 'La llave de bambú. ¿Dónde la usas?', cuerno: 'El cuerno de marfil. ¿Dónde va?', nota: 'La nota. «Leer» la abre.',
    cajita: 'La cajita roja. «Mirar» la enseña de cerca.', ojo: 'El ojo de piedra de luna. ¿Dónde va?',
    ficha: 'La ficha de shōgi. «Mirar» la enseña de cerca.',
    campanilla: n3 && n3.completa ? 'La campanilla. Toca donde quieras hacerla sonar.' : 'La campanilla, sin badajo. «Mirar» la enseña por todos lados.',
    badajo: 'El badajo. ¿Dónde va?', hija: 'La caja pequeña. ¿Dónde cabe?',
    esquirlas: 'Las esquirlas. «Mirar» te las pone en la mano.', mejilla: 'El pedazo de la mejilla. «Mirar» te lo pone en la mano.',
    laca: 'La laca. Se usa con el pedazo en la mano.', oro: 'El polvo de oro. Se usa con el pedazo en la mano.',
    tarjeta: 'La tarjeta del lazo. «Mirar» la enseña de cerca.',
    tsukegi: estado.nivel >= 6 ? 'Las tsukegi. Prenden con una brasa.' : 'Las tsukegi. «Mirar» las enseña de cerca.',
    secreto: 'Su secreto. «Mirar» lo enseña de cerca.' };
  mensaje(textos[objeto], 2.4);
}
// (desde: de dónde sale volando, si se arrastró desde la bandeja; toque: el punto de la pantalla donde se usa)
function usarObjeto(objeto, p, desde = null, toque = desde) {
  const deseleccionar = () => { estado.seleccion = null; pintarInventario(); };
  const deFrente = p && p.cara !== 'detras';
  if (objeto === 'nota') { deseleccionar(); leerNota(); return; }
  // nivel 5: la llave de bambú en el costado (en c6 entra, pero no gira: se empuja)
  if (estado.nivel === 5 && estado.n5 && objeto === 'llave' && p && p.cajon && deFrente) { deseleccionar(); usarLlave5(p.cajon, desde); return; }
  if (p && p.cajon && deFrente) {
    deseleccionar(); sonar('trabado', -8, 1.2);
    mensaje(objeto === 'llave' ? (tieneCerradura(p.cajon) ? 'La cerradura de este cajón es aún más pequeña.' : 'Este cajón no tiene cerradura.') : 'Ahí no encaja.');
    return;
  }
  if (objeto === 'llave' && deFrente && dentro(INCENSARIO, p) && estado.tapa === 'puesta') { deseleccionar(); meterLlave(desde); return; }
  if (objeto === 'cuerno' && deFrente && dentro(['elipse', 912, 291, 40, 40], p)) { deseleccionar(); ponerCuerno(desde); return; }
  if (objeto === 'ojo' && deFrente && !p.hija && dentro(['elipse', CUENCA.x, CUENCA.y, 42, 28], p)) { deseleccionar(); ponerOjo(desde); return; }
  if (objeto === 'cajita') { deseleccionar(); sonar('trabado', -10, 1.3); mensaje('Primero habría que abrirla: elígela y pulsa «Mirar».'); return; }
  // nivel 3
  if (objeto === 'ficha' && p && p.cara === 'detras' && dentro(['rect', 805, 318, 888, 418], p)) { deseleccionar(); ponerFicha(desde); return; }
  if (objeto === 'campanilla' && estado.n3 && estado.nivel === 3) { deseleccionar(); usarCampanilla(p, desde); return; }
  if (objeto === 'hija' && estado.fin) {
    deseleccionar();
    const f = estado.fin, c = toque && tec.puntoEnCorazon ? tec.puntoEnCorazon(toque.x, toque.y) : null;
    if (f.fase === 'centro' && (p && p.corazon || (c && c.r < 0.11))) { ponerHijaEnCorazon(desde); return; }
    sonar('trabado', -8, 1.2);
    mensaje(f.fase === 'anillos' ? 'El corazón aún no tiene hueco: primero, sus tres anillos.' : 'Ahí no. ¿Dónde hay un hueco de su tamaño?');
    return;
  }
  if (objeto === 'badajo' && p && p.cara !== 'detras' && dentro(['poli', CAJA], p)) { deseleccionar(); sonar('trabado', -8, 1.2); mensaje('El badajo solo, no. Va dentro de algo.'); return; }
  // nivel 4: las esquirlas y el pedazo en la mejilla o en la boca (su aliento cura la laca); la laca y el oro, en la mano
  if (estado.nivel === 4 && estado.n4 && ['esquirlas', 'mejilla', 'laca', 'oro'].includes(objeto)) {
    const n4 = estado.n4, enMejilla = deFrente && p && dentro(['poli', nivel4.contorno], p);
    const enBoca = deFrente && p && dentro(['elipse', BOCA.x, BOCA.y + 4, 56, 30], p);
    const enTe = p && (dentro(['rect', 1206, 476, 1376, 626], p) || dentro(['rect', 1140, 592, 1336, 698], p));
    if (objeto === 'mejilla' && enBoca && n4.pieza === 'dorada') { cantar4Caja(); return; }      // (sigue elegido: ahora, la mejilla)
    deseleccionar();
    if (objeto === 'mejilla' && enMejilla && n4.pieza === 'dorada') { ponerMejilla(desde); return; }
    if (objeto === 'mejilla' && enBoca) { usarMejillaEnBoca(desde); return; }
    sonar('trabado', -8, 1.2);
    if (objeto === 'esquirlas' && enMejilla) {
      if (!n4.probada && n4.esquirlas[1] === 'lampara') { n4.probada = true; setTimeoutReloj(1.2, () => mirarA({ x: nivel4.lampara.sombra[0], y: nivel4.lampara.sombra[1] }, 1.4)); }
      n4.probada = true;
      mensaje(enMano4().length < 3 ? 'Es de su mejilla, pero sola no se sostiene: faltan pedazos.' : 'Son los tres pedazos, sueltos. Móntalos primero en la mano: tócalos dos veces en la bandeja.', 4);
      return;
    }
    if (objeto === 'mejilla' && enMejilla) {
      mensaje({ montada: 'Encaja, pero se caería: las juntas están abiertas.', lacada: 'La laca aún está fresca: no sujeta. Tiene que curar.',
        curada: 'Curada, pero sin oro las juntas se ven negras. ¿Qué falta?' }[n4.pieza] || 'Todavía no.', 4);
      return;
    }
    if (objeto === 'mejilla' && enTe) { mensaje(n4.pieza === 'lacada' ? 'El té ya está tibio: no echa vapor.' : 'Ahí no.', 3.5); return; }
    if (objeto === 'laca' || objeto === 'oro') { mensaje(n4.pieza === 'sueltas' ? 'Primero hay que montar las esquirlas.' : 'Se usa con el pedazo en la mano: tócalo dos veces en la bandeja.', 3.5); return; }
    mensaje(enMejilla ? 'Todavía no.' : 'Ahí no.');
    return;
  }
  // nivel 5: la tarjeta es una pista (no se usa, se mira); su secreto, igual
  if (objeto === 'tarjeta' || objeto === 'secreto') {
    deseleccionar(); sonar('papel', -12, 1.2);
    if (objeto === 'secreto') { examinar('secreto'); return; }
    mensaje(p && (p.borla || estado.vista === 'borla') ? 'Es este lazo. En la tarjeta, la flecha tira de la cola de la punta negra.'
      : 'Es un dibujo: no se usa, se mira. Un lazo… ¿dónde hay uno?', 4);
    return;
  }
  if (objeto === 'tsukegi' && estado.nivel === 5) { deseleccionar(); sonar('trabado', -10, 1.3); mensaje('Para prenderlas hace falta una brasa. Aún hay luz.', 3.5); return; }
  // nivel 6: la tsukegi en las brasas (prende si están avivadas) y, encendida, en la mecha
  if (objeto === 'tsukegi' && enLaNoche()) {
    deseleccionar();
    if (p && dentro(INCENSARIO, p)) { prenderTsukegi(); return; }
    if (p && dentro(zonaLampara6(), p)) {
      if (llamaEnMano()) { encenderLampara(); return; }
      sonar('trabado', -10, 1.3); mensaje(estado.n6.mecha ? 'Sin llama no prende. ¿Dónde queda algo encendido?' : 'La mecha humea, pero sin fuego no prende.', 3.5);
      return;
    }
    sonar('trabado', -10, 1.3); mensaje(llamaEnMano() ? 'Ahí no. La llama se consume…' : 'Ahí no.', 2.5);
    return;
  }
  deseleccionar();
  sonar('trabado', -8, 1.2);
  const enCaja = p && (p.cara === 'detras' || dentro(['poli', CAJA], p));
  if (objeto === 'llave') mensaje(p && p.cara === 'detras' && dentro(['rect', 715, 474, 990, 558], p) ? 'No es esta llave: es demasiado pequeña.' : enCaja ? 'La llave no entra en la caja.' : 'La llave no entra ahí.');
  else if (objeto === 'ojo') mensaje(enCaja ? 'Ahí no encaja. ¿Dónde le falta un ojo a la cara?' : 'Ahí no encaja.');
  else if (objeto === 'ficha') mensaje(enCaja ? 'Ahí no encaja. ¿Dónde hay un hueco con su forma?' : 'Ahí no encaja.');
  else if (objeto === 'badajo') mensaje('Ahí no. ¿De qué es la lengua?');
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
  sonar('despertar', -5); vibrar(120); sacudir(7, 0.5);
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
// La partida guarda el último nivel superado y cuántos niveles tenía el juego. Hasta la 0.7 no guardaba cuántos, y en la
// 0.6 el final era el nivel 5: una partida de entonces con el 5 superado terminó aquel final, no «La cómoda», así que
// sigue en «La cómoda» en vez de saltársela
function leerProgreso() {
  try {
    const g = JSON.parse(localStorage.getItem(CLAVE_PARTIDA));
    if (!g || !g.superado) return null;
    if (!g.niveles && g.superado === 5) g.superado = 4;
    return g;
  } catch (e) { return null; }
}
// el nivel a medias: el mismo estado que guarda la recarga en caliente, en el almacenamiento del móvil. Solo de los
// niveles 2 a 6 en la escena 3D (el 1 y el final son cortos) y sin nada en marcha
function guardarEnCurso() {
  if (estado.fase !== 'jugando' || estado.ocupado || estado.nivel < 2 || estado.nivel >= NIVEL_FINAL || !hay3D()) return false;
  try {
    localStorage.setItem(CLAVE_EN_CURSO, JSON.stringify({ estado: { ...estado, ocupado: false, seleccion: null, vista: 'sala' },
      niveles: ULTIMO_NIVEL, fecha: Date.now() }));
    return true;
  } catch (e) { return false; }
}
function leerEnCurso(nivel) {
  try {
    const g = JSON.parse(localStorage.getItem(CLAVE_EN_CURSO));
    return g && g.niveles === ULTIMO_NIVEL && g.estado && g.estado.nivel === nivel && g.estado.fase === 'jugando' ? g : null;
  } catch (e) { return null; }
}
function borrarEnCurso() { try { localStorage.removeItem(CLAVE_EN_CURSO); } catch (e) { /* nada */ } }
function guardarProgreso(superado) {
  try {
    const antes = leerProgreso();
    localStorage.setItem(CLAVE_PARTIDA, JSON.stringify({ superado: Math.max(superado, antes ? antes.superado : 0),
      niveles: ULTIMO_NIVEL, fecha: Date.now() }));
  } catch (e) { /* sin almacenamiento: se juega igual */ }
}
const hay3D = () => tec.nombre !== 'A' && !!tec.hayHija && tec.hayHija();
function terminarNivel(n) {
  estado.fase = 'tarjeta';
  estado.ocupado = false;
  estado.seleccion = null; pintarInventario();
  el.volver.hidden = true;
  guardarProgreso(n);
  borrarEnCurso();
  const nivel = NIVELES[n], siguiente = NIVELES[n + 1];
  el.tarjetaTitulo.textContent = nivel.titulo;
  el.tarjetaTexto.textContent = nivel.texto;
  for (const pieza of el.tarjeta.querySelectorAll('.pieza')) {
    const i = Object.values(NIVELES).findIndex(v => v.pieza === pieza.dataset.pieza) + 1;
    pieza.classList.toggle('recuperada', i <= n);
    pieza.classList.toggle('nueva', i === n);
  }
  el.tarjeta.querySelector('.marcador').setAttribute('aria-label', `La cara: ${Math.min(n, 6)} de 6 piezas`);
  const puede = n < ULTIMO_NIVEL && hay3D();
  el.tarjetaHecho.textContent = `${nombreNivel(n)} superado`;
  el.tarjetaSiguiente.textContent = n >= ULTIMO_NIVEL ? 'Fin de la primera caja. Gracias por jugar.'
    : puede ? `${nombreNivel(n + 1)} · ${siguiente.titulo}`
      : `${nombreNivel(n + 1)} necesita la escena 3D, y este móvil no puede abrirla.`;
  el.seguir.hidden = !puede;
  // quedarse en la sala: al final (o si este móvil no puede seguir), para mirar la caja con calma
  el.quedarse.hidden = puede;
  // «Volver a empezar» solo al final (o si no se puede seguir): junto a «Seguir», un toque de más llevaba al nivel 1
  el.otra.hidden = puede;
  el.tarjeta.hidden = false;
  requestAnimationFrame(() => el.tarjeta.classList.remove('oculta'));
  sonar('papel', -10, 0.9);
  if (n < ULTIMO_NIVEL) setTimeout(() => { sonar('tope_madera', -6, 0.6); vibrar([20, 40, 30]); }, 1250);   // el sello estampa
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
  if (tec.enderezar) tec.enderezar();             // la caja de frente, aunque se dejara a medio girar
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
  actualizarNivel3(dt);
  actualizarNivel4(dt);
  actualizarNivel5(dt);
  actualizarNivel6(dt);
  if (estado.nivel >= 3) actualizarLuzFria(dt);
  actualizarTetera3(dt);
  actualizarFinal(dt);
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
    if (!pausado) actualizar(dt);                       // en pausa, el juego no avanza (se sigue viendo detrás del menú)
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
const VISTA_PADRE = { cajones: 'caja', cara: 'caja', incensario: 'sala', caja: 'sala', hija: 'caja', te: 'sala', largo: 'caja', corazon: 'caja', zocalo: 'caja',
  espalda: 'caja', borla: 'caja', lampara: 'sala' };
function posicion(e) { const r = lienzo.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; }
lienzo.addEventListener('pointerdown', e => {
  desbloquearAudio();
  sueno.toque = reloj;
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
  puntero = { ...q, x0: q.x, y0: q.y, inicio: performance.now(), reloj0: reloj, id: e.pointerId, movido: 0, gesto: gestoEn(p, q),
    // (en el final no se gira: su corazón está en la tapa y los ojos tienen que verlo)
    enCaja: (v === 'sala' || v === 'caja') && !hijaEnMesa() && estado.nivel !== NIVEL_FINAL && !enLaNoche() && !!(p && (p.cara === 'detras' || p.cajon || dentro(['poli', CAJA], p))),
    enHija: hijaEnMesa() && v === 'hija' };
  if (estado.fase === 'jugando' && p && p.cara === 'frente') { if (estado.nivel !== NIVEL_FINAL && !enLaNoche()) mirarA(p); guiarLuz(p); alumbrarCorazon(q); }
});
lienzo.addEventListener('pointermove', e => {
  const q = posicion(e);
  if (punteros.has(e.pointerId)) punteros.set(e.pointerId, q);
  if (pellizco && punteros.size >= 2) { moverPellizco(); return; }
  if ((e.pointerType === 'mouse' || puntero) && estado.fase === 'jugando') {
    const p = tec.aPintura(q.x, q.y);
    moverDedo(p);
    if (p && p.cara === 'frente') { if (estado.nivel !== NIVEL_FINAL && !enLaNoche()) mirarA(p); if (puntero) { guiarLuz(p); alumbrarCorazon(q); } }
  }
  if (!puntero || e.pointerId !== puntero.id) return;
  const dx = q.x - puntero.x, dy = q.y - puntero.y;
  puntero.movido = Math.max(puntero.movido, Math.hypot(q.x - puntero.x0, q.y - puntero.y0));
  // la velocidad del dedo (px/s): al soltar con impulso, la caja sigue girando un poco
  const ahoraMov = performance.now(), pasoMov = Math.max(0.008, (ahoraMov - (puntero.tMov || puntero.inicio)) / 1000);
  puntero.vx = mezclar(puntero.vx || 0, dx / pasoMov, 0.5); puntero.tMov = ahoraMov;
  if (puntero.gesto && moverGesto(puntero.gesto, q)) { puntero.x = q.x; puntero.y = q.y; return; }
  // nivel 6, a oscuras: arrastrar mueve la luz fría (al revés del dedo), no la cámara ni la caja
  if (enLaNoche() && estado.fase === 'jugando') {
    if (puntero.movido > 8 && !estado.ocupado) moverLuz6(dx, dy);
    puntero.x = q.x; puntero.y = q.y;
    return;
  }
  if (puntero.movido > 10 && estado.fase !== 'portada' && !estado.ocupado) {
    if (puntero.enHija) tec.girarHija(dx, dy);
    else if (puntero.enCaja) {
      // sobre la caja grande: de lado la gira; hacia abajo, la vista se inclina para verla por encima (la tapa y su
      // trampilla), y hacia arriba vuelve. El primer tramo decide el eje, para que al girarla no se incline sin querer
      const tx = Math.abs(q.x - puntero.x0), ty = Math.abs(q.y - puntero.y0);
      if (!puntero.eje && puntero.movido > 16) puntero.eje = ty > tx * 1.3 ? 'v' : tx > ty * 1.3 ? 'h' : 'libre';
      // desde la sala, arrastrarla hacia abajo acerca la caja y la enseña desde arriba
      if (puntero.eje === 'v' && estado.vista === 'sala' && q.y - puntero.y0 > 36 && tec.nombre !== 'A') {
        irA('caja'); tec.inclinar(0, 0.3);
      }
      tec.arrastrar(puntero.eje === 'v' ? 0 : dx, puntero.eje === 'h' ? 0 : dy, true);
    }
    // en la sala se mira alrededor; de cerca, la vista sigue anclada a su sitio, pero gira a su alrededor
    else if (estado.vista !== 'subida') tec.arrastrar(dx, dy, false);
    if (tec.nombre !== 'A' && (puntero.enCaja || puntero.enHija) && puntero.eje !== 'v' && !puntero.sonoGiro && puntero.movido > 24) {
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
  else if (puntero.movido < 16 && (performance.now() - puntero.inicio < 900 || puntero.movido < 8) && e.type === 'pointerup') tocarEscena(q.x, q.y);
  else {
    if (puntero.enHija && tec.soltarHija) { tec.soltarHija(); if (puntero.movido >= 16) sentir('tope', { db: -9, tono: 1.6, sinVibrar: true }); }
    const conImpulso = puntero.enCaja && puntero.eje !== 'v' && performance.now() - (puntero.tMov || 0) < 80;
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
  // nivel final: los anillos del corazón se giran en círculo, y la caja pequeña puesta en él, también
  if (estado.nivel === NIVEL_FINAL && estado.fin && v === 'corazon' && tec.puntoEnCorazon) {
    const f = estado.fin, c = tec.puntoEnCorazon(q.x, q.y);
    if (c && f.fase === 'anillos' && anilloEn(c.r) >= 0) return { tipo: 'anillo', i: anilloEn(c.r) };
    if (c && f.fase === 'centro' && f.hija === 'puesta' && c.r < 0.075) return { tipo: 'llaveHija' };
  }
  if (!p) return null;
  // nivel 6, a oscuras: el shoji (desde la sala) y la puertecilla de la lámpara; lo no alumbrado no se coge
  if (enLaNoche()) {
    if (v === 'sala' && dentro(zonaShoji6(), p)) return { tipo: 'shoji6' };
    const [x0, y0, x1, y1] = nivel6.lampara.puerta;
    if ((v === 'lampara' || v === 'sala') && dentro(['rect', x0 - 8, y0 - 8, x1 + 8, y1 + 8], p) && iluminado(p)) return { tipo: 'puerta6' };
    if (!iluminado(p)) return null;
  }
  if (p.cajon && v === 'cajones') return { tipo: 'cajon', id: p.cajon };
  // nivel 5: los cajones de la espalda (de cerca) y la borla del costado
  if (estado.nivel === 5 && estado.n5) {
    if (v === 'espalda' && p.cara === 'detras' && !p.largo) { const id = p.detras5 || cajonDetrasEn(p); if (id) return { tipo: 'detras5', id }; }
    if (v === 'borla' && p.borla) { const parte = parteDeBorla(nivel5.borla, estadoBorla(), p.bx, p.by); if (parte) return { tipo: 'borla5', parte }; }
  }
  // nivel 3: el cajón largo de la espalda (suelto o abierto) se tira; la tetera, de cerca, se vuelca
  if (estado.nivel === 3 && estado.n3) {
    if (p.cara === 'detras' && (p.largo || dentro(LARGO, p)) && estado.n3.largo !== 'cerrado' && v !== 'sala') return { tipo: 'largo' };
    if (v === 'te' && tec.inclinarTetera && p.cara === 'frente' && dentro(['rect', 1196, 466, 1376, 632], p)) return { tipo: 'tetera' };
  }
  // nivel 4: el cajón de la peana (suelto o abierto) se tira, de cerca
  if (estado.nivel === 4 && estado.n4 && estado.n4.zocalo !== 'cerrado' && v === 'zocalo' && p.cara === 'frente'
    && (p.zocalo || dentro(['rect', ...nivel4.cajon_zocalo], p))) return { tipo: 'zocalo' };
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
      const n5 = estado.nivel === 5 ? estado.n5 : null;
      // nivel 5: con la llave metida en c6, empujar hacia dentro la empuja
      if (n5 && g.id === 'c6' && n5.llave === 'metida') {
        const eje = ejeCajon(g.id);
        if (eje && eje.a && eje.b && cosenoConEje(eje, dx, dy) < -0.3) { empujarLlave5(); g.estado = 'hecho'; return true; }
      }
      if (tieneCerradura(g.id)) {
        const c = centroCajon(g.id);
        cajonCerrado(g.id, c.x, c.y, 1, -0.6, 'Tiene una cerradura pequeña. No cede.');
        g.estado = 'bloqueado';
        return true;
      }
      // c6, suelto: mientras mira, no deja; dormida, sí… pero despacio
      if (n5 && g.id === 'c6' && estado.cajones.c6 !== 'abierto') {
        if (!sueno.dormida) { guardarSecreto(); g.estado = 'bloqueado'; return true; }
        g.sigilo = true;
      }
      const a = cajonAnim[g.id];
      g.eje = ejeCajon(g.id); g.k0 = a.k; g.kAntes = a.k; g.t = performance.now();
      g.asentado = a.k < 0.02;              // cerrado, está asentado: cede tras un poco de tirón
      a.agarrado = true; a.v = 0;
      if (!g.asentado) sentir('roce', { tono: 1.05 });
      break;
    }
    case 'anillo': case 'llaveHija': {
      const f = estado.fin;
      if (g.tipo === 'anillo' && f.bloqueados[g.i]) { sentir('tope', { db: -6, tono: 0.8 }); mensaje('Ese ya está en su sitio.'); g.estado = 'bloqueado'; return true; }
      const c = tec.puntoEnCorazon(puntero.x0, puntero.y0);
      g.alfa = c ? c.alfa : 0;
      g.objetivo = g.tipo === 'anillo' ? f.angulos[g.i] : f.giroHija;
      g.paso = Math.round(g.objetivo / PASO_ANILLO);
      sentir('roce', { tono: 0.7, db: -2 });
      break;
    }
    case 'detras5': {
      const n5 = estado.n5, id = g.id, a = anim5(id);
      g.eje = tec.pantallaDetras ? { a: tec.pantallaDetras(id, 0), b: tec.pantallaDetras(id, 1) } : null;
      if (!g.eje || !g.eje.a || !g.eje.b) return false;
      const coseno = cosenoConEje(g.eje, dx, dy);          // > 0: hacia fuera (tirar); < 0: hacia dentro (empujar)
      if (id === 'c' && n5.c === 'trabado') {
        if (coseno < -0.3) { soltarArgolla(); g.estado = 'hecho'; return true; }
        sonar('toc', -10, 1.15); ruido(1);
        mensaje(insistir('argolla') === 1 ? 'No sale. Su argolla no se mueve ni un poco.' : 'No se tira…');
        g.estado = 'bloqueado'; return true;
      }
      if (id === 'p' && n5.p === 'escondido') {
        a.v += 0.6; sonar('trabado', -10, 1.3); ruido(0.5);
        mensaje(primeraVez('p-atascado') ? 'Se mueve un pelo y se atasca: algo suelto, dentro, no deja.' : 'Se atasca.');
        g.estado = 'bloqueado'; return true;
      }
      const b = bloqueaA(id);
      if (b && coseno > 0) { trabadoPor(id, b); g.estado = 'bloqueado'; return true; }
      g.k0 = a.k; g.kAntes = a.k; g.t = performance.now();
      a.agarrado = true; a.v = 0;
      sentir('roce', { tono: 1.05 });
      break;
    }
    case 'shoji6': case 'puerta6': {
      g.k0 = g.tipo === 'shoji6' ? noche.shoji : noche.puerta; g.escala = escalaSala();
      if (g.tipo === 'shoji6') { sentir('roce', { tono: 0.75 }); sonar('deslizar_madera', -12, 0.75); }
      else { sentir('roce', { tono: 1.6, db: -6 }); sonar('papel', -18, 1.5); }
      break;
    }
    case 'borla5': {
      const n5 = estado.n5;
      g.x0 = puntero.x0; g.y0 = puntero.y0; g.escala = escalaBorla();
      if (g.parte === 'borla' && n5.lazo === 'atado') {
        mecerBorla(0.08); sonar('seda', -10, 0.9);
        mensaje(insistir('borla-atada') === 1 ? 'La borla baja un poco y el lazo la frena.' : 'El lazo no deja que baje.');
        g.estado = 'bloqueado'; return true;
      }
      if (g.parte === 'borla' && n5.borla === 'abajo') return false;
      sentir('roce', { tono: 1.5, db: -6 });
      break;
    }
    case 'zocalo': {
      const a = cajonAnim.zocalo;
      g.eje = tec.pantallaZocalo ? { a: tec.pantallaZocalo(0), b: tec.pantallaZocalo(1) } : null;
      if (!g.eje || !g.eje.a || !g.eje.b) return false;
      g.k0 = a.k; g.kAntes = a.k; g.t = performance.now();
      a.agarrado = true; a.v = 0;
      sentir('roce', { tono: 0.95 });
      break;
    }
    case 'largo': {
      const a = cajonAnim.largo;
      g.eje = tec.pantallaLargo ? { a: tec.pantallaLargo(0), b: tec.pantallaLargo(1) } : null;
      if (!g.eje || !g.eje.a || !g.eje.b) return false;
      g.k0 = a.k; g.kAntes = a.k; g.t = performance.now();
      a.agarrado = true; a.v = 0;
      sentir('roce', { tono: 0.9 });
      break;
    }
    case 'tetera': {
      if (dy < -Math.abs(dx) * 0.5) return false;             // hacia arriba no se vuelca
      g.objetivo = tetera3.inclinacion; g.t = performance.now();
      sentir('roce', { tono: 1.7, db: -4 });
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
      const a = cajonAnim[g.id], k = limitar(g.k0 + avance, 0, 1.04), rapidez = (k - a.k) / paso;
      // (el primer movimiento trae de golpe lo que el dedo recorrió antes de que empezara el gesto: no es rapidez)
      a.v = g.movido ? mezclar(a.v, rapidez, 0.5) : 0;
      g.rapidez = g.movido ? mezclar(g.rapidez, rapidez, 1 - Math.exp(-paso / 0.12)) : 0;      // media de unos 0,1 s
      g.movido = true; a.k = k; g.t = ahora;
      // nivel 5: c6 con la caja dormida; un tirón deprisa hace ruido (o llegar al tope de golpe). La rapidez, de dos
      // maneras: la de ahora (media de 0,1 s) y la de todo el tirón desde que se puso el dedo (un movimiento muy rápido
      // puede llegar en un solo evento). En tiempo real: el reloj del juego va más lento que el de verdad en un móvil a
      // menos de 20 cuadros por segundo, y un tirón despacio contaría como deprisa
      if (g.sigilo) {
        const media = (k - g.k0) / Math.max(0.05, (ahora - puntero.inicio) / 1000);
        if (g.rapidez > VELOCIDAD_RUIDO || (k - g.k0 > 0.3 && media > VELOCIDAD_RUIDO) || (k >= 1 && g.kAntes < 1 && g.rapidez > 1)) { tironFuerte(g); break; }
      }
      if (k <= 0 && g.kAntes > 0.015 && reloj > a.golpe) {                  // cerrado de un empujón
        a.golpe = reloj + 0.25; sonar('tope_madera', -9, 1.15); vibrar(10); agitarTe(0.3); ruido(1);
      }
      if (k >= 1 && g.kAntes < 1) sentir('tope', { db: -4, tono: 1.1 });       // el tope de fuera
      g.kAntes = k;
      break;
    }
    case 'anillo': case 'llaveHija': {
      const c = tec.puntoEnCorazon(q.x, q.y);
      if (!c || c.r < 0.012) break;                       // en el centro mismo, el ángulo salta
      g.objetivo += angular(c.alfa - g.alfa); g.alfa = c.alfa;
      if (g.tipo === 'llaveHija' && Math.abs(g.objetivo) > 1.35) { g.estado = 'hecho'; girarLlaveHija(Math.sign(g.objetivo)); }
      break;
    }
    case 'zocalo': {
      const a = cajonAnim.zocalo, k = limitar(g.k0 + avanceEnEje(g.eje, dx, dy), 0, 1.04);
      a.v = mezclar(a.v, (k - a.k) / paso, 0.5); a.k = k; g.t = ahora;
      if (k >= 1 && g.kAntes < 1) sentir('tope', { db: -4, tono: 0.9 });
      g.kAntes = k;
      break;
    }
    case 'detras5': {
      const a = anim5(g.id), k = limitar(g.k0 + avanceEnEje(g.eje, dx, dy), 0, 1.04);
      a.v = mezclar(a.v, (k - a.k) / paso, 0.5); a.k = k; g.t = ahora;
      if (k >= 1 && g.kAntes < 1) sentir('tope', { db: -4, tono: 1.05 });
      if (k <= 0 && g.kAntes > 0.015 && reloj > a.golpe) { a.golpe = reloj + 0.25; sonar('tope_madera', -11, 1.2); ruido(0.5); }
      g.kAntes = k;
      break;
    }
    case 'shoji6': {
      noche.shoji = estado.n6.shoji = limitar(g.k0 + dx / (nivel6.shoji.abre * g.escala), 0, 1);
      break;
    }
    case 'puerta6': {
      const [x0, , x1] = nivel6.lampara.puerta;
      noche.puerta = limitar(g.k0 - dx / ((x1 - x0 - 8) * g.escala), 0, 1);
      break;
    }
    case 'borla5': {
      const n5 = estado.n5, s = g.escala || 1, lejos = Math.hypot(dx, dy) / s;
      if (g.parte === 'cola_der' && lejos > 45) { g.estado = 'hecho'; desatarLazo(); break; }
      if ((g.parte === 'cola_izq' || g.parte.startsWith('lazo')) && lejos > 35) {
        g.estado = 'hecho';
        apretarLazo(g.parte === 'cola_izq' ? 'Esa cola solo aprieta el nudo.' : 'Tirar del lazo lo aprieta más.');
        break;
      }
      if (g.parte === 'nudo' && lejos > 35) { g.estado = 'hecho'; mecerBorla(0.06); mensaje('El nudo no se deshace así: tira de una de sus colas.', 3.5); break; }
      if (g.parte === 'borla' && n5.lazo === 'suelto' && n5.borla === 'arriba') {
        borla5.objetivoBajada = limitar(dy / s / 110, 0, 1);
        borla5.meneo += (dx / s) * 0.00004;
        if (borla5.objetivoBajada > 0.92) { g.estado = 'hecho'; tirarBorla(); }
      }
      break;
    }
    case 'largo': {
      const a = cajonAnim.largo, k = limitar(g.k0 + avanceEnEje(g.eje, dx, dy), 0, 1.04);
      a.v = mezclar(a.v, (k - a.k) / paso, 0.5); a.k = k; g.t = ahora;
      if (k >= 1 && g.kAntes < 1) sentir('tope', { db: -4, tono: 0.95 });
      g.kAntes = k;
      break;
    }
    case 'tetera': {
      // se vuelca hacia la taza: arrastrando hacia abajo (o hacia abajo y a la izquierda, hacia el pico)
      g.objetivo = limitar((dy - dx * 0.6) / 110, 0, 1);
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
    case 'anillo': {
      const f = estado.fin;
      f.angulos[g.i] += (g.objetivo - f.angulos[g.i]) * seguir(14);
      const paso = Math.round(f.angulos[g.i] / PASO_ANILLO);
      if (paso !== g.paso) {
        g.paso = paso;
        sentir('muesca', { tono: 0.75 + 0.12 * g.i }); sonar('anillo', -12, 0.9 + 0.1 * g.i);
        // la voz: al pasar por su sitio, la campanilla de la boca suena
        if (g.i === 2 && enSitio(f, 2, paso * PASO_ANILLO)) avisarVoz();
      }
      break;
    }
    case 'llaveHija': {
      const f = estado.fin;
      f.giroHija += (g.objetivo - f.giroHija) * seguir(12);
      const paso = Math.round(f.giroHija / (PASO_ANILLO / 2));
      if (paso !== g.paso) { g.paso = paso; sentir('muesca', { tono: 0.7 }); }
      break;
    }
    case 'tetera': {
      // pesa: va detrás del dedo, despacio
      tetera3.inclinacion += (g.objetivo - tetera3.inclinacion) * seguir(5);
      if (tec.inclinarTetera) tec.inclinarTetera(tetera3.inclinacion);
      break;
    }
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
    case 'anillo': {
      const f = estado.fin, i = g.i, desde = f.angulos[i], final = Math.round(desde / PASO_ANILLO) * PASO_ANILLO;
      animar(0.18, k => { f.angulos[i] = mezclar(desde, final, suave(k)); }, () => {
        f.angulos[i] = final;
        if (!cancelado && enSitio(f, i)) bloquearAnillo(i);
        else sentir('tope', { db: -10, tono: 0.9, sinVibrar: true });
      });
      break;
    }
    case 'llaveHija': {
      const f = estado.fin, desde = f.giroHija;
      animar(0.3, k => { f.giroHija = desde * (1 - suave(k)); });
      if (!cancelado) mensaje(primeraVez('girar-hija') ? 'Gírala más: un cuarto de vuelta, como una llave.' : 'Más.');
      break;
    }
    case 'detras5': {
      const a = anim5(g.id);
      a.agarrado = false;
      const final = a.k + limitar(a.v, -6, 6) * 0.12;
      if (!cancelado && final > 0.5) { if (estado.n5.cajones[g.id] !== 'abierto' || g.id === 'm1' && estado.n5.m1 === 'fuera') abrirDetras(g.id); else a.objetivo = 1; }
      else cerrarDetras(g.id);
      if (g.id === 'm1' && final > 0.5) estado.n5.m1 = 'dentro';
      break;
    }
    case 'shoji6': {
      const n6 = estado.n6;
      if (noche.shoji < 0.08) { noche.shoji = n6.shoji = 0; sentir('tope', { db: -8, tono: 0.9 }); }
      if (noche.shoji > 0.3) {
        sonar('viento', -12, 0.95);
        if (g.k0 <= 0.3) mensaje(primeraVez('shoji-abierto') ? 'Entra el aire de la noche, a ráfagas.' : 'Entra el viento.', 3);
      } else if (g.k0 > 0.3) mensaje('El shoji, cerrado: ya no entra el viento.', 2.5);
      break;
    }
    case 'puerta6': {
      const n6 = estado.n6, abrir = !cancelado && noche.puerta > 0.5, desde = noche.puerta;
      animar(0.25, k => { noche.puerta = mezclar(desde, abrir ? 1 : 0, suave(k)); });
      if (abrir && n6.puerta !== 'abierta') {
        n6.puerta = 'abierta'; sonar('papel', -8, 1.3); sentir('tope', { db: -10, tono: 1.5 });
        mensaje('La puertecilla se corre: dentro, el platillo de aceite y la mecha, que aún humea.', 4);
      } else if (!abrir && n6.puerta === 'abierta') { n6.puerta = 'cerrada'; sonar('papel', -12, 1.2); }
      break;
    }
    case 'borla5': {
      if (g.parte === 'borla' && borla5.objetivoBajada < 0.92) {
        borla5.objetivoBajada = 0;
        if (!cancelado && estado.n5.lazo === 'suelto') mensaje(primeraVez('borla-mas') ? 'Sube otra vez. Tira más, hasta abajo del todo.' : 'Hasta abajo.', 3);
      }
      break;
    }
    case 'zocalo': {
      const a = cajonAnim.zocalo, n4 = estado.n4;
      a.agarrado = false;
      const final = a.k + limitar(a.v, -6, 6) * 0.12;
      if (!cancelado && final > 0.5) { if (n4.zocalo !== 'abierto') abrirZocalo(); else a.objetivo = 1; }
      else {
        n4.zocalo = 'suelto'; a.objetivo = 0.14;
        if (a.k > 0.2) a.v = Math.min(a.v, -1.2);
      }
      break;
    }
    case 'largo': {
      const a = cajonAnim.largo, n3 = estado.n3;
      a.agarrado = false;
      const final = a.k + limitar(a.v, -6, 6) * 0.12;
      if (!cancelado && final > 0.5) { if (n3.largo !== 'abierto') abrirLargo(); else a.objetivo = 1; }
      else {
        n3.largo = 'suelto'; a.objetivo = 0.12;
        if (a.k > 0.2) a.v = Math.min(a.v, -1.2);
      }
      break;
    }
    case 'tetera': {
      const i0 = tetera3.inclinacion;
      animar(0.5, k => { tetera3.inclinacion = i0 * (1 - curva(k)); if (tec.inclinarTetera) tec.inclinarTetera(tetera3.inclinacion); },
        () => { tetera3.inclinacion = 0; if (tec.inclinarTetera) tec.inclinarTetera(0); if (i0 > 0.1) sentir('tope', { db: -6, tono: 1.7 }); });
      if (!cancelado && i0 < 0.4) mensaje(primeraVez('volcar') ? 'Pesa. Arrastra más hacia abajo, y aguanta, para volcarla.' : 'Más abajo.');
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
  if (estado.fase !== 'jugando' || estado.ocupado || estado.nivel === 2 || estado.nivel === NIVEL_FINAL || enLaNoche()) return;
  sonar('deslizar_madera', -10, 1.1);
  tec.girar();
  // desde la sala o desde el costado de los cajones, la cámara se aparta para ver la caja entera girar
  if (['sala', 'cajones', 'largo', 'cara', 'espalda', 'borla'].includes(estado.vista)) irA('caja');
  setTimeoutReloj(0.45, () => bocanada(EJE_CAJA, 600, 0, -1, 0.5));
}

// (cada hueco de la bandeja; si se lleva más de lo que cabe, pintarInventario añade otro con prepararHueco)
function prepararHueco(hueco) {
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
    // soltado encima de otro objeto de la bandeja: se juntan (si encajan)
    const bajo = document.elementFromPoint(e.clientX, e.clientY), otro = bajo && bajo.closest ? bajo.closest('.hueco') : null;
    if (otro && otro !== hueco && otro.dataset.objeto) { if (estado.seleccion) { estado.seleccion = null; pintarInventario(); } combinar(a.objeto, otro.dataset.objeto); return; }
    const q = posicion(e); q.y -= 30;
    usarObjeto(a.objeto, tec.aPintura(q.x, q.y), q);
  };
  hueco.addEventListener('pointerup', soltar);
  hueco.addEventListener('pointercancel', soltar);
  hueco.addEventListener('keydown', e => { if ((e.key === 'Enter' || e.key === ' ') && hueco.dataset.objeto) { e.preventDefault(); seleccionar(hueco.dataset.objeto); } });
}
huecosBandeja().forEach(prepararHueco);
el.volver.addEventListener('click', () => { if (!estado.ocupado) irA('sala'); });
el.girar.addEventListener('click', () => { desbloquearAudio(); girarCaja(); });
el.pista.addEventListener('click', () => { desbloquearAudio(); if (estado.fase === 'jugando') pista(); });
// ---------------------------------------------------------------------------------------------
// Los menús: el de inicio (la portada), la pausa, los niveles y las opciones; lo que no tiene vuelta atrás (reiniciar
// el nivel, volver al inicio, una partida nueva, salir) se confirma antes
// ---------------------------------------------------------------------------------------------
const puente = window.CajaViva || null;              // en el APK: salir de la app (en el navegador no se puede)
let pausado = false;
function mostrarCapa(capa) { capa.hidden = false; requestAnimationFrame(() => capa.classList.remove('oculta')); }
function ocultarCapa(capa, ms = 350) {
  if (capa.hidden) return;
  capa.classList.add('oculta');
  setTimeout(() => { if (capa.classList.contains('oculta')) capa.hidden = true; }, ms);
}
const capaAbierta = capa => !capa.hidden && !capa.classList.contains('oculta');
// confirmar: una promesa que dice sí o no
let respuesta = null;
function confirmar(texto, { si = 'Sí', detalle = '' } = {}) {
  if (respuesta) responder(false);
  el.confirmarTexto.textContent = texto;
  el.confirmarDetalle.textContent = detalle; el.confirmarDetalle.hidden = !detalle;
  el.confirmarSi.textContent = si;
  mostrarCapa(el.confirmar);
  sonar('papel', -12, 1.1);
  setTimeout(() => el.confirmarNo.focus({ preventScroll: true }), 60);
  return new Promise(ok => { respuesta = ok; });
}
function responder(si) {
  if (!respuesta) return;
  const ok = respuesta; respuesta = null;
  ocultarCapa(el.confirmar, 250);
  ok(si);
}
el.confirmarSi.addEventListener('click', () => responder(true));
el.confirmarNo.addEventListener('click', () => responder(false));

// los ajustes: sonido y vibración (en la pausa y en las opciones de la portada); en pausa, el ambiente baja
const volumenMaestro = () => (audio.mudo ? 0 : pausado ? 0.3 : 0.9);
function pintarAjustes() {
  for (const b of document.querySelectorAll('.interruptor')) {
    const si = !!ajustes[b.dataset.ajuste];
    b.setAttribute('aria-pressed', String(si));
    b.querySelector('b').textContent = si ? 'sí' : 'no';
  }
  audio.mudo = !ajustes.sonido;
  if (audio.maestro) audio.maestro.gain.setTargetAtTime(volumenMaestro(), audio.ctx.currentTime, 0.08);
}
for (const b of document.querySelectorAll('.interruptor')) b.addEventListener('click', () => {
  desbloquearAudio();
  ajustes[b.dataset.ajuste] = !ajustes[b.dataset.ajuste];
  guardarAjustes(); pintarAjustes();
  if (b.dataset.ajuste === 'vibracion' && ajustes.vibracion) vibrar(30);
  if (b.dataset.ajuste === 'sonido' && ajustes.sonido) sonar('toque', -10, 1.2);
});
pintarAjustes();

// la pausa: el juego se para (el reloj del juego no corre: ni la llama se gasta ni la caja se duerme)
function abrirMenu() {
  if (estado.fase === 'portada' || capaAbierta(el.menu)) return;
  desbloquearAudio();
  if (!el.examinar.hidden) cerrarExaminar();
  if (!el.nota.hidden) cerrarNota();
  soltarTodo();
  pausado = true;
  const n = estado.nivel;
  el.menuNivel.textContent = `${nombreNivel(n)} · ${NIVELES[n].titulo}`;
  el.menuReiniciar.hidden = estado.fase !== 'jugando';          // en la tarjeta, el nivel ya está superado
  el.menuSalir.hidden = !puente;
  mostrarCapa(el.menu);
  pintarAjustes();
  sonar('papel', -12, 0.9);
  setTimeout(() => el.menuSeguir.focus({ preventScroll: true }), 60);
}
function cerrarMenu() {
  if (el.menu.hidden) return;
  pausado = false; ultimo = performance.now();
  ocultarCapa(el.menu);
  pintarAjustes();
}
// qué se guarda si se sale ahora (para decirlo en la confirmación)
function textoGuardado() {
  if (estado.fase === 'tarjeta') return 'Tu partida queda guardada.';
  if (estado.nivel >= 2 && estado.nivel < NIVEL_FINAL && hay3D()) return 'Lo que llevas queda guardado: «Seguir» te devuelve aquí.';
  return 'Este nivel empezará otra vez; los niveles superados no se pierden.';
}
el.botonMenu.addEventListener('click', abrirMenu);
el.menuSeguir.addEventListener('click', cerrarMenu);
el.menuReiniciar.addEventListener('click', async () => {
  const n = estado.nivel;
  if (!(await confirmar(`¿Empezar «${NIVELES[n].titulo}» otra vez?`, { si: 'Sí, reiniciar', detalle: 'Lo que llevas de este nivel se pierde.' }))) return;
  borrarEnCurso();
  cerrarMenu();
  reiniciar(n);
});
el.menuInicio.addEventListener('click', async () => {
  if (await confirmar('¿Volver al menú de inicio?', { si: 'Sí, volver', detalle: textoGuardado() })) irAlInicio();
});
el.menuSalir.addEventListener('click', async () => {
  if (await confirmar('¿Salir del juego?', { si: 'Sí, salir', detalle: textoGuardado() })) salirDelJuego();
});
function irAlInicio() { guardarEnCurso(); location.reload(); }
function salirDelJuego() { guardarEnCurso(); try { puente.salir(); } catch (e) { /* nada */ } }

// el menú de inicio: seguir, una partida nueva (la primera vez, «Entrar en la sala»), los niveles, las opciones y salir
let sin3d = false;
function pintarPortada() {
  const progreso = leerProgreso(), superado = progreso ? progreso.superado : 0;
  const con3d = eleccion !== 'A' && !sin3d;
  nivelSeguir = limitar(Math.max(superado + 1, nivelPedido), 1, ULTIMO_NIVEL);
  const seguir = con3d && nivelSeguir >= 2 && (superado < ULTIMO_NIVEL || nivelPedido >= 2);
  el.continuar.hidden = !seguir;
  if (seguir) el.continuar.textContent = `Seguir: ${nombreNivel(nivelSeguir).toLowerCase()} · ${NIVELES[nivelSeguir].titulo}`;
  el.entrar.textContent = superado >= 1 ? 'Nueva partida' : 'Entrar en la sala';
  el.entrar.classList.toggle('secundario', seguir);
  el.botonNiveles.hidden = !(con3d && superado >= 1);
  el.botonSalir.hidden = !puente;
  if (sin3d) el.portadaNota.textContent = 'En este móvil se juega el nivel 1, con la sala pintada.';
}
el.entrar.addEventListener('click', async () => {
  const progreso = leerProgreso();
  if (progreso && progreso.superado >= 1 && !(await confirmar('¿Empezar una partida nueva, desde el nivel 1?',
    { si: 'Sí, empezar', detalle: 'Los niveles superados no se pierden: los puedes volver a elegir en «Niveles».' }))) return;
  entrar(1);
});
el.botonNiveles.addEventListener('click', () => { pintarNiveles(); mostrarCapa(el.niveles); sonar('papel', -12, 1); });
el.nivelesVolver.addEventListener('click', () => ocultarCapa(el.niveles));
el.botonOpciones.addEventListener('click', () => { desbloquearAudio(); pintarAjustes(); mostrarCapa(el.opciones); sonar('papel', -12, 1); });
el.opcionesVolver.addEventListener('click', () => ocultarCapa(el.opciones));
el.botonSalir.addEventListener('click', async () => { if (await confirmar('¿Salir del juego?', { si: 'Sí, salir' })) salirDelJuego(); });
// los niveles: los superados y el siguiente se pueden jugar otra vez; los demás, sin desvelar
const SELLO_NIVEL = { 1: '角', 2: '目', 3: '声', 4: '金', 5: '秘', 6: '灯', 7: '箱' };
function pintarNiveles() {
  const progreso = leerProgreso(), abierto = limitar((progreso ? progreso.superado : 0) + 1, 1, ULTIMO_NIVEL);
  el.listaNiveles.textContent = '';
  for (let n = 1; n <= ULTIMO_NIVEL; n++) {
    const li = document.createElement('li'), b = document.createElement('button');
    b.type = 'button';
    const libre = n <= abierto, hecho = progreso && n <= progreso.superado;
    b.disabled = !libre;
    b.innerHTML = `<b aria-hidden="true">${libre ? SELLO_NIVEL[n] : ''}</b><span></span><small></small>`;
    b.querySelector('span').textContent = `${nombreNivel(n)} · ${libre ? NIVELES[n].titulo : '· · ·'}`;
    b.querySelector('small').textContent = hecho ? 'superado' : libre ? 'siguiente' : '';
    b.setAttribute('aria-label', libre ? `${nombreNivel(n)}, ${NIVELES[n].titulo}${hecho ? ', superado' : ''}` : `${nombreNivel(n)}, todavía cerrado`);
    if (libre) b.addEventListener('click', () => { ocultarCapa(el.niveles); entrar(n); });
    li.appendChild(b); el.listaNiveles.appendChild(li);
  }
}
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
        decoracion: { sombrasBambu, rollo, ROLLO, VENTANAS }, recortarTe, nivel2, nivel4, nivel5, borla: () => estadoBorla(),
        recortarTetera: (l, dx = 0, dy = 0) => recortarTe(l, dx, dy, true),
        // nivel final: dónde alumbra el ojo nuevo en el corazón (lo que tocas) y con cuánta fuerza
        luzCorazon: () => { const f = estado.fin; return f && f.luz && reloj < f.luz.hasta ? { alfa: f.luz.alfa, fuerza: luzFria.fuerza * (1 - ojo2.cerrado) } : null; },
        // (en el nivel 3 respira más hondo: se ve cuándo suelta el aire)
        estado: () => estado, reloj: () => reloj, aliento: () => aliento.valor * (estado.nivel === 3 ? 1.7 : 1), despertar, alHornear,
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
async function entrar(nivel = 1, seguir = false) {
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
  // seguir una partida (o «?nivel=N»): la caja como quedó al terminar el nivel anterior
  const enCurso = seguir && nivel >= 2 && hay3D() ? leerEnCurso(nivel) : null;
  if (enCurso && restaurar(enCurso)) {
    estado.fase = 'jugando';
    for (const [id, st] of Object.entries(estado.cajones)) if (cajonAnim[id]) cajonAnim[id].k = cajonAnim[id].objetivo = st === 'abierto' ? 1 : 0;
    if (tec.ponerHija && estado.hija) tec.ponerHija(estado.hija);
    if (enLaNoche()) bucle('noche', -11, 2);
    pintarInventario();
    await esperar(1.6);
    mensaje('Sigues donde lo dejaste.', 3);
    return;
  }
  if (nivel >= 2 && hay3D()) {
    estadoTrasNivel1();
    if (nivel >= 3) estadoTrasNivel2();
    if (nivel >= 4) estadoTrasNivel3();
    if (nivel >= 5) estadoTrasNivel4();
    if (nivel >= 6) estadoTrasNivel5();
    if (nivel >= 7) estadoTrasNivel6();
    estado.ocupado = true; el.girar.hidden = true;      // mientras se prepara, ni girar ni pistas del nivel 1
    await esperar(1.2);
    estado.ocupado = false;
    if (nivel === 2) empezarNivel2();
    else if (nivel === 3) empezarNivel3();
    else if (nivel === 4) empezarNivel4();
    else if (nivel === 5) empezarNivel5();
    else if (nivel === 6) empezarNivel6();
    else empezarFinal();
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
  if (estado.vista === 'sala') mensaje('Toca la caja para acercarte. Deslízala de lado para girarla, o hacia abajo para verla por encima. Pellizca para acercar.', 6);
}
function reiniciar(nivel = 1) {
  estado = estadoInicial();
  // lo del nivel 3: la luz, la tetera, el papel, los objetos y la nota del principio
  luzFria.guiadaHasta = 0; luzFria.fuerza = 0; tetera3.inclinacion = 0; tetera3.vertido = 0; tetera3.chorro = 0;
  if (tec && tec.inclinarTetera) tec.inclinarTetera(0);
  notaSale = 0; labiosTiemblan = 0;
  oroBorde = 0; cantar4.hasta = 0; esquirlaCae.activa = false; olas4.hundida = [0, 0, 0]; olas4.brillo = [0, 0, 0];
  pedazoEnBoca = null; mano4.herramienta = null; mano4.motas.length = 0;
  Object.assign(borla5, { desatado: 0, aprieto: 0, bajada: 0, objetivoBajada: 0, vBajada: 0, meneo: 0, vMeneo: 0 });
  Object.assign(sueno, { nivel: 0, dormida: false, avisado: false }); pararBucle('ronquido', 0.3);
  Object.assign(noche, { oscuridad: 0, brasa: BRASA_BASE, shoji: 0, puerta: 0, tinta: 0, proximaRafaga: 0, humo: null });
  luzFria.punto = null;
  ponerLlamaEnBandeja(false);
  for (const t of Object.values(TINTAS)) { t.vis = 0; t.acum = 0; }
  if (img.ficha_peon) { img.ficha = img.ficha_peon; OBJETOS.ficha.icono = OBJETOS.ficha.iconoPeon; ponerCampanillaCompleta(false); }
  ponerTextoNota(1);
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
let nivelSeguir = 2;
el.continuar.addEventListener('click', () => entrar(nivelSeguir, true));
el.otra.addEventListener('click', () => reiniciar(1));
// el paso al nivel siguiente desde la tarjeta
function siguienteNivel() {
  const n = estado.nivel + 1;
  if (n === 2) empezarNivel2();
  else if (n === 3) empezarNivel3();
  else if (n === 4) empezarNivel4();
  else if (n === 5) empezarNivel5();
  else if (n === 6) empezarNivel6();
  else if (n === NIVEL_FINAL) empezarFinal();
}
el.seguir.addEventListener('click', () => { desbloquearAudio(); siguienteNivel(); });
el.quedarse.addEventListener('click', () => {
  ocultarTarjeta();
  estado.fase = 'jugando';
  el.volver.hidden = estado.vista === 'sala';
  mensaje(estado.nivel >= ULTIMO_NIVEL ? 'La caja respira tranquila. Puedes quedarte con ella todo lo que quieras.' : 'La caja te mira.', 4);
});

// Si la página se actualiza con alguien jugando, conserva por dónde iba
function restaurar(guardado) {
  if (!guardado || !guardado.estado || guardado.estado.fase === 'portada') return false;
  const g = guardado.estado;
  estado = { ...estadoInicial(), ...g, ocupado: false, seleccion: null, vista: 'sala' };
  if (estado.fase === 'despertar' || estado.fase === 'fin' || estado.fase === 'tarjeta') estado.fase = estado.nivel >= 2 ? 'jugando' : 'fin';
  if (estado.tapa === 'abierta') estado.tapaEnMesa = true;
  if (estado.llave === 'cerradura') llaveGirando = { t: 0, sentido: -1, desvanece: 0 };
  tapaVuelo = estado.tapa === 'suelta' ? tapaSuelta() : null;
  if (estado.nivel >= 2 && estado.hija) {
    if (estado.hija.fase === 'subiendo') estado.hija.fase = 'mesa';
    Object.assign(despertar, { ojos: 0, humo: 0, trampilla: estado.nivel === 2 ? 1 : 0, oscuridad: 0.16 });
    lampara.apagada = 0.1;
    if (estado.hija.ojo === 'puesto') Object.assign(ojo2, { visible: 1, parpadoBase: 0, cerrado: 0 });
    // nivel 3: los objetos y el cajón largo como estaban
    const n3 = estado.n3;
    if (estado.nivel >= 3 && n3) {
      if (n3.ficha === 'cayendo') n3.ficha = 'suelo';
      fichaCae.x = FICHA_SUELO.x; fichaCae.y = FICHA_SUELO.y; fichaCae.ang = 0;
      notaSale = 1;
      cajonAnim.largo.k = cajonAnim.largo.objetivo = n3.largo === 'abierto' ? 1 : n3.largo === 'suelto' ? 0.12 : 0;
      if (n3.nota === 'mano') ponerTextoNota(3);
      if (img.ficha_peon) { ponerCaraFicha(n3.fichaCara); ponerCampanillaCompleta(n3.completa); }
    }
    // nivel 4: lo que estaba a medias
    const n4 = estado.n4;
    if (estado.nivel >= 4 && n4) {
      if (n4.esquirlas[0] === 'cayendo') n4.esquirlas[0] = 'peana';
      if (n4.esquirlas[0] === 'peana') Object.assign(esquirlaCae, { x: ESQUIRLA_PEANA.x + 3, y: ESQUIRLA_PEANA.y, ang: 6.3, activa: true });
      cajonAnim.zocalo.k = cajonAnim.zocalo.objetivo = estado.nivel > 4 ? 0 : n4.zocalo === 'abierto' ? 1 : n4.zocalo === 'suelto' ? 0.14 : 0;
      if (n4.pieza === 'puesta') oroBorde = 1;
      ponerPiezaMejilla();
    }
    // nivel 5: los cajones de la espalda y del costado, y la borla, como estaban (despierta)
    const n5 = estado.n5;
    if (estado.nivel >= 5 && n5) {
      for (const id of [...CAJONES5, 'p']) {
        const a = anim5(id);
        a.k = a.objetivo = n5.cajones[id] === 'abierto' ? 1 : id === 'm1' && n5.m1 === 'fuera' ? M1_FUERA : id === 'p' && n5.p === 'suelto' ? 0.05 : 0;
      }
      for (const [id, st] of Object.entries(estado.cajones)) if (cajonAnim[id]) cajonAnim[id].k = cajonAnim[id].objetivo = st === 'abierto' ? 1 : 0;
      if (estado.nivel === 5 && n5.pasador === 'quitado' && n5.tsukegi === 'c2' && estado.cajones.c2 !== 'abierto') cajonAnim.c2.k = cajonAnim.c2.objetivo = 0.24;
      const suelto = n5.lazo === 'suelto', abajo = n5.borla === 'abajo';
      Object.assign(borla5, { desatado: suelto ? 1 : 0, aprieto: 0, bajada: abajo ? 1 : 0, objetivoBajada: abajo ? 1 : 0, vBajada: 0, meneo: 0, vMeneo: 0 });
      Object.assign(sueno, { nivel: 0, dormida: false, toque: reloj, ruido: reloj });
    }
    // nivel 6: a oscuras (o con la lámpara ya encendida), el shoji y la puertecilla como estaban; la llama no dura
    const n6 = estado.n6;
    if (estado.nivel === 6 && n6) {
      n6.llama = 0;
      noche.shoji = n6.shoji || 0; noche.puerta = n6.puerta === 'abierta' ? 1 : 0;
      if (n6.lampara !== 'encendida') {
        lampara.apagada = 1; noche.oscuridad = 1; noche.proximoVagar = reloj + 2; noche.proximoTemblor = reloj + 6;
        luzFria.punto = { x: 760, y: 640 }; luzFria.guiadaHasta = Infinity;
        if (nivel6) { noche.humo = new Cinta(nivel6.lampara.humo[0], nivel6.lampara.humo[1], { ritmo: 7, vida: 3.4, vel: 10, ancho: 2.4, alfa: 0.2, tinta: 0.06, rizo: 0.9, objeto: 'sala' }); humos.sueltos.push(noche.humo); }
      }
    }
    if (estado.fin && estado.fin.fase === 'subiendo') { estado.fin.subida = 1; estado.fin.fase = 'anillos'; }
    el.girar.hidden = estado.nivel === 2 || estado.nivel === NIVEL_FINAL || enLaNoche(); el.inventario.hidden = false;
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
    const [d, cam, esc, caj, n2, n4, n5, n6, ...imagenes] = await Promise.all([
      fetch('capas/capas.json').then(r => r.json()),
      fetch('capas/camara.json').then(r => r.json()),
      fetch('capas/escena.json').then(r => r.json()),
      fetch('capas/cajones.json').then(r => r.json()),
      fetch('capas/nivel2.json').then(r => r.json()),
      fetch('capas/nivel4.json').then(r => r.json()),
      fetch('capas/nivel5.json').then(r => r.json()),
      fetch('capas/nivel6.json').then(r => r.json()),
      ...[...CAPAS, ...CAPAS_NIVEL2, ...CAPAS_NIVEL4, ...CAPAS_NIVEL5, ...CAPAS_NIVEL6].map(n => new Promise((ok, mal) => {
        const i = new Image();
        i.onload = () => ok(i);
        i.onerror = () => mal(new Error(n));
        i.src = 'capas/' + n + '.webp';
      })),
    ]);
    [...CAPAS, ...CAPAS_NIVEL2, ...CAPAS_NIVEL4, ...CAPAS_NIVEL5, ...CAPAS_NIVEL6].forEach((n, i) => { img[n] = imagenes[i]; });
    datos = d; camaraBoceto = cam; escena3d = esc; cajonesDatos = caj; nivel2 = n2; nivel4 = n4; nivel5 = n5; nivel6 = n6;
    if (datos.caja) CAJA = datos.caja;
  } catch (e) {
    el.cargando.textContent = 'No se pudo cargar la ilustración. Recarga la página.';
    return;
  }
  compuesto.width = ANCHO; compuesto.height = ALTO;
  prepararOjo(); prepararOjoLuna(); prepararMotas(); prepararPuntoLuz(); prepararCapasFijas(); prepararLaca(); prepararDecoracion();
  prepararNivel3();
  prepararNivel4();
  prepararNivel5();
  prepararNivel6();
  pintarInventario();
  const restaurado = restaurar(guardado);
  hornear();
  humoDelIncienso();
  humos.te = [new Cinta(1188, 611, { ritmo: 9, vida: 2.8, vel: 13, ancho: 2.4, alfa: 0.14, tinta: 0.05, rizo: 0.8, objeto: 'te' }),
              new Cinta(1287, 627, { ritmo: 9, vida: 2.6, vel: 12, ancho: 2.2, alfa: 0.12, tinta: 0.05, rizo: 0.8, objeto: 'te' })];
  tecnicaA.activar();
  el.cargando.hidden = true;
  el.entrar.disabled = false; el.entrar.textContent = 'Entrar en la sala';
  // seguir donde se dejó: el nivel siguiente al último superado (o el que se pida con «?nivel=N»)
  pintarPortada();
  if (restaurado) {
    if (eleccion !== 'A' && !(await usarTecnica(eleccion))) await usarTecnica('A');
    if (estado.nivel >= 2 && tec.ponerHija) tec.ponerHija(estado.hija);
    if (estado.fase === 'jugando') bucle('noche', -13, 2);
    if (estado.fase === 'fin' && estado.nivel === 1) terminarNivel(1);
  } else if (eleccion !== 'A') prepararTecnica(eleccion).catch(() => { sin3d = true; pintarPortada(); });   // mientras se mira la portada
}

const caliente = window.claude && window.claude.hot;
if (caliente && caliente.snapshot) caliente.snapshot(() => ({ estado: { ...estado, ocupado: false, seleccion: null }, tecnica: tec.nombre }));
requestAnimationFrame(cuadro);
if (caliente && caliente.ready) caliente.ready(arrancar); else arrancar((caliente && caliente.data) || {});

// En el APK (apk/): el botón «atrás» de Android cierra lo que esté abierto o vuelve a la sala, y devuelve si hizo algo
// (si no, la app pasa a segundo plano); al salir de la app el sonido se para y al volver sigue
window.__atras = () => {
  if (capaAbierta(el.confirmar)) { responder(false); return true; }
  if (capaAbierta(el.niveles)) { ocultarCapa(el.niveles); return true; }
  if (capaAbierta(el.opciones)) { ocultarCapa(el.opciones); return true; }
  if (capaAbierta(el.menu)) { cerrarMenu(); return true; }
  if (!el.examinar.hidden) { cerrarExaminar(); return true; }
  if (!el.nota.hidden) { cerrarNota(); return true; }
  if (estado.fase === 'portada') return false;                     // en el menú de inicio, la app pasa a segundo plano
  if (estado.fase === 'jugando' && !estado.ocupado && estado.vista !== 'sala') { irA('sala'); return true; }
  // en la sala, con la tarjeta o a mitad de una escena: la pausa (nunca se sale de golpe)
  abrirMenu();
  return true;
};
document.addEventListener('keydown', e => { if (e.key === 'Escape' && estado.fase !== 'portada' && el.nota.hidden) window.__atras(); });
// al salir de la app: lo que el dedo tenía agarrado se suelta (si no, un dedo «colgado» haría de cada toque un
// pellizco) y el nivel a medias se guarda
function soltarTodo() {
  if (puntero && puntero.gesto && puntero.gesto.estado) soltarGesto(puntero.gesto, true);
  puntero = null; pellizco = null; punteros.clear();
}
document.addEventListener('visibilitychange', () => { if (document.hidden) { soltarTodo(); guardarEnCurso(); } });
window.__pausa = pausada => {
  if (pausada) { soltarTodo(); guardarEnCurso(); }
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
  mirada: () => (tec.mirada ? tec.mirada() : null), giroCaja: () => (tec.giroCaja ? tec.giroCaja() : 0), enderezarCaja: () => tec.enderezar && tec.enderezar(),
  // ¿el incensario se ve en (x, y) del boceto? (la máscara de su silueta en la técnica B)
  incensarioVisible: (x, y) => (tec.alfaIncensario ? tec.alfaIncensario(x, y) : 1),
  usar: (objeto, x, y, o = 'caja') => { const m = tec.ancla({ x, y }, o); usarObjeto(objeto, tec.aPintura(m.x, m.y), null); },
  // nivel 3: la luz fría y las tintas, el rollo, la respiración, la tetera, el cajón largo y la ficha en la mano
  n3: () => (estado.n3 ? JSON.parse(JSON.stringify(estado.n3)) : null),
  luz: () => ({ x: luzFria.x, y: luzFria.y, fuerza: luzFria.fuerza, guiada: reloj < luzFria.guiadaHasta }),
  luzObjetivo: () => (luzFria.punto ? { ...luzFria.punto } : null),
  espejoLuz: (x, y) => espejoLuz({ x, y }),
  tinta: id => ({ x: TINTAS[id].x, y: TINTAS[id].y, vis: TINTAS[id].vis || 0 }),
  rollo: () => ({ a: rollo.a, v: rollo.v }),
  aliento: () => ({ fase: aliento.fase, valor: aliento.valor, exhalando: exhalando(), soplo: aliento.soplo }),
  tetera: () => ({ ...tetera3 }),
  largo: () => ({ ...cajonAnim.largo }),
  pantallaLargo: k => (tec.pantallaLargo ? tec.pantallaLargo(k) : null),
  fichaGiro: () => ({ giro: fichaGiro.giro, objetivo: fichaGiro.objetivo }),
  labios: () => (estado.n3 ? estado.n3.labios : 0),
  puntoCampanilla: () => { const v = tec.puntoCampanillaLargo && tec.puntoCampanillaLargo(), m = v ? tec.ancla(v) : null; return m ? { x: m.x, y: m.y } : null; },
  // nivel final: el corazón (sus anillos y dónde va cada uno) y dónde está en la pantalla un punto suyo
  fin: () => (estado.fin ? JSON.parse(JSON.stringify(estado.fin)) : null),
  enSitio: i => !!(estado.fin && enSitio(estado.fin, i)),
  sitioAnillo: i => (estado.fin ? sitioAnillo(estado.fin, i) : 0),
  puntoCorazon: (r, alfa) => (tec.corazonEnPantalla ? tec.corazonEnPantalla(r, alfa) : null),
  // nivel 4: su estado, dónde están las cosas en la pantalla, si canta, y la mano (dónde está cada esquirla y cada junta,
  // de −1 a 1 en el bolsillo)
  n4: () => (estado.n4 ? JSON.parse(JSON.stringify(estado.n4)) : null),
  nivel4: () => nivel4,
  cantando: () => cantando4(),
  ojoCerrado: () => ojo.cerrado,
  zocalo: () => ({ ...cajonAnim.zocalo }),
  pantallaZocalo: k => (tec.pantallaZocalo ? tec.pantallaZocalo(k) : null),
  puntoZocalo: parte => { const v = tec.puntoZocalo && tec.puntoZocalo(parte), m = v ? tec.ancla(v) : null; return m ? { x: m.x, y: m.y } : null; },
  mano: () => {
    const n4 = estado.n4, W = el.bolsillo.width, s = escalaMano(), aBolsillo = (x, y) => ({ x: (x * s + W / 2) / W * 2 - 1, y: (y * s + W * 0.44) / W * 2 - 1 });
    const c = centroMejilla();
    return {
      esquirlas: n4.montaje.map((m, i) => { const cc = centroDe(esquirlaEnMano(i)); return { ...aBolsillo(cc.x, cc.y), a: m.a, puesta: m.puesta }; }),
      sitios: nivel4.esquirlas.map(p => { const cc = centroDe(relativo(p, c)); return aBolsillo(cc.x, cc.y); }),
      juntas: nivel4.juntas.map(j => muestrear(relativo(j, c), 8).map(([x, y]) => aBolsillo(x, y))),
      herramientas: herramientas4(), herramienta: mano4.herramienta,
    };
  },
  // nivel 5: su estado, el sueño, los cajones de la espalda (dónde está su frente en la pantalla, cerrado y abierto) y la
  // borla (dónde está en la pantalla un punto del costado, en píxeles de capas/cara_izquierda.webp)
  n5: () => (estado.n5 ? JSON.parse(JSON.stringify(estado.n5)) : null),
  nivel5: () => nivel5,
  sueno: () => ({ ...sueno }),
  cajonDetras: id => ({ ...anim5(id) }),
  pantallaDetras: (id, k) => (tec.pantallaDetras ? tec.pantallaDetras(id, k) : null),
  pantallaBorla: (bx, by) => (tec.pantallaBorla ? tec.pantallaBorla(bx, by) : null),
  borla: () => ({ ...borla5 }),
  escalaBorla: () => escalaBorla(),
  ejeCajonLado: id => { const e = ejeCajon(id); return e && e.a && e.b ? { a: { x: e.a.x, y: e.a.y }, b: { x: e.b.x, y: e.b.y } } : null; },
  // nivel 6: su estado, la noche (oscuridad, brasas, shoji, puertecilla, tinta), si un punto del boceto se ve, dónde
  // está el frente de un cajón del costado en el boceto, y si la llama sigue encendida
  n6: () => (estado.n6 ? JSON.parse(JSON.stringify(estado.n6)) : null),
  nivel6: () => nivel6,
  noche: () => ({ oscuridad: noche.oscuridad, brasa: noche.brasa, shoji: noche.shoji, puerta: noche.puerta, tinta: noche.tinta }),
  iluminado: (x, y) => iluminado({ x, y }),
  frenteCajon: id => { const c = frenteCajonEnBoceto(id); return c ? { x: c.x, y: c.y } : null; },
  llama: () => llamaEnMano(),
  lampara: () => ({ apagada: lampara.apagada, intensidad: lampara.intensidad }),
  // la partida guardada: cómo se lee (con las de antes de la 0.7 ya puestas al día) y guardar un nivel superado
  partida: () => leerProgreso(), guardarPartida: n => guardarProgreso(n),
  // los menús y la vitrina 3D
  pausado: () => pausado, vitrina: () => (vitrina ? vitrina.estado() : null), examinar: id => examinar(id),
  enCurso: () => { try { return JSON.parse(localStorage.getItem(CLAVE_EN_CURSO)); } catch (e) { return null; } },
};
window.__tec = () => tec;

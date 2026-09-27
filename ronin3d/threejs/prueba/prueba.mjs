// =============================================================================
// Prueba automática de RONIN 3D · versión Three.js (HD-2D)
//
// 1. Sirve la carpeta del juego con un servidor HTTP local (http.createServer).
// 2. Abre ronin3d.html en Chromium sin ventana, con WebGL por software (SwiftShader).
// 3. Simula teclas y ratón, y comprueba el estado del juego a través de
//    window.estadoJuego (una instantánea congelada, de solo lectura).
// 4. Guarda capturas 1280×720 en ../../capturas/ con el prefijo threejs_.
// 5. Falla si hay errores en la consola o excepciones en la página.
//
// Uso:
//     cd prueba
//     npm install          (instala Playwright; no descarga navegadores si ya hay)
//     node prueba.mjs
//
// Si Chromium no puede conectar con cdn.jsdelivr.net (por ejemplo, detrás de un
// proxy con certificado propio), la prueba sirve los archivos de Three.js a través
// de Node, que sí valida el certificado del proxy. Nunca se desactiva TLS.
// =============================================================================

import { chromium } from 'playwright';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const CARPETA_PRUEBA = path.dirname(fileURLToPath(import.meta.url));
const CARPETA_JUEGO = path.resolve(CARPETA_PRUEBA, '..');
const CARPETA_CAPTURAS = path.resolve(CARPETA_JUEGO, '..', 'capturas');
const ARCHIVO_JUEGO = path.join(CARPETA_JUEGO, 'ronin3d.html');
const ARCHIVO_FUENTE = path.join(CARPETA_JUEGO, 'ronin3d_fuente.html');
const ANCHO = 1280, ALTO = 720;
// Durante los recorridos se usa una ventana más pequeña para que el render por
// software vaya más rápido; las capturas y la medida de FPS se hacen a 1280×720.
const ANCHO_RAPIDO = 640, ALTO_RAPIDO = 360;
const CDN = 'https://cdn.jsdelivr.net/npm/three@0.170.0/';
const ARGUMENTOS_CHROMIUM = [
  '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
  '--ignore-gpu-blocklist', '--enable-webgl',
];

const TEXTOS = {
  intro: 'Castillo de Hoshiyama. Akira sirve como guardia del señor Takeda.',
  cierre: 'Akira cruza la última puerta. El castillo de Hoshiyama queda a su espalda.',
  derrota: 'Levántate, Akira. La noche aún no ha terminado.',
};

const resultados = [];
const errores = [];
const inicioPrueba = Date.now();
let pagina;

// -----------------------------------------------------------------------------
// Utilidades generales
// -----------------------------------------------------------------------------
function registrar(texto) {
  const segundos = ((Date.now() - inicioPrueba) / 1000).toFixed(1).padStart(6);
  console.log(`[${segundos} s] ${texto}`);
}

function comprobar(nombre, correcto, detalle = '') {
  resultados.push({ nombre, correcto: Boolean(correcto), detalle });
  registrar(`${correcto ? 'OK   ' : 'FALLO'} ${nombre}${detalle ? ' — ' + detalle : ''}`);
  return Boolean(correcto);
}

const esperarMs = (ms) => new Promise((r) => setTimeout(r, ms));
const redondear = (v, d = 2) => Math.round(v * 10 ** d) / 10 ** d;
const normalizarAngulo = (a) => ((a % 360) + 540) % 360 - 180;

function crearServidor(raiz) {
  const tipos = {
    '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
    '.mjs': 'text/javascript; charset=utf-8', '.png': 'image/png', '.json': 'application/json',
  };
  return new Promise((resolver) => {
    const servidor = http.createServer((peticion, respuesta) => {
      let ruta = decodeURIComponent(new URL(peticion.url, 'http://localhost').pathname);
      if (ruta === '/favicon.ico') { respuesta.writeHead(204); respuesta.end(); return; }
      if (ruta === '/__sonda') {
        respuesta.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        respuesta.end('<!DOCTYPE html><meta charset="utf-8"><title>sonda</title>');
        return;
      }
      if (ruta === '/') ruta = '/ronin3d.html';
      const archivo = path.join(raiz, path.normalize(ruta));
      if (!archivo.startsWith(raiz)) { respuesta.writeHead(403); respuesta.end(); return; }
      fs.readFile(archivo, (error, datos) => {
        if (error) { respuesta.writeHead(404); respuesta.end('No encontrado'); return; }
        respuesta.writeHead(200, {
          'Content-Type': tipos[path.extname(archivo)] || 'application/octet-stream',
          'Cache-Control': 'no-store',
        });
        respuesta.end(datos);
      });
    });
    servidor.listen(0, '127.0.0.1', () => resolver(servidor));
  });
}

async function lanzarNavegador() {
  try {
    return await chromium.launch({ headless: true, args: ARGUMENTOS_CHROMIUM });
  } catch (error) {
    // La versión de Playwright no coincide con el navegador instalado: se busca uno
    const base = process.env.PLAYWRIGHT_BROWSERS_PATH || '/opt/pw-browsers';
    const carpetas = fs.existsSync(base)
      ? fs.readdirSync(base).filter((n) => n.startsWith('chromium')).sort().reverse() : [];
    for (const carpeta of carpetas) {
      for (const relativo of ['chrome-linux/headless_shell', 'chrome-linux/chrome']) {
        const ejecutable = path.join(base, carpeta, relativo);
        if (!fs.existsSync(ejecutable)) continue;
        try {
          registrar(`Usando el navegador ${ejecutable}`);
          return await chromium.launch({ headless: true, args: ARGUMENTOS_CHROMIUM, executablePath: ejecutable });
        } catch { /* se prueba el siguiente */ }
      }
    }
    throw error;
  }
}

// Comprueba si Chromium llega a la CDN; si no, sirve Three.js desde Node
async function prepararCDN(contexto, urlBase) {
  const sonda = await contexto.newPage();
  await sonda.goto(urlBase + '__sonda');
  const directo = await sonda.evaluate(async (url) => {
    try {
      const r = await fetch(url, { cache: 'no-store' });
      return r.ok;
    } catch {
      return false;
    }
  }, CDN + 'package.json');
  await sonda.close();
  if (directo) return 'directa desde Chromium';
  const cache = new Map();
  await contexto.route('https://cdn.jsdelivr.net/**', async (ruta) => {
    const url = ruta.request().url();
    try {
      if (!cache.has(url)) {
        const r = await fetch(url);
        cache.set(url, {
          estado: r.status,
          cuerpo: Buffer.from(await r.arrayBuffer()),
          tipo: r.headers.get('content-type') || 'text/javascript; charset=utf-8',
        });
      }
      const c = cache.get(url);
      await ruta.fulfill({
        status: c.estado, body: c.cuerpo,
        headers: { 'content-type': c.tipo, 'access-control-allow-origin': '*' },
      });
    } catch {
      await ruta.abort();
    }
  });
  return 'a través de Node (Chromium no confía en el certificado del proxy de este entorno)';
}

// -----------------------------------------------------------------------------
// Utilidades sobre la página del juego
// -----------------------------------------------------------------------------
const leerEstado = () => pagina.evaluate(() => window.estadoJuego);

async function esperarEstado(condicion, { tiempo = 60000, descripcion = 'condición' } = {}) {
  const limite = Date.now() + tiempo;
  let ultimo = null;
  while (Date.now() < limite) {
    ultimo = await leerEstado();
    if (ultimo && condicion(ultimo)) return ultimo;
    await esperarMs(120);
  }
  throw new Error(`Tiempo agotado esperando: ${descripcion} (escena: ${ultimo && ultimo.escena})`);
}

async function esperarFotogramas(cantidad) {
  const inicial = (await leerEstado()).fotogramas;
  await esperarEstado((e) => e.fotogramas >= inicial + cantidad, { tiempo: 30000, descripcion: `${cantidad} fotogramas` });
}

async function usarVentana(ancho, alto) {
  const actual = pagina.viewportSize();
  if (actual.width === ancho && actual.height === alto) return;
  await pagina.setViewportSize({ width: ancho, height: alto });
  await esperarFotogramas(2);
}

async function capturar(nombre) {
  await usarVentana(ANCHO, ALTO);
  await esperarFotogramas(2);
  const ruta = path.join(CARPETA_CAPTURAS, nombre);
  await pagina.screenshot({ path: ruta });
  registrar(`Captura guardada: ${ruta}`);
  return ruta;
}

async function mantener(teclas, ms) {
  for (const t of teclas) await pagina.keyboard.down(t);
  await esperarMs(ms);
  for (const t of [...teclas].reverse()) await pagina.keyboard.up(t);
}

async function pulsar(tecla) {
  await pagina.keyboard.press(tecla);
}

// Teclas WASD que llevan hacia una dirección del mundo, con la cámara en «giro»
function teclasHacia(dx, dz, giroGrados) {
  const g = giroGrados * Math.PI / 180;
  const adelante = dx * -Math.sin(g) + dz * -Math.cos(g);
  const derecha = dx * Math.cos(g) + dz * -Math.sin(g);
  const umbral = Math.sin(22.5 * Math.PI / 180);
  const teclas = new Set();
  if (adelante > umbral) teclas.add('KeyW'); else if (adelante < -umbral) teclas.add('KeyS');
  if (derecha > umbral) teclas.add('KeyD'); else if (derecha < -umbral) teclas.add('KeyA');
  return teclas;
}

// Mantiene pulsadas exactamente las teclas del conjunto indicado
let teclasPulsadas = new Set();
async function fijarTeclas(deseadas) {
  for (const t of [...teclasPulsadas]) if (!deseadas.has(t)) await pagina.keyboard.up(t);
  for (const t of deseadas) if (!teclasPulsadas.has(t)) await pagina.keyboard.down(t);
  teclasPulsadas = new Set(deseadas);
}
const soltarTodo = () => fijarTeclas(new Set());

// Lleva a Akira hasta (x, z) con un bucle cerrado sobre el estado del juego
async function irHacia(x, z, { tolerancia = 0.8, correr = false, tiempo = 30000, parar = null } = {}) {
  const limite = Date.now() + tiempo;
  let e = await leerEstado();
  while (Date.now() < limite) {
    e = await leerEstado();
    if (e.escena !== 'patio' || (parar && parar(e))) break;
    const dx = x - e.akira.x, dz = z - e.akira.z;
    const d = Math.hypot(dx, dz);
    if (d <= tolerancia) break;
    const teclas = teclasHacia(dx / d, dz / d, e.camara.giro);
    if (correr && d > 2) teclas.add('Shift');
    await fijarTeclas(teclas);
    await esperarMs(90);
  }
  await soltarTodo();
  return leerEstado();
}

async function girarCamaraA(objetivo, tolerancia = 5) {
  for (let i = 0; i < 60; i++) {
    const e = await leerEstado();
    const diferencia = normalizarAngulo(objetivo - e.camara.giro);
    if (Math.abs(diferencia) <= tolerancia) return e;
    const tecla = diferencia > 0 ? 'KeyQ' : 'KeyE';          // Q aumenta el giro, E lo reduce
    await mantener([tecla], Math.min(700, Math.max(120, Math.abs(diferencia) / 90 * 1000 * 0.7)));
    await esperarMs(100);
  }
  return leerEstado();
}

async function inclinarCamaraA(objetivo, tolerancia = 2) {
  for (let i = 0; i < 60; i++) {
    const e = await leerEstado();
    const diferencia = objetivo - e.camara.inclinacion;
    if (Math.abs(diferencia) <= tolerancia) return e;
    const tecla = diferencia > 0 ? 'KeyR' : 'KeyF';
    await mantener([tecla], Math.min(700, Math.max(120, Math.abs(diferencia) / 45 * 1000 * 0.7)));
    await esperarMs(100);
  }
  return leerEstado();
}

async function acercarCamaraA(objetivo, tolerancia = 0.6) {
  for (let i = 0; i < 40; i++) {
    const e = await leerEstado();
    const diferencia = objetivo - e.camara.distancia;
    if (Math.abs(diferencia) <= tolerancia) return e;
    await mantener([diferencia > 0 ? '-' : '+'], Math.min(600, Math.max(100, Math.abs(diferencia) / 9 * 1000 * 0.7)));
    await esperarMs(100);
  }
  return leerEstado();
}

function soldadoMasCercano(e, soloVivos = true, soloEnElSuelo = false) {
  let mejor = null, distancia = Infinity;
  for (const s of e.soldados) {
    if (soloVivos && (s.vida <= 0 || s.estado === 'muerto')) continue;
    if (soloEnElSuelo && s.y > 0.5) continue;
    const d = Math.hypot(s.x - e.akira.x, s.z - e.akira.z);
    if (d < distancia) { distancia = d; mejor = s; }
  }
  return { soldado: mejor, distancia };
}

async function avisosVisiblesEnPantalla() {
  return pagina.evaluate(() => [...document.querySelectorAll('.aviso')]
    .filter((a) => a.style.display === 'block').length);
}

async function textoDelPanel() {
  return pagina.evaluate(() => document.getElementById('panelTexto').innerText);
}

async function continuarTexto() {
  // Primer ENTER: completa el texto; segundo ENTER: continúa
  let e = await leerEstado();
  if (e.texto && !e.texto.completo) {
    await pulsar('Enter');
    e = await esperarEstado((x) => !x.texto || x.texto.completo, { tiempo: 20000, descripcion: 'texto completo' });
  }
  const escenaAntes = e.escena;
  await pulsar('Enter');
  return esperarEstado((x) => x.escena !== escenaAntes, { tiempo: 20000, descripcion: 'cambio de escena' });
}

async function medirFPS(segundos) {
  const inicio = await pagina.evaluate(() => [window.estadoJuego.fotogramas, performance.now()]);
  await esperarMs(segundos * 1000);
  const fin = await pagina.evaluate(() => [window.estadoJuego.fotogramas, performance.now()]);
  return (fin[0] - inicio[0]) / ((fin[1] - inicio[1]) / 1000);
}

// -----------------------------------------------------------------------------
// Fases de la prueba
// -----------------------------------------------------------------------------
async function faseIntro() {
  await esperarEstado((e) => e.listo && e.escena === 'intro', { tiempo: 120000, descripcion: 'juego listo en la intro' });
  const e = await leerEstado();
  comprobar('Arranca en la introducción', e.escena === 'intro' && e.texto && e.texto.titulo === 'RONIN',
    `título «${e.texto && e.texto.titulo}»`);
  comprobar('Post-proceso (bloom + maqueta) activo', e.postproceso.activo && e.postproceso.bloom && e.postproceso.maqueta,
    e.postproceso.motivo || 'UnrealBloomPass + desenfoque arriba/abajo + viñeta');
  comprobar('Cámara de presentación durante la intro', e.camara.modo === 'presentacion',
    `cámara en (${e.camara.x}, ${e.camara.y}, ${e.camara.z})`);
  // Deja escribir el texto un momento y luego lo completa con ENTER
  await esperarMs(1500);
  await pulsar('Enter');
  await esperarEstado((x) => x.texto && x.texto.completo, { tiempo: 20000, descripcion: 'texto de la intro completo' });
  const texto = await textoDelPanel();
  comprobar('Texto de la intro copiado de samurai.py', texto.includes(TEXTOS.intro) && texto.includes('Genzo'));
  await capturar('threejs_intro.png');
}

async function fasePatio() {
  await pulsar('Enter');
  let e = await esperarEstado((x) => x.escena === 'patio', { tiempo: 20000, descripcion: 'entrar al patio' });
  comprobar('ENTER pasa de la intro al patio', e.escena === 'patio');
  comprobar('Transición suave de la presentación a la órbita', ['transicion', 'orbita'].includes(e.camara.modo), e.camara.modo);
  e = await esperarEstado((x) => x.camara.modo === 'orbita', { tiempo: 20000, descripcion: 'cámara en órbita' });
  comprobar('Akira empieza en (−20, 0, 0) con 5 de vida', Math.hypot(e.akira.x + 20, e.akira.z) < 0.05 && e.akira.vida === 5,
    `(${e.akira.x}, ${e.akira.y}, ${e.akira.z}), vida ${e.akira.vida}`);
  comprobar('Cámara por defecto: d 12, inclinación 38°, giro −60°, FOV 38', e.camara.distancia === 12 &&
    e.camara.inclinacion === 38 && e.camara.giro === -60 && e.camara.fov === 38,
    `d ${e.camara.distancia} (efectiva ${e.camara.distanciaEfectiva}), incl ${e.camara.inclinacion}, giro ${e.camara.giro}, fov ${e.camara.fov}`);
  comprobar('Akira se ve de espaldas al empezar (mira al este)', e.akira.sprite.fila === 1, `fila ${e.akira.sprite.fila}`);
  comprobar('HUD: ayuda visible al empezar', e.ayudaVisible);
  const hudTexto = await pagina.evaluate(() => [document.getElementById('hudVida').innerText,
    document.getElementById('hudDerrotados').innerText, document.querySelectorAll('.rombo:not(.vacio)').length,
    document.getElementById('hudMotor').innerText]);
  comprobar('HUD: AKIRA con 5 rombos, «Soldados derrotados: 0/6» y el motor', hudTexto[0].includes('AKIRA') &&
    hudTexto[2] === 5 && hudTexto[1].replace(/\s+/g, ' ').includes('Soldados derrotados: 0/6') && hudTexto[3] === 'Three.js · HD-2D',
    `${hudTexto[1].replace(/\s+/g, ' ')} · rombos ${hudTexto[2]} · «${hudTexto[3]}»`);
  await esperarMs(800);
  await capturar('threejs_patio.png');
  const fps = await medirFPS(6);
  registrar(`FPS a 1280×720 (render por software): ${fps.toFixed(2)}`);
  return fps;
}

async function faseTorreon() {
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  // Cámara baja mirando al norte: se ven el muro norte, el torreón y la luna
  await girarCamaraA(-8, 3);
  let e = await inclinarCamaraA(-5, 0.6);
  e = await esperarEstado((x) => x.camara.inclinacion <= -4.4, { tiempo: 5000, descripcion: 'cámara baja' })
    .catch(() => leerEstado());
  comprobar('La inclinación baja hasta −5° (mira un poco hacia arriba)', e.camara.inclinacion <= -4.4 && e.camara.inclinacion >= -5.01,
    `inclinación ${e.camara.inclinacion}°, cámara a ${e.camara.y} m de altura`);
  await esperarMs(600);
  await capturar('threejs_torreon.png');
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  await inclinarCamaraA(38, 1.5);
  await girarCamaraA(-60, 3);
}

async function faseMovimiento() {
  // Caminar (D: a la derecha de la cámara)
  let e0 = await leerEstado();
  const g = e0.camara.giro * Math.PI / 180;
  let velocidadMaxima = 0;
  await pagina.keyboard.down('KeyD');
  const finCaminar = Date.now() + 1000;
  while (Date.now() < finCaminar) {
    const e = await leerEstado();
    velocidadMaxima = Math.max(velocidadMaxima, e.akira.velocidad);
    await esperarMs(80);
  }
  await pagina.keyboard.up('KeyD');
  await esperarMs(400);
  let e1 = await leerEstado();
  const dx = e1.akira.x - e0.akira.x, dz = e1.akira.z - e0.akira.z;
  const recorrido = Math.hypot(dx, dz);
  const alineacion = recorrido > 0 ? (dx * Math.cos(g) + dz * -Math.sin(g)) / recorrido : 0;
  comprobar('Akira se mueve (WASD relativo a la cámara)', recorrido > 1.5 && alineacion > 0.9,
    `recorrió ${redondear(recorrido)} m; alineación con la derecha de la cámara ${redondear(alineacion)}`);
  comprobar('Velocidad al caminar ≈ 5 m/s', velocidadMaxima > 4.6 && velocidadMaxima < 5.4, `${redondear(velocidadMaxima)} m/s`);

  // Correr (SHIFT + A)
  e0 = await leerEstado();
  velocidadMaxima = 0;
  await pagina.keyboard.down('Shift');
  await pagina.keyboard.down('KeyA');
  const finCorrer = Date.now() + 1000;
  while (Date.now() < finCorrer) {
    const e = await leerEstado();
    velocidadMaxima = Math.max(velocidadMaxima, e.akira.velocidad);
    await esperarMs(80);
  }
  await pagina.keyboard.up('KeyA');
  await pagina.keyboard.up('Shift');
  await esperarMs(400);
  e1 = await leerEstado();
  comprobar('Correr con SHIFT ≈ 8 m/s', velocidadMaxima > 7.4 && velocidadMaxima < 8.6,
    `${redondear(velocidadMaxima)} m/s; recorrió ${redondear(Math.hypot(e1.akira.x - e0.akira.x, e1.akira.z - e0.akira.z))} m`);

  // Saltar
  e0 = await leerEstado();
  let alturaMaxima = 0;
  await pulsar('Space');
  const finSalto = Date.now() + 2500;
  while (Date.now() < finSalto) {
    const e = await leerEstado();
    alturaMaxima = Math.max(alturaMaxima, e.akira.y, e.akira.alturaMaxima);
    await esperarMs(60);
  }
  e1 = await leerEstado();
  comprobar('Salto con ESPACIO (sube ~1,28 m y vuelve al suelo)', e1.akira.saltos === e0.akira.saltos + 1 &&
    alturaMaxima > 1.15 && alturaMaxima < 1.4 && e1.akira.enSuelo && e1.akira.y < 0.01,
    `altura máxima ${redondear(alturaMaxima)} m`);
}

async function faseCamara() {
  let e0 = await leerEstado();
  await mantener(['KeyQ'], 1200);
  await esperarMs(300);
  let e1 = await leerEstado();
  const giroQ = normalizarAngulo(e1.camara.giro - e0.camara.giro);
  comprobar('Q gira la cámara', giroQ > 30, `giro ${e0.camara.giro}° → ${e1.camara.giro}° (${redondear(giroQ)}°)`);
  await capturar('threejs_camara_girada.png');
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  e0 = await leerEstado();
  await mantener(['KeyE'], 800);
  await esperarMs(300);
  e1 = await leerEstado();
  const giroE = normalizarAngulo(e1.camara.giro - e0.camara.giro);
  comprobar('E gira la cámara al otro lado', giroE < -20, `${redondear(giroE)}°`);

  // Zoom con + / − y con la rueda
  e0 = await leerEstado();
  await mantener(['-'], 500);
  await esperarMs(250);
  e1 = await leerEstado();
  const alejar = e1.camara.distancia - e0.camara.distancia;
  await mantener(['+'], 900);
  await esperarMs(250);
  const e2 = await leerEstado();
  const acercar = e2.camara.distancia - e1.camara.distancia;
  await pagina.mouse.move(ANCHO_RAPIDO / 2, ALTO_RAPIDO / 2);
  await pagina.mouse.wheel(0, 400);
  await esperarMs(400);
  const e3 = await leerEstado();
  const rueda = e3.camara.distancia - e2.camara.distancia;
  comprobar('Zoom con − / + y con la rueda (entre 7 y 18 m)', alejar > 0.5 && acercar < -0.5 && rueda > 0.5 &&
    e2.camara.distancia >= 7 && e3.camara.distancia <= 18,
    `−: ${redondear(alejar)} m, +: ${redondear(acercar)} m, rueda: ${redondear(rueda)} m (d = ${e3.camara.distancia})`);

  // Inclinar con R / F
  e0 = await leerEstado();
  await mantener(['KeyF'], 500);
  await esperarMs(250);
  e1 = await leerEstado();
  await mantener(['KeyR'], 2500);
  await esperarMs(250);
  const e4 = await leerEstado();
  comprobar('R / F inclinan la cámara (tope 60°)', e1.camara.inclinacion < e0.camara.inclinacion &&
    e4.camara.inclinacion > e1.camara.inclinacion && e4.camara.inclinacion <= 60,
    `${e0.camara.inclinacion}° → F ${e1.camara.inclinacion}° → R ${e4.camara.inclinacion}°`);

  // Botón derecho + arrastrar
  e0 = await leerEstado();
  await pagina.mouse.move(300, 180);
  await pagina.mouse.down({ button: 'right' });
  await pagina.mouse.move(400, 160, { steps: 6 });
  await pagina.mouse.up({ button: 'right' });
  await esperarMs(300);
  e1 = await leerEstado();
  comprobar('Botón derecho + arrastrar gira e inclina', Math.abs(normalizarAngulo(e1.camara.giro - e0.camara.giro)) > 10 &&
    e1.camara.inclinacion < e0.camara.inclinacion,
    `giro ${e0.camara.giro}° → ${e1.camara.giro}°, inclinación ${e0.camara.inclinacion}° → ${e1.camara.inclinacion}°`);

  // Deja la cámara como al principio
  await inclinarCamaraA(38, 1.5);
  await acercarCamaraA(12, 0.6);
  await girarCamaraA(-60, 3);
}

async function faseMuro() {
  // Empuja hacia el oeste contra el muro (su cara interior está en x = −24)
  let minimoX = Infinity, e = await leerEstado();
  const limite = Date.now() + 4000;
  while (Date.now() < limite) {
    e = await leerEstado();
    minimoX = Math.min(minimoX, e.akira.x);
    await fijarTeclas(teclasHacia(-1, 0, e.camara.giro));
    await esperarMs(90);
  }
  await soltarTodo();
  e = await leerEstado();
  minimoX = Math.min(minimoX, e.akira.x);
  comprobar('Akira no atraviesa el muro oeste', minimoX >= -24 + 0.35 - 0.02 && e.akira.x < -23.3,
    `x mínima ${minimoX} (cara del muro en −24, radio 0,35)`);

  // Y contra el muro norte, por detrás de los barriles (cara interior en z = −16)
  await irHacia(-21.5, -12, { correr: true, tiempo: 15000 });
  let minimoZ = Infinity;
  const limite2 = Date.now() + 3500;
  while (Date.now() < limite2) {
    e = await leerEstado();
    minimoZ = Math.min(minimoZ, e.akira.z);
    await fijarTeclas(teclasHacia(0, -1, e.camara.giro));
    await esperarMs(90);
  }
  await soltarTodo();
  e = await leerEstado();
  minimoZ = Math.min(minimoZ, e.akira.z);
  comprobar('Akira no atraviesa el muro norte', minimoZ >= -16 + 0.35 - 0.02 && e.akira.z < -15.3,
    `z mínima ${minimoZ} (cara del muro en −16)`);
}

async function faseCombate() {
  // Busca al soldado 1 (patrulla en x = −14) y lo ataca con J hasta herirlo
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  let e = await leerEstado();
  const indice = 1;
  const vidaInicial = e.soldados[indice - 1].vida;
  let capturado = false, estadoCaptura = null;
  let ataques = 0;
  const limite = Date.now() + 90000;
  while (Date.now() < limite) {
    e = await leerEstado();
    if (e.escena !== 'patio') break;
    const s = e.soldados[indice - 1];
    if (s.vida < vidaInicial && capturado) break;
    const dx = s.x - e.akira.x, dz = s.z - e.akira.z;
    const d = Math.hypot(dx, dz);
    // La captura de combate se hace a 1280×720: se cambia de tamaño al acercarse
    if (!capturado) await usarVentana(d < 4.5 ? ANCHO : ANCHO_RAPIDO, d < 4.5 ? ALTO : ALTO_RAPIDO);
    if (d > 1.3) {
      const teclas = teclasHacia(dx / d, dz / d, e.camara.giro);
      if (d > 5) teclas.add('Shift');
      await fijarTeclas(teclas);
      await esperarMs(80);
      continue;
    }
    // Cerca: gira hacia él con un toque y ataca
    const mira = (dx * e.akira.mirarX + dz * e.akira.mirarZ) / Math.max(d, 1e-3);
    if (mira < 0.7) {
      await fijarTeclas(teclasHacia(dx / d, dz / d, e.camara.giro));
      await esperarMs(60);
    }
    await soltarTodo();
    await pulsar('KeyJ');
    ataques++;
    if (!capturado) {
      await pagina.screenshot({ path: path.join(CARPETA_CAPTURAS, 'threejs_combate.png') });
      estadoCaptura = await leerEstado();
      capturado = true;
      registrar(`Captura guardada: ${path.join(CARPETA_CAPTURAS, 'threejs_combate.png')}`);
      await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
    }
    await esperarMs(350);
  }
  await soltarTodo();
  e = await leerEstado();
  const s = e.soldados[indice - 1];
  comprobar('Atacar con J cerca de un soldado le hace daño', s.vida < vidaInicial,
    `soldado ${indice}: vida ${vidaInicial} → ${s.vida} (${s.estado}); ataques ${ataques}`);
  if (estadoCaptura) {
    const cercano = soldadoMasCercano(estadoCaptura, false);
    registrar(`En la captura de combate: tajo visible ${estadoCaptura.akira.tajoVisible}, soldado a ${redondear(cercano.distancia)} m (${cercano.soldado && cercano.soldado.estado})`);
  }
  // Remata al soldado para comprobar la muerte y el contador
  const limite2 = Date.now() + 60000;
  while (Date.now() < limite2) {
    e = await leerEstado();
    const sol = e.soldados[indice - 1];
    if (e.escena !== 'patio' || sol.estado === 'muerto') break;
    const dx = sol.x - e.akira.x, dz = sol.z - e.akira.z;
    const d = Math.hypot(dx, dz);
    if (d > 1.3) {
      await fijarTeclas(teclasHacia(dx / d, dz / d, e.camara.giro));
      await esperarMs(80);
      continue;
    }
    await fijarTeclas(teclasHacia(dx / d, dz / d, e.camara.giro));
    await esperarMs(50);
    await soltarTodo();
    await pulsar('KeyJ');
    await esperarMs(350);
  }
  await soltarTodo();
  e = await leerEstado();
  const muerto = e.soldados[indice - 1].estado === 'muerto';
  comprobar('Un soldado con 2 de vida cae al segundo golpe y cuenta en el HUD', muerto && e.derrotados >= 1,
    `estado ${e.soldados[indice - 1].estado}, derrotados ${e.derrotados}`);
  if (muerto) {
    await esperarMs(2200);
    e = await leerEstado();
    const numeroHUD = await pagina.evaluate(() => document.getElementById('numeroDerrotados').textContent);
    comprobar('El soldado derrotado desaparece (1,2 s) y el HUD lo muestra', !e.soldados[indice - 1].visible && numeroHUD === String(e.derrotados),
      `visible ${e.soldados[indice - 1].visible}, HUD ${numeroHUD}/6`);
  }
}

async function faseDerrota() {
  // Se queda junto a un soldado sin defenderse hasta caer
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  let e = await leerEstado();
  let vioAviso = false, vioAvisoEnPantalla = false, vioEstocada = false;
  const limite = Date.now() + 150000;
  while (Date.now() < limite) {
    e = await leerEstado();
    if (e.escena !== 'patio') break;
    const { soldado, distancia } = soldadoMasCercano(e, true, true);   // el de la pasarela no alcanza desde abajo
    if (!soldado) break;
    if (e.soldados.some((s) => s.aviso)) {
      vioAviso = true;
      if (!vioAvisoEnPantalla) vioAvisoEnPantalla = (await avisosVisiblesEnPantalla()) > 0;
    }
    if (e.soldados.some((s) => s.estado === 'estocada')) vioEstocada = true;
    if (distancia > 1.2) {
      const dx = soldado.x - e.akira.x, dz = soldado.z - e.akira.z;
      await fijarTeclas(teclasHacia(dx / distancia, dz / distancia, e.camara.giro));
    } else {
      await soltarTodo();
    }
    await esperarMs(90);
  }
  await soltarTodo();
  e = await esperarEstado((x) => x.escena === 'derrota', { tiempo: 20000, descripcion: 'pantalla de derrota' }).catch(() => leerEstado());
  const avisos = e.soldados.reduce((suma, s) => suma + s.avisos, 0);
  comprobar('Los soldados avisan con «!» antes de la estocada', vioAviso && vioEstocada && avisos > 0,
    `avisos ${avisos}; «!» visto en pantalla: ${vioAvisoEnPantalla}`);
  comprobar('Vida 0 → «Akira ha caído»', e.escena === 'derrota' && e.texto && e.texto.titulo === 'Akira ha caído',
    `escena ${e.escena}, golpes recibidos ${e.akira.golpesRecibidos}`);
  if (e.escena !== 'derrota') return;
  await pulsar('Enter');
  await esperarEstado((x) => x.texto && x.texto.completo, { tiempo: 20000, descripcion: 'texto de derrota completo' });
  const texto = await textoDelPanel();
  comprobar('Texto de derrota copiado de samurai.py', texto.includes(TEXTOS.derrota));
  e = await continuarTexto();
  e = await esperarEstado((x) => x.escena === 'patio', { tiempo: 20000, descripcion: 'reintentar' });
  comprobar('ENTER reintenta: patio de nuevo con 5 de vida y los 6 soldados', e.escena === 'patio' && e.akira.vida === 5 &&
    e.derrotados === 0 && e.soldados.every((s) => s.vida === 2 && s.visible),
    `vida ${e.akira.vida}, derrotados ${e.derrotados}`);
}

async function fasePorton() {
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  let e = await leerEstado();
  for (let intento = 1; intento <= 3 && e.escena !== 'cierre'; intento++) {
    if (e.escena === 'derrota') {
      await continuarTexto();
      await esperarEstado((x) => x.escena === 'patio', { tiempo: 20000, descripcion: 'reintentar' });
    }
    // Cruza el patio corriendo por el centro y empuja contra el portón
    for (const [x, z] of [[-4, 0], [12, -0.5], [21.5, 0]]) {
      e = await irHacia(x, z, { correr: true, tolerancia: 1.2, tiempo: 40000, parar: (s) => s.escena !== 'patio' });
      if (e.escena !== 'patio') break;
    }
    const limite = Date.now() + 25000;
    while (Date.now() < limite) {
      e = await leerEstado();
      if (e.escena !== 'patio') break;
      const dx = 25 - e.akira.x, dz = 0 - e.akira.z;
      const d = Math.hypot(dx, dz);
      await fijarTeclas(teclasHacia(dx / d, dz / d, e.camara.giro));
      await esperarMs(90);
    }
    await soltarTodo();
    e = await esperarEstado((x) => x.escena !== 'patio', { tiempo: 5000, descripcion: 'salir del patio' }).catch(() => leerEstado());
    registrar(`Intento ${intento} de llegar al portón: escena ${e.escena}`);
  }
  comprobar('Llegar al portón muestra el texto de cierre', e.escena === 'cierre' && e.llegoAlPorton &&
    e.texto && e.texto.titulo === 'Fin del capítulo 1', `escena ${e.escena}`);
  if (e.escena !== 'cierre') return;
  await esperarMs(1200);
  await pulsar('Enter');
  await esperarEstado((x) => x.texto && x.texto.completo, { tiempo: 20000, descripcion: 'texto de cierre completo' });
  const texto = await textoDelPanel();
  comprobar('Texto de cierre copiado de samurai.py', texto.includes(TEXTOS.cierre) && texto.includes('ronin'));
  await esperarMs(1000);
  await capturar('threejs_cierre.png');
}

async function fasePausaYVuelta() {
  await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
  let e = await continuarTexto();
  comprobar('Tras el cierre, ENTER vuelve a la introducción', e.escena === 'intro');
  await continuarTexto();
  e = await esperarEstado((x) => x.escena === 'patio', { tiempo: 20000, descripcion: 'patio' });
  await pulsar('Escape');
  e = await esperarEstado((x) => x.pausado, { tiempo: 5000, descripcion: 'pausa' }).catch(() => leerEstado());
  const tiempoPausa = e.tiempo;
  await esperarMs(800);
  const quieto = (await leerEstado()).tiempo === tiempoPausa;
  comprobar('ESC pausa el juego (el tiempo se detiene)', e.pausado && quieto);
  await pulsar('Escape');
  e = await esperarEstado((x) => !x.pausado, { tiempo: 5000, descripcion: 'reanudar' }).catch(() => leerEstado());
  comprobar('ESC otra vez reanuda', !e.pausado && e.escena === 'patio');
  await pulsar('Escape');
  await esperarEstado((x) => x.pausado, { tiempo: 5000, descripcion: 'pausa' });
  await pulsar('KeyQ');
  e = await esperarEstado((x) => x.escena === 'intro', { tiempo: 5000, descripcion: 'salir al título' }).catch(() => leerEstado());
  comprobar('Q en pausa sale al título', e.escena === 'intro');
}

async function faseArchivoLocal(contexto) {
  // Abrir el HTML con doble clic equivale a cargarlo con file://
  const local = await contexto.newPage();
  const erroresLocales = [];
  local.on('console', (m) => { if (m.type() === 'error') erroresLocales.push(m.text()); });
  local.on('pageerror', (err) => erroresLocales.push(err.message));
  await local.setViewportSize({ width: ANCHO_RAPIDO, height: ALTO_RAPIDO });
  await local.goto(pathToFileURL(ARCHIVO_JUEGO).href);
  let listo = false;
  try {
    await local.waitForFunction(() => window.estadoJuego && window.estadoJuego.listo && window.estadoJuego.escena === 'intro',
      null, { timeout: 90000, polling: 200 });
    listo = true;
  } catch { /* se informa abajo */ }
  comprobar('También funciona abierto como archivo (file://)', listo && erroresLocales.length === 0,
    erroresLocales.length ? erroresLocales.join(' | ') : 'sin errores');
  await local.close();
}

// -----------------------------------------------------------------------------
// Programa principal
// -----------------------------------------------------------------------------
async function principal() {
  if (!fs.existsSync(ARCHIVO_JUEGO)) throw new Error('Falta ronin3d.html: ejecuta antes  python3 construir.py');
  if (fs.existsSync(ARCHIVO_FUENTE) && fs.statSync(ARCHIVO_FUENTE).mtimeMs > fs.statSync(ARCHIVO_JUEGO).mtimeMs) {
    registrar('AVISO: ronin3d_fuente.html es más reciente que ronin3d.html (ejecuta python3 construir.py)');
  }
  fs.mkdirSync(CARPETA_CAPTURAS, { recursive: true });
  const tamano = fs.statSync(ARCHIVO_JUEGO).size;
  registrar(`ronin3d.html: ${(tamano / 1024).toFixed(1)} KB`);

  const servidor = await crearServidor(CARPETA_JUEGO);
  const urlBase = `http://127.0.0.1:${servidor.address().port}/`;
  const navegador = await lanzarNavegador();
  const contexto = await navegador.newContext({ viewport: { width: ANCHO, height: ALTO }, deviceScaleFactor: 1 });
  const modoCDN = await prepararCDN(contexto, urlBase);
  registrar(`Three.js desde la CDN: ${modoCDN}`);

  pagina = await contexto.newPage();
  pagina.on('console', (m) => { if (m.type() === 'error') errores.push('consola: ' + m.text()); });
  pagina.on('pageerror', (err) => errores.push('excepción: ' + err.message));
  const renderer = await (async () => {
    await pagina.goto(urlBase + '__sonda');
    return pagina.evaluate(() => {
      const gl = document.createElement('canvas').getContext('webgl2');
      const info = gl && gl.getExtension('WEBGL_debug_renderer_info');
      return gl ? (info ? gl.getParameter(info.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER)) : 'sin WebGL 2';
    });
  })();
  registrar(`WebGL: ${renderer}`);

  let fps = null, fpsRapido = null, fallo = null;
  try {
    await pagina.goto(urlBase + 'ronin3d.html');
    await faseIntro();
    fps = await fasePatio();
    await faseTorreon();
    await faseMovimiento();
    await faseCamara();
    await faseMuro();
    await usarVentana(ANCHO_RAPIDO, ALTO_RAPIDO);
    fpsRapido = await medirFPS(4);
    registrar(`FPS a ${ANCHO_RAPIDO}×${ALTO_RAPIDO}: ${fpsRapido.toFixed(2)}`);
    await faseCombate();
    await faseDerrota();
    await fasePorton();
    await fasePausaYVuelta();
    await faseArchivoLocal(contexto);
  } catch (error) {
    fallo = error;
    comprobar('La prueba termina sin interrupciones', false, error.message);
    try { await pagina.screenshot({ path: path.join(CARPETA_CAPTURAS, 'threejs_error_prueba.png') }); } catch { /* nada */ }
  }
  comprobar('Sin errores en la consola ni excepciones en la página', errores.length === 0,
    errores.length ? errores.slice(0, 5).join(' | ') : 'ninguno');

  await navegador.close();
  servidor.close();

  const fallos = resultados.filter((r) => !r.correcto);
  console.log('\n================ RESUMEN ================');
  console.log(`Comprobaciones: ${resultados.length - fallos.length}/${resultados.length} correctas`);
  if (fps !== null) console.log(`FPS aproximados (Chromium sin ventana, WebGL por software): ${fps.toFixed(2)} a ${ANCHO}×${ALTO}` +
    (fpsRapido !== null ? `, ${fpsRapido.toFixed(2)} a ${ANCHO_RAPIDO}×${ALTO_RAPIDO}` : ''));
  console.log(`Tamaño de ronin3d.html: ${(tamano / 1024).toFixed(1)} KB`);
  console.log(`Capturas en: ${CARPETA_CAPTURAS}`);
  for (const f of fallos) console.log(`  FALLO: ${f.nombre}${f.detalle ? ' — ' + f.detalle : ''}`);
  console.log(`Duración: ${((Date.now() - inicioPrueba) / 1000).toFixed(0)} s`);
  if (fallo) console.error(fallo);
  process.exitCode = fallos.length ? 1 : 0;
}

principal().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

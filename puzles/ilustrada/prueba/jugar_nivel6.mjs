// Juega el nivel 6 de la caja viva («La noche») con gestos de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_nivel6.mjs [horizontal] [carpeta de capturas]
// Empieza en el nivel 6 con «?nivel=6» (el botón «Seguir» de la portada). Solo existe en la B (3D): sin tarjeta gráfica
// se usa SwiftShader y las esperas van en tiempo de juego. El juego es horizontal.
// A oscuras, arrastrar mueve la luz fría al revés del dedo (y se queda); solo lo alumbrado se toca. El shoji y la
// puertecilla de la lámpara se deslizan arrastrando; la tsukegi prende en las brasas cuando una ráfaga las aviva.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

if (process.argv[2] === 'vertical') console.log('(el juego es horizontal: el nivel 6 se prueba en horizontal)');
const [ancho, alto, sufijo] = [844, 390, 'h'];
const carpeta = (process.argv[3] || '/tmp/capturas_caja_viva').replace(/\/?$/, '/');
mkdirSync(carpeta, { recursive: true });

const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium',
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const contexto = await navegador.newContext({ viewport: { width: ancho, height: alto }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
const cache = new Map();
// CAJA_VIVA_URL prueba otra copia de la página (por ejemplo, la web del APK: apk/LEEME.md); con SIN_RED=1, cualquier
// petición fuera de localhost falla, para comprobar que no le hace falta internet
const BASE = process.env.CAJA_VIVA_URL || 'http://localhost:8765/';
const SIN_RED = process.env.SIN_RED === '1';
const fuera = [];
if (SIN_RED) await contexto.route(url => !url.href.startsWith('http://localhost'), ruta => { fuera.push(ruta.request().url()); ruta.abort(); });
else await contexto.route('https://cdn.jsdelivr.net/**', async ruta => {
  const url = ruta.request().url();
  if (!cache.has(url)) {
    const r = await fetch(url);
    cache.set(url, { estado: r.status, cuerpo: Buffer.from(await r.arrayBuffer()), tipo: r.headers.get('content-type') });
  }
  const c = cache.get(url);
  await ruta.fulfill({ status: c.estado, body: c.cuerpo, headers: { 'content-type': c.tipo || 'text/javascript', 'access-control-allow-origin': '*' } });
});
if (!SIN_RED) await contexto.route('https://fonts.*/**', ruta => ruta.abort());
const pagina = await contexto.newPage();
const cdp = await contexto.newCDPSession(pagina);
const errores = [];
pagina.on('pageerror', e => errores.push(e.message));
pagina.on('console', m => { if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) errores.push(m.text()); });
pagina.on('response', r => { if (r.status() >= 400 && r.url().startsWith('http://localhost')) errores.push(r.status() + ' ' + r.url()); });

let bien = 0, total = 0;
function comprobar(nombre, condicion, detalle = '') {
  total++;
  if (condicion) bien++;
  console.log(`${condicion ? 'bien' : 'MAL '}  ${nombre}${detalle ? '  (' + detalle + ')' : ''}`);
}
const LIMITE = 240000;
const reloj = () => pagina.evaluate(() => window.__prueba.reloj());
async function espera(s) {
  const t0 = await reloj();
  await pagina.waitForFunction(([t0, s]) => window.__prueba.reloj() >= t0 + s, [t0, s], { timeout: LIMITE, polling: 50 });
}
const hasta = (condicion, arg) => pagina.waitForFunction(condicion, arg, { timeout: LIMITE, polling: 100 });
const foto = n => pagina.screenshot({ path: `${carpeta}N6_${sufijo}_${n}.png` });
const n6 = () => pagina.evaluate(() => window.__prueba.n6());
const noche = () => pagina.evaluate(() => window.__prueba.noche());
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const libre = () => hasta(() => !window.__prueba.estado().ocupado);
const vista = () => pagina.evaluate(() => window.__prueba.estado().vista);
const inventario = () => pagina.evaluate(() => window.__prueba.inventario());
const enPantalla = (x, y, objeto = 'caja') => pagina.evaluate(([x, y, o]) => window.__prueba.aPantalla(x, y, o), [x, y, objeto]);
const irA = async v => { if (await vista() !== v) { await pagina.evaluate(v => window.__prueba.irA(v), v); await espera(1.1); } };

const kLado = id => pagina.evaluate(id => window.__prueba.cajon(id).k, id);
async function tocar(x, y, s = 0.3) { await pagina.touchscreen.tap(x, y); await espera(s); }
async function tocarBoceto(x, y, objeto = 'caja', s = 0.3) { const p = await enPantalla(x, y, objeto); await tocar(p.x, p.y, s); }
async function hueco(objeto) {
  const h = await pagina.$(`#hueco-${objeto}`);
  if (!h) throw new Error(`«${objeto}» no está en la bandeja`);
  const r = await h.boundingBox();
  return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
}
async function elegir(objeto) { const h = await hueco(objeto); await tocar(h.x, h.y, 0.2); }
// arrastrar un dedo de un punto a otro (eventos táctiles de verdad); «cada»: segundos de juego entre paso y paso (con 0, sin
// esperar: un tirón de verdad deprisa, aunque sin tarjeta gráfica cada cuadro tarde)
async function arrastrar(x0, y0, x1, y1, pasos = 12, cada = 0.02) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: x0, y: y0 }] });
  for (let i = 1; i <= pasos; i++) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: x0 + (x1 - x0) * i / pasos, y: y0 + (y1 - y0) * i / pasos }] });
    if (cada > 0) await espera(cada);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.3);
}
// un cajón del costado: por la línea por la que sale (despacio: muchos pasos y más tiempo entre ellos)
async function moverLado(id, hacia = 1.15, pasos = 12, cada = 0.02) {
  const e = await pagina.evaluate(id => window.__prueba.ejeCajon(id), id);
  const k = await kLado(id), desde = { x: e.a.x + (e.b.x - e.a.x) * k, y: e.a.y + (e.b.y - e.a.y) * k };
  await arrastrar(desde.x, desde.y, desde.x + (e.b.x - e.a.x) * hacia, desde.y + (e.b.y - e.a.y) * hacia, pasos, cada);
}

// la luz fría: arrastrar en un sitio libre (sin gestos) la lleva hasta (x, y) del boceto, en unos pocos intentos
async function apuntarLuz(x, y, margen = 14) {
  for (let i = 0; i < 4; i++) {
    const o = await pagina.evaluate(() => window.__prueba.luzObjetivo());
    const dx = x - o.x, dy = y - o.y;
    if (Math.hypot(dx, dy) < margen) break;
    const a = await enPantalla(o.x, o.y, 'sala'), b = await enPantalla(o.x + 100, o.y, 'sala'), k = Math.abs(b.x - a.x) / 100;
    // (al revés del dedo: el dedo va hacia el otro lado; los primeros píxeles del arrastre no mueven la luz)
    const fx = -dx * k, fy = -dy * k, L = Math.hypot(fx, fy), extra = L > 1 ? 9 / L : 0;
    const x0 = fx > 0 ? 130 : 700, y0 = fy > 0 ? 70 : 330;
    await arrastrar(x0, y0, x0 + fx * (1 + extra), y0 + fy * (1 + extra), 14);
  }
  await espera(0.9);
  const o = await pagina.evaluate(() => window.__prueba.luzObjetivo());
  return Math.hypot(x - o.x, y - o.y);
}
const iluminado = (x, y) => pagina.evaluate(([x, y]) => window.__prueba.iluminado(x, y), [x, y]);
const llama = () => pagina.evaluate(() => window.__prueba.llama());
async function tocarSala(x, y, s = 0.4) { const p = await enPantalla(x, y, 'sala'); await tocar(p.x, p.y, s); }
// el shoji: su hoja de la derecha, arrastrada hasta abierta «hacia» (0 cerrado … 1 abierto)
async function deslizarShoji(hacia) {
  const S = (await pagina.evaluate(() => window.__prueba.nivel6())).shoji, k0 = (await noche()).shoji;
  const p = await enPantalla(S.poste + 40 + S.abre * k0, 250, 'sala'), q = await enPantalla(S.poste + 140 + S.abre * k0, 250, 'sala');
  const k = (q.x - p.x) / 100, d = (hacia - k0) * S.abre * k * 1.25;
  await arrastrar(p.x, p.y, p.x + d + Math.sign(d) * 10, p.y, 10);
}
const esperarRafaga = () => hasta(() => window.__prueba.noche().brasa > 0.9);
async function usarEn(objeto, x, y, ancla = 'sala') { await elegir(objeto); const p = await enPantalla(x, y, ancla); await tocar(p.x, p.y, 0.4); }

await pagina.goto(BASE + '?nivel=6');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel 6', /nivel 6 · La noche/.test(await pagina.textContent('#boton-continuar')), await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 6 && window.__prueba.estado().fase === 'jugando');
await libre();
await espera(0.6);
await foto('01_a_oscuras');
const N6 = await pagina.evaluate(() => window.__prueba.nivel6());
comprobar('una ráfaga apaga la lámpara: la sala, a oscuras', (await noche()).oscuridad > 0.95 && (await pagina.evaluate(() => window.__prueba.lampara().apagada)) > 0.95, await mensaje());
comprobar('a oscuras, la caja no se gira', await pagina.isHidden('#boton-girar'));

// 1. lo no alumbrado no se encuentra; la caja, a oscuras, se asusta
await tocarSala(1290, 560, 0.5);
comprobar('tocar lo que no se ve: a oscuras no encuentras nada', /oscuras/.test(await mensaje()), await mensaje());
await tocarBoceto(850, 300, 'caja', 0.5);
comprobar('tocar la caja a oscuras la asusta', /respingo/.test(await mensaje()), await mensaje());

// 2. la luz: va al revés del dedo y se queda donde la dejas (un toque no la mueve)
const antes = await pagina.evaluate(() => window.__prueba.luzObjetivo());
await arrastrar(300, 200, 360, 200, 8);
const despues = await pagina.evaluate(() => window.__prueba.luzObjetivo());
comprobar('arrastrar el dedo a la derecha lleva la luz a la izquierda', despues.x < antes.x - 30, `${Math.round(antes.x)} → ${Math.round(despues.x)}`);
await tocarSala(1290, 560, 0.4);
const tras = await pagina.evaluate(() => window.__prueba.luzObjetivo());
comprobar('un toque no la mueve: se queda donde estaba', Math.hypot(tras.x - despues.x, tras.y - despues.y) < 1);

// 3. la lámpara: alumbrada, se encuentra; la mecha humea; su puertecilla se desliza
const errLampara = await apuntarLuz(596, 300);
comprobar('la luz llega a la lámpara', errLampara < 20 && await iluminado(580, 309), String(Math.round(errLampara)));
await espera(0.5);
await foto('02_lampara_alumbrada');
await tocarSala(604, 268, 1.4);
comprobar('tocada, la cámara se acerca a la lámpara: la mecha aún humea', await vista() === 'lampara' && (await n6()).mecha, await mensaje());
await foto('03_lampara_cerca');
const [px0, py0, px1, py1] = N6.lampara.puerta;
const pA = await enPantalla(px1 - 6, (py0 + py1) / 2, 'sala'), pB = await enPantalla(px0, (py0 + py1) / 2, 'sala');
await arrastrar(pA.x, pA.y, pA.x - (pA.x - pB.x) * 1.15, pA.y, 10);
await espera(0.5);
comprobar('la puertecilla de papel se corre: dentro, la mecha', (await n6()).puerta === 'abierta', await mensaje());
await foto('04_puertecilla');
await pagina.tap('#volver');
await espera(1.2);

// 4. la llamita de tinta fría en el cajón de arriba del costado; dentro, las tsukegi
const c2 = await pagina.evaluate(() => window.__prueba.frenteCajon('c2'));
await apuntarLuz(c2.x, c2.y);
await hasta(() => window.__prueba.n6().tinta);
await espera(0.6);
await foto('05_llamita');
comprobar('bajo la luz fría, en el cajón de arriba brilla una llamita de tinta', /llamita/.test(await mensaje()), await mensaje());
await tocarBoceto(c2.x, c2.y, 'caja', 1.2);
comprobar('alumbrado, el cajón se encuentra: la cámara va al costado', await vista() === 'cajones', await vista());
await moverLado('c2');
await hasta(() => window.__prueba.estado().cajones.c2 === 'abierto');
await espera(0.9);
const pc2 = await pagina.evaluate(() => window.__prueba.centroCajon('c2'));
await tocarBoceto(pc2.x, pc2.y, 'caja', 0.4);
await hasta(() => window.__prueba.inventario().includes('tsukegi'));
await espera(1);
comprobar('las tsukegi van a la bandeja', (await inventario()).includes('tsukegi'));
await pagina.tap('#volver');
await espera(1.2);
if (await vista() !== 'sala') { await pagina.tap('#volver'); await espera(1.2); }

// 5. las brasas, sin aire, no prenden la tsukegi; el shoji entreabierto deja entrar el viento
await usarEn('tsukegi', 578, 515, 'incensario');
comprobar('en las brasas casi apagadas, la tsukegi no prende', !(await llama()) && /no prende|apagadas/.test(await mensaje()), await mensaje());
await deslizarShoji(1);
await espera(0.5);
comprobar('el shoji se entreabre arrastrando su hoja', (await noche()).shoji > 0.8, String((await noche()).shoji));
await esperarRafaga();
await foto('06_rafaga');
await usarEn('tsukegi', 578, 515, 'incensario');
await espera(0.4);
comprobar('con la ráfaga, las brasas se avivan y la tsukegi prende (azufre, chispa azul, llama)', await llama(), await mensaje());
await foto('07_llama');
comprobar('la tsukegi encendida arde en la bandeja', await pagina.evaluate(() => !!document.querySelector('#hueco-tsukegi.arde')));
// con el shoji abierto, la ráfaga siguiente la apaga
await hasta(() => !window.__prueba.llama());
await espera(0.4);
comprobar('con el shoji abierto, una ráfaga apaga la llama', /apaga la llama/.test(await mensaje()) && (await n6()).apagadas === 1, await mensaje());

// 6. otra vez, y ahora se cierra el shoji antes de llevarla
await esperarRafaga();
await usarEn('tsukegi', 578, 515, 'incensario');
await espera(0.3);
comprobar('prende otra (el manojo trae más)', await llama(), await mensaje());
await deslizarShoji(0);
await espera(0.4);
comprobar('el shoji, cerrado: ya no entra el viento', (await noche()).shoji === 0, String((await noche()).shoji));
await espera(3.5);
comprobar('con el shoji cerrado, la llama sigue encendida', await llama());

// 7. la llama a la mecha: la lámpara se enciende
await usarEn('tsukegi', 600, 290);
await hasta(() => window.__prueba.n6().lampara === 'encendida');
await espera(2.4);
await foto('08_lampara_encendida');
comprobar('la llama prende la mecha: vuelve la luz cálida', (await noche()).oscuridad < 0.2 && (await pagina.evaluate(() => window.__prueba.lampara().apagada)) < 0.1, await mensaje());
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.5);
await foto('09_tarjeta');
comprobar('la tarjeta cierra el nivel 6: la noche', (await pagina.textContent('#tarjeta-titulo')) === 'La noche', await pagina.textContent('#tarjeta-hecho'));
comprobar('la cara tiene sus seis sellos', (await pagina.$$eval('.pieza.recuperada', l => l.length)) === 6
  && (await pagina.getAttribute('.marcador', 'aria-label')) === 'La cara: 6 de 6 piezas');
comprobar('la tarjeta ofrece el nivel final', /final/i.test(await pagina.textContent('#tarjeta-siguiente')), await pagina.textContent('#tarjeta-siguiente'));
comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
if (SIN_RED) comprobar('sin pedir nada a internet', fuera.length === 0, fuera.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

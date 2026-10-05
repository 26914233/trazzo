// Juega el nivel 3 de la caja viva («La voz») con gestos de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_nivel3.mjs [horizontal] [carpeta de capturas]
// Empieza en el nivel 3 con «?nivel=3» (el botón «Seguir» de la portada). Como el 2, solo existe en la B (3D): sin
// tarjeta gráfica se usa SwiftShader y las esperas van en tiempo de juego. El juego es horizontal.
// La luz fría del ojo nuevo va al revés del dedo: para alumbrar una tinta, el dedo se queda quieto en el punto opuesto
// (respecto de la cuenca, a 1/1,6 de distancia). El rollo se mece con toques seguidos; la ficha se voltea deslizándola
// en la mano; el cajón largo y la tetera se mueven arrastrando; la campanilla suena al tocar la caja mientras suelta
// el aire.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

if (process.argv[2] === 'vertical') console.log('(el juego es horizontal: el nivel 3 se prueba en horizontal)');
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
const foto = n => pagina.screenshot({ path: `${carpeta}N3_${sufijo}_${n}.png` });
const n3 = () => pagina.evaluate(() => window.__prueba.n3());
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const libre = () => hasta(() => !window.__prueba.estado().ocupado);
const vista = () => pagina.evaluate(() => window.__prueba.estado().vista);
const enPantalla = (x, y, objeto = 'caja') => pagina.evaluate(([x, y, o]) => window.__prueba.aPantalla(x, y, o), [x, y, objeto]);
const CUENCA = { x: 905, y: 378 };
// dónde poner el dedo para que la luz fría caiga en (x, y): al otro lado de la cuenca, más cerca
const dedoPara = (x, y) => ({ x: CUENCA.x - (x - CUENCA.x) / 1.6, y: CUENCA.y - (y - CUENCA.y) / 1.6 });

async function tocar(x, y, s = 0.3) { await pagina.touchscreen.tap(x, y); await espera(s); }
async function tocarBoceto(x, y, objeto = 'caja', s = 0.3) { const p = await enPantalla(x, y, objeto); await tocar(p.x, p.y, s); }
// el dedo quieto un rato (no es un toque: no se acerca a nada)
async function mantener(x, y, segundos) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
  await espera(segundos);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.3);
}
// arrastre de un dedo, con pasos (eventos táctiles de verdad); «aguantar» deja el dedo al final antes de soltar
async function arrastrar(x0, y0, dx, dy, pasos = 10, aguantar = 0) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: x0, y: y0 }] });
  for (let i = 1; i <= pasos; i++) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: x0 + dx * i / pasos, y: y0 + dy * i / pasos }] });
    await espera(0.02);
  }
  if (aguantar) await espera(aguantar);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.5);
}
async function hueco(objeto) {
  const h = await pagina.$(`#hueco-${objeto}`);
  if (!h) throw new Error(`«${objeto}» no está en la bandeja`);
  const r = await h.boundingBox();
  return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
}
async function elegir(objeto) { const h = await hueco(objeto); await tocar(h.x, h.y, 0.2); }
async function aSala() { if (await vista() !== 'sala') { await pagina.tap('#volver'); await espera(1); } }
async function girarCaja(cara) {
  if (await pagina.evaluate(() => window.__prueba.cara()) !== cara) { await pagina.tap('#boton-girar'); await espera(1.4); }
}

await pagina.goto(BASE + '?nivel=3');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel 3', await pagina.isVisible('#boton-continuar') && /nivel 3/.test(await pagina.textContent('#boton-continuar')),
  await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 3 && window.__prueba.estado().fase === 'jugando');
await espera(4);
await foto('01_papel');
comprobar('empieza con los dos ojos y un papel entre los labios', (await n3()).nota === 'boca' && await pagina.evaluate(() => window.__prueba.ojo2().visible > 0.9),
  await mensaje());
comprobar('en el nivel 3 la caja se puede girar', await pagina.isVisible('#boton-girar'));

// 1. la nota de la boca
await tocarBoceto(848, 484);
await hasta(() => !document.getElementById('nota').hidden);
await espera(0.8);
comprobar('el papel de la boca se lee: le falta la voz', /voz/.test(await pagina.textContent('#nota-texto')), (await pagina.textContent('#nota-texto')).replace(/\s+/g, ' '));
await pagina.tap('#nota');
await espera(0.8);
comprobar('la nota nueva queda en la bandeja', (await n3()).nota === 'mano' && (await pagina.evaluate(() => window.__prueba.inventario())).includes('nota'));

// 2. la luz fría: el dedo quieto en la tetera lleva la luz al rollo, y descubre su tinta
await aSala();
await pagina.evaluate(() => window.__prueba.calmarLampara());
const d1 = dedoPara(326, 196), p1 = await enPantalla(d1.x, d1.y, 'te');
await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: p1.x, y: p1.y }] });
await espera(1.2);
const luz = await pagina.evaluate(() => window.__prueba.luz());
await foto('02_luz_fria');
comprobar('la luz fría va al otro lado del dedo', luz.guiada && Math.hypot(luz.x - 326, luz.y - 196) < 90, JSON.stringify(luz));
await espera(1.4);
await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await espera(0.4);
comprobar('alumbrada un momento, la tinta del rollo aparece', (await n3()).tintas.rollo === true, await mensaje());
comprobar('mantener el dedo no es un toque: la cámara no se acerca a la tetera', await vista() === 'sala');

// 3. el rollo: se mece con toques seguidos y la ficha cae de su varilla
const rollo = await enPantalla(326, 140, 'sala');
await tocar(rollo.x, rollo.y, 0.15);
comprobar('dentro de la varilla del rollo suena algo suelto', /suelto|golpea/.test(await mensaje()), await mensaje());
for (let i = 0; i < 6 && (await n3()).ficha === 'rollo'; i++) await tocar(rollo.x, rollo.y, 0.35);
await hasta(() => window.__prueba.n3().ficha === 'suelo');
await espera(0.5);
await foto('03_ficha_cae');
comprobar('mecido fuerte, la ficha cae al tatami', (await n3()).ficha === 'suelo', await mensaje());
await tocarBoceto(386, 474, 'sala', 1);
comprobar('la ficha se coge del tatami', (await n3()).ficha === 'mano' && (await pagina.evaluate(() => window.__prueba.inventario())).includes('ficha'));

// 4. sin coronar, el hueco de la espalda la devuelve
await girarCaja('detras');
await hasta(() => window.__prueba.estado().vista === 'caja');
await espera(0.8);
await foto('04_espalda');
await elegir('ficha');
await tocarBoceto(846, 368, 'caja_detras', 0.3);
await libre();
await espera(0.5);
comprobar('por la cara del peón, el hueco devuelve la ficha', (await n3()).ficha === 'mano' && (await n3()).largo === 'cerrado', await mensaje());

// 5. en la mano se le da la vuelta: と, coronada
await elegir('ficha'); await elegir('ficha');
await hasta(() => !document.getElementById('examinar').hidden && !document.getElementById('bolsillo').hidden);
await espera(0.5);
const b = await (await pagina.$('#bolsillo')).boundingBox();
await arrastrar(b.x + b.width * 0.3, b.y + b.height / 2, b.width * 0.4, 0, 8);
await espera(0.8);
await foto('05_coronada');
comprobar('deslizándola de lado, la ficha se voltea: coronada', (await n3()).fichaCara === 'promovida', await pagina.textContent('#examinar-texto'));
await tocar(30, alto - 30, 0.8);

// 6. coronada, encaja: el cajón largo se suelta; se tira de él y dentro está la campanilla
await elegir('ficha');
await tocarBoceto(846, 368, 'caja_detras', 0.3);
await libre();
await espera(0.8);
comprobar('coronada, la ficha encaja y suelta el cajón largo', (await n3()).ficha === 'puesta' && (await n3()).largo === 'suelto', await mensaje());
const a0 = await pagina.evaluate(() => window.__prueba.pantallaLargo(0)), a1 = await pagina.evaluate(() => window.__prueba.pantallaLargo(1));
await arrastrar(a0.x, a0.y, (a1.x - a0.x) * 1.4, (a1.y - a0.y) * 1.4 + 1, 12);
await espera(1.2);
await foto('06_cajon_largo');
comprobar('tirando con el dedo, el cajón largo sale y se queda abierto', (await n3()).largo === 'abierto' && (await pagina.evaluate(() => window.__prueba.largo())).k > 0.9);
const pc = await pagina.evaluate(() => window.__prueba.puntoCampanilla());
await tocar(pc.x, pc.y, 1.2);
comprobar('dentro, la campanilla (sin badajo) va a la bandeja', (await n3()).campanilla === 'mano', await mensaje());
await elegir('campanilla');
await tocarBoceto(780, 520, 'caja_detras', 0.3);
comprobar('sin badajo, la campanilla no suena', /roza|muda/.test(await mensaje()), await mensaje());

// 7. la tinta de la tetera, y la tetera volcada: con el té cae el badajo en la taza
await girarCaja('frente');
await aSala();
const d2 = dedoPara(1306, 392), p2 = await enPantalla(d2.x, d2.y, 'sala');
await mantener(p2.x, p2.y, 2.6);
comprobar('la luz descubre la tinta de la madera, junto a la tetera', (await n3()).tintas.te === true, await mensaje());
await tocarBoceto(1300, 560, 'te', 1.2);
comprobar('en el nivel 3, tocar la tetera la mira de cerca', await vista() === 'te');
await foto('07_tetera');
const t0 = await enPantalla(1300, 556, 'te');
await arrastrar(t0.x, t0.y, -20, 120, 10, 2.2);
await foto('08_vertida');
comprobar('volcada un rato sobre la taza, el badajo cae en ella', (await n3()).badajo === 'taza', await mensaje());
comprobar('al soltarla, la tetera vuelve a su sitio', (await pagina.evaluate(() => window.__prueba.tetera())).inclinacion < 0.05);
await tocarBoceto(1190, 612, 'te', 1);
comprobar('el badajo se saca de la taza', (await n3()).badajo === 'mano');

// 8. en la bandeja, el badajo encima de la campanilla: ya tiene lengua
const hb = await hueco('badajo'), hc = await hueco('campanilla');
await arrastrar(hb.x, hb.y, hc.x - hb.x, hc.y - hb.y, 8);
await espera(0.8);
comprobar('arrastrado encima, el badajo encaja en la campanilla', (await n3()).completa && !(await pagina.evaluate(() => window.__prueba.inventario())).includes('badajo'), await mensaje());

// 9. la tinta del tatami, y la campanilla al soltar el aire: tres veces
await aSala();
const d3 = dedoPara(250, 562), p3 = await enPantalla(d3.x, d3.y, 'sala');
await mantener(p3.x, p3.y, 2.6);
comprobar('la luz descubre la tinta del tatami', (await n3()).tintas.suelo === true, await mensaje());
await foto('09_tinta_suelo');
await tocarBoceto(960, 600, 'caja', 1);
// mientras toma aire, no contesta
await hasta(() => !window.__prueba.aliento().exhalando && window.__prueba.aliento().fase % (2 * Math.PI) > 0.4);
await elegir('campanilla');
await tocarBoceto(990, 560, 'caja', 0.4);
comprobar('mientras toma aire, la caja no contesta a la campanilla', (await n3()).toques === 0, await mensaje());
for (let i = 1; i <= 3; i++) {
  await hasta(() => window.__prueba.aliento().exhalando && Math.sin(window.__prueba.aliento().fase) < -0.3);
  await elegir('campanilla');
  await tocarBoceto(990, 560, 'caja', 0.3);
  await hasta(i => window.__prueba.n3().toques >= i, i);
  await espera(1);
}
comprobar('soltando el aire, contesta tres veces', (await n3()).toques >= 3);
await hasta(() => window.__prueba.labios() >= 1 && !window.__prueba.estado().ocupado);
await espera(0.5);
await foto('10_labios');
comprobar('al tercer murmullo, los labios se entreabren', (await n3()).labios >= 1, await mensaje());

// 10. la campanilla en la boca: canta y cierra el nivel
await elegir('campanilla');
await tocarBoceto(848, 484, 'caja', 1);
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.5);
await foto('11_tarjeta');
comprobar('la campanilla en la boca: canta y cierra el nivel 3', (await pagina.textContent('#tarjeta-titulo')) === 'La voz', await pagina.textContent('#tarjeta-hecho'));
comprobar('la cara ya tiene sus tres piezas', (await pagina.$$eval('.pieza.recuperada', l => l.length)) === 3);
comprobar('la tarjeta ofrece el nivel final', /final/i.test(await pagina.textContent('#tarjeta-siguiente')), await pagina.textContent('#tarjeta-siguiente'));
comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
if (SIN_RED) comprobar('sin pedir nada a internet', fuera.length === 0, fuera.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

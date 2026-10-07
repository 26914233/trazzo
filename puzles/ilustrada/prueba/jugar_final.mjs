// Juega el nivel final de la caja viva («El corazón») con gestos de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_final.mjs [horizontal] [carpeta de capturas]
// Empieza en el final con «?nivel=5» (el botón «Seguir» de la portada). Solo existe en la B (3D): sin tarjeta gráfica
// se usa SwiftShader y las esperas van en tiempo de juego. El juego es horizontal.
// Los anillos del corazón se giran arrastrando el dedo en círculo sobre ellos (la prueba sigue el círculo de cada uno,
// proyectado en la pantalla); la caja pequeña se coge de la mesa, se pone en el hueco del centro y se gira como una llave.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

if (process.argv[2] === 'vertical') console.log('(el juego es horizontal: el final se prueba en horizontal)');
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
const foto = n => pagina.screenshot({ path: `${carpeta}N4_${sufijo}_${n}.png` });
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

const fin = () => pagina.evaluate(() => window.__prueba.fin());
const RADIO = [0.0945, 0.078, 0.0622];                 // el centro de cada anillo (m)
const angular = a => Math.atan2(Math.sin(a), Math.cos(a));
const puntoCorazon = (r, a) => pagina.evaluate(([r, a]) => window.__prueba.puntoCorazon(r, a), [r, a]);
// arrastrar el dedo en círculo sobre el corazón, a radio r, desde el ángulo «desde» girando «delta»
async function girarEnCorazon(r, desde, delta, pasos = 18) {
  const p0 = await puntoCorazon(r, desde);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: p0.x, y: p0.y }] });
  for (let i = 1; i <= pasos; i++) {
    const p = await puntoCorazon(r, desde + delta * i / pasos);
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: p.x, y: p.y }] });
    await espera(0.03);
  }
  await espera(0.25);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.7);
}
// lleva el anillo i a su sitio, cogiéndolo por el frente
async function aSuSitio(i) {
  const f = await fin(), objetivo = await pagina.evaluate(i => window.__prueba.sitioAnillo(i), i);
  await girarEnCorazon(RADIO[i], 0, angular(objetivo - f.angulos[i]));
}

await pagina.goto(BASE + '?nivel=5');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel final', /final/.test(await pagina.textContent('#boton-continuar')), await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 5 && window.__prueba.fin() && window.__prueba.fin().fase === 'anillos');
await espera(1.5);
await foto('01_corazon');
comprobar('el corazón sube por la trampilla y se queda en la tapa', (await fin()).subida > 0.99 && await vista() === 'corazon', await mensaje());
comprobar('en el final la caja no se gira', await pagina.isHidden('#boton-girar'));
comprobar('ningún anillo empieza en su sitio', !(await pagina.evaluate(() => [0, 1, 2].some(i => window.__prueba.enSitio(i)))));

// 1. el anillo del cuerno: soltado fuera de su sitio no encaja; en la ranura que mira el ojo viejo, sí
const f0 = await fin(), mal = angular(f0.ranura * Math.PI / 4 + Math.PI / 4 - f0.angulos[0]);
await girarEnCorazon(RADIO[0], 0, Math.abs(mal) < 0.1 ? angular(mal + Math.PI / 2) : mal);
comprobar('fuera de su sitio, el anillo del cuerno no encaja', !(await fin()).bloqueados[0]);
await aSuSitio(0);
await foto('02_cuerno');
comprobar('con el cuerno en la ranura que mira el ojo, el anillo encaja', (await fin()).bloqueados[0], await mensaje());

// 2. el anillo del ojo: su marca solo se ve donde alumbra el ojo nuevo (lo que tocas)
const f1 = await fin(), marca = f1.marca * Math.PI / 4 + f1.angulos[1];
const pm = await puntoCorazon(RADIO[1], marca);
await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: pm.x, y: pm.y }] });
await espera(0.8);
await foto('03_tinta_ojo');
await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await espera(0.4);
comprobar('tocar el anillo del ojo lo alumbra donde está el dedo', Math.abs(angular((await fin()).luz.alfa - marca)) < 0.25, JSON.stringify((await fin()).luz));
await aSuSitio(1);
comprobar('con su marca en la muesca del frente, el anillo del ojo encaja', (await fin()).bloqueados[1], await mensaje());

// 3. el anillo de la voz: sin marca; donde suena la campanilla, encaja
await aSuSitio(2);
await foto('04_voz');
comprobar('donde suena la voz, el anillo de dentro encaja', (await fin()).bloqueados[2], await mensaje());
await hasta(() => window.__prueba.fin().fase === 'centro' && window.__prueba.fin().centro > 0.99);
comprobar('con los tres anillos en su sitio, se abre el hueco del centro', (await fin()).fase === 'centro', await mensaje());

// 4. la caja pequeña, de la mesa al corazón
await aSala();
await espera(0.5);
const ph = await pagina.evaluate(() => window.__prueba.pantallaHija('cuerpo'));
await tocar(ph.x, ph.y, 1.2);
comprobar('la caja pequeña se coge de la mesa', (await fin()).hija === 'mano' && (await pagina.evaluate(() => window.__prueba.inventario())).includes('hija'));
await tocarBoceto(930, 205, 'caja', 1.2);
if (await vista() !== 'corazon') await tocarBoceto(930, 205, 'caja', 1.2);
comprobar('tocando la tapa, la cámara vuelve al corazón', await vista() === 'corazon');
await espera(1);
await elegir('hija');
const pc = await puntoCorazon(0, 0);
await tocar(pc.x, pc.y, 0.5);
await libre();
await espera(0.6);
await foto('05_llave');
comprobar('la caja pequeña encaja en el centro del corazón', (await fin()).hija === 'puesta', await mensaje());

// 5. se gira como una llave: el corazón se abre, late y la caja canta
await girarEnCorazon(0.03, -Math.PI / 2, Math.PI * 0.62, 14);
await hasta(() => window.__prueba.fin().fase === 'abierto');
await espera(2.5);
await foto('06_abierto');
comprobar('girada un cuarto de vuelta, el corazón se abre', (await fin()).fase === 'abierto');
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.5);
await foto('07_fin');
comprobar('la tarjeta del final: el corazón', (await pagina.textContent('#tarjeta-titulo')) === 'El corazón' && /Fin/.test(await pagina.textContent('#tarjeta-siguiente')),
  await pagina.textContent('#tarjeta-siguiente'));
comprobar('al final no hay siguiente nivel: quedarse o volver a empezar', await pagina.isHidden('#boton-seguir') && await pagina.isVisible('#boton-quedarse'));
comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
if (SIN_RED) comprobar('sin pedir nada a internet', fuera.length === 0, fuera.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

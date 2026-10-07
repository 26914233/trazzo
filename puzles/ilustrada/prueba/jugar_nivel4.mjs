// Juega el nivel 4 de la caja viva («El oro») con gestos de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_nivel4.mjs [horizontal] [carpeta de capturas]
// Empieza en el nivel 4 con «?nivel=4» (el botón «Seguir» de la portada). Solo existe en la B (3D): sin tarjeta gráfica
// se usa SwiftShader y las esperas van en tiempo de juego. El juego es horizontal.
// La caja canta (con los ojos cerrados) si se le toca la boca mientras suelta el aire; las tres olas de la peana se
// tocan en el orden de su canto; el cajón de la peana se tira arrastrando; en la mano, las esquirlas se arrastran a su
// sitio y se giran con un toque, la laca se traza por las juntas y el oro se espolvorea encima.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

if (process.argv[2] === 'vertical') console.log('(el juego es horizontal: el nivel 4 se prueba en horizontal)');
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
const n4 = () => pagina.evaluate(() => window.__prueba.n4());
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const libre = () => hasta(() => !window.__prueba.estado().ocupado);
const vista = () => pagina.evaluate(() => window.__prueba.estado().vista);
const inventario = () => pagina.evaluate(() => window.__prueba.inventario());
const enPantalla = (x, y, objeto = 'caja') => pagina.evaluate(([x, y, o]) => window.__prueba.aPantalla(x, y, o), [x, y, objeto]);
const irA = async v => { if (await vista() !== v) { await pagina.evaluate(v => window.__prueba.irA(v), v); await espera(1.1); } };
const PI2 = 2 * Math.PI;
const BOCA = { x: 848, y: 484 };

async function tocar(x, y, s = 0.3) { await pagina.touchscreen.tap(x, y); await espera(s); }
async function tocarBoceto(x, y, objeto = 'caja', s = 0.3) { const p = await enPantalla(x, y, objeto); await tocar(p.x, p.y, s); }
// un dedo por una lista de puntos de la pantalla (eventos táctiles de verdad)
async function recorrer(puntos, pasosPorTramo = 4) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [puntos[0]] });
  for (let i = 1; i < puntos.length; i++) {
    for (let k = 1; k <= pasosPorTramo; k++) {
      const a = puntos[i - 1], b = puntos[i];
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: a.x + (b.x - a.x) * k / pasosPorTramo, y: a.y + (b.y - a.y) * k / pasosPorTramo }] });
      await espera(0.02);
    }
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.3);
}
async function hueco(objeto) {
  const h = await pagina.$(`#hueco-${objeto}`);
  if (!h) throw new Error(`«${objeto}» no está en la bandeja`);
  const r = await h.boundingBox();
  return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
}
async function elegir(objeto) { const h = await hueco(objeto); await tocar(h.x, h.y, 0.2); }
async function examinar(objeto) {
  await elegir(objeto); await elegir(objeto);
  await hasta(() => !document.getElementById('examinar').hidden);
  await espera(0.6);
}
async function cerrarExaminar() {
  await pagina.touchscreen.tap(12, 12);
  await hasta(() => document.getElementById('examinar').hidden);
  await espera(0.3);
}
// el bolsillo: de −1…1 a la pantalla
async function enBolsillo(q) {
  const r = await pagina.locator('#bolsillo').boundingBox();
  return { x: r.x + (q.x + 1) / 2 * r.width, y: r.y + (q.y + 1) / 2 * r.height };
}
const mano = () => pagina.evaluate(() => window.__prueba.mano());
async function esperarAliento(soltando) {
  if (soltando) await hasta(PI2 => { const a = window.__prueba.aliento(), f = a.fase % PI2; return a.exhalando && f > Math.PI + 0.15 && f < Math.PI + 1; }, PI2);
  else await hasta(PI2 => { const a = window.__prueba.aliento(), f = a.fase % PI2; return !a.exhalando && f > 0.25 && f < 1.1; }, PI2);
}

await pagina.goto(BASE + '?nivel=4');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel 4', await pagina.isVisible('#boton-continuar') && /nivel 4/.test(await pagina.textContent('#boton-continuar')),
  await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 4 && window.__prueba.estado().fase === 'jugando');
await hasta(() => !window.__prueba.estado().ocupado && window.__prueba.n4().esquirlas[0] === 'peana');
await espera(0.6);
await foto('01_esquirla_cae');
comprobar('al cantar, se le suelta una esquirla de la mejilla a la peana', (await n4()).esquirlas[0] === 'peana', await mensaje());
comprobar('en el nivel 4 la caja se puede girar', await pagina.isVisible('#boton-girar'));

// 1. la primera esquirla, en la peana
await irA('caja');
await tocarBoceto(961, 567);
await hasta(() => window.__prueba.n4().esquirlas[0] === 'mano');
await espera(1);
comprobar('la esquirla se coge de la peana', (await inventario()).includes('esquirlas'));
// probarla en la mejilla: faltan pedazos
await irA('cara');
await elegir('esquirlas');
await tocarBoceto(943, 440, 'caja', 0.5);
comprobar('sola, en la mejilla no se sostiene: faltan pedazos', /faltan/.test(await mensaje()), await mensaje());

// 2. la sombra en la pared y la esquirla de encima de la lámpara
await irA('sala');
await espera(0.5);
await foto('02_sombra');
await tocarBoceto(600, 150, 'sala', 0.4);
comprobar('la sombra de la pared delata algo encima de la lámpara', /sombra|marco/.test(await mensaje()), await mensaje());
await tocarBoceto(604, 300, 'sala', 1.2);
await hasta(() => window.__prueba.n4().esquirlas[1] === 'mano');
comprobar('encima de la lámpara está la segunda esquirla', (await n4()).esquirlas[1] === 'mano', await mensaje());
await espera(1);
await tocarBoceto(604, 300, 'sala', 0.4);
comprobar('la llama ya no distrae al ojo', !(await pagina.evaluate(() => window.__prueba.distraidoPor())), await mensaje());

// 3. la boca: mientras toma aire lo contiene; mientras lo suelta, canta tres notas con los ojos cerrados
await irA('cara');
await esperarAliento(false);
await tocarBoceto(BOCA.x, BOCA.y, 'caja', 0.3);
comprobar('mientras toma aire, no canta', !(await pagina.evaluate(() => window.__prueba.cantando())), await mensaje());
await espera(0.8);
await esperarAliento(true);
await tocarBoceto(BOCA.x, BOCA.y, 'caja', 0.7);
const cerrado = await pagina.evaluate(() => window.__prueba.ojoCerrado());
await foto('03_canta');
comprobar('soltando el aire, canta con los ojos cerrados', await pagina.evaluate(() => window.__prueba.cantando()) && cerrado > 0.8, `${await mensaje()} · ojo ${cerrado.toFixed(2)}`);
await espera(4.5);

// 4. las olas de la peana: mal orden, vuelven a subir; en el orden de su canto, sueltan el cajón
const datos4 = await pagina.evaluate(() => window.__prueba.nivel4());
const { frase } = await n4();
await irA('zocalo');
await foto('04_peana');
const otra = [0, 1, 2].find(i => i !== frase[0]);
await tocarBoceto(datos4.olas[otra].x, datos4.olas[otra].y, 'caja', 0.8);
comprobar('en otro orden, las olas vuelven a subir', (await n4()).pulsadas.length === 0 && (await n4()).zocalo === 'cerrado', await mensaje());
for (const i of frase) await tocarBoceto(datos4.olas[i].x, datos4.olas[i].y, 'caja', 0.4);
await hasta(() => window.__prueba.n4().zocalo === 'suelto' && !window.__prueba.estado().ocupado);
await espera(0.5);
comprobar('en el orden de su canto, el cajón de la peana se suelta', (await n4()).zocalo === 'suelto', await mensaje());

// 5. tirar del cajón de la peana y coger lo de dentro
const a = await pagina.evaluate(() => window.__prueba.pantallaZocalo(0.14)), b = await pagina.evaluate(() => window.__prueba.pantallaZocalo(1));
await recorrer([a, { x: a.x + (b.x - a.x) * 0.5, y: a.y + (b.y - a.y) * 0.5 }, { x: a.x + (b.x - a.x) * 1.2, y: a.y + (b.y - a.y) * 1.2 }], 6);
await hasta(() => window.__prueba.n4().zocalo === 'abierto');
await espera(1.2);
await foto('05_cajon_peana');
comprobar('tirando, el cajón de la peana sale', (await n4()).zocalo === 'abierto');
for (const parte of ['esquirla', 'laca', 'oro']) {
  const p = await pagina.evaluate(parte => window.__prueba.puntoZocalo(parte), parte);
  await tocar(p.x, p.y, 1.2);
}
await hasta(() => { const n = window.__prueba.n4(); return n.esquirlas[2] === 'mano' && n.laca === 'mano' && n.oro === 'mano'; });
await espera(0.8);
comprobar('dentro: la tercera esquirla, la laca y el oro', ['esquirlas', 'laca', 'oro'].every(o => true) && (await inventario()).includes('laca') && (await inventario()).includes('oro'),
  (await inventario()).join(', '));

// 6. en la mano: montar las tres esquirlas (girarlas con un toque y arrastrarlas a su sitio)
await examinar('esquirlas');
await foto('06_mano');
comprobar('las esquirlas se miran en la mano', await pagina.evaluate(() => window.__prueba.bolsillo().activo));
for (let i = 0; i < 3; i++) {
  for (let vueltas = 0; vueltas < 6; vueltas++) {
    const m = (await mano()).esquirlas[i];
    if (Math.abs(Math.atan2(Math.sin(m.a), Math.cos(m.a))) < 0.05) break;
    const p = await enBolsillo(m);
    await tocar(p.x, p.y, 0.15);
  }
  const m = (await mano()).esquirlas[i], sitio = (await mano()).sitios[i];
  await recorrer([await enBolsillo(m), await enBolsillo({ x: (m.x + sitio.x) / 2, y: (m.y + sitio.y) / 2 }), await enBolsillo(sitio)], 6);
}
await espera(0.5);
await foto('07_montada');
comprobar('montadas, las tres esquirlas son un pedazo', (await n4()).pieza === 'montada' && (await inventario()).includes('mejilla'),
  JSON.stringify((await mano()).esquirlas.map(e => e.puesta)));

// 7. la laca: se elige y se repasan las dos juntas
const herr = async id => (await mano()).herramientas.find(h => h.id === id);
let h = await herr('laca');
let p = await enBolsillo(h); await tocar(p.x, p.y, 0.3);
for (const junta of (await mano()).juntas) await recorrer(await Promise.all(junta.map(q => enBolsillo(q))), 5);
await espera(0.4);
comprobar('repasadas las juntas, el pedazo queda con laca', (await n4()).pieza === 'lacada', await pagina.textContent('#examinar-ayuda'));
// el oro, con la laca fresca, no se pega
h = await herr('oro');
p = await enBolsillo(h); await tocar(p.x, p.y, 0.3);
for (const junta of (await mano()).juntas) await recorrer(await Promise.all(junta.map(q => enBolsillo({ x: q.x, y: q.y - 0.02 }))), 4);
await espera(1.5);
comprobar('con la laca fresca, el oro no se pega', (await n4()).pieza === 'lacada' && (await n4()).dorado.every(j => j.every(x => !x)), await pagina.textContent('#examinar-ayuda'));
await foto('08_laca');
await cerrarExaminar();

// 8. curarla: el té está tibio; su aliento, mientras lo suelta
await irA('sala');
await elegir('mejilla');
await tocarBoceto(1270, 640, 'sala', 0.5);
comprobar('el té ya está tibio: no sirve para curar la laca', /tibio/.test(await mensaje()), await mensaje());
await irA('cara');
await elegir('mejilla');
await esperarAliento(true);
await tocarBoceto(BOCA.x, BOCA.y, 'caja', 0.5);
await hasta(() => window.__prueba.n4().pieza === 'curada' && !window.__prueba.estado().ocupado);
await espera(0.8);
comprobar('su aliento, húmedo, cura la laca', (await n4()).pieza === 'curada', await mensaje());

// 9. el oro, espolvoreado sobre las juntas
await examinar('mejilla');
h = await herr('oro');
p = await enBolsillo(h); await tocar(p.x, p.y, 0.3);
for (let vuelta = 0; vuelta < 3 && (await n4()).pieza !== 'dorada'; vuelta++) {
  for (const junta of (await mano()).juntas) await recorrer(await Promise.all(junta.map(q => enBolsillo({ x: q.x, y: q.y - 0.015 }))), 4);
  await espera(1.6);
}
await foto('09_oro');
comprobar('espolvoreado, el oro se pega a las juntas', (await n4()).pieza === 'dorada', await pagina.textContent('#examinar-texto'));
await cerrarExaminar();

// 10. ponerlo: mientras mira no deja tocarle la cara (ni la llama la distrae); mientras canta, cierra los ojos
await irA('cara');
await pagina.evaluate(() => window.__prueba.calmarLampara());
await elegir('mejilla');
await tocarBoceto(943, 440, 'caja', 0.5);
comprobar('mientras mira, no deja ponerlo en su cara', (await n4()).pieza === 'dorada', await mensaje());
await elegir('mejilla');
await esperarAliento(true);
await tocarBoceto(BOCA.x, BOCA.y, 'caja', 0.6);
comprobar('con el pedazo elegido, tocarle la boca la hace cantar (y el pedazo sigue elegido)',
  await pagina.evaluate(() => window.__prueba.cantando() && window.__prueba.estado().seleccion === 'mejilla'), await mensaje());
await tocarBoceto(943, 440, 'caja', 0.5);
await hasta(() => window.__prueba.n4().pieza === 'puesta');
await espera(2.6);
await foto('10_oro_corre');
comprobar('mientras canta con los ojos cerrados, el pedazo encaja en su mejilla', (await n4()).pieza === 'puesta');
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.5);
await foto('11_tarjeta');
comprobar('la tarjeta cierra el nivel 4: el oro', (await pagina.textContent('#tarjeta-titulo')) === 'El oro', await pagina.textContent('#tarjeta-hecho'));
comprobar('la cara tiene sus cuatro sellos', (await pagina.$$eval('.pieza.recuperada', l => l.length)) === 4);
comprobar('la tarjeta ofrece el nivel 5: la cómoda', /Nivel 5 · La cómoda/.test(await pagina.textContent('#tarjeta-siguiente')), await pagina.textContent('#tarjeta-siguiente'));
comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
if (SIN_RED) comprobar('sin pedir nada a internet', fuera.length === 0, fuera.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

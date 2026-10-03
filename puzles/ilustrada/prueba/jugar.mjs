// Juega la caja viva de punta a punta con toques de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar.mjs [B|A] [horizontal|vertical] [carpeta de capturas]
// B es el juego (DECISIÓN 29); A, el respaldo para móviles sin WebGL (se abre con «?tecnica=A»).
// Usa el Playwright global y el Chromium de /opt/pw-browsers (los del contenedor de Claude). La B necesita WebGL:
// sin tarjeta gráfica se usa SwiftShader, que es lento; por eso las esperas van en tiempo de juego (el reloj de la
// página) y comprobando el estado, no en segundos de verdad.
// Three.js viene de cdn.jsdelivr.net: aquí se descarga con el fetch de Node y se le pasa a la página.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const tecnica = process.argv[2] === 'A' ? 'A' : 'B';
const vertical = process.argv[3] === 'vertical';
const [ancho, alto, sufijo] = vertical ? [390, 844, 'v'] : [844, 390, 'h'];
const carpeta = (process.argv[4] || '/tmp/capturas_caja_viva').replace(/\/?$/, '/');
mkdirSync(carpeta, { recursive: true });

const con3d = tecnica !== 'A';
const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium',
  args: con3d ? ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] : [] });
const contexto = await navegador.newContext({ viewport: { width: ancho, height: alto }, deviceScaleFactor: con3d ? 1 : 2,
  isMobile: true, hasTouch: true });
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
// las fuentes de Google no cargan detrás del proxy del contenedor: se cortan (no es un fallo de la página)
if (!SIN_RED) await contexto.route('https://fonts.*/**', ruta => ruta.abort());
const pagina = await contexto.newPage();
const cdp = await contexto.newCDPSession(pagina);
const errores = [];
pagina.on('pageerror', e => errores.push(e.message));
pagina.on('console', m => {
  // los recursos que fallan se apuntan abajo con su dirección (la consola no la dice)
  if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) errores.push(m.text());
});
pagina.on('response', r => { if (r.status() >= 400 && r.url().startsWith('http://localhost')) errores.push(r.status() + ' ' + r.url()); });

let bien = 0, total = 0;
function comprobar(nombre, condicion, detalle = '') {
  total++;
  if (condicion) bien++;
  console.log(`${condicion ? 'bien' : 'MAL '}  ${nombre}${detalle ? '  (' + detalle + ')' : ''}`);
}
const LIMITE = 240000;
const reloj = () => pagina.evaluate(() => window.__prueba.reloj());
// espera «s» segundos del reloj del juego
async function espera(s) {
  const t0 = await reloj();
  await pagina.waitForFunction(([t0, s]) => window.__prueba.reloj() >= t0 + s, [t0, s], { timeout: LIMITE, polling: 50 });
}
const hasta = (condicion, arg) => pagina.waitForFunction(condicion, arg, { timeout: LIMITE, polling: 100 });
const foto = n => pagina.screenshot({ path: `${carpeta}${tecnica}_${sufijo}_${n}.png` });
const estado = () => pagina.evaluate(() => ({ ...window.__prueba.estado() }));
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const cajon = id => pagina.evaluate(id => window.__prueba.cajon(id), id);
// toca un punto de la ilustración (en la capa de su objeto); si la vista no lo enseña, vuelve antes a la sala.
// En 3D, al acercarse, lo de la sala puede quedar detrás de la caja: se comprueba qué hay de verdad en ese punto.
const donde = (x, y, objeto) => pagina.evaluate(([x, y, o]) => {
  const p = window.__prueba.aPantalla(x, y, o);
  if (!p) return null;
  const t = window.__tec(), v = o === 'sala' && t.nombre !== 'A' ? t.aPintura(p.x, p.y) : null;
  // un botón o un mensaje encima del punto también lo tapa
  const encima = document.elementFromPoint(p.x, p.y);
  return { x: p.x, y: p.y, tapado: (v ? Math.hypot(v.x - x, v.y - y) > 25 : false) || (encima && encima.id !== 'lienzo') };
}, [x, y, objeto]);
async function tocar(x, y, objeto = 'caja') {
  let p = await donde(x, y, objeto);
  if (!p || p.tapado || p.x < 5 || p.y < 5 || p.x > ancho - 5 || p.y > alto - 5) {
    await pagina.tap('#volver'); await espera(1.1);
    p = await donde(x, y, objeto);
  }
  await pagina.touchscreen.tap(p.x, p.y);
}
// un cajón del costado (al tocarlo, la cámara se acerca al costado)
async function tocarCajon(id) {
  const c = await pagina.evaluate(id => window.__prueba.centroCajon(id), id);
  await tocar(c.x, c.y);
}
// mantener pulsado (toques de verdad, para que salgan eventos de puntero táctiles)
async function mantener(selector, segundos) {
  const r = await pagina.locator(selector).boundingBox();
  const punto = { x: r.x + r.width / 2, y: r.y + r.height / 2 };
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [punto] });
  await espera(segundos);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}

await pagina.goto(BASE + (tecnica === 'A' ? '?tecnica=A' : ''));
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 30000 });
await foto('01_portada');
await pagina.tap('#boton-entrar');
await hasta(() => window.__prueba.estado().fase === 'jugando' && window.__prueba.ojo().parpadoBase === 0);
await espera(0.5);
await foto('02_sala');
comprobar(`entra en la sala con el ojo abierto y la técnica ${tecnica}`, await pagina.evaluate(() => window.__prueba.tecnica()) === tecnica);

await tocar(900, 420);
await espera(1.1);
await foto('03_caja');
comprobar('tocar la caja la acerca', (await estado()).vista === 'caja');

// los cajones del costado: cerrados; se abren deslizándose
let e = await estado();
comprobar('los nueve cajones del costado empiezan cerrados', Object.values(e.cajones).length === 9 && Object.values(e.cajones).every(v => v === 'cerrado'));
await tocarCajon('c8');
await espera(0.9);
await foto('04_cajon_abierto');
let c = await cajon('c8');
comprobar('el cajón de abajo se abre con su animación y la cámara se acerca al costado', c.estado === 'abierto' && c.k > 0.95
  && (await estado()).vista === 'cajones', JSON.stringify(c));

await tocarCajon('c8');
await espera(0.5);
await foto('05_resiste_llave');
e = await estado();
comprobar('la llave no se deja coger mientras el ojo mira', e.llave === 'cajon' && /mientras te mira/.test(await mensaje()), await mensaje());

await espera(1.5);
await tocarCajon('c2');
await espera(0.7);
await foto('06_cajon_cerradura');
c = await cajon('c2');
comprobar('un cajón con cerradura resiste sin moverse', c.estado === 'cerrado' && c.k === 0 && /cerradura|cede/.test(await mensaje()), await mensaje());

await espera(1.5);
await tocar(605, 320, 'sala');
await espera(0.7);
await foto('07_lampara');
comprobar('la lámpara distrae al ojo', await pagina.evaluate(() => window.__prueba.ojo().distraidoHasta > window.__prueba.reloj()));
await tocarCajon('c8');
await espera(1.3);
await foto('08_llave_cogida');
e = await estado();
comprobar('con el ojo en la lámpara, la llave se coge y va a la bandeja', e.llave === 'mano' && e.inventario.includes('llave') && await pagina.isVisible('#hueco-llave'), e.llave);

await espera(1.0);
await tocarCajon('c8');
await espera(0.7);
c = await cajon('c8');
comprobar('el cajón vacío se cierra', c.estado === 'cerrado' && c.k < 0.02, JSON.stringify(c));

await tocarCajon('c9');
await espera(0.9);
comprobar('el cajón de al lado se abre', (await cajon('c9')).estado === 'abierto');
await tocarCajon('c9');
await hasta(() => !document.getElementById('nota').hidden && !document.getElementById('nota').classList.contains('oculta'));
await espera(0.4);
await foto('09_nota');
comprobar('la nota se lee al cogerla y no se cierra sola', await pagina.isVisible('#nota'));
await pagina.tap('#nota');
await pagina.waitForTimeout(800);
e = await estado();
comprobar('la nota se cierra al tocarla y queda en la bandeja', !(await pagina.isVisible('#nota')) && e.inventario.includes('nota') && await pagina.isVisible('#hueco-nota'));

// examinar: mantener pulsada la llave
await mantener('#hueco-llave', 0.8);
await espera(0.5);
await foto('10_examinar');
comprobar('mantener pulsado un objeto lo examina', await pagina.isVisible('#examinar') && /Llave/.test(await pagina.textContent('#examinar-nombre')), await pagina.textContent('#examinar-nombre'));
await pagina.tap('#examinar');
await pagina.waitForTimeout(700);
comprobar('y se guarda al tocarlo', !(await pagina.isVisible('#examinar')));

// la espalda de la caja
await pagina.tap('#boton-girar');
await espera(1.6);
await foto('11_espalda');
comprobar('el botón de girar enseña la espalda', await pagina.evaluate(() => window.__prueba.cara()) === 'detras');
await espera(1.2);
await tocar(850, 516, 'caja_detras');
await espera(0.7);
comprobar('el cajón largo de la espalda no es para esta llave', /cerradura|llave/.test(await mensaje()), await mensaje());
await pagina.tap('#boton-girar');
await espera(1.6);
comprobar('girar otra vez vuelve al frente', await pagina.evaluate(() => window.__prueba.cara()) === 'frente');

await tocar(575, 540, 'incensario');
await espera(1.1);
await tocar(575, 540, 'incensario');
await espera(0.6);
await foto('12_incensario_cerrado');
e = await estado();
comprobar('el incensario no se abre sin la llave', e.vista === 'incensario' && e.tapa === 'puesta' && /cerradura|león/.test(await mensaje()), await mensaje());

await pagina.tap('#hueco-llave');
await espera(0.4);
await tocar(575, 540, 'incensario');
await espera(1.5);
await foto('13_abriendo');
await hasta(() => window.__prueba.estado().tapaEnMesa && !window.__prueba.estado().ocupado);
await espera(0.6);
await foto('14_abierto');
e = await estado();
comprobar('la llave abre el incensario, la tapa queda en la mesa y la llave deja la bandeja',
  e.tapa === 'abierta' && e.tapaEnMesa && e.llave === 'usada' && !e.inventario.includes('llave'));

await tocar(593, 480, 'incensario');
await espera(1.3);
await foto('15_cuerno_cogido');
e = await estado();
comprobar('el cuerno sale de las brasas', e.cuerno === 'mano' && await pagina.isVisible('#hueco-cuerno'), e.cuerno);

if (await pagina.isVisible('#volver')) { await pagina.tap('#volver'); await espera(1.1); }
await pagina.tap('#hueco-cuerno');
await espera(0.3);
await tocar(912, 292);
await espera(2.6);
await foto('16_despertando');
await espera(2.2);
await foto('17_despierta');
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.6);
await foto('18_final');
e = await estado();
comprobar('el cuerno en la frente despierta la caja y cierra el nivel 1', e.cuerno === 'puesto' && e.fase === 'tarjeta'
  && await pagina.isVisible('#tarjeta') && await pagina.evaluate(() => document.querySelectorAll('.pieza.recuperada').length === 1));
// en la B, la tarjeta deja seguir en el nivel 2 (jugar_nivel2.mjs lo juega); en la A, que no tiene 3D, lo explica
comprobar(tecnica === 'A' ? 'en la A, la tarjeta dice que el nivel 2 necesita 3D' : 'la tarjeta ofrece seguir en el nivel 2',
  tecnica === 'A' ? await pagina.isHidden('#boton-seguir') : await pagina.isVisible('#boton-seguir'),
  await pagina.evaluate(() => document.getElementById('tarjeta-siguiente').textContent));

await pagina.tap('#boton-otra');
await hasta(() => window.__prueba.estado().fase === 'jugando' && window.__prueba.ojo().parpadoBase === 0);
e = await estado();
const cerrados = await pagina.evaluate(() => Object.keys(window.__prueba.estado().cajones).every(id => window.__prueba.cajon(id).k === 0));
comprobar('volver a empezar deja la caja como al principio', e.fase === 'jugando' && e.llave === 'cajon' && e.nota === 'cajon' && e.tapa === 'puesta'
  && e.cuerno === 'brasas' && e.inventario.length === 0 && cerrados);

if (SIN_RED) {
  comprobar('sin internet: nada sale de la página', fuera.length === 0, fuera.slice(0, 3).join(' | '));
  comprobar('sin internet: las fuentes del juego están cargadas', await pagina.evaluate(async () => {
    await document.fonts.ready;
    return ['800 30px "Shippori Mincho"', '400 16px "Shippori Mincho"', '400 15px "Zen Kaku Gothic New"']
      .every(f => document.fonts.check(f, 'Caja')) && [...document.fonts].some(f => f.family.includes('Shippori') && f.status === 'loaded');
  }));
}
comprobar('sin errores en la consola', errores.length === 0, errores.join(' | '));
console.log(`\n${bien} de ${total} (técnica ${tecnica}, ${vertical ? 'vertical' : 'horizontal'}); capturas en ${carpeta}`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

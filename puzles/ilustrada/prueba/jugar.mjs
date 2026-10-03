// Juega la caja viva de punta a punta con toques de móvil, en la técnica elegida, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar.mjs [A|B|C] [horizontal|vertical] [carpeta de capturas]
// Usa el Playwright global y el Chromium de /opt/pw-browsers (los del contenedor de Claude). Las técnicas B y C
// necesitan WebGL: sin tarjeta gráfica se usa SwiftShader, que es lento; por eso las esperas van en tiempo de
// juego (el reloj de la página) y comprobando el estado, no en segundos de verdad.
// Three.js viene de cdn.jsdelivr.net: aquí se descarga con el fetch de Node y se le pasa a la página.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const tecnica = ['A', 'B', 'C'].includes(process.argv[2]) ? process.argv[2] : 'A';
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
await contexto.route('https://cdn.jsdelivr.net/**', async ruta => {
  const url = ruta.request().url();
  if (!cache.has(url)) {
    const r = await fetch(url);
    cache.set(url, { estado: r.status, cuerpo: Buffer.from(await r.arrayBuffer()), tipo: r.headers.get('content-type') });
  }
  const c = cache.get(url);
  await ruta.fulfill({ status: c.estado, body: c.cuerpo, headers: { 'content-type': c.tipo || 'text/javascript', 'access-control-allow-origin': '*' } });
});
// las fuentes de Google no cargan detrás del proxy del contenedor: se cortan (no es un fallo de la página)
await contexto.route('https://fonts.*/**', ruta => ruta.abort());
const pagina = await contexto.newPage();
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

await pagina.goto('http://localhost:8765/');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 30000 });
await pagina.tap(`#tecnicas [data-tecnica="${tecnica}"]`);
await foto('01_portada');
comprobar('la portada marca la técnica elegida', await pagina.getAttribute(`#tecnicas [data-tecnica="${tecnica}"]`, 'aria-pressed') === 'true');
await pagina.tap('#boton-entrar');
await hasta(() => window.__prueba.estado().fase === 'jugando' && window.__prueba.ojo().parpadoBase === 0);
await espera(0.5);
await foto('02_sala');
comprobar('entra en la sala con el ojo abierto y la técnica elegida', await pagina.evaluate(() => window.__prueba.tecnica()) === tecnica);

await tocar(900, 420);
await espera(1.1);
await foto('03_caja');
comprobar('tocar la caja la acerca', (await estado()).vista === 'caja');

await tocar(1072, 488);
await espera(0.5);
await foto('04_resiste_llave');
let e = await estado();
comprobar('la llave no se deja coger mientras el ojo mira', e.llave === 'cajon' && /mientras te mira/.test(await mensaje()), await mensaje());

await espera(1.5);
await tocar(1045, 270);
await espera(0.7);
await foto('05_cajon_cerrado');
comprobar('un cajón cerrado resiste sin moverse', /aliento|mueve|insistas/.test(await mensaje()), await mensaje());

await espera(1.5);
await tocar(605, 320, 'sala');
await espera(0.7);
await foto('06_lampara');
comprobar('la lámpara distrae al ojo', await pagina.evaluate(() => window.__prueba.ojo().distraidoHasta > window.__prueba.reloj()));
// si para ver la lámpara hubo que volver a la sala, el primer toque en la caja solo acerca la cámara
if ((await estado()).vista !== 'caja') { await tocar(900, 420); await espera(0.9); }
await tocar(1072, 488);
await espera(1.3);
await foto('07_llave_cogida');
e = await estado();
comprobar('con el ojo en la lámpara, la llave se coge', e.llave === 'mano' && await pagina.isVisible('#hueco-llave'), e.llave);

await espera(1.5);
await tocar(1135, 450);
await espera(0.9);
await foto('08_nota');
comprobar('la nota se abre y no se cierra sola', await pagina.isVisible('#nota'));
await pagina.tap('#nota');
await pagina.waitForTimeout(800);
comprobar('la nota se cierra al tocarla', !(await pagina.isVisible('#nota')));

// la espalda de la caja
await pagina.tap('#boton-girar');
await espera(1.6);
await foto('09_espalda');
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
await foto('10_incensario_cerrado');
e = await estado();
comprobar('el incensario no se abre sin la llave', e.vista === 'incensario' && e.tapa === 'puesta' && /cerradura|león/.test(await mensaje()), await mensaje());

await pagina.tap('#hueco-llave');
await espera(0.4);
await tocar(575, 540, 'incensario');
await espera(1.5);
await foto('11_abriendo');
await hasta(() => window.__prueba.estado().tapaEnMesa && !window.__prueba.estado().ocupado);
await espera(0.6);
await foto('12_abierto');
e = await estado();
comprobar('la llave abre el incensario y la tapa queda en la mesa', e.tapa === 'abierta' && e.tapaEnMesa && e.llave === 'usada');

await tocar(593, 480, 'incensario');
await espera(1.3);
await foto('13_cuerno_cogido');
e = await estado();
comprobar('el cuerno sale de las brasas', e.cuerno === 'mano' && await pagina.isVisible('#hueco-cuerno'), e.cuerno);

if (await pagina.isVisible('#volver')) { await pagina.tap('#volver'); await espera(1.1); }
await pagina.tap('#hueco-cuerno');
await espera(0.3);
await tocar(912, 292);
await espera(2.6);
await foto('14_despertando');
await espera(2.2);
await foto('15_despierta');
await hasta(() => window.__prueba.estado().fase === 'fin');
await espera(1);
await foto('16_final');
e = await estado();
comprobar('el cuerno en la frente despierta la caja', e.cuerno === 'puesto' && e.fase === 'fin' && await pagina.isVisible('#final'));

// en las técnicas 3D, cambiar de técnica a mitad de partida (B y C se cargan juntas)
if (con3d) {
  const otra = tecnica === 'B' ? 'C' : 'B';
  await pagina.tap(`#cambiar-tecnica [data-tecnica="${otra}"]`);
  await espera(1);
  await foto('17_otra_tecnica');
  comprobar(`se cambia a la técnica ${otra} sin perder el estado`, await pagina.evaluate(() => window.__prueba.tecnica()) === otra && (await estado()).cuerno === 'puesto');
  await pagina.tap('#cambiar-tecnica [data-tecnica="A"]');
  await espera(1);
  comprobar('y a la técnica A', await pagina.evaluate(() => window.__prueba.tecnica()) === 'A');
  await pagina.tap(`#cambiar-tecnica [data-tecnica="${tecnica}"]`);
  await espera(1);
}

await pagina.tap('#boton-otra');
await hasta(() => window.__prueba.estado().fase === 'jugando' && window.__prueba.ojo().parpadoBase === 0);
e = await estado();
comprobar('volver a empezar deja la caja como al principio', e.fase === 'jugando' && e.llave === 'cajon' && e.tapa === 'puesta' && e.cuerno === 'brasas');

comprobar('sin errores en la consola', errores.length === 0, errores.join(' | '));
console.log(`\n${bien} de ${total} (técnica ${tecnica}, ${vertical ? 'vertical' : 'horizontal'}); capturas en ${carpeta}`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

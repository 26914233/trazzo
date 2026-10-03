// Juega la caja viva ilustrada de punta a punta con toques de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar.mjs [horizontal|vertical] [carpeta de capturas]
// Usa el Playwright global y el Chromium de /opt/pw-browsers (los del contenedor de Claude).
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const vertical = process.argv[2] === 'vertical';
const [ancho, alto, sufijo] = vertical ? [390, 844, 'v'] : [844, 390, 'h'];
const carpeta = (process.argv[3] || '/tmp/capturas_caja_viva').replace(/\/?$/, '/');
mkdirSync(carpeta, { recursive: true });

const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium' });
const contexto = await navegador.newContext({ viewport: { width: ancho, height: alto }, deviceScaleFactor: 2, isMobile: true, hasTouch: true });
const pagina = await contexto.newPage();
const errores = [];
pagina.on('pageerror', e => errores.push(e.message));
pagina.on('console', m => {
  // los recursos que fallan se apuntan abajo con su dirección (la consola no la dice)
  if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) errores.push(m.text());
});
pagina.on('response', r => {
  // las fuentes de Google no cargan detrás del proxy del contenedor: no es un fallo de la página
  if (r.status() >= 400 && r.url().startsWith('http://localhost')) errores.push(r.status() + ' ' + r.url());
});

let bien = 0, total = 0;
function comprobar(nombre, condicion, detalle = '') {
  total++;
  if (condicion) bien++;
  console.log(`${condicion ? 'bien' : 'MAL '}  ${nombre}${detalle ? '  (' + detalle + ')' : ''}`);
}
const espera = ms => pagina.waitForTimeout(ms);
const foto = n => pagina.screenshot({ path: `${carpeta}${sufijo}_${n}.png` });
const estado = () => pagina.evaluate(() => ({ ...window.__prueba.estado() }));
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
// toca un punto de la ilustración; si la vista no lo enseña, vuelve antes a la sala
async function tocar(x, y) {
  let p = await pagina.evaluate(([x, y]) => window.__prueba.aPantalla(x, y), [x, y]);
  if (p.x < 5 || p.y < 5 || p.x > ancho - 5 || p.y > alto - 5) {
    await pagina.tap('#volver'); await espera(1000);
    p = await pagina.evaluate(([x, y]) => window.__prueba.aPantalla(x, y), [x, y]);
  }
  await pagina.touchscreen.tap(p.x, p.y);
}

await pagina.goto('http://localhost:8765/');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 20000 });
await espera(800);
await foto('01_portada');
await pagina.tap('#boton-entrar');
await espera(4200);
await foto('02_sala');
let e = await estado();
comprobar('entra en la sala con el ojo abierto', e.fase === 'jugando' && (await pagina.evaluate(() => window.__prueba.ojo().parpadoBase)) === 0);

await tocar(900, 420);
await espera(1100);
await foto('03_caja');
comprobar('tocar la caja la acerca', (await estado()).vista === 'caja');

await tocar(1072, 488);
await espera(500);
await foto('04_resiste_llave');
e = await estado();
comprobar('la llave no se deja coger mientras el ojo mira', e.llave === 'cajon' && /mientras te mira/.test(await mensaje()));

await espera(1500);
await tocar(1045, 270);
await espera(700);
await foto('05_cajon_cerrado');
comprobar('un cajón cerrado resiste sin moverse', /aliento/.test(await mensaje()));

await espera(1500);
await tocar(605, 320);
await espera(700);
await foto('06_lampara');
comprobar('la lámpara distrae al ojo', await pagina.evaluate(() => window.__prueba.ojo().distraidoHasta > 0));
await tocar(1072, 488);
await espera(1300);
await foto('07_llave_cogida');
e = await estado();
comprobar('con el ojo en la lámpara, la llave se coge', e.llave === 'mano' && await pagina.isVisible('#hueco-llave'));

await espera(1500);
await tocar(1135, 450);
await espera(900);
await foto('08_nota');
comprobar('la nota se abre y no se cierra sola', await pagina.isVisible('#nota'));
await pagina.tap('#nota');
await espera(800);
comprobar('la nota se cierra al tocarla', !(await pagina.isVisible('#nota')));

await tocar(575, 540);
await espera(1100);
await tocar(575, 540);
await espera(600);
await foto('09_incensario_cerrado');
e = await estado();
comprobar('el incensario no se abre sin la llave', e.vista === 'incensario' && e.tapa === 'puesta' && /cerradura/.test(await mensaje()));

await pagina.tap('#hueco-llave');
await espera(400);
await tocar(575, 540);
await espera(1500);
await foto('10_abriendo');
await espera(2600);
await foto('11_abierto');
e = await estado();
comprobar('la llave abre el incensario y la tapa queda en la mesa', e.tapa === 'abierta' && e.tapaEnMesa && e.llave === 'usada');

await tocar(593, 480);
await espera(1300);
await foto('12_cuerno_cogido');
e = await estado();
comprobar('el cuerno sale de las brasas', e.cuerno === 'mano' && await pagina.isVisible('#hueco-cuerno'));

if (await pagina.isVisible('#volver')) { await pagina.tap('#volver'); await espera(1000); }
await pagina.tap('#hueco-cuerno');
await espera(300);
await tocar(912, 292);
await espera(2600);
await foto('13_despertando');
await espera(2200);
await foto('14_despierta');
await espera(5500);
await foto('15_final');
e = await estado();
comprobar('el cuerno en la frente despierta la caja', e.cuerno === 'puesto' && e.fase === 'fin' && await pagina.isVisible('#final'));

await pagina.tap('#boton-otra');
await espera(4500);
e = await estado();
comprobar('volver a empezar deja la caja como al principio', e.fase === 'jugando' && e.llave === 'cajon' && e.tapa === 'puesta' && e.cuerno === 'brasas');

comprobar('sin errores en la consola', errores.length === 0, errores.join(' | '));
console.log(`\n${bien} de ${total} (${vertical ? 'vertical' : 'horizontal'}); capturas en ${carpeta}`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

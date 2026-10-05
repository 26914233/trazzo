// Juega la caja viva de punta a punta con gestos de móvil (tocar, tirar, empujar, girar, levantar y pellizcar),
// comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar.mjs [B|A] [horizontal|vertical] [carpeta de capturas]
// B es el juego (DECISIÓN 29); A, el respaldo para móviles sin WebGL (se abre con «?tecnica=A»).
// El juego es horizontal: en vertical, la prueba comprueba que el móvil pide girarse (y nada más).
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
  // (lo mismo con lo que hay en la mesa: en el borde de la pantalla, el dedo puede caer en el canto de su silueta)
  const t = window.__tec(), comprobarlo = t.nombre !== 'A' && !/^caja/.test(o), v = comprobarlo ? t.aPintura(p.x, p.y) : null;
  // un botón encima del punto también lo tapa, y uno muy cerca también: el móvil lleva el toque al botón más próximo
  const cerca = [[0, 0], [-14, 0], [14, 0], [0, -14], [0, 14]].some(([dx, dy]) => {
    const e = document.elementFromPoint(p.x + dx, p.y + dy);
    return e && e.id !== 'lienzo';
  });
  return { x: p.x, y: p.y, tapado: (comprobarlo ? !v || Math.hypot(v.x - x, v.y - y) > 25 : false) || cerca };
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
// arrastrar un dedo de un punto a otro (eventos táctiles de verdad: salen eventos de puntero)
async function arrastrar(x0, y0, x1, y1, pasos = 12) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: x0, y: y0 }] });
  for (let i = 1; i <= pasos; i++) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: x0 + (x1 - x0) * i / pasos, y: y0 + (y1 - y0) * i / pasos }] });
    await espera(0.02);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}
// un dedo en círculo alrededor de un punto, desde el ángulo a0 y girando «giro» radianes
async function enCirculo(cx, cy, radio, a0, giro, pasos = 16) {
  const punto = a => ({ x: cx + Math.cos(a) * radio, y: cy + Math.sin(a) * radio });
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [punto(a0)] });
  for (let i = 1; i <= pasos; i++) { await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [punto(a0 + giro * i / pasos)] }); await espera(0.02); }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}
// pellizcar con dos dedos alrededor de un punto: de d0 a d1 píxeles de separación
async function pellizcar(cx, cy, d0, d1, pasos = 10) {
  const dedos = d => [{ x: cx - d / 2, y: cy, id: 1 }, { x: cx + d / 2, y: cy, id: 2 }];
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: dedos(d0) });
  for (let i = 1; i <= pasos; i++) { await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: dedos(d0 + (d1 - d0) * i / pasos) }); await espera(0.02); }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}
// tirar de un cajón del costado (o empujarlo, con «hacia» negativo): el dedo va por la línea por la que sale
async function tirarCajon(id, hacia = 1.15) {
  if ((await estado()).vista !== 'cajones') { await tocarCajon(id); await espera(1.1); }
  const e = await pagina.evaluate(id => window.__prueba.ejeCajon(id), id);
  const k = (await cajon(id)).k, desde = { x: e.a.x + (e.b.x - e.a.x) * k, y: e.a.y + (e.b.y - e.a.y) * k };
  await arrastrar(desde.x, desde.y, desde.x + (e.b.x - e.a.x) * hacia, desde.y + (e.b.y - e.a.y) * hacia);
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
if (vertical) {
  // el juego es horizontal: en un móvil en vertical, un aviso pide girarlo y tapa el juego
  comprobar('en vertical, el móvil pide girarse', await pagina.isVisible('#girar-movil')
    && await pagina.evaluate(() => document.elementFromPoint(innerWidth / 2, innerHeight / 2).closest('#girar-movil') !== null));
  await pagina.setViewportSize({ width: alto, height: ancho });
  await pagina.waitForTimeout(400);
  comprobar('al girarlo, el aviso se va', await pagina.isHidden('#girar-movil'));
  comprobar('sin errores en la consola', errores.length === 0, errores.join(' | '));
  console.log(`\n${bien} de ${total} (técnica ${tecnica}, vertical); capturas en ${carpeta}`);
  await navegador.close();
  process.exit(bien === total ? 0 : 1);
}
comprobar('en horizontal no hay aviso de girar el móvil', await pagina.isHidden('#girar-movil'));
await pagina.tap('#boton-entrar');
await hasta(() => window.__prueba.estado().fase === 'jugando' && window.__prueba.ojo().parpadoBase === 0);
await espera(0.5);
await foto('02_sala');
comprobar(`entra en la sala con el ojo abierto y la técnica ${tecnica}`, await pagina.evaluate(() => window.__prueba.tecnica()) === tecnica);
// el vistazo: si pasa un rato sin avanzar, el ojo mira de reojo hacia lo que teme (al principio, el cajón de la llave)
await pagina.evaluate(() => window.__prueba.adelantarVistazo());
await espera(0.3);
const vistazo = await pagina.evaluate(() => window.__prueba.vistazo()), cajonLlave = await pagina.evaluate(() => window.__prueba.centroCajon('c8'));
comprobar('sin avanzar, el ojo mira de reojo hacia el cajón de la llave', !!vistazo && Math.hypot(vistazo.x - cajonLlave.x, vistazo.y - cajonLlave.y) < 2,
  JSON.stringify(vistazo));

await tocar(900, 420);
await espera(1.1);
await foto('03_caja');
comprobar('tocar la caja la acerca', (await estado()).vista === 'caja');

// los cajones del costado: cerrados; se abren tirando de ellos
let e = await estado();
comprobar('los nueve cajones del costado empiezan cerrados', Object.values(e.cajones).length === 9 && Object.values(e.cajones).every(v => v === 'cerrado'));
await tocarCajon('c8');
await espera(1.1);
let c = await cajon('c8');
comprobar('tocar un cajón de lejos solo acerca la cámara al costado', (await estado()).vista === 'cajones' && c.estado === 'cerrado', JSON.stringify(c));
await tocarCajon('c8');
await espera(0.8);
c = await cajon('c8');
comprobar('un toque no abre el cajón: asoma y vuelve, y dice que se tira de él', c.estado === 'cerrado' && c.k < 0.02 && /[Tt]ira/.test(await mensaje()), await mensaje());
await tirarCajon('c8');
await espera(0.9);
await foto('04_cajon_abierto');
c = await cajon('c8');
comprobar('tirando con el dedo, el cajón de abajo sale y se queda abierto', c.estado === 'abierto' && c.k > 0.95, JSON.stringify(c));
await espera(0.8);
if (tecnica === 'B') {
  const m = await pagina.evaluate(() => window.__prueba.mirada());
  comprobar('al abrir el cajón de la llave, la cámara se asoma para ver dentro', m && m.ph > 0.2, JSON.stringify(m));
}
const ejeAntes = await pagina.evaluate(() => window.__prueba.ejeCajon('c8'));
// (la tetera: su tintineo también distrae al ojo, pero calmarLampara lo deshace; el shoji no vale, su viento agita la
// llama y distrae al ojo)
const tetera = await pagina.evaluate(() => window.__prueba.pantallaBoceto(1290, 540, 'te'));
await pagina.touchscreen.tap(tetera.x, tetera.y);
await espera(0.9);
const ejeDespues = await pagina.evaluate(() => window.__prueba.ejeCajon('c8'));
comprobar('de cerca, la cámara se queda fija: tocar otra cosa no vuelve a la sala',
  (await estado()).vista === 'cajones' && Math.hypot(ejeAntes.a.x - ejeDespues.a.x, ejeAntes.a.y - ejeDespues.a.y) < 6);
if (tecnica === 'B') {
  // de cerca, la vista sigue anclada, pero arrastrar en vacío la gira alrededor de los cajones (también hacia arriba)
  const antes = await pagina.evaluate(() => window.__prueba.mirada());
  await arrastrar(ancho * 0.45, alto * 0.2, ancho * 0.3, alto * 0.45, 10);
  await espera(0.6);
  const despues = await pagina.evaluate(() => window.__prueba.mirada());
  comprobar('de cerca, arrastrar en vacío gira la vista sin salir de ella', (await estado()).vista === 'cajones'
    && Math.abs(despues.thObj - antes.thObj) > 0.05, `${JSON.stringify(antes)} → ${JSON.stringify(despues)}`);
}

await pagina.evaluate(() => window.__prueba.calmarLampara());
await tocarCajon('c8');
await espera(0.5);
await foto('05_resiste_llave');
e = await estado();
comprobar('la llave no se deja coger mientras el ojo mira', e.llave === 'cajon' && /mientras te mira/.test(await mensaje()), await mensaje());
// la caja también oye: el tintineo de la tapa de la tetera le aparta el ojo un momento (otra forma de distraerlo)
await pagina.touchscreen.tap(tetera.x, tetera.y);
await espera(0.4);
const oido = await pagina.evaluate(() => window.__prueba.distraidoPor());
comprobar('la caja también oye: el tintineo de la tetera le aparta el ojo', !!oido && Math.hypot(oido.x - 1301, oido.y - 508) < 2,
  `${JSON.stringify(oido)} · ${await mensaje()}`);
await pagina.evaluate(() => window.__prueba.calmarLampara());

await espera(1.5);
await tirarCajon('c2');
await espera(0.7);
await foto('06_cajon_cerradura');
c = await cajon('c2');
comprobar('un cajón con cerradura resiste el tirón sin moverse', c.estado === 'cerrado' && c.k === 0 && /cerradura|cede|aliento/.test(await mensaje()), await mensaje());

// pellizcar: acercarse con dos dedos y, al alejarse del todo, volver a la vista de antes
await espera(1.2);
await pellizcar(ancho * 0.55, alto * 0.5, 120, 230);
await espera(0.5);
const lupa = await pagina.evaluate(() => window.__prueba.lupa());
comprobar('pellizcar acerca la vista', lupa < 0.8 && (await estado()).vista === 'cajones', `lupa ${lupa.toFixed(2)}`);
await pellizcar(ancho * 0.55, alto * 0.5, 320, 80, 14);
await espera(1.1);
comprobar('alejarse del todo con los dedos vuelve a la caja', (await estado()).vista === 'caja', (await estado()).vista);

await espera(0.5);
await tocar(605, 320, 'sala');
await espera(0.7);
await foto('07_lampara');
comprobar('la lámpara distrae al ojo', await pagina.evaluate(() => window.__prueba.ojo().distraidoHasta > window.__prueba.reloj()));
await tocarCajon('c8');
await espera(1.1);
if ((await estado()).vista === 'cajones' && (await cajon('c8')).estado === 'abierto') await tocarCajon('c8');
await espera(1.3);
await foto('08_llave_cogida');
e = await estado();
comprobar('con el ojo en la lámpara, la llave se coge y va a la bandeja', e.llave === 'mano' && e.inventario.includes('llave') && await pagina.isVisible('#hueco-llave'), e.llave);

await espera(1.0);
await tirarCajon('c8', -1.2);
await espera(0.8);
c = await cajon('c8');
comprobar('empujándolo, el cajón vacío se cierra', c.estado === 'cerrado' && c.k < 0.02, JSON.stringify(c));

await tirarCajon('c9');
await espera(0.9);
comprobar('el cajón de al lado se abre tirando', (await cajon('c9')).estado === 'abierto');
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
await hasta(() => window.__prueba.estado().llave === 'cerradura' && !window.__prueba.estado().ocupado);
await espera(0.4);
await foto('13_llave_metida');
e = await estado();
comprobar('la llave entra en la cerradura y se queda: hay que girarla', e.llave === 'cerradura' && e.tapa === 'puesta' && e.vista === 'incensario'
  && !e.inventario.includes('llave') && /[Gg]ír/.test(await mensaje()), await mensaje());
let cer = await pagina.evaluate(() => window.__prueba.pantallaBoceto(576, 508, 'incensario'));
await enCirculo(cer.x, cer.y, 55, -Math.PI / 2, 0.45);
await espera(0.6);
e = await estado();
comprobar('medio giro no basta: la llave vuelve', e.llave === 'cerradura' && (await pagina.evaluate(() => window.__prueba.llave().t)) < 0.05);
await enCirculo(cer.x, cer.y, 55, -Math.PI / 2, 1.5);
await hasta(() => window.__prueba.estado().tapa === 'suelta' && !window.__prueba.estado().ocupado);
await espera(0.3);
await foto('14_cerradura_abierta');
comprobar('girando el dedo en círculo, la llave abre la cerradura', (await estado()).llave === 'usada');
const tapa = await pagina.evaluate(() => window.__prueba.pantallaBoceto(575, 500, 'incensario'));
await arrastrar(tapa.x, tapa.y, tapa.x + 4, tapa.y - 14, 6);
await espera(0.6);
comprobar('si se suelta enseguida, la tapa cae en su sitio', (await estado()).tapa === 'suelta');
await arrastrar(tapa.x, tapa.y, tapa.x + 6, tapa.y - 110, 14);
await hasta(() => window.__prueba.estado().tapaEnMesa && !window.__prueba.estado().ocupado);
await espera(0.6);
await foto('15_abierto');
e = await estado();
comprobar('arrastrando hacia arriba, la tapa se levanta y queda en la mesa', e.tapa === 'abierta' && e.tapaEnMesa);
comprobar('sin la tapa, el incensario se sigue viendo (el cuenco y el cuerno en las brasas)',
  await pagina.evaluate(() => window.__prueba.incensarioVisible(575, 565) > 0.5 && window.__prueba.incensarioVisible(601, 478) > 0.5));

await tocar(593, 480, 'incensario');
await espera(1.3);
await foto('16_cuerno_cogido');
e = await estado();
comprobar('el cuerno sale de las brasas', e.cuerno === 'mano' && await pagina.isVisible('#hueco-cuerno'), e.cuerno);

if (await pagina.isVisible('#volver')) { await pagina.tap('#volver'); await espera(1.1); }
await pagina.tap('#hueco-cuerno');
await espera(0.3);
await tocar(912, 292);
await espera(2.6);
await foto('17_despertando');
await espera(2.2);
await foto('18_despierta');
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.6);
await foto('19_final');
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

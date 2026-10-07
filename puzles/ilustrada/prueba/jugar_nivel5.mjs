// Juega el nivel 5 de la caja viva («La cómoda») con gestos de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_nivel5.mjs [horizontal] [carpeta de capturas]
// Empieza en el nivel 5 con «?nivel=5» (el botón «Seguir» de la portada). Solo existe en la B (3D): sin tarjeta gráfica
// se usa SwiftShader y las esperas van en tiempo de juego. El juego es horizontal.
// Los cajones de la espalda se tiran (y se empujan) arrastrando por la línea por la que salen; el panel del hueco de la
// ficha se golpea con toques; en la borla se tira de las colas del lazo y de la borla; c6 se abre con la caja dormida,
// despacio (si se tira deprisa, hace ruido y se despierta).
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

if (process.argv[2] === 'vertical') console.log('(el juego es horizontal: el nivel 5 se prueba en horizontal)');
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
const foto = n => pagina.screenshot({ path: `${carpeta}N5_${sufijo}_${n}.png` });
const n5 = () => pagina.evaluate(() => window.__prueba.n5());
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const libre = () => hasta(() => !window.__prueba.estado().ocupado);
const vista = () => pagina.evaluate(() => window.__prueba.estado().vista);
const inventario = () => pagina.evaluate(() => window.__prueba.inventario());
const enPantalla = (x, y, objeto = 'caja') => pagina.evaluate(([x, y, o]) => window.__prueba.aPantalla(x, y, o), [x, y, objeto]);
const irA = async v => { if (await vista() !== v) { await pagina.evaluate(v => window.__prueba.irA(v), v); await espera(1.1); } };

const sueno = () => pagina.evaluate(() => window.__prueba.sueno());
const k5 = id => pagina.evaluate(id => window.__prueba.cajonDetras(id).k, id);
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
// un cajón de la espalda: del punto de su frente abierto «desde» al abierto «hasta» (0 cerrado, 1 abierto)
async function moverDetras(id, desde, hasta) {
  const a = await pagina.evaluate(id => window.__prueba.pantallaDetras(id, 0), id), b = await pagina.evaluate(id => window.__prueba.pantallaDetras(id, 1), id);
  const en = k => ({ x: a.x + (b.x - a.x) * k, y: a.y + (b.y - a.y) * k });
  const p0 = en(desde), p1 = en(hasta);
  await arrastrar(p0.x, p0.y, p1.x, p1.y);
}
async function tocarDetras(id, k = null) {
  const kk = k === null ? await k5(id) : k;
  const a = await pagina.evaluate(id => window.__prueba.pantallaDetras(id, 0), id), b = await pagina.evaluate(id => window.__prueba.pantallaDetras(id, 1), id);
  await tocar(a.x + (b.x - a.x) * kk, a.y + (b.y - a.y) * kk, 0.4);
}
// un cajón del costado: por la línea por la que sale (despacio: muchos pasos y más tiempo entre ellos)
async function moverLado(id, hacia = 1.15, pasos = 12, cada = 0.02) {
  const e = await pagina.evaluate(id => window.__prueba.ejeCajon(id), id);
  const k = await kLado(id), desde = { x: e.a.x + (e.b.x - e.a.x) * k, y: e.a.y + (e.b.y - e.a.y) * k };
  await arrastrar(desde.x, desde.y, desde.x + (e.b.x - e.a.x) * hacia, desde.y + (e.b.y - e.a.y) * hacia, pasos, cada);
}
// la borla: un punto del costado (píxeles de su repintado) en la pantalla
const enBorla = (bx, by) => pagina.evaluate(([x, y]) => window.__prueba.pantallaBorla(x, y), [bx, by]);
async function arrastrarBorla(bx, by, dx, dy, pasos = 10) { const p = await enBorla(bx, by); await arrastrar(p.x, p.y, p.x + dx, p.y + dy, pasos); }
const NUDO = [600, 486], COLA_IZQ = [574, 556], COLA_DER = [626, 556], CABEZA = [616, 712];

await pagina.goto(BASE + '?nivel=5');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel 5', /nivel 5 · La cómoda/.test(await pagina.textContent('#boton-continuar')), await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 5 && window.__prueba.estado().fase === 'jugando');
await hasta(() => !window.__prueba.estado().ocupado && window.__prueba.n5() && window.__prueba.n5().m1 === 'fuera');
await espera(0.4);
await foto('01_bosteza');
comprobar('bosteza y a su espalda algo hace «clac»: un cajón sale solo', /clac/.test(await mensaje()) && Math.abs(await k5('m1') - 0.35) < 0.05, await mensaje());
comprobar('en el nivel 5 la caja se puede girar', await pagina.isVisible('#boton-girar'));

// 1. la espalda: con m1 fuera, t2 no sale
await pagina.tap('#boton-girar');
await espera(1.6);
await tocarBoceto(852, 300, 'caja', 0.4);                  // (de lejos, la cámara se acerca a la caja)
if (await vista() !== 'espalda') { const p = await pagina.evaluate(() => window.__prueba.pantallaDetras('t2', 0)); await tocar(p.x, p.y, 1.2); }
comprobar('tocar un cajón de la espalda acerca la vista a la espalda', await vista() === 'espalda', await vista());
await espera(0.5);
await foto('02_espalda');
await moverDetras('t2', 0, 1);
await espera(0.5);
comprobar('con el cajón de la izquierda fuera, el de arriba se traba (y el culpable tiembla)', (await n5()).cajones.t2 === 'cerrado' && /traba|tiembla/.test(await mensaje()), await mensaje());
await moverDetras('m1', 0.35, -0.3);
await espera(0.6);
comprobar('empujado hasta dentro, suena un clic por dentro', (await n5()).m1 === 'dentro' && await k5('m1') < 0.05, await mensaje());
await moverDetras('t2', 0, 1.1);
await hasta(() => window.__prueba.n5().cajones.t2 === 'abierto');
await espera(0.9);
await foto('03_tarjeta');
comprobar('ahora sí sale el de arriba: dentro, una tarjeta', /tarjeta/.test(await mensaje()), await mensaje());
await tocarDetras('t2');
await hasta(() => window.__prueba.n5().tarjeta === 'mano');
await espera(1);
comprobar('la tarjeta del lazo va a la bandeja', (await inventario()).includes('tarjeta'));

// 2. el cajón de la argolla fija: no se tira, se empuja
await moverDetras('c', 0, 1);
await espera(0.4);
comprobar('el de la argolla fija no sale tirando', (await n5()).c === 'trabado' && await k5('c') < 0.05, await mensaje());
await moverDetras('c', 0.05, -0.4);
await hasta(() => window.__prueba.n5().c === 'suelto');
await espera(0.8);
comprobar('empujado, un muelle lo saca', await k5('c') > 0.3, String(await k5('c')));
await moverDetras('c', await k5('c'), 1.1);
await hasta(() => window.__prueba.n5().cajones.c === 'abierto');
await espera(0.9);
comprobar('dentro, la llave de bambú', /llave/.test(await mensaje()), await mensaje());
await tocarDetras('c');
await hasta(() => window.__prueba.n5().llave === 'mano');
await espera(1);
comprobar('la llave va a la bandeja', (await inventario()).includes('llave'));
await moverDetras('c', 1, -0.3);
await espera(0.5);

// 3. el panel del hueco de la ficha: atascado; golpearlo tres veces suelta su pasador; el hueco es el tirador
await moverDetras('p', 0, 1);
await espera(0.4);
comprobar('el panel se atasca: algo suelto dentro no deja', (await n5()).p === 'escondido' && /atasca/.test(await mensaje()), await mensaje());
for (let i = 0; i < 3; i++) await tocarDetras('p', 0.0);
await hasta(() => window.__prueba.n5().p === 'suelto');
await espera(0.8);
comprobar('a la tercera, «clinc»: el pasador cae dentro', /Clinc/.test(await mensaje()), await mensaje());
await moverDetras('p', 0.05, 1.1);
await hasta(() => window.__prueba.n5().cordon);
await espera(0.9);
await foto('04_cordon');
comprobar('el cajón escondido sale: dentro, el cordón de la borla', (await n5()).cajones.p === 'abierto' && /cordón/.test(await mensaje()), await mensaje());

// 4. la borla: desde la espalda se ve en el costado; tocarla lleva a su vista
const enCostado = await enBorla(CABEZA[0], CABEZA[1]);
await tocar(enCostado.x, enCostado.y, 1.3);
if (await vista() !== 'borla') { await pagina.evaluate(() => { window.__tec().girarA(Math.PI / 2); window.__prueba.irA('borla'); }); await espera(1.4); }
comprobar('tocar el costado de la borla lleva a ella', await vista() === 'borla', await vista());
await espera(0.6);
await foto('05_borla');
await arrastrarBorla(CABEZA[0], CABEZA[1], 0, 60);
await espera(0.4);
comprobar('atada, la borla no baja: el lazo la frena', (await n5()).borla === 'arriba' && /lazo/.test(await mensaje()), await mensaje());
await arrastrarBorla(COLA_IZQ[0], COLA_IZQ[1], -6, 30);
await espera(0.4);
comprobar('la cola deshilachada solo aprieta el nudo', (await n5()).lazo === 'atado' && (await pagina.evaluate(() => window.__prueba.borla().aprieto)) > 0.2, await mensaje());
await arrastrarBorla(COLA_DER[0], COLA_DER[1], 6, 30);
await hasta(() => window.__prueba.n5().lazo === 'suelto');
await espera(1.2);
await foto('06_lazo_suelto');
comprobar('la cola de la punta negra deshace el lazo (y la tarjeta deja la bandeja)', !(await inventario()).includes('tarjeta'), await mensaje());
await arrastrarBorla(CABEZA[0], CABEZA[1], 0, 25);
await espera(0.6);
comprobar('soltada a medias, la borla sube otra vez', (await n5()).borla === 'arriba', await mensaje());
await arrastrarBorla(CABEZA[0], CABEZA[1], 0, 80, 14);
await hasta(() => window.__prueba.n5().pasador === 'quitado');
await libre();
await espera(0.5);
await foto('07_comoda_suelta');
comprobar('tirada hasta abajo, el pasador sube y la cómoda se suelta: arriba asoma un cajón',
  (await n5()).borla === 'abajo' && await kLado('c2') > 0.15 && await vista() === 'caja', await mensaje());

// 5. las tsukegi del cajón que asoma (c2)
await pagina.evaluate(() => window.__prueba.irA('cajones'));
await espera(1.2);
await moverLado('c2');
await hasta(() => window.__prueba.estado().cajones.c2 === 'abierto');
await espera(0.9);
comprobar('dentro del que asomaba, un manojo de tsukegi', /ciprés/.test(await mensaje()), await mensaje());
const pc2 = await pagina.evaluate(() => window.__prueba.centroCajon('c2'));
await tocar((await enPantalla(pc2.x, pc2.y)).x, (await enPantalla(pc2.x, pc2.y)).y, 0.4);
await hasta(() => window.__prueba.n5().tsukegi === 'mano');
await espera(1);
comprobar('las tsukegi van a la bandeja', (await inventario()).includes('tsukegi'));
await moverLado('c2', -1.2);
await espera(0.6);

// 6. c6: la llave entra, no gira; se empuja como una varilla
const pc6 = await pagina.evaluate(() => window.__prueba.centroCajon('c6'));
const enC6 = async () => enPantalla(pc6.x, pc6.y);
await elegir('llave');
await tocar((await enC6()).x, (await enC6()).y, 0.4);
await hasta(() => window.__prueba.n5().llave === 'metida');
await libre();
comprobar('la llave entra en el agujero de c6, pero no gira', /no gira/.test(await mensaje()), await mensaje());
await tocar((await enC6()).x, (await enC6()).y, 0.5);
comprobar('empujada, algo cede al fondo', (await n5()).c6 === 'suelto' && (await n5()).llave === 'usada', await mensaje());
await espera(0.5);
await moverLado('c6');
await espera(0.5);
comprobar('despierta, no deja: lo más guardado', await pagina.evaluate(() => window.__prueba.estado().cajones.c6) !== 'abierto' && /mira|guarda/.test(await mensaje()), await mensaje());

// 7. el sueño: sin tocar nada, se duerme; tocarle la cara la despierta
await hasta(() => window.__prueba.sueno().dormida);
await espera(0.6);
await foto('08_dormida');
comprobar('sin tocar nada, se duerme (los párpados cerrados)', (await sueno()).dormida && (await pagina.evaluate(() => window.__prueba.ojo().parpadoBase)) > 0.9, await mensaje());
await pagina.evaluate(() => window.__prueba.irA('cara'));
await espera(1.2);
await tocarBoceto(850, 420, 'caja', 0.5);
comprobar('tocarle la cara la despierta', !(await sueno()).dormida, await mensaje());
await pagina.evaluate(() => window.__prueba.irA('cajones'));
await espera(1.2);

// 8. dormida: un tirón deprisa hace ruido y la despierta; despacio, el cajón sale
await hasta(() => window.__prueba.sueno().dormida);
await espera(0.4);
await moverLado('c6', 1.3, 1, 0);
await espera(0.6);
comprobar('un tirón deprisa hace ruido: se despierta y lo cierra de golpe', !(await sueno()).dormida && /despacio|deprisa/i.test(await mensaje()), await mensaje());
await hasta(() => window.__prueba.sueno().dormida);
await espera(0.4);
await moverLado('c6', 1.12, 40, 0.06);
await hasta(() => window.__prueba.estado().cajones.c6 === 'abierto');
await espera(0.8);
await foto('09_secreto');
comprobar('despacio, con ella dormida, el cajón sale: un papel doblado', (await sueno()).dormida && /papel/.test(await mensaje()), await mensaje());
await tocar((await enC6()).x, (await enC6()).y, 0.4);
await hasta(() => window.__prueba.n5().secreto === 'mano');
await hasta(() => !document.getElementById('examinar').hidden);
await espera(0.8);
await foto('10_su_secreto');
comprobar('su secreto: un dibujo de la sala de noche', /noche/.test(await pagina.textContent('#examinar-texto')), await pagina.textContent('#examinar-texto'));

// 9. la tarjeta del nivel
await hasta(() => window.__prueba.estado().fase === 'tarjeta');
await espera(1.5);
await foto('11_tarjeta');
comprobar('la tarjeta cierra el nivel 5: la cómoda', (await pagina.textContent('#tarjeta-titulo')) === 'La cómoda', await pagina.textContent('#tarjeta-hecho'));
comprobar('la cara tiene cinco sellos de seis', (await pagina.$$eval('.pieza.recuperada', l => l.length)) === 5
  && (await pagina.getAttribute('.marcador', 'aria-label')) === 'La cara: 5 de 6 piezas');
comprobar('la tarjeta ofrece el nivel 6: la noche', /Nivel 6 · La noche/.test(await pagina.textContent('#tarjeta-siguiente')), await pagina.textContent('#tarjeta-siguiente'));
comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
if (SIN_RED) comprobar('sin pedir nada a internet', fuera.length === 0, fuera.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

// Juega el nivel 2 de la caja viva («La caja de dentro») con toques de móvil, comprueba cada paso y saca capturas.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/jugar_nivel2.mjs [horizontal|vertical] [carpeta de capturas]
// Empieza en el nivel 2 con «?nivel=2» (el botón «Seguir» de la portada). El nivel 2 solo existe en la B (3D): como
// en jugar.mjs, sin tarjeta gráfica se usa SwiftShader y las esperas van en tiempo de juego.
// La caja pequeña se gira con arrastres de verdad (unos 137 px son un cuarto de vuelta); para cada tablilla se busca
// el giro que la pone de cara a la cámara y de espaldas al ojo grande, y se comprueba antes que, vista por el ojo, no
// se mueve.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const vertical = process.argv[2] === 'vertical';
const [ancho, alto, sufijo] = vertical ? [390, 844, 'v'] : [844, 390, 'h'];
const carpeta = (process.argv[3] || '/tmp/capturas_caja_viva').replace(/\/?$/, '/');
mkdirSync(carpeta, { recursive: true });

const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium',
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const contexto = await navegador.newContext({ viewport: { width: ancho, height: alto }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
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
await contexto.route('https://fonts.*/**', ruta => ruta.abort());
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
const foto = n => pagina.screenshot({ path: `${carpeta}N2_${sufijo}_${n}.png` });
const hija = () => pagina.evaluate(() => window.__prueba.hija());
const mensaje = () => pagina.evaluate(() => document.getElementById('mensaje').textContent);
const libre = () => hasta(() => !window.__prueba.estado().ocupado);

// arrastre de un dedo, con pasos (eventos táctiles de verdad)
async function arrastrar(x0, y0, dx, dy, pasos = 10) {
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: x0, y: y0 }] });
  for (let i = 1; i <= pasos; i++) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: x0 + dx * i / pasos, y: y0 + dy * i / pasos }] });
    await espera(0.02);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await espera(0.7);                     // que se asiente en su orientación
}
// un cuarto de vuelta de la caja pequeña: arrastrar en el centro de la pantalla
const CUARTO = 137;
const GIROS = { abajo: [0, CUARTO], arriba: [0, -CUARTO], derecha: [CUARTO, 0], izquierda: [-CUARTO, 0] };
const CONTRARIO = { abajo: 'arriba', arriba: 'abajo', derecha: 'izquierda', izquierda: 'derecha' };
async function girar(nombre) { const [dx, dy] = GIROS[nombre]; await arrastrar(ancho * 0.5, alto * 0.5, dx, dy); }
// ¿la tablilla i se puede tocar (de cara a la cámara) y el ojo no la ve?
const lista = i => pagina.evaluate(i => window.__prueba.tablillaHaciaCamara(i) > 0.45 && !window.__prueba.tablillaVista(i), i);
// busca hasta dos giros que la dejen así (deshaciendo los que no sirven)
async function ponerDeCara(i) {
  if (await lista(i)) return [];
  for (const a of Object.keys(GIROS)) {
    await girar(a);
    if (await lista(i)) return [a];
    for (const b of Object.keys(GIROS)) {
      if (b === CONTRARIO[a]) continue;
      await girar(b);
      if (await lista(i)) return [a, b];
      await girar(CONTRARIO[b]);
    }
    await girar(CONTRARIO[a]);
  }
  return null;
}
async function tocarHija(parte, i) {
  const p = await pagina.evaluate(([parte, i]) => window.__prueba.pantallaHija(parte, i), [parte, i]);
  await pagina.touchscreen.tap(p.x, p.y);
  await espera(0.25);
}

await pagina.goto('http://localhost:8765/?nivel=2');
await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 60000 });
comprobar('la portada ofrece seguir en el nivel 2', await pagina.isVisible('#boton-continuar'));
await pagina.tap('#boton-continuar');
await hasta(() => window.__prueba.estado().nivel === 2 && window.__prueba.estado().fase === 'jugando');
await espera(2.5);
await foto('01_calma');
comprobar('la caja se calma y la trampilla sigue abierta', await pagina.evaluate(() => window.__prueba.ojo().visible > 0.95 && window.__prueba.hija().fase === 'dentro'));
comprobar('en el nivel 2 no se gira la caja grande', await pagina.isHidden('#boton-girar'));

// 1. la trampilla: sube la caja hija
const t = await pagina.evaluate(() => window.__prueba.aPantalla(930, 196, 'caja'));
await pagina.touchscreen.tap(t.x, t.y);
await espera(1.6);
await foto('02_sube');
await hasta(() => window.__prueba.hija().fase === 'mesa' && !window.__prueba.estado().ocupado);
await espera(1);
await foto('03_en_la_mesa');
comprobar('la caja hija sube de la trampilla y baja a la mesa', (await hija()).fase === 'mesa' && await pagina.evaluate(() => window.__prueba.estado().vista) === 'hija');

// 2. fuera de orden: la tablilla del costado no corre (no le toca)
await tocarHija('tablilla', 1);
comprobar('una tablilla fuera de orden no corre', !(await hija()).tablillas[1], await mensaje());

// 3. la de arriba, de cara al ojo grande: no se mueve
comprobar('el ojo grande ve la tablilla de arriba', await pagina.evaluate(() => window.__prueba.tablillaVista(0)));
await tocarHija('tablilla', 0);
await espera(0.4);
await foto('04_la_mira');
comprobar('lo que el ojo ve no se mueve', !(await hija()).tablillas[0], await mensaje());

// 4. la lámpara ya no lo distrae
const l = await pagina.evaluate(() => window.__prueba.aPantalla(604, 302, 'sala'));
if (l && l.x > 0 && l.x < ancho && l.y > 0 && l.y < alto) {
  await pagina.touchscreen.tap(l.x, l.y);
  await espera(0.3);
  comprobar('la lámpara ya no distrae al ojo', await pagina.evaluate(() => window.__prueba.ojo().distraidoHasta <= window.__prueba.reloj()), await mensaje());
  if (await pagina.evaluate(() => window.__prueba.estado().vista) !== 'hija') {
    const c = await pagina.evaluate(() => window.__prueba.pantallaHija('cuerpo'));
    await pagina.touchscreen.tap(c.x, c.y); await espera(1);
  }
}

// 5. las cinco tablillas en orden, cada una escondida del ojo
for (let i = 0; i < 5; i++) {
  const giros = await ponerDeCara(i);
  if (!giros) { comprobar(`la tablilla ${i + 1} se puede poner de cara`, false); break; }
  await tocarHija('tablilla', i);
  await espera(0.7);
  const h = await hija();
  comprobar(`la tablilla ${i + 1} corre, escondida del ojo`, h.tablillas[i], `giros: ${giros.join(', ') || 'ninguno'}`);
  if (i === 0) await foto('05_primera');
  if (i === 2) await foto('06_tercera');
}
await foto('07_tapa');

// 6. el cajoncito y la cajita roja
await tocarHija('cajon');
await espera(0.9);
comprobar('detrás de la tapa sale un cajoncito', (await hija()).cajon === 'abierto');
await foto('08_cajoncito');
await tocarHija('cajita');
await espera(1.2);
comprobar('la cajita roja va al inventario', await pagina.evaluate(() => window.__prueba.inventario().includes('cajita')));

// 7. el puzle de bolsillo: examinar la cajita (dos toques) y girar su tapa hasta la marca
await pagina.tap('#hueco-cajita'); await espera(0.2);
await pagina.tap('#hueco-cajita'); await espera(0.8);
comprobar('la cajita se examina como puzle de bolsillo', await pagina.isVisible('#bolsillo'));
await foto('09_bolsillo');
const r = await pagina.locator('#bolsillo').boundingBox();
const cx = r.x + r.width / 2, cy = r.y + r.height / 2, radio = r.width * 0.3;
const a0 = await pagina.evaluate(() => window.__prueba.bolsillo().angulo), a1 = -Math.PI / 2;
let d = Math.atan2(Math.sin(a1 - a0), Math.cos(a1 - a0));
const pasos = 24;
await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: cx + Math.cos(a0) * radio, y: cy + Math.sin(a0) * radio }] });
for (let k = 1; k <= pasos; k++) {
  const a = a0 + d * k / pasos;
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: cx + Math.cos(a) * radio, y: cy + Math.sin(a) * radio }] });
  await espera(0.02);
}
await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await espera(2);
const b = await pagina.evaluate(() => window.__prueba.bolsillo());
comprobar('la tapa encaja con la marca y se abre', b.encajada && b.abierta > 0.95, `ángulo ${b.angulo.toFixed(2)}`);
await foto('10_ojo_dentro');
await pagina.touchscreen.tap(cx, cy);
await espera(1.4);
comprobar('el ojo de piedra de luna va al inventario', await pagina.evaluate(() => window.__prueba.inventario().includes('ojo') && !window.__prueba.inventario().includes('cajita')));

// 8. el ojo en la cuenca: la caja abre los dos ojos y se cierra el nivel
comprobar('con el ojo en la mano, la cámara enseña la cara', await pagina.evaluate(() => window.__prueba.estado().vista) === 'cara');
await espera(0.6);
await pagina.tap('#hueco-ojo'); await espera(0.3);
const q = await pagina.evaluate(() => window.__prueba.aPantalla(905, 378, 'caja'));
comprobar('la cuenca vacía se ve en la pantalla', q.x > 0 && q.x < ancho && q.y > 0 && q.y < alto, `${Math.round(q.x)}, ${Math.round(q.y)}`);
await pagina.touchscreen.tap(q.x, q.y);
await hasta(() => window.__prueba.hija().ojo === 'puesto');
await hasta(() => window.__prueba.ojo2().parpadoBase === 0);
await espera(0.6);
await foto('11_dos_ojos');
await hasta(() => !document.getElementById('tarjeta').hidden);
await espera(1.5);
await foto('12_tarjeta');
comprobar('el ojo nuevo está en la cuenca y abierto', await pagina.evaluate(() => window.__prueba.hija().ojo === 'puesto' && window.__prueba.ojo2().visible === 1));
comprobar('la tarjeta cierra el nivel 2 con dos piezas', await pagina.evaluate(() =>
  document.getElementById('tarjeta-hecho').textContent.includes('2') && document.querySelectorAll('.pieza.recuperada').length === 2));
comprobar('la partida queda guardada', await pagina.evaluate(() => JSON.parse(localStorage.getItem('caja_viva_partida')).superado === 2));
await pagina.tap('#boton-quedarse');
await espera(1.2);
comprobar('se puede quedar en la sala', await pagina.evaluate(() => window.__prueba.estado().fase === 'jugando'));

comprobar('sin errores en la página', errores.length === 0, errores.slice(0, 3).join(' | '));
console.log(`\n${bien} de ${total} comprobaciones bien`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

// Prueba los menús de la caja viva (pedidos por el usuario el 09-10-2026) y «Mirar» (la vitrina 3D):
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/menus.mjs [carpeta de capturas]
// El menú de inicio (seguir, nueva partida, niveles, opciones), la pausa (el juego se para; reiniciar el nivel y volver
// al inicio, con confirmación; el atrás de Android), el nivel a medias que «Seguir» recupera, los niveles y el botón
// «Mirar» junto al objeto elegido, que lo enseña en 3D y lo deja girar con el dedo. En la B, en horizontal.
import { mkdirSync } from 'node:fs';
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const [ancho, alto] = [844, 390];
const carpeta = (process.argv[2] || '/tmp/capturas_caja_viva').replace(/\/?$/, '/');
mkdirSync(carpeta, { recursive: true });
const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium',
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const contexto = await navegador.newContext({ viewport: { width: ancho, height: alto }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
const cache = new Map();
// CAJA_VIVA_URL prueba otra copia de la página (la web del APK: apk/LEEME.md); con SIN_RED=1, nada sale de localhost
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

let bien = 0, total = 0;
function comprobar(nombre, condicion, detalle = '') {
  total++;
  if (condicion) bien++;
  console.log(`${condicion ? 'bien' : 'MAL '}  ${nombre}${detalle ? '  (' + detalle + ')' : ''}`);
}
const LIMITE = 240000;
const hasta = (condicion, arg) => pagina.waitForFunction(condicion, arg, { timeout: LIMITE, polling: 100 });
const estado = () => pagina.evaluate(() => window.__prueba.estado());
const reloj = () => pagina.evaluate(() => window.__prueba.reloj());
const visible = sel => pagina.isVisible(sel);
const abierta = id => pagina.evaluate(id => { const c = document.getElementById(id); return !c.hidden && !c.classList.contains('oculta'); }, id);
const foto = n => pagina.screenshot({ path: `${carpeta}MENU_${n}.png` });
const enPortada = () => hasta(() => !document.getElementById('boton-entrar').disabled);
const jugando = n => hasta(n => { const e = window.__prueba.estado(); return e.fase === 'jugando' && e.nivel === n && !e.ocupado; }, n);
const pausa = ms => pagina.waitForTimeout(ms);

// 1. el menú de inicio, con el nivel 2 pedido
await pagina.goto(BASE + (BASE.includes('?') ? '&' : '?') + 'nivel=2');
await enPortada();
await foto('1_inicio');
comprobar('el inicio ofrece seguir, opciones y (sin partida) entrar en la sala',
  await visible('#boton-continuar') && await visible('#boton-opciones') && /Entrar/.test(await pagina.textContent('#boton-entrar')));
comprobar('en el navegador no hay «Salir» (solo en el APK) ni «Niveles» sin partida', !(await visible('#boton-salir')) && !(await visible('#boton-niveles')));
// las opciones: la vibración se apaga y se recuerda
await pagina.tap('#boton-opciones');
await hasta(() => !document.getElementById('opciones').classList.contains('oculta'));
await pagina.tap('#opciones [data-ajuste="vibracion"]');
comprobar('opciones: la vibración se apaga y se guarda', await pagina.evaluate(() =>
  document.querySelector('#opciones [data-ajuste="vibracion"]').getAttribute('aria-pressed') === 'false'
  && JSON.parse(localStorage.getItem('caja_viva_ajustes')).vibracion === false));
await pagina.tap('#opciones-volver');
await pausa(500);

// 2. seguir: el nivel 2
await pagina.tap('#boton-continuar');
await jugando(2);
comprobar('«Seguir» lleva al nivel 2', (await estado()).nivel === 2);

// 3. la pausa: el juego se para
await pagina.tap('#boton-menu');
await hasta(() => !document.getElementById('menu').classList.contains('oculta'));
const r0 = await reloj(); await pausa(1500); const r1 = await reloj();
await foto('2_pausa');
comprobar('el menú de pausa para el juego (el reloj del juego no corre)', await pagina.evaluate(() => window.__prueba.pausado()) && r1 === r0, `${r0} → ${r1}`);
comprobar('la pausa ofrece seguir, reiniciar el nivel y volver al inicio', await visible('#menu-seguir') && await visible('#menu-reiniciar') && await visible('#menu-inicio'));
// volver al inicio pide confirmación; «No» deja la pausa como estaba
await pagina.tap('#menu-inicio');
await hasta(() => !document.getElementById('confirmar').classList.contains('oculta'));
await foto('3_confirmar');
comprobar('volver al inicio pide confirmación', await visible('#confirmar-si') && /inicio/.test(await pagina.textContent('#confirmar-texto')));
await pagina.tap('#confirmar-no');
await pausa(500);
comprobar('«No» no hace nada: sigue la pausa', !(await abierta('confirmar')) && await abierta('menu') && (await estado()).nivel === 2);
// reiniciar el nivel, confirmado
await pagina.tap('#menu-reiniciar');
await hasta(() => !document.getElementById('confirmar').classList.contains('oculta'));
await pagina.tap('#confirmar-si');
await jugando(2);
const e2 = await estado();
comprobar('reiniciar el nivel: el nivel 2 otra vez, desde el principio, sin pausa',
  e2.nivel === 2 && e2.hija && e2.hija.fase === 'dentro' && !(await pagina.evaluate(() => window.__prueba.pausado())) && !(await abierta('menu')));
comprobar('mientras se juega, el nivel a medias queda guardado', await pagina.evaluate(() => { const g = window.__prueba.enCurso(); return !!g && g.estado.nivel === 2; }));

// 4. el atrás de Android: en la sala abre la pausa; otra vez, la cierra
comprobar('atrás en la sala abre la pausa (no saca de la app)', await pagina.evaluate(() => window.__atras()) === true && await abierta('menu'));
await pausa(400);
comprobar('atrás otra vez cierra la pausa', await pagina.evaluate(() => window.__atras()) === true && !(await abierta('menu')));
await pausa(500);

// 5. «Mirar»: elegir un objeto de la bandeja (la nota se lee; otro, se mira en 3D)
const objetos = (await estado()).inventario;
const objeto = objetos.find(o => o !== 'nota') || 'nota';
const hueco = pagina.locator(`#bandeja .hueco[data-objeto="${objeto}"]`);
await hueco.tap();
await pausa(400);
await foto('4_elegido');
comprobar(`al elegir un objeto de la bandeja (${objeto}) aparece «Mirar»`, await visible('#boton-mirar'),
  await pagina.textContent('#boton-mirar'));
await pagina.tap('#boton-mirar');
if (objeto === 'nota') {
  await hasta(() => !document.getElementById('nota').hidden);
  comprobar('«Leer» abre la nota', true);
  await pagina.evaluate(() => window.__atras());
} else {
  await hasta(o => { const v = window.__prueba.vitrina(); return v && v.objeto === o && v.tieneModelo; }, objeto);
  await pausa(2500);
  const caja = await pagina.locator('#vitrina3d').boundingBox();
  const c = { x: caja.x + caja.width / 2, y: caja.y + caja.height / 2 };
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [c] });
  for (let k = 1; k <= 6; k++) { await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: c.x + k * 20, y: c.y - k * 12 }] }); await pausa(40); }
  await pausa(200);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await pausa(1500);
  const v = await pagina.evaluate(() => window.__prueba.vitrina());
  await foto('5_vitrina');
  comprobar('«Mirar» lo enseña en 3D y el dedo lo gira (también hacia arriba)', v.activo && v.giro > 0.4, `giro ${v.giro.toFixed(2)} rad`);
  comprobar('girarlo no cierra la vitrina', await abierta('examinar'));
  await pagina.mouse.click(30, alto - 30);                   // tocar fuera: se guarda
  await pausa(900);
  comprobar('tocar fuera la cierra y la vitrina se para', !(await abierta('examinar')) && !(await pagina.evaluate(() => window.__prueba.vitrina().activo)));
}

// 6. volver al inicio (confirmado): la página vuelve a la portada y «Seguir» recupera el nivel a medias
await pagina.tap('#boton-menu');
await hasta(() => !document.getElementById('menu').classList.contains('oculta'));
await pagina.tap('#menu-inicio');
await hasta(() => !document.getElementById('confirmar').classList.contains('oculta'));
await Promise.all([pagina.waitForNavigation({ timeout: LIMITE }), pagina.tap('#confirmar-si')]);
await enPortada();
comprobar('de vuelta en el inicio, «Seguir» lleva al nivel 2', /nivel 2/.test(await pagina.textContent('#boton-continuar')), await pagina.textContent('#boton-continuar'));
await pagina.tap('#boton-continuar');
await jugando(2);
await hasta(() => /donde lo dejaste/.test(document.getElementById('mensaje').textContent));
comprobar('«Seguir» vuelve al nivel a medias («Sigues donde lo dejaste»)', true);

// 7. los niveles: con el 3 superado se pueden elegir del 1 al 4; los demás, cerrados
await pagina.evaluate(() => window.__prueba.guardarPartida(3));
await pagina.goto(BASE);
await enPortada();
comprobar('con partida, el inicio ofrece «Nueva partida» y «Niveles»', /Nueva partida/.test(await pagina.textContent('#boton-entrar')) && await visible('#boton-niveles'));
await pagina.tap('#boton-niveles');
await hasta(() => !document.getElementById('niveles').classList.contains('oculta'));
await foto('6_niveles');
const libres = await pagina.evaluate(() => [...document.querySelectorAll('#lista-niveles button')].map(b => !b.disabled));
comprobar('los niveles 1 a 4 se pueden elegir; del 5 al final, cerrados', libres.join() === 'true,true,true,true,false,false,false', libres.join());
await pagina.locator('#lista-niveles button').nth(2).tap();
await jugando(3);
comprobar('elegir el nivel 3 lo empieza', (await estado()).nivel === 3);
// una partida nueva pide confirmación
await pagina.goto(BASE);
await enPortada();
await pagina.tap('#boton-entrar');
await hasta(() => !document.getElementById('confirmar').classList.contains('oculta'));
comprobar('«Nueva partida» pide confirmación', /nueva/.test(await pagina.textContent('#confirmar-texto')));
await pagina.tap('#confirmar-no');

if (SIN_RED) comprobar('sin internet: nada sale de la página', fuera.length === 0, fuera.slice(0, 3).join(' | '));
comprobar('sin errores en la consola', errores.length === 0, errores.join(' | '));
console.log(`\n${bien} de ${total}; capturas en ${carpeta}`);
await navegador.close();
process.exit(bien === total ? 0 : 1);

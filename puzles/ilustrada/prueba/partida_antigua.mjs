// Comprueba la partida guardada en la portada: adónde lleva «Seguir» con partidas de antes y de ahora.
//   python3 puzles/ilustrada/prueba/servir.py &
//   node puzles/ilustrada/prueba/partida_antigua.mjs
// Hasta la 0.7 la partida no guardaba cuántos niveles tenía el juego, y en la 0.6 el final era el nivel 5: una partida
// de la 0.6 con el final hecho tiene que seguir en «La cómoda» (el 5 de ahora), no saltársela. Solo mira la portada
// (con la B, que es la que ofrece «Seguir»), sin jugar ni internet: tarda poco y no necesita WebGL.
import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';

const navegador = await chromium.launch({ headless: true, executablePath: '/opt/pw-browsers/chromium' });
// CAJA_VIVA_URL prueba otra copia de la página (por ejemplo, la web del APK: apk/LEEME.md); con SIN_RED=1, cualquier
// petición fuera de localhost falla
const BASE = process.env.CAJA_VIVA_URL || 'http://localhost:8765/';
const SIN_RED = process.env.SIN_RED === '1';

let bien = 0, total = 0;
function comprobar(nombre, condicion, detalle = '') {
  total++;
  if (condicion) bien++;
  console.log(`${condicion ? 'bien' : 'MAL '}  ${nombre}${detalle ? '  (' + detalle + ')' : ''}`);
}

// abre la portada con esta partida guardada (o sin ninguna) y devuelve lo que dice «Seguir» y la partida leída
async function portada(guardada, despues) {
  const contexto = await navegador.newContext({ viewport: { width: 844, height: 390 }, isMobile: true, hasTouch: true });
  await contexto.route(url => !url.href.startsWith('http://localhost'), ruta => ruta.abort());
  if (guardada) await contexto.addInitScript(g => { try { localStorage.setItem('caja_viva_partida', g); } catch (e) {} }, JSON.stringify(guardada));
  const pagina = await contexto.newPage();
  const errores = [];
  pagina.on('pageerror', e => errores.push(e.message));
  await pagina.goto(BASE);
  await pagina.waitForFunction(() => !document.getElementById('boton-entrar').disabled, null, { timeout: 120000 });
  const leido = await pagina.evaluate(() => ({
    seguir: document.getElementById('boton-continuar').hidden ? null : document.getElementById('boton-continuar').textContent,
    partida: window.__prueba.partida ? window.__prueba.partida() : null,
  }));
  if (despues) leido.despues = await pagina.evaluate(despues);
  await contexto.close();
  return { ...leido, errores };
}

let r = await portada(null);
comprobar('sin partida no hay «Seguir»', r.seguir === null, r.seguir);
comprobar('sin errores en la página', r.errores.length === 0, r.errores.join(' | '));

// la 0.6: el final era el 5
r = await portada({ superado: 5, fecha: Date.UTC(2026, 9, 7, 19) });
comprobar('0.6 con el final hecho → sigue en La cómoda', r.seguir === 'Seguir: nivel 5 · La cómoda', r.seguir);
comprobar('…y la partida se lee con el 4 superado', r.partida && r.partida.superado === 4, JSON.stringify(r.partida));

r = await portada({ superado: 4, fecha: Date.UTC(2026, 9, 7, 19) });
comprobar('0.6 con El oro hecho → sigue en La cómoda', r.seguir === 'Seguir: nivel 5 · La cómoda', r.seguir);

r = await portada({ superado: 2, fecha: Date.UTC(2026, 9, 5, 19) });
comprobar('una partida vieja a medias no cambia', r.seguir === 'Seguir: nivel 3 · La voz', r.seguir);

// la 0.7 sin el número: el 6 solo puede ser «La noche»
r = await portada({ superado: 6, fecha: Date.UTC(2026, 9, 7, 23) });
comprobar('sin el número, el 6 superado → el final', r.seguir === 'Seguir: nivel final · El corazón', r.seguir);

// las de ahora: guardan cuántos niveles hay y el 5 es La cómoda
r = await portada({ superado: 5, niveles: 7, fecha: Date.now() });
comprobar('ahora, La cómoda hecha → sigue en La noche', r.seguir === 'Seguir: nivel 6 · La noche', r.seguir);

// guardar desde una partida vieja: el número se escribe y no se pierde lo superado
r = await portada({ superado: 5, fecha: Date.UTC(2026, 9, 7, 19) }, () => {
  window.__prueba.guardarPartida(5);
  return JSON.parse(localStorage.getItem('caja_viva_partida'));
});
comprobar('al superar La cómoda se guarda con el número de niveles', r.despues && r.despues.superado === 5 && r.despues.niveles === 7,
  JSON.stringify(r.despues));
r = await portada(r.despues);
comprobar('…y la portada sigue en La noche', r.seguir === 'Seguir: nivel 6 · La noche', r.seguir);

await navegador.close();
console.log(`\n${bien} de ${total} comprobaciones${SIN_RED ? ' (sin red)' : ''}`);
process.exit(bien === total ? 0 : 1);

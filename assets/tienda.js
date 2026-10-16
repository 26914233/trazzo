/* Tienda web de Prismas de Curtzz.
   Mientras SERVIDOR esté vacío la tienda no vende: enseña un aviso y el botón de pago queda desactivado.
   Todo lo que llega del servidor se pinta como TEXTO (createElement/textContent): nunca se interpreta como HTML. */
(function () {
  'use strict';

  // URL del servidor de compras (07-Servidor en Railway), sin barra final. Vacía = la tienda aún no vende.
  // Al rellenarla, ajusta también connect-src en la CSP de tienda.html (ver README.md).
  const SERVIDOR = '';

  // Moneda y precios: los dice el servidor (/v1/web/paquetes). Estos son de reserva (USD).
  let MONEDA = 'USD';
  let PAQUETES = [
    { id: 'web_250', prismas: 250, base: 200, precio: 1.99 },
    { id: 'web_690', prismas: 690, base: 550, precio: 4.99 },
    { id: 'web_1500', prismas: 1500, base: 1200, precio: 9.99 },
    { id: 'web_3125', prismas: 3125, base: 2500, precio: 19.99 }
  ];

  const CLAVE_PEDIDO = 'curtzz_pedido';
  const ID_VALIDO = /^[A-Za-z0-9_-]{1,80}$/;
  const HOST_MERCADOPAGO = /^(www\.)?mercadopago\.(com|com\.[a-z]{2})$/;
  const MAX_INTENTOS = 90;
  const espera = (n) => (n < 20 ? 3000 : 10000);
  const ESPERA_ERROR = 5000;

  const $ = (s) => document.querySelector(s);
  const params = new URLSearchParams(location.search);
  let elegido = params.get('paquete') || '';
  const fmt = (n) => n.toLocaleString('es-CO');
  const precio = (n) => (MONEDA === 'USD' ? n.toFixed(2).replace('.', ',') + ' US$' : fmt(n) + ' ' + MONEDA);

  // Solo se sale a una página de pago de Mercado Pago: https, sin usuario ni puerto y con un dominio exacto
  // (mercadopago.com, mercadopago.com.co, www.mercadopago.com.ar...; nunca mercadopago.evil.tk).
  function pagoSeguro(u) {
    let x;
    try { x = new URL(String(u || '')); } catch (e) { return false; }
    return x.protocol === 'https:' && !x.username && !x.password && x.port === '' && HOST_MERCADOPAGO.test(x.hostname);
  }

  function el(tag, clase, texto) {
    const e = document.createElement(tag);
    if (clase) e.className = clase;
    if (texto != null) e.textContent = texto;
    return e;
  }

  // Mensaje en la región #estado (role="status"); partes = nodos o textos
  function mostrar(clase, ...partes) {
    const est = $('#estado');
    const caja = el('div', 'box' + (clase ? ' ' + clase : ''));
    partes.forEach((p) => caja.append(p));
    // si el mensaje no cambia (sondeo repetido) no se repinta: así el lector de pantalla no lo repite cada pocos segundos
    const actual = est.firstElementChild;
    if (actual && actual.className === caja.className && actual.textContent === caja.textContent) return actual;
    est.replaceChildren(caja);
    return caja;
  }

  function guardarPedido(id) { try { localStorage.setItem(CLAVE_PEDIDO, id); } catch (e) { /* sin almacenamiento: no pasa nada */ } }
  function borrarPedido() { try { localStorage.removeItem(CLAVE_PEDIDO); } catch (e) { /* idem */ } }
  function leerPedido() { try { return localStorage.getItem(CLAVE_PEDIDO); } catch (e) { return null; } }

  /* ---------- paquetes ---------- */
  function pintar() {
    const cont = $('#packs');
    const activo = document.activeElement;
    const previo = activo && activo.classList && activo.classList.contains('pack') ? activo.dataset.id : null;
    cont.replaceChildren();
    PAQUETES.forEach((p) => {
      const b = el('button', 'pack' + (p.id === elegido ? ' sel' : ''));
      b.type = 'button';
      b.dataset.id = p.id;
      b.setAttribute('aria-pressed', p.id === elegido ? 'true' : 'false');
      b.append(
        el('span', 'n', fmt(p.prismas)),
        el('span', null, 'Prismas'),
        el('span', 'b', fmt(p.base) + ' + ' + fmt(p.prismas - p.base) + ' de bono'),
        el('span', 'p', precio(p.precio))
      );
      b.addEventListener('click', () => elegir(p.id));
      cont.append(b);
    });
    if (previo) {
      const f = [...cont.children].find((x) => x.dataset.id === previo);
      if (f) f.focus();
    }
    boton();
  }

  function elegir(id) {
    elegido = id;
    document.querySelectorAll('.pack').forEach((b) => {
      const on = b.dataset.id === id;
      b.classList.toggle('sel', on);
      b.setAttribute('aria-pressed', on ? 'true' : 'false');
    });
    boton();
    const b = document.querySelector('.pack[aria-pressed="true"]');
    if (b) b.focus();   // el foco vuelve al paquete elegido (Safari y Firefox en Mac no enfocan al pulsar)
  }

  function boton() {
    const btn = $('#pagar');
    if (!SERVIDOR) { btn.disabled = true; btn.textContent = 'Pagar (aún no disponible)'; return; }
    const p = PAQUETES.find((x) => x.id === elegido);
    btn.disabled = !p;
    btn.textContent = p ? 'Pagar ' + precio(p.precio) : 'Elige un paquete';
  }

  /* ---------- pago ---------- */
  $('#pagar').addEventListener('click', async () => {
    const btn = $('#pagar');
    btn.disabled = true; btn.textContent = 'Abriendo el pago…';
    try {
      const r = await fetch(SERVIDOR + '/v1/web/pedido', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ paquete: elegido }) });
      if (!r.ok) throw new Error(String(r.status));
      const d = await r.json();
      if (!pagoSeguro(d.pagar)) throw new Error('enlace de pago no válido');
      if (ID_VALIDO.test(String(d.pedido))) guardarPedido(String(d.pedido));
      location.href = new URL(d.pagar).href;
    } catch (e) {
      mostrar('bad', 'No se pudo abrir el pago. Prueba otra vez en un momento.');
      boton();
    }
  });
  // Al volver con «Atrás» la página puede venir de la caché con el botón bloqueado.
  window.addEventListener('pageshow', (e) => { if (e.persisted) boton(); });

  /* ---------- seguimiento del pedido ---------- */
  function finalizar(clase, texto) { mostrar(clase, texto); }

  function reintentar(pid, almacen, intentos, ms) {
    if (intentos + 1 >= MAX_INTENTOS) {
      finalizar('', 'Sigue pendiente: vuelve a esta página más tarde, el código no se pierde.');
      return;
    }
    setTimeout(() => seguir(pid, almacen, intentos + 1), ms);
  }

  // Vuelta desde Mercado Pago (o pedido guardado en el navegador): esperar a que el pago se confirme y enseñar el código.
  async function seguir(pid, almacen, intentos) {
    let r;
    try {
      r = await fetch(SERVIDOR + '/v1/web/pedido/' + encodeURIComponent(pid));
    } catch (e) {
      mostrar('', 'No pudimos consultar el pedido. Reintentando…');
      return reintentar(pid, almacen, intentos, ESPERA_ERROR);
    }
    if (r.status === 404) {
      // el pedido no existe: respuesta final, se deja de sondear
      if (almacen) borrarPedido();
      return finalizar('bad', 'No encontramos ese pedido. Puede que el enlace esté incompleto o que el pedido ya no exista. Si pagaste, escríbenos (correo al pie de la página) con tu comprobante de pago.');
    }
    if (!r.ok) {
      if (r.status >= 400 && r.status < 500 && r.status !== 408 && r.status !== 429) {
        return finalizar('bad', 'No se pudo comprobar el pedido (error ' + r.status + '). Revisa el enlace e inténtalo de nuevo.');
      }
      mostrar('', 'No pudimos consultar el pedido. Reintentando…');
      return reintentar(pid, almacen, intentos, r.status === 429 ? 10000 : ESPERA_ERROR);
    }
    let d;
    try { d = await r.json(); } catch (e) {
      mostrar('', 'No pudimos consultar el pedido. Reintentando…');
      return reintentar(pid, almacen, intentos, ESPERA_ERROR);
    }
    d = d || {};

    if (d.canjeado) {
      borrarPedido();
      mostrar('', el('strong', 'ok', 'Este código ya se canjeó.'), ' ', el('span', 'muted', 'Los Prismas están en tu juego.'));
      return;
    }
    if (d.codigo) {
      const caja = mostrar('',
        el('strong', 'ok', '¡Pago confirmado!'), ' Tu código para ', el('span', null, fmt(Number(d.prismas) || 0)), ' Prismas:',
        el('div', 'code', String(d.codigo)));
      const copiar = el('button', 'btn main', 'Copiar código');
      copiar.type = 'button';
      copiar.addEventListener('click', () => {
        const ok = () => { copiar.textContent = 'Copiado ✓'; };
        const no = () => { copiar.textContent = 'Selecciona el código y cópialo a mano'; };
        try { navigator.clipboard.writeText(String(d.codigo)).then(ok, no); } catch (e) { no(); }
      });
      caja.append(copiar, el('p', 'muted nota', 'Guárdalo: esta página lo enseña hasta que lo canjees.'));
      $('#compra').hidden = true;
      return;
    }
    if (['rejected', 'cancelled', 'refunded', 'charged_back'].includes(d.estado)) {
      if (almacen) borrarPedido();
      finalizar('bad', 'El pago no se completó. No se ha cobrado nada; puedes intentarlo otra vez.');
      return;
    }
    mostrar('', 'Esperando la confirmación del pago… ', el('span', 'muted', '(con PSE o efectivo puede tardar)'));
    reintentar(pid, almacen, intentos, espera(intentos));
  }

  /* ---------- precios del servidor ---------- */
  async function cargarPrecios() {
    if (!SERVIDOR) return;
    try {
      const r = await fetch(SERVIDOR + '/v1/web/paquetes');
      if (!r.ok) return;
      const d = await r.json();
      if (d && Array.isArray(d.paquetes) && d.paquetes.length) {
        const lista = d.paquetes.map((p) => {
          const prismas = Number(p.prismas);
          return { id: String(p.id), prismas, base: Number(p.base) || Math.round(prismas / 1.25), precio: Number(p.precio) };
        }).filter((p) => ID_VALIDO.test(p.id) && Number.isFinite(p.prismas) && p.prismas > 0 && Number.isFinite(p.base) && p.base > 0 && p.base <= p.prismas && Number.isFinite(p.precio) && p.precio > 0);
        if (lista.length) {
          MONEDA = /^[A-Z]{3}$/.test(String(d.moneda)) ? String(d.moneda) : 'USD';
          PAQUETES = lista;
          pintar();
        }
      }
    } catch (e) { /* se quedan los precios de reserva */ }
  }

  /* ---------- arranque ---------- */
  const aviso = $('#aviso');
  if (SERVIDOR && aviso) aviso.hidden = true;
  $('#compra').hidden = false;
  pintar();
  cargarPrecios();

  let pid = params.get('pedido');
  let almacen = false;
  if (!pid || !ID_VALIDO.test(pid)) {
    pid = leerPedido();
    almacen = true;
  }
  if (SERVIDOR && pid && ID_VALIDO.test(pid)) seguir(pid, almacen, 0);
})();

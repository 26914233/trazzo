/* Curtzz: fondo animado de la cabecera (rectángulos que se cierran alrededor de un punto en movimiento).
   Decorativo y sin dependencias. Se puede pausar con el botón #pausa (aria-pressed) y no arranca
   si el sistema pide menos movimiento (prefers-reduced-motion), ni siquiera si se activa mientras se ve la página. */
(function () {
  'use strict';
  var cv = document.getElementById('board');
  if (!cv || !cv.getContext) return;
  var ctx = cv.getContext('2d');
  var btn = document.getElementById('pausa');
  var mq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  var W = 0, H = 0, dpr = 1;
  var raf = 0, t = 0, pausado = false;

  var enemy = { x: 0.5, y: 0.5, vx: 0.0016, vy: 0.0011, r: 7 };
  var rects = [];

  function reducir() { return !!(mq && mq.matches); }

  function resize() {
    dpr = window.devicePixelRatio || 1;
    W = cv.clientWidth; H = cv.clientHeight;
    cv.width = W * dpr; cv.height = H * dpr;   // al cambiar el tamaño el lienzo se borra
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    if (!raf) dibujar();                       // pausado: se repinta el último estado
  }

  function spawnRect() {
    // rectángulo aleatorio que no contiene al enemigo
    for (var i = 0; i < 24; i++) {
      var x = Math.random() * 0.75;
      var y = Math.random() * 0.75;
      var w = 0.10 + Math.random() * 0.22;
      var h = 0.10 + Math.random() * 0.22;
      var pad = 0.035;
      var hits = enemy.x > x - pad && enemy.x < x + w + pad && enemy.y > y - pad && enemy.y < y + h + pad;
      if (!hits) {
        rects.push({ x: x, y: y, w: w, h: h, p: 0, life: 0 });
        return;
      }
    }
  }

  function avanzar() {
    t++;
    enemy.x += enemy.vx; enemy.y += enemy.vy;
    if (enemy.x < 0.06 || enemy.x > 0.94) enemy.vx *= -1;
    if (enemy.y < 0.08 || enemy.y > 0.92) enemy.vy *= -1;

    if (t % 70 === 0 && rects.length < 7) spawnRect();

    for (var i = rects.length - 1; i >= 0; i--) {
      var r = rects[i];
      r.p = Math.min(1, r.p + 0.012);
      if (r.p >= 1) {
        r.life++;
        if (r.life > 200) rects.splice(i, 1);
      }
    }
  }

  function dibujar() {
    ctx.clearRect(0, 0, W, H);

    // rejilla muy tenue
    ctx.strokeStyle = 'rgba(255,255,255,0.028)';
    ctx.lineWidth = 1;
    var gs = 46;
    for (var gx = 0; gx < W; gx += gs) {
      ctx.beginPath(); ctx.moveTo(gx + 0.5, 0); ctx.lineTo(gx + 0.5, H); ctx.stroke();
    }
    for (var gy = 0; gy < H; gy += gs) {
      ctx.beginPath(); ctx.moveTo(0, gy + 0.5); ctx.lineTo(W, gy + 0.5); ctx.stroke();
    }

    // rectángulos
    for (var i = 0; i < rects.length; i++) {
      var r = rects[i];
      var px = r.x * W, py = r.y * H, pw = r.w * W, ph = r.h * H;
      var per = 2 * (pw + ph);
      var drawn = per * r.p;

      ctx.strokeStyle = r.p >= 1 ? 'rgba(74,222,128,0.55)' : 'rgba(34,211,238,0.85)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      // perímetro parcial
      var segs = [[pw, 0], [0, ph], [-pw, 0], [0, -ph]];
      var cx = px, cy = py, left = drawn;
      ctx.moveTo(cx, cy);
      for (var s = 0; s < segs.length && left > 0; s++) {
        var len = Math.abs(segs[s][0]) + Math.abs(segs[s][1]);
        var f = Math.min(1, left / len);
        cx += segs[s][0] * f; cy += segs[s][1] * f;
        ctx.lineTo(cx, cy);
        left -= len;
      }
      ctx.stroke();

      if (r.p >= 1) {
        ctx.fillStyle = 'rgba(74,222,128,0.07)';
        ctx.fillRect(px, py, pw, ph);
      }
    }

    // enemigo
    var ex = enemy.x * W, ey = enemy.y * H;
    var pulse = 1 + Math.sin(t * 0.06) * 0.12;
    ctx.beginPath();
    ctx.arc(ex, ey, enemy.r * pulse * 2.6, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(251,191,36,0.10)';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(ex, ey, enemy.r, 0, Math.PI * 2);
    ctx.fillStyle = '#FBBF24';
    ctx.fill();
  }

  function paso() {
    avanzar();
    dibujar();
    raf = requestAnimationFrame(paso);
  }

  function arrancar() { if (!raf && !pausado && !reducir()) raf = requestAnimationFrame(paso); }
  function parar() { if (raf) { cancelAnimationFrame(raf); raf = 0; } }

  resize();
  window.addEventListener('resize', resize);

  if (btn) {
    btn.addEventListener('click', function () {
      pausado = !pausado;
      btn.setAttribute('aria-pressed', pausado ? 'true' : 'false');
      if (pausado) parar(); else arrancar();
    });
  }
  // si el sistema pasa a pedir menos movimiento con la página abierta, se para; si deja de pedirlo, se reanuda
  if (mq) {
    var cambio = function () { if (reducir()) parar(); else arrancar(); };
    if (mq.addEventListener) mq.addEventListener('change', cambio); else if (mq.addListener) mq.addListener(cambio);
  }

  arrancar();
})();

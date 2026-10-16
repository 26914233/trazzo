/* Común a todas las páginas: pone el año actual en el pie. */
(function () {
  'use strict';
  var y = document.getElementById('year');
  if (y) y.textContent = new Date().getFullYear();
})();

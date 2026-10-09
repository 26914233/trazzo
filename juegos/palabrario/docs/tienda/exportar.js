// Exporta cada HTML de docs/tienda/html a PNG con su tamaño exacto.
// Uso: node docs/tienda/exportar.js  (desde juegos/palabrario)
const { chromium } = require('playwright');
const fs = require('fs'); const path = require('path');
(async () => {
  const dir = path.join(__dirname, 'html');
  const browser = await chromium.launch();
  for (const f of fs.readdirSync(dir).filter(f => f.endsWith('.html'))) {
    const [w, h] = f.startsWith('destacado') ? [1024, 500] : [1080, 1920];
    const page = await browser.newPage({ viewport: { width: w, height: h } });
    await page.goto('file://' + path.join(dir, f));
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: path.join(__dirname, f.replace('.html', '.png')) });
    await page.close();
    console.log('exportado', f, w + 'x' + h);
  }
  await browser.close();
})();

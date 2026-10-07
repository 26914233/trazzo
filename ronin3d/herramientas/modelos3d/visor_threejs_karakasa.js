// Escena que se mandó al visor de Three.js del chat (conector «Three.js 3D Viewer», three r181).
// El visor pone THREE, OrbitControls, EffectComposer, RenderPass, UnrealBloomPass, canvas, width y height.
// Se probó antes en Chromium con la misma versión de three.js.
// RONIN · Karakasa-obake (id 369) hecha solo con código: forma y patrón de ataque, en sus 3 rangos.
// Ficha: «Salta a una pierna; al cerrarse, la tela le sirve de escudo».
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x1d1b26);
const camera = new THREE.PerspectiveCamera(35, width / height, 0.1, 100);
camera.position.set(0, 2.1, 7.2);
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
renderer.setSize(width, height);
const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 0.9, 0);
controls.enableDamping = true;
controls.minDistance = 3;
controls.maxDistance = 14;
controls.maxPolarAngle = Math.PI * 0.49;
scene.add(new THREE.HemisphereLight(0xb8b0e0, 0x2a2238, 1.1));
const sol = new THREE.DirectionalLight(0xffe6c8, 1.6);
sol.position.set(3, 6, 4);
scene.add(sol);
const suelo = new THREE.Mesh(new THREE.CircleGeometry(5, 48), new THREE.MeshToonMaterial({ color: 0x3a3346 }));
suelo.rotation.x = -Math.PI / 2;
scene.add(suelo);

const bandas = new THREE.DataTexture(new Uint8Array([70, 165, 255]), 3, 1, THREE.RedFormat);
bandas.minFilter = bandas.magFilter = THREE.NearestFilter;
bandas.needsUpdate = true;
const reloj = { value: 0 };

// Rangos, como en el juego: 1 base · 2 alfa (más grande, oscura, grietas que laten) · 3 silenciada (gris)
const VORONOI = `
uniform float uTiempo; uniform vec3 uLava; varying vec3 vPosObj;
vec3 azar3(vec3 p) { p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)), dot(p, vec3(113.5, 271.9, 124.6))); return fract(sin(p) * 43758.5453); }
float arista(vec3 p) {
  vec3 celda = floor(p), resto = fract(p); float d1 = 8.0, d2 = 8.0;
  for (int x = -1; x <= 1; x++) for (int y = -1; y <= 1; y++) for (int z = -1; z <= 1; z++) {
    vec3 v = vec3(float(x), float(y), float(z)); vec3 r = v + azar3(celda + v) - resto; float d = dot(r, r);
    if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; } }
  return sqrt(d2) - sqrt(d1);
}
`;
function tono(color, rango) {
  const c = new THREE.Color(color);
  if (rango === 3) { const g = c.r * 0.3 + c.g * 0.59 + c.b * 0.11; c.setRGB(g * 1.15, g * 1.15, g * 1.22); }
  if (rango === 2) c.multiplyScalar(0.62);
  return c;
}
function toon(color, rango, opciones = {}) {
  const c = opciones.crudo ? new THREE.Color(color) : tono(color, rango);
  const m = new THREE.MeshToonMaterial({ color: c, gradientMap: bandas, side: opciones.doble ? THREE.DoubleSide : THREE.FrontSide });
  if (opciones.brillo) { m.emissive = new THREE.Color(opciones.brillo); m.emissiveIntensity = rango === 2 ? 2.2 : 1.0; }
  if (rango === 2 && !opciones.sinGrietas) {
    m.onBeforeCompile = (sh) => {
      sh.uniforms.uTiempo = reloj;
      sh.uniforms.uLava = { value: new THREE.Color("#ff7a2a") };
      sh.vertexShader = "varying vec3 vPosObj;\n" + sh.vertexShader.replace("#include <begin_vertex>", "#include <begin_vertex>\nvPosObj = position;");
      sh.fragmentShader = VORONOI + sh.fragmentShader.replace("#include <emissivemap_fragment>", `#include <emissivemap_fragment>
        {
          vec3 q = vPosObj * 7.0;
          q += 0.45 * vec3(sin(q.y * 0.9 + 1.3) + sin(q.z * 1.7), sin(q.z * 1.1 + 0.7) + sin(q.x * 1.3), sin(q.x * 0.8 + 2.1) + sin(q.y * 1.9));
          float a = arista(q);
          float linea = 1.0 - smoothstep(0.0, 0.07, a);
          float halo = 1.0 - smoothstep(0.0, 0.25, a);
          totalEmissiveRadiance += uLava * (linea * 2.2 + halo * 0.3) * (0.75 + 0.25 * sin(uTiempo * 2.2));
        }`);
    };
  }
  return m;
}
const casco = new THREE.MeshBasicMaterial({ color: 0x0d0a12, side: THREE.BackSide });
casco.onBeforeCompile = (sh) => {
  sh.vertexShader = sh.vertexShader.replace("#include <begin_vertex>", "#include <begin_vertex>\ntransformed += normal * 0.022;");
};
function conContorno(malla) { const c = new THREE.Mesh(malla.geometry, casco); malla.add(c); return malla; }

function karakasa(rango, x) {
  const raiz = new THREE.Group();
  raiz.position.x = x;
  scene.add(raiz);
  const cuerpo = new THREE.Group();
  cuerpo.scale.setScalar(rango === 2 ? 1.2 : 1.0);
  raiz.add(cuerpo);
  // Tela de papel aceitado: 16 paños alternos, como un wagasa
  const lona = new THREE.ConeGeometry(0.62, 0.5, 16, 1, true);
  const colores = [], claro = tono(0xd9893a, rango), oscuro = tono(0xb8652a, rango);
  for (let i = 0; i < lona.attributes.position.count; i++) {
    const p = new THREE.Vector3().fromBufferAttribute(lona.attributes.position, i);
    const panel = Math.floor(((Math.atan2(p.z, p.x) + Math.PI) / (Math.PI * 2)) * 16 + 0.5) % 2;
    const c = (panel ? claro : oscuro).clone();
    colores.push(c.r, c.g, c.b);
  }
  lona.setAttribute("color", new THREE.Float32BufferAttribute(colores, 3));
  const matLona = toon(0xffffff, rango, { doble: true, crudo: true });
  matLona.vertexColors = true;
  const tela = conContorno(new THREE.Mesh(lona, matLona));
  const sombrero = new THREE.Group();
  sombrero.position.y = 1.15;
  sombrero.add(tela);
  // Varillas por dentro (de la punta al borde; se cierran con la tela) y la punta
  const madera = toon(0x6b4a2b, rango, { sinGrietas: true });
  const arriba = new THREE.Vector3(0, 1, 0), cima = new THREE.Vector3(0, 0.23, 0);
  for (let i = 0; i < 16; i++) {
    const a = (i / 16) * Math.PI * 2;
    const borde = new THREE.Vector3(Math.cos(a) * 0.6, -0.26, Math.sin(a) * 0.6);
    const tramo = borde.clone().sub(cima);
    const varilla = new THREE.Mesh(new THREE.CylinderGeometry(0.007, 0.007, tramo.length(), 4), madera);
    varilla.position.copy(cima).addScaledVector(tramo, 0.5);
    varilla.quaternion.setFromUnitVectors(arriba, tramo.clone().normalize());
    tela.add(varilla);
  }
  const punta = conContorno(new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.05, 0.12, 8), madera));
  punta.position.y = 0.3;
  sombrero.add(punta);
  // Un ojo enorme y la lengua larga
  const ojo = new THREE.Group();
  ojo.position.set(0, 0.0, 0.33);
  ojo.rotation.x = -0.9;
  const blanco = conContorno(new THREE.Mesh(new THREE.SphereGeometry(0.13, 20, 12), toon(0xf4efe0, rango, { sinGrietas: true })));
  blanco.scale.set(1, 1, 0.45);
  ojo.add(blanco);
  const pupila = new THREE.Mesh(new THREE.SphereGeometry(0.055, 16, 10), toon(0x15101a, rango, { brillo: rango === 2 ? 0xff5a12 : rango === 3 ? 0x000000 : 0x000000, sinGrietas: true }));
  pupila.position.z = 0.05;
  pupila.scale.set(1, 1, 0.5);
  ojo.add(pupila);
  sombrero.add(ojo);
  const curva = new THREE.CatmullRomCurve3([new THREE.Vector3(0, -0.12, 0.42), new THREE.Vector3(0.02, -0.32, 0.55), new THREE.Vector3(-0.04, -0.55, 0.5), new THREE.Vector3(0.03, -0.72, 0.58)]);
  const lengua = conContorno(new THREE.Mesh(new THREE.TubeGeometry(curva, 20, 0.045, 8), toon(0xd9425a, rango, { sinGrietas: true })));
  sombrero.add(lengua);
  cuerpo.add(sombrero);
  // Una pierna (el mango) y un geta
  const pierna = conContorno(new THREE.Mesh(new THREE.CylinderGeometry(0.035, 0.04, 0.9, 8), madera));
  pierna.position.y = 0.55;
  cuerpo.add(pierna);
  const geta = new THREE.Group();
  const tabla = conContorno(new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.035, 0.32), madera));
  geta.add(tabla);
  for (const z of [-0.09, 0.09]) { const diente = new THREE.Mesh(new THREE.BoxGeometry(0.15, 0.06, 0.03), madera); diente.position.set(0, -0.045, z); geta.add(diente); }
  geta.position.y = 0.09;
  cuerpo.add(geta);
  return { raiz, cuerpo, sombrero, tela, fase: x * 0.7, rango };
}

function rotulo(texto, x) {
  const lienzo = document.createElement("canvas");
  lienzo.width = 512; lienzo.height = 96;
  const ctx = lienzo.getContext("2d");
  ctx.font = "600 40px sans-serif";
  ctx.textAlign = "center";
  ctx.fillStyle = "#e8e0f0";
  ctx.fillText(texto, 256, 60);
  const s = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(lienzo), transparent: true, depthTest: false }));
  s.scale.set(1.9, 0.36, 1);
  s.position.set(x, 0.12, 1.1);
  scene.add(s);
}
const criaturas = [karakasa(1, -2.0), karakasa(2, 0), karakasa(3, 2.0)];
rotulo("Base", -2.0);
rotulo("Alfa (rango 2)", 0);
rotulo("Silenciada (rango 3)", 2.0);

const composer = new EffectComposer(renderer);
composer.addPass(new RenderPass(scene, camera));
composer.addPass(new UnrealBloomPass(new THREE.Vector2(width, height), 0.6, 0.35, 0.85));

// Patrón de ataque a 12 poses por segundo: tres saltos a una pierna, se cierra (escudo) y se abre
const inicio = performance.now();
function animar() {
  requestAnimationFrame(animar);
  const t = (performance.now() - inicio) / 1000;
  reloj.value = t;
  const paso = Math.floor(t * 12) / 12;
  for (const c of criaturas) {
    const ciclo = (((paso + c.fase) % 4.0) + 4.0) % 4.0;
    let alto = 0, aplastar = 0, cierre = 0;
    if (ciclo < 2.4) {
      const s = (ciclo % 0.8) / 0.8;
      alto = s < 0.2 ? 0 : Math.sin(((s - 0.2) / 0.8) * Math.PI) * 0.55;
      aplastar = s < 0.2 ? Math.sin((s / 0.2) * Math.PI) * 0.18 : 0;
    } else if (ciclo < 3.4) {
      cierre = Math.min(1, (ciclo - 2.4) / 0.25) * Math.min(1, (3.4 - ciclo) / 0.25);
    }
    const e = c.rango === 2 ? 1.2 : 1.0;
    c.cuerpo.position.y = alto;
    c.cuerpo.scale.set(e * (1 + aplastar * 0.5), e * (1 - aplastar), e * (1 + aplastar * 0.5));
    c.tela.scale.set(1 - cierre * 0.72, 1 + cierre * 0.55, 1 - cierre * 0.72);
    c.sombrero.rotation.x = cierre * 0.35 - alto * 0.25;
  }
  controls.update();
  composer.render();
}
animar();

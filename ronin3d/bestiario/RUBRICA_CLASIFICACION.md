# Rúbrica para clasificar el catálogo de criaturas de RONIN

Sirve para convertir una lista de nombres en datos que el juego puede usar. Cada criatura se
clasifica **por lo que es, no por la columna «Categoría» del catálogo original**: esa columna se
repite en ciclo de 10 y no corresponde a la criatura (la Medusa figura como «marina», Cerbero como
«no-muerto» y la Esfinge como «demonio»). Tampoco se fía de la columna «Cultura»: tiene errores
(Tiamat figura en Francia, Quetzalcóatl en África, Anansi en Corea).

## Qué hay que entregar

Un archivo JSON con una lista, un objeto por cada entrada del archivo de entrada, en el mismo
orden y con estas claves exactas:

```json
{
  "id": 353,
  "nombre": "Kappa",
  "cultura": "Japón",
  "tipo_entrada": "criatura",
  "familia": "bipedo",
  "tamano": "S",
  "rol": "veloz",
  "elemento": "agua",
  "bioma": "rio_lago",
  "modelado": "variante",
  "base_de": "",
  "sensibilidad": 0,
  "prompt_en": "small hunched river imp with blue-green skin, turtle shell on its back, beak-like mouth, webbed clawed hands, a water-filled dish on its head ringed by black hair",
  "nota": "Si Akira espera en postura sin atacar, hace la reverencia y pierde el agua"
}
```

## Valores permitidos

- **cultura** (elige la tradición REAL de la criatura, no la que diga el catálogo): `Grecia`, `Roma`,
  `Nórdica`, `Celta e Irlanda`, `Británica`, `Eslava y Balcanes`, `Germánica y Alpes`,
  `Francia, Iberia y Vasca`, `Báltica y Uralica`, `Mesopotamia`, `Egipto`, `Persia y Cáucaso`,
  `Árabe e islámica`, `Hebrea y Levante`, `India`, `Tíbet y Himalaya`, `Asia Central y Siberia`,
  `China`, `Japón`, `Corea`, `Sudeste Asiático`, `África Occidental y Central`,
  `África Oriental y Austral`, `Norte de África`, `Mesoamérica`, `Sudamérica y Caribe`,
  `Norteamérica indígena`, `Australia y Oceanía`, `Moderna y críptidos`.
- **tipo_entrada**:
  - `criatura`: criatura, monstruo o espíritu con identidad propia.
  - `deidad`: dios, diosa o ser divino (aunque tenga forma animal). Se puede usar como jefe o PNJ.
  - `generica`: clase amplia o relleno sin identidad propia («Water spirit of the Zambezi», «Raven
    spirit», nombres que el propio catálogo llama «categoría», «comparativo» o «requiere
    verificación»).
  - `no_criatura`: no es una criatura (objeto, persona, animal corriente, ingrediente, bulo, ritual).
    Estas no se dibujan: `prompt_en` va vacío.
- **familia** (el cuerpo con el que se pelea; elige la forma principal):
  - `bipedo`: humanoides, ogros, oni, duendes, vampiros, brujas, esqueletos, gólems, simios.
  - `cuadrupedo`: lobos, felinos, caballos, toros, perros, quimeras, esfinges, centauros.
  - `serpentino`: serpientes, dragones sin patas, gusanos, anguilas, hidras. Cuerpos largos.
  - `alado`: aves, murciélagos, dragones alados, arpías. Lo que define a la criatura es volar.
  - `acuatico`: peces, pulpos, krakens, sirenas, cocodrilos, monstruos marinos.
  - `flotante`: fantasmas, llamas, nubes, cabezas voladoras, objetos animados, espíritus sin patas.
  - `artropodo`: arañas, ciempiés, escorpiones, cangrejos, insectos.
- **tamano**: `S` (hasta 1 m, un niño o un perro), `M` (persona, 1,5–2,5 m), `L` (2,5–6 m),
  `XL` (colosal, jefe de escala).
- **rol** (qué enseña al jugador de iaidō):
  - `veloz`: aviso corto, ataca y se retira. Enseña a leer.
  - `poderoso`: golpes lentos; algunos no se pueden parar y hay que esquivar.
  - `enjambre`: aparece en grupos de 4–8, débil por separado. Pide el corte de luna.
  - `gigante`: parte a parte, con puntos débiles y avisos enormes. Casi siempre `L`/`XL`.
  - `engano`: ilusiones, disfraces, posesión, copias. El aviso falso no hace daño.
  - `distancia`: proyectiles, magia, aliento, canto.
  - `emboscador`: acecha escondido (agua, sombra, techo) y agarra o sorprende.
  - `apoyo`: cura, protege, invoca o maldice a otros. Prioridad de objetivo.
- **elemento**: `ninguno`, `fuego`, `agua`, `hielo`, `rayo`, `viento`, `tierra`, `veneno`,
  `sombra`, `luz`, `sangre`.
- **bioma**: `bosque`, `montana`, `rio_lago`, `mar`, `pantano`, `desierto`, `ciudad_hogar`,
  `cielo`, `subsuelo`, `inframundo`, `nieve`, `ruinas`, `llanura`, `selva`.
- **modelado**: cómo se construye en el juego.
  - `propio`: necesita modelo propio porque su anatomía no sale de «una familia + piezas», o porque
    es un jefe icónico. Ejemplos: Blemmyes (cara en el torso), Ouroboros (serpiente en círculo),
    una hidra de 9 cabezas, quimeras con tres o más animales, Tiamat, Jörmungandr, Bahamut,
    Quetzalcóatl. **Objetivo: 10–15 % de las entradas.**
  - `variante`: familia + piezas + paleta (casi todas). **Objetivo: 65–75 %.**
  - `reskin`: mismo cuerpo que otra entrada de la lista con otra paleta y accesorios. Pon el
    nombre de esa otra entrada en `base_de`. Ejemplos: Cadejo blanco/negro, los perros negros
    británicos, hermanas y versiones regionales. **Objetivo: 10–20 %.**
- **base_de**: nombre de la entrada en la que se basa (solo para `reskin`, o para `variante` que
  claramente deriva de otra). Si no, `""`.
- **sensibilidad** (cuidado cultural; es una recomendación para decidir con el usuario):
  - `2` = **no enemigo**: deidades y seres sagrados de religiones VIVAS (hinduismo, budismo,
    sintoísmo, islam, judaísmo, cristianismo, zoroastrismo) y seres ancestrales sagrados de culturas
    indígenas vivas (la Serpiente Arcoíris, Hine-nui-te-pō…). Solo como lore o PNJ.
  - `1` = **con cuidado**: seres que algunas comunidades vivas consideran reales o peligrosos
    (Wendigo, Deer Woman, Mami Wata, jinn, taniwha, Pishtaco), dioses de culturas indígenas actuales
    (mesoamericanos), figuras con riesgo de caricatura. Usarlos con respeto, sin burla.
  - `0` = **libre**: folclore europeo, mitologías antiguas extinguidas (Grecia, Roma, Egipto,
    Mesopotamia), yōkai, monstruos populares y críptidos modernos.
- **prompt_en**: descripción visual EN INGLÉS, de 15 a 35 palabras, de la criatura entera
  (anatomía, colores, materiales, objetos). Sin nombres de estilos, de marcas ni de otros juegos;
  el estilo (tinta y cel-shading) lo pone el cuaderno de imágenes. Sin sangre explícita, sin
  desnudos ni poses sugerentes (apto para todos los públicos). Los pueblos y personas de
  tradiciones vivas se describen como seres de fantasía, sin caricaturas étnicas.
- **nota**: opcional, máximo 15 palabras en español: una idea de mecánica o de diseño.

## Criterios

1. **No inventes tradición.** Si no reconoces la criatura con seguridad, pon `tipo_entrada:
   "generica"` o `"criatura"` con un `prompt_en` prudente, y empieza la `nota` con «Dudosa:».
2. **Reparte los roles.** No pongas todo como `poderoso`; mezcla según lo que cuenta la leyenda.
3. **Una entrada = una fila.** No cambies, borres ni añadas entradas; conserva el `id`.
4. **El nombre** se conserva tal cual salvo que sea una errata evidente. Si hay varios alias, ya
   están fusionados y el campo `alias` de la entrada de entrada te los muestra.
5. **El campo `descripcion`** (si lo hay) es una frase del catálogo; sirve de pista, pero si
   contradice lo que sabes de la criatura, fíate de lo que sabes y avísalo en la `nota`.

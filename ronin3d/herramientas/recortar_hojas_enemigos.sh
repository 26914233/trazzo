#!/bin/sh
# Recorta todas las hojas de enemigos generadas con Gemini (arte/conceptos/hoja_<id>.*) y deja sus
# sprites en godot/recursos/sprites/<id>_hoja.png y .json. Ver arte/conceptos/LEEME_ENEMIGOS.md.
# Uso, desde la raíz del repositorio:  sh ronin3d/herramientas/recortar_hojas_enemigos.sh
set -e
cd "$(dirname "$0")/.."
R="python3 herramientas/recortar_hoja.py"
C5=reposo,caminar,ataque,golpe,muerte
C6=reposo,caminar,ataque,area,golpe,muerte
# Capítulo 1
$R arte/conceptos/hoja_kappa.png kappa_hoja $C5
$R arte/conceptos/hoja_onibi.png onibi_hoja $C5
$R arte/conceptos/hoja_soldado.png soldado_hoja $C5
# Capítulo 2
for id in kamaitachi okuri_inu kitsune tanuki noppera_bo tsukumogami karasu_tengu kodama; do
	$R arte/conceptos/hoja_$id.jpg ${id}_hoja $C5
done
$R arte/conceptos/hoja_sojobo.jpg sojobo_hoja $C6
# Capítulo 3
for id in dogu haniwa komainu omukade gaki hombre_lagarto goblin slime gargola golem; do
	$R arte/conceptos/hoja_$id.jpg ${id}_hoja $C5
done
# Figuras que se tocan con las patas: se parten (ver recortar_hoja.py).
$R arte/conceptos/hoja_jorogumo.jpg jorogumo_hoja $C5 golpe:1/2
$R arte/conceptos/hoja_tsuchigumo.jpg tsuchigumo_hoja $C5 caminar:0/3,caminar:1/2
# Los dos primeros cuadros de su coletazo son solo la cola enroscada; el aliento sale en dos cuadros pegados.
$R arte/conceptos/hoja_bahamut.jpg bahamut_hoja $C6 ataque:0,ataque:1,area:2/2
# Capítulo 4
for id in kasha nue gashadokuro vampiro hombre_lobo elfo_oscuro ogro ifrit; do
	$R arte/conceptos/hoja_$id.jpg ${id}_hoja $C5
done
# Su última fila trae el golpe (3 cuadros) y la derrota.
$R arte/conceptos/hoja_genzo.jpg genzo_hoja reposo,caminar,ataque,area,golpe+muerte@3
$R arte/conceptos/hoja_tamamo.jpg tamamo_hoja $C6 area:0/4
$R arte/conceptos/hoja_tamamo_zorro.jpg tamamo_zorro_hoja $C6
# Variantes de color (variantes_color.py): el oni azul, las hitodama y los fuegos de zorro de Tamamo.
python3 herramientas/variantes_color.py oni_jefe oni_azul_hoja 205 1.1 1.05
python3 herramientas/variantes_color.py onibi_hoja hitodama_hoja 300 0.35 1.15
python3 herramientas/variantes_color.py onibi_hoja kitsunebi_hoja 60 1.2 1.0
# Paleta de 128 colores en todas (reducir_paleta.py): igual a la vista y unas tres veces más ligeras.
python3 herramientas/reducir_paleta.py $(cd godot/recursos/sprites && ls *_hoja.png | sed 's/\.png$//')

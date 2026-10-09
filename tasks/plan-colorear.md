# Plan: juego de colorear (Godot 4.7 → Google Play)

Orden por riesgo. Cada paso deja algo verificable.

1. **Generador de láminas** (`herramientas/laminas.py`): mandalas, vitrales, flores y
   geometría → `lineas.png` + `regiones.png` + índice. Verificar: sin zonas diminutas,
   número de zonas razonable, láminas renderizadas a la vista.
2. **Coloreado por zonas** en Godot: shader + paleta, toque → relleno, deshacer, zoom y
   desplazamiento. Verificar: pruebas headless de la lógica y captura de pantalla.
3. **Guardado** de cada obra (colores por zona) y miniaturas. Prueba de ida y vuelta.
4. **Menú, categorías y Mis obras** con el molde visual de Palabrario.
5. **Mandala libre y lienzo libre** (trazos, simetría, deshacer).
6. **Exportar la obra como PNG** (guardar en el móvil).
7. **Diseño, nombre y gráficos de tienda** (decide el dueño con imágenes delante).
8. **Android**: export, antipiratería, auditoría, checklist de lanzamiento.

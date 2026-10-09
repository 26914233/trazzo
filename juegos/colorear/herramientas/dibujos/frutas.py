"""Frutas. Caja 0..1000, y hacia abajo."""
import math

from dibujos import camino, espejo, simetrico


def manzana(p):
    p.cinta(camino((500, 260), (500, 200), (520, 140), (550, 110)), 30, 22)         # rabito
    p.forma(simetrico(camino((500, 270), (420, 200), (180, 220), (170, 470), (160, 720), (330, 900), (420, 880), (460, 870), (480, 880), (500, 890))))
    p.forma(camino((530, 200), (600, 110), (720, 100), (800, 140), (720, 220), (600, 240), (530, 200)))   # hoja
    p.trazo(camino((540, 195), (620, 160), (700, 140), (780, 140)), 0.7)
    p.forma(camino((260, 420), (270, 340), (320, 300), (360, 300), (320, 360), (300, 420), (290, 480), (275, 485), (260, 460), (260, 420)), solido=True, g=0.8)   # brillo


SUJETOS = [
    ("manzana", "Manzana", "nada", manzana),
]

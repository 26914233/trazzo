"""Animales. Caja 0..1000, y hacia abajo. Se pintan de atrás hacia delante."""
import math

from dibujos import camino, espejo, simetrico
from laminas import polar


def gato(p):
    p.cinta(camino((640, 860), (860, 860), (900, 640), (800, 520)), 70, 50)        # cola
    p.elipse((500, 720), 230, 220)                                                 # cuerpo
    p.elipse((500, 760), 120, 140)                                                 # barriga
    for x in (410, 590):
        p.elipse((x, 905), 70, 50)                                                 # patas
    for lado in (-1, 1):
        p.forma([(500 + lado * 230, 300), (500 + lado * 215, 80), (500 + lado * 80, 210)])    # oreja
        p.forma([(500 + lado * 200, 260), (500 + lado * 200, 140), (500 + lado * 120, 220)], g=0.8)
    p.elipse((500, 360), 260, 210)                                                 # cabeza
    for x in (410, 590):
        p.ojo((x, 350), 42)
    p.forma([(470, 425), (530, 425), (500, 455)], negro=True)                      # nariz
    p.trazo(camino((500, 455), (500, 480), (470, 495), (450, 480)))
    p.trazo(camino((500, 455), (500, 480), (530, 495), (550, 480)))
    for lado in (-1, 1):
        for dy in (-15, 15):
            p.trazo([(500 + lado * 110, 450 + dy * 0.5), (500 + lado * 250, 440 + dy * 2.2)], 0.7)


def pez(p):
    p.forma(camino((300, 500), (200, 380), (120, 330), (80, 300), (130, 420), (130, 580), (80, 700), (120, 670), (200, 620), (300, 500)))   # cola
    p.forma(camino((420, 330), (480, 160), (640, 170), (700, 330)))               # aleta de arriba
    p.forma(camino((470, 660), (500, 800), (620, 800), (640, 660)))               # aleta de abajo
    p.elipse((540, 500), 330, 210)                                                 # cuerpo
    p.trazo(camino((690, 330), (640, 420), (640, 580), (690, 670)), 1.0)           # agalla
    for i, x in enumerate((360, 440, 520)):
        for y in (420, 500, 580):
            if abs(y - 500) + abs(x - 440) < 200:
                p.trazo([polar((x, y), 40, math.pi * (-0.4 + k / 10)) for k in range(9)], 0.8)
    p.forma(camino((560, 520), (620, 540), (660, 600), (610, 615), (580, 620), (560, 590), (560, 520)), g=0.8)   # aleta lateral
    p.ojo((770, 450), 46)
    p.trazo(camino((840, 560), (820, 580), (790, 585), (770, 575)))


def perro(p):
    p.cinta(camino((650, 830), (760, 800), (820, 720), (830, 620)), 52, 30)
    p.elipse((500, 730), 210, 200)
    p.elipse((500, 765), 110, 130)
    for x in (420, 580):
        p.elipse((x, 905), 66, 48)
    p.elipse((500, 380), 230, 200)
    p.elipse((585, 345), 75, 70, g=0.8)                                            # mancha
    for lado in (-1, 1):
        p.elipse((500 + lado * 215, 420), 70, 150, rot=-lado * 0.3)               # orejas
    p.ojo((420, 355), 38)
    p.ojo((585, 355), 38)
    p.elipse((500, 470), 95, 68)                                                   # hocico
    p.elipse((500, 435), 36, 25, negro=True)
    p.trazo(camino((500, 460), (500, 490), (465, 505), (445, 490)))
    p.trazo(camino((500, 460), (500, 490), (535, 505), (555, 490)))
    p.forma(camino((480, 500), (480, 560), (520, 560), (520, 500)), g=0.8)        # lengua


def conejo(p):
    p.circulo((690, 830), 55)                                                      # rabito
    p.elipse((500, 740), 200, 190)
    for x in (400, 600):
        p.elipse((x, 912), 88, 45)
    for lado in (-1, 1):
        p.elipse((500 + lado * 85, 190), 58, 175, rot=lado * 0.15)
        p.elipse((500 + lado * 85, 200), 28, 125, rot=lado * 0.15, g=0.8)
    p.circulo((500, 420), 190)
    for x in (390, 610):
        p.circulo((x, 480), 28, g=0.7)
    p.ojo((430, 405), 34)
    p.ojo((570, 405), 34)
    p.forma([(480, 460), (520, 460), (500, 482)], negro=True)
    p.trazo(camino((500, 482), (500, 500), (475, 512), (458, 500)))
    p.trazo(camino((500, 482), (500, 500), (525, 512), (542, 500)))
    p.forma([(486, 506), (514, 506), (514, 536), (486, 536)], g=0.7)              # dientes
    p.trazo([(500, 506), (500, 536)], 0.6)


def _oso(p, negro=False):
    for x in (330, 670):
        p.circulo((x, 200), 75, negro=negro)
        if not negro:
            p.circulo((x, 205), 40, g=0.8)
    p.elipse((500, 720), 230, 220)
    if not negro:
        p.elipse((500, 760), 130, 130)
    for lado in (-1, 1):
        p.elipse((500 + lado * 215, 690), 70, 115, rot=-lado * 0.45, negro=negro)
    for x in (380, 620):
        p.circulo((x, 900), 85, negro=negro)
        if not negro:
            p.circulo((x, 905), 45, g=0.8)
    p.circulo((500, 360), 200)
    if negro:
        for lado in (-1, 1):
            p.elipse((500 + lado * 82, 340), 60, 75, rot=lado * 0.5, negro=True)
    p.elipse((500, 435), 95, 72)
    p.elipse((500, 405), 40, 28, negro=True)
    p.trazo(camino((500, 430), (500, 460), (470, 475), (450, 460)))
    p.trazo(camino((500, 430), (500, 460), (530, 475), (550, 460)))
    p.ojo((420, 335), 30)
    p.ojo((580, 335), 30)


def oso(p):
    _oso(p)


def panda(p):
    _oso(p, negro=True)


def zorro(p):
    p.forma(camino((600, 860), (900, 900), (980, 600), (860, 420), (830, 560), (780, 700), (600, 760)))    # cola
    p.forma(camino((860, 420), (900, 470), (930, 520), (940, 560), (900, 560), (850, 520), (830, 470), (845, 440), (850, 430), (860, 420)), g=0.8)
    p.elipse((480, 740), 190, 190)
    p.forma(simetrico(camino((480, 560), (440, 640), (400, 760), (480, 860)), 480))   # pechera
    for x in (400, 560):
        p.elipse((x, 910), 62, 45)
    for lado in (-1, 1):
        p.forma([(500 + lado * 210, 280), (500 + lado * 230, 60), (500 + lado * 80, 220)])
        p.forma([(500 + lado * 190, 250), (500 + lado * 205, 120), (500 + lado * 110, 220)], g=0.8)
    p.forma(simetrico(camino((500, 210), (420, 200), (330, 230), (280, 300), (230, 370), (210, 420), (250, 450), (330, 500), (420, 560), (500, 585))))
    p.forma(simetrico(camino((500, 440), (440, 430), (330, 420), (250, 450), (330, 500), (420, 560), (500, 585))), g=0.8)
    p.circulo((500, 570), 24, negro=True)
    p.ojo((410, 375), 30)
    p.ojo((590, 375), 30)


def buho(p):
    p.cinta([(60, 935), (940, 945)], 60, 50)                                      # rama
    for lado in (-1, 1):
        p.forma([(500 + lado * 200, 260), (500 + lado * 250, 90), (500 + lado * 80, 210)])
    p.elipse((500, 560), 280, 360)
    p.elipse((500, 660), 170, 230)
    for fila, y in enumerate((540, 610, 680, 750, 820)):
        n = 3 if fila % 2 == 0 else 4
        for j in range(n):
            x = 500 + (j - (n - 1) / 2) * 80
            if abs(x - 500) < 150 - abs(y - 680) * 0.3:
                p.trazo([polar((x, y), 38, math.pi * k / 10) for k in range(11)], 0.8)
    for lado in (-1, 1):
        p.elipse((500 + lado * 255, 610), 85, 215, rot=-lado * 0.15)
    for x in (400, 600):
        p.circulo((x, 395), 100)
        p.ojo((x, 395), 55)
    p.forma([(470, 470), (530, 470), (500, 540)])
    for x in (440, 560):
        for d in (-28, 0, 28):
            p.elipse((x + d, 925), 16, 30)


def pajaro(p):
    p.forma([(240, 540), (50, 440), (90, 600)])
    p.elipse((470, 570), 270, 200)
    p.elipse((520, 640), 160, 110, rot=0.15, g=0.8)
    p.forma(camino((300, 520), (380, 420), (560, 440), (600, 520), (520, 600), (400, 640), (300, 520)))   # ala
    p.trazo(camino((360, 540), (420, 500), (500, 500), (540, 530)), 0.7)
    for x in (430, 540):
        p.trazo([(x, 760), (x - 10, 890)], 1.2)
        for d in (-30, 0, 30):
            p.trazo([(x - 10, 890), (x - 10 + d, 920)], 1.0)
    p.circulo((690, 400), 145)
    p.forma([(815, 370), (950, 405), (815, 445)])
    p.trazo([(820, 408), (930, 405)], 0.7)
    p.ojo((720, 375), 32)


def tortuga(p):
    for x in (280, 700):
        p.elipse((x, 720), 75, 95)
    p.forma([(120, 640), (60, 690), (150, 680)])                                   # cola
    p.cinta(camino((760, 580), (800, 560), (820, 540), (840, 520)), 110, 100)
    p.elipse((860, 500), 115, 95)
    p.ojo((890, 470), 26)
    p.trazo(camino((900, 540), (920, 550), (940, 545), (950, 530)), 0.9)
    p.forma(camino((140, 650), (140, 250), (860, 250), (860, 650)))               # caparazón
    p.elipse((500, 655), 390, 50)
    p.poligono((500, 450), 95, 6, math.pi / 6, g=0.9)
    for j in range(6):
        a = math.pi / 6 + j * math.pi / 3
        q = polar((500, 450), 95, a)
        p.trazo([q, polar((500, 450), 330, a)], 0.9)
    p.trazo(camino((170, 560), (330, 520), (670, 520), (830, 560)), 0.9)


def elefante(p):
    for lado in (-1, 1):
        p.elipse((500 + lado * 210, 380), 190, 220)
        p.elipse((500 + lado * 225, 390), 120, 150, g=0.8)
    p.elipse((500, 750), 230, 190)
    for x in (390, 610):
        p.elipse((x, 905), 72, 58)
        for d in (-30, 0, 30):
            p.circulo((x + d, 935), 14, g=0.6)
    p.circulo((500, 380), 185)
    p.ojo((425, 350), 28)
    p.ojo((575, 350), 28)
    for x in (400, 600):
        p.circulo((x, 440), 26, g=0.7)
    trompa = camino((500, 420), (500, 560), (480, 650), (580, 690), (640, 700), (680, 650), (660, 620))
    p.cinta(trompa, 110, 60)
    for k in range(2, len(trompa) - 6, 4):
        a = trompa[k]
        b = trompa[k + 1]
        ang = math.atan2(b[1] - a[1], b[0] - a[0]) + math.pi / 2
        w = 50 - 22 * k / len(trompa)
        p.trazo([polar(a, w * 0.6, ang), polar(a, -w * 0.6, ang)], 0.6)


def jirafa(p):
    for x in (410, 500, 640, 730):
        p.cinta([(x, 790), (x, 965)], 52, 46)
        p.elipse((x, 965), 30, 14, negro=True)
    p.cinta(camino((780, 720), (840, 760), (850, 820), (840, 880)), 18, 12)
    p.elipse((570, 750), 230, 130)
    p.cinta(camino((440, 700), (410, 560), (380, 420), (370, 290)), 140, 100)
    for x, l in ((300, -1), (380, 1)):
        p.cinta([(x, 180), (x + l * 8, 100)], 20, 18)
        p.circulo((x + l * 8, 95), 22)
    p.elipse((250, 210), 50, 25, rot=-0.5)
    p.elipse((350, 230), 140, 85, rot=-0.25)
    p.elipse((250, 270), 60, 45, rot=-0.25, g=0.8)
    p.circulo((235, 262), 8, negro=True)
    p.ojo((380, 200), 24)
    for c, r in (((400, 380), 34), ((420, 500), 40), ((390, 620), 36), ((500, 700), 44), ((610, 740), 48), ((700, 720), 40), ((560, 800), 36), ((680, 810), 30)):
        p.poligono(c, r, 6, 0.4, g=0.8)


def leon(p):
    p.cinta(camino((660, 860), (800, 860), (880, 780), (880, 680)), 28, 20)
    p.circulo((880, 660), 40)
    p.elipse((500, 790), 200, 160)
    for x in (410, 590):
        p.elipse((x, 920), 66, 45)
    for j in range(16):
        p.circulo(polar((500, 400), 200, 2 * math.pi * j / 16), 78)
    p.circulo((500, 400), 210)
    for x in (390, 610):
        p.circulo((x, 280), 42)
    p.circulo((500, 410), 150)
    p.ojo((445, 385), 26)
    p.ojo((555, 385), 26)
    for x in (470, 530):
        p.circulo((x, 470), 42, g=0.8)
    p.forma([(475, 430), (525, 430), (500, 458)], negro=True)
    p.trazo(camino((500, 460), (500, 495), (485, 505), (470, 500)), 0.9)
    p.trazo(camino((500, 460), (500, 495), (515, 505), (530, 500)), 0.9)


def mono(p):
    p.cinta(camino((640, 850), (860, 860), (900, 700), (800, 660), (740, 650), (740, 730), (800, 730)), 40, 26)
    p.elipse((500, 800), 190, 160)
    p.elipse((500, 820), 110, 100, g=0.8)
    for lado in (-1, 1):
        p.circulo((500 + lado * 260, 400), 82)
        p.circulo((500 + lado * 260, 400), 50, g=0.8)
    p.circulo((500, 400), 230)
    p.forma(simetrico(camino((500, 310), (450, 250), (300, 260), (300, 380), (300, 450), (330, 520), (370, 560), (420, 610), (470, 625), (500, 625))), g=0.9)
    p.ojo((430, 375), 34)
    p.ojo((570, 375), 34)
    for x in (480, 520):
        p.elipse((x, 470), 9, 14, negro=True)
    p.sonrisa((500, 530), 80, 45)


def cerdo(p):
    p.trazo(camino((760, 680), (840, 640), (860, 720), (810, 720), (780, 720), (790, 660), (840, 660)), 1.1)
    p.elipse((500, 720), 280, 210)
    for x in (330, 430, 570, 670):
        p.elipse((x, 905), 52, 40)
    for lado in (-1, 1):
        p.forma([(500 + lado * 120, 250), (500 + lado * 250, 160), (500 + lado * 210, 330)])
    p.circulo((500, 420), 200)
    for x in (380, 620):
        p.circulo((x, 470), 30, g=0.7)
    p.ojo((430, 380), 30)
    p.ojo((570, 380), 30)
    p.elipse((500, 480), 92, 66)
    for x in (470, 530):
        p.elipse((x, 480), 14, 22, negro=True)
    p.sonrisa((500, 565), 50, 22)


def vaca(p):
    p.elipse((500, 820), 260, 160)
    p.forma(camino((330, 760), (380, 720), (450, 760), (430, 820), (410, 870), (330, 860), (330, 760)), g=0.8)
    p.forma(camino((600, 780), (660, 740), (730, 790), (700, 850), (680, 890), (600, 860), (600, 780)), g=0.8)
    for lado in (-1, 1):
        p.cinta(camino((500 + lado * 120, 220), (500 + lado * 170, 190), (500 + lado * 200, 140), (500 + lado * 190, 90)), 40, 22)
        p.elipse((500 + lado * 240, 330), 95, 45, rot=lado * 0.35)
    p.elipse((500, 400), 200, 230)
    p.forma(camino((380, 250), (440, 230), (480, 290), (450, 340), (420, 380), (360, 340), (380, 250)), g=0.8)
    p.ojo((430, 380), 32)
    p.ojo((570, 380), 32)
    p.elipse((500, 560), 175, 110)
    for x in (445, 555):
        p.elipse((x, 550), 20, 32, negro=True)
    p.sonrisa((500, 610), 50, 18)


def pollito(p):
    for x in (420, 580):
        p.forma([(x, 860), (x - 50, 950), (x + 50, 950)])
    for d in (-60, 0, 60):
        p.forma(camino((500 + d, 340), (480 + d * 1.4, 280), (500 + d * 1.6, 230), (520 + d * 1.5, 240), (530 + d, 290), (510 + d, 330), (500 + d, 340)))
    p.circulo((500, 600), 260)
    for lado in (-1, 1):
        p.elipse((500 + lado * 210, 640), 75, 130, rot=-lado * 0.45)
    zig = [(240, 700)] + [(240 + 40 * k, 700 + (0 if k % 2 else 60)) for k in range(1, 13)] + [(760, 700)]
    p.forma(zig + [(780, 760), (720, 880), (280, 880), (220, 760)])               # cáscara
    p.ojo((420, 520), 36)
    p.ojo((580, 520), 36)
    p.forma([(455, 590), (500, 560), (545, 590), (500, 635)])
    p.trazo([(455, 590), (545, 590)], 0.7)
    for x in (380, 620):
        p.circulo((x, 590), 26, g=0.7)


def pato(p):
    p.forma(camino((180, 520), (160, 760), (420, 840), (600, 800), (760, 770), (820, 640), (760, 560), (620, 600), (400, 560), (180, 520)))
    p.forma([(180, 520), (90, 450), (200, 600)])
    p.forma(camino((330, 620), (420, 560), (580, 600), (620, 660), (540, 720), (400, 720), (330, 620)), g=0.9)
    p.trazo(camino((380, 650), (440, 630), (520, 640), (560, 670)), 0.7)
    p.circulo((700, 400), 140)
    p.forma(camino((820, 400), (900, 380), (970, 410), (950, 440), (900, 470), (840, 470), (820, 440)) + [(820, 400)])
    p.trazo([(830, 435), (950, 430)], 0.7)
    p.ojo((730, 370), 30)
    p.trazo([(80, 860), (250, 840), (420, 870), (600, 840), (780, 870), (940, 850)], 1.0)


def rana(p):
    for lado in (-1, 1):
        p.elipse((500 + lado * 210, 820), 130, 85)
        for d in (-50, 0, 50):
            p.elipse((500 + lado * 300 + d, 905), 25, 18)
    p.elipse((500, 700), 230, 200)
    p.elipse((500, 730), 140, 120, g=0.8)
    for lado in (-1, 1):
        p.circulo((500 + lado * 135, 290), 100)
    p.elipse((500, 440), 290, 180)
    for lado in (-1, 1):
        p.ojo((500 + lado * 135, 290), 56)
        p.circulo((500 + lado * 200, 480), 30, g=0.7)
    p.sonrisa((500, 470), 150, 70)
    for x in (470, 530):
        p.circulo((x, 400), 8, negro=True)


def mariposa(p):
    for lado in (-1, 1):
        sup = camino((500, 450), (420 - 0, 250), (300, 90), (130, 140), (40, 200), (80, 420), (500, 500))
        inf = camino((500, 520), (300, 520), (150, 600), (180, 760), (220, 880), (420, 820), (500, 560))
        if lado == 1:
            sup, inf = espejo(sup), espejo(inf)
        p.forma(inf)
        p.forma(sup)
        c1 = (500 + lado * 250, 260)
        p.circulo(c1, 70, g=0.8)
        p.circulo(c1, 30, g=0.7)
        p.elipse((500 + lado * 200, 680), 60, 80, g=0.8)
        for k in range(3):
            p.circulo((500 + lado * (120 + 60 * k), 420 - 20 * k), 16, g=0.6)
    p.elipse((500, 540), 42, 230)
    for y in (420, 480, 540, 600, 660):
        p.trazo([(462, y), (538, y)], 0.6)
    p.circulo((500, 290), 55)
    for lado in (-1, 1):
        p.trazo(camino((500 + lado * 20, 245), (500 + lado * 40, 170), (500 + lado * 90, 120), (500 + lado * 120, 110)), 0.9)
        p.circulo((500 + lado * 125, 105), 20)
    p.ojo((480, 285), 12)
    p.ojo((520, 285), 12)


SUJETOS = [
    ("gato", "Gato", "tierra", gato),
    ("pez", "Pez", "agua", pez),
    ("perro", "Perro", "tierra", perro),
    ("conejo", "Conejo", "tierra", conejo),
    ("oso", "Oso", "tierra", oso),
    ("panda", "Panda", "tierra", panda),
    ("zorro", "Zorro", "tierra", zorro),
    ("buho", "Búho", "aire", buho),
    ("pajaro", "Pájaro", "aire", pajaro),
    ("tortuga", "Tortuga", "tierra", tortuga),
    ("elefante", "Elefante", "tierra", elefante),
    ("jirafa", "Jirafa", "tierra", jirafa),
    ("leon", "León", "tierra", leon),
    ("mono", "Mono", "tierra", mono),
    ("cerdo", "Cerdo", "tierra", cerdo),
    ("vaca", "Vaca", "tierra", vaca),
    ("pollito", "Pollito", "tierra", pollito),
    ("pato", "Pato", "agua", pato),
    ("rana", "Rana", "tierra", rana),
    ("mariposa", "Mariposa", "aire", mariposa),
]

"""Objetos. Caja 0..1000, y hacia abajo."""
from dibujos import camino


def casa(p):
    p.forma([(640, 300), (640, 140), (730, 140), (730, 380)])                       # chimenea
    p.forma([(200, 480), (800, 480), (800, 900), (200, 900)])                       # paredes
    p.forma([(130, 500), (500, 170), (870, 500)])                                   # tejado
    p.forma([(440, 680), (560, 680), (560, 900), (440, 900)])                       # puerta
    p.circulo((540, 800), 10, negro=True)
    for x in (250, 610):
        p.forma([(x, 580), (x + 140, 580), (x + 140, 720), (x, 720)])               # ventana
        p.trazo([(x + 70, 580), (x + 70, 720)], 0.8)
        p.trazo([(x, 650), (x + 140, 650)], 0.8)
    p.circulo((500, 380), 55)                                                       # ventanita redonda
    p.forma([(420, 900), (580, 900), (640, 990), (360, 990)])                       # camino


SUJETOS = [
    ("casa", "Casa", "tierra", casa),
]

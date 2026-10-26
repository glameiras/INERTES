extends Node2D
## Cenário estático e regras de colisão.
## Desenha uma única vez (não redesenha a cada frame).

const Cfg = preload("res://scripts/config.gd")
const Desenho = preload("res://scripts/desenho.gd")

var obstaculos: Array[Rect2] = [
	Rect2(420, 180, 150, 160), Rect2(440, 620, 160, 170), Rect2(760, 100, 180, 230),
	Rect2(770, 640, 170, 180), Rect2(1120, 190, 130, 140), Rect2(1120, 650, 130, 160),
]

func bloqueado(p: Vector2, raio: float) -> bool:
	if p.x < raio or p.y < raio or p.x > Cfg.MUNDO.x - raio or p.y > Cfg.MUNDO.y - raio:
		return true
	for r in obstaculos:
		if r.grow(raio).has_point(p):
			return true
	return false

## Move com deslizamento: cada eixo é testado separadamente.
func mover(p: Vector2, velocidade: Vector2, raio: float) -> Vector2:
	var proximo := p
	if not bloqueado(proximo + Vector2(velocidade.x, 0.0), raio):
		proximo.x += velocidade.x
	if not bloqueado(proximo + Vector2(0.0, velocidade.y), raio):
		proximo.y += velocidade.y
	return proximo

## Se a posição ficou presa dentro de um obstáculo (ex.: ao fundir perto de uma parede,
## porque o raio aumenta), devolve o ponto livre mais próximo.
func resolver(p: Vector2, raio: float) -> Vector2:
	if not bloqueado(p, raio):
		return p
	for distancia in range(2, 61, 2):
		for i in 16:
			var candidato := p + Vector2.from_angle(TAU * i / 16.0) * distancia
			if not bloqueado(candidato, raio):
				return candidato
	return p

@warning_ignore("integer_division")
func _draw() -> void:
	for x in range(0, 1600, 40):
		for y in range(0, 960, 40):
			var tom := Color("1b2931") if (x / 40 + y / 40) % 2 == 0 else Color("1d2c34")
			draw_rect(Rect2(x, y, 39, 39), tom)
	draw_rect(Rect2(0, 395, 1600, 170), Color("26363e"))
	for x in range(30, 1600, 80):
		draw_rect(Rect2(x, 477, 35, 4), Color("53605a"))
	draw_rect(Rect2(75, 420, 150, 120), Color("254b48"))
	Desenho.texto(self, Vector2(90, 410), "ABRIGO", 18, "7be2bc")
	for r in obstaculos:
		draw_rect(Rect2(r.position + Vector2(9, 12), r.size), Color("0e1922"))
		draw_rect(r, Color("3d4c55"))
		draw_rect(Rect2(r.position + Vector2(5, 5), r.size - Vector2(10, 10)), Color("293943"))
		for x in range(int(r.position.x) + 15, int(r.end.x) - 15, 30):
			draw_rect(Rect2(x, r.position.y + 16, 12, 8), Color("65756b"))
		draw_rect(Rect2(r.position.x + 8, r.end.y - 12, r.size.x - 16, 5), Color("a47655"))
	Desenho.texto(self, Vector2(640, 385), "ZONA DE EXCLUSÃO  /  07", 14, "83959b")

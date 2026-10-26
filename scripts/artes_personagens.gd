extends RefCounted
const IMAGENS = [preload("res://assets/personagens/homem.png"), preload("res://assets/personagens/mulher.png")]
const NOMES = ["Sucateiro", "Sucateira"]
static func desenhar(no: Node2D, indice: int, esquerda: bool, t: float = 0.0, movendo: bool = false, golpe: float = 0.0) -> void:
	no.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	no.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, 0.30))
	no.draw_circle(Vector2(0, 8), 12, Color(0,0,0,0.22))
	var salto := -absf(sin(t * 11.0)) * 1.5 if movendo else sin(t * 2.0) * 0.35
	var inclinacao := sin(t * 11.0) * 0.025 if movendo else 0.0
	inclinacao += golpe * (0.12 if not esquerda else -0.12)
	no.draw_set_transform(Vector2(0, salto), inclinacao)
	var tamanho := Vector2(48, 72)
	var pos := Vector2(-24, -67)
	if esquerda:
		pos.x += tamanho.x
		tamanho.x = -tamanho.x
	no.draw_texture_rect(IMAGENS[indice], Rect2(pos, tamanho), false)

	no.draw_set_transform(Vector2.ZERO)

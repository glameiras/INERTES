extends RefCounted
const IMAGENS = [preload("res://assets/robos/bipede.png"), preload("res://assets/robos/flutuante.png"), preload("res://assets/robos/cerbero.png")]
static func desenhar(no: Node2D, tipo: int, esquerda: bool, t: float = 0.0, movendo: bool = false, golpe: float = 0.0, aliado: bool = false, morto: bool = false) -> void:
	no.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var tex: Texture2D = IMAGENS[tipo]
	var altura := 79.0 if tipo != 2 else 90.0
	var largura := altura * tex.get_width() / tex.get_height()
	var salto := sin(t * 4.0) * 2.5 if tipo == 1 else (-absf(sin(t * 10.0)) * 2.0 if movendo else sin(t * 2.0) * 0.4)
	var inclinacao := sin(t * 10.0) * 0.025 if movendo and tipo != 1 else 0.0
	inclinacao += golpe * (0.16 if not esquerda else -0.16)
	no.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, 0.30))
	no.draw_circle(Vector2(0, 8), largura * 0.25, Color(0,0,0,0.24))
	no.draw_set_transform(Vector2(0, salto), inclinacao, Vector2.ONE if not morto else Vector2(1, 0.25))
	var tamanho := Vector2(largura, altura)
	var pos := Vector2(-largura / 2, -altura + 5)
	if esquerda:
		pos.x += largura
		tamanho.x = -largura
	var cor := Color("a2e5ed") if aliado else Color.WHITE
	if morto:
		cor = Color(0.45,0.45,0.45,0.65)
	no.draw_texture_rect(tex, Rect2(pos, tamanho), false, cor)
	no.draw_set_transform(Vector2.ZERO)
	if aliado:
		no.draw_arc(Vector2.ZERO, 20, 0, TAU, 24, Color("72ded3"), 1.0)

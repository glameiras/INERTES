extends RefCounted
## Desenhos geométricos provisórios compartilhados (até chegarem os sprites).

static func robo(c: CanvasItem, p: Vector2, cor: Color, escala: float = 1.0) -> void:
	var s := escala
	p = p.floor()
	c.draw_rect(Rect2(p + Vector2(-14, 9) * s, Vector2(28, 8) * s), Color("0a1118"))
	for x in [-11, 5]:
		c.draw_rect(Rect2(p + Vector2(x, 5) * s, Vector2(6, 12) * s), Color("52616e"))
	c.draw_rect(Rect2(p + Vector2(-13, -11) * s, Vector2(26, 20) * s), cor)
	c.draw_rect(Rect2(p + Vector2(-19, -6) * s, Vector2(6, 17) * s), cor.darkened(0.25))
	c.draw_rect(Rect2(p + Vector2(13, -6) * s, Vector2(6, 17) * s), cor.darkened(0.25))
	c.draw_rect(Rect2(p + Vector2(-7, -21) * s, Vector2(14, 11) * s), Color("8d9ba3"))
	c.draw_rect(Rect2(p + Vector2(-5, -17) * s, Vector2(10, 3) * s), Color("c9ffff"))
	c.draw_rect(Rect2(p + Vector2(-4, -6) * s, Vector2(8, 8) * s), Color("e5ffe9"))

static func texto(c: CanvasItem, p: Vector2, conteudo: String, tamanho: int = 16, cor: String = "d7e4e8") -> void:
	c.draw_string(ThemeDB.fallback_font, p, conteudo, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, Color(cor))

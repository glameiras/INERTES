extends Node2D
## Luz local, brasas e fumaça em camadas; tempo visual respeita pausa.
var jogo: Node
var tonalidade: CanvasModulate
var tempo := 0.0
var luzes: Array[PointLight2D] = []
var pontos := [Vector2(300,105), Vector2(1390,100), Vector2(530,155)]
func _ready() -> void:
	z_index = 1800
	tonalidade = CanvasModulate.new()
	add_child(tonalidade)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1,1,1,0.9), Color(1,1,1,0)])
	var textura := GradientTexture2D.new()
	textura.gradient = grad
	textura.width = 128
	textura.height = 128
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5,0.5)
	textura.fill_to = Vector2(1,0.5)
	for ponto in pontos:
		var luz := PointLight2D.new()
		luz.texture = textura
		luz.texture_scale = 3.0
		luz.color = Color("ffaf60")
		luz.energy = 0.4
		luz.blend_mode = Light2D.BLEND_MODE_ADD
		luz.position = ponto
		add_child(luz)
		luzes.append(luz)
func _process(dt: float) -> void:
	if jogo.modo == "jogando": tempo += minf(dt,0.04)
	tonalidade.color = Color.WHITE.lerp(Color(0.38,0.48,0.65), jogo.ciclo.escuridao()*0.85)
	for i in luzes.size():
		luzes[i].visible = jogo.farm.ativa
		luzes[i].energy = 0.35 + sin(tempo*8+i)*0.08
	queue_redraw()
func _draw() -> void:
	if not jogo.farm.ativa: return
	for ponto in pontos:
		for i in 9:
			var fase := fmod(tempo*0.35 + i*0.113, 1.0)
			var pos: Vector2 = ponto + Vector2(sin(i*17.0+tempo)*10, -fase*125)
			draw_circle(pos, 9+fase*22, Color(0.13,0.16,0.15,(1-fase)*0.08))
		for i in 8:
			var fase := fmod(tempo*0.55+i*0.13,1.0)
			draw_circle(ponto+Vector2(sin(i*12.0+tempo)*16,-fase*85), 1.2, Color(1,0.6,0.2,1-fase))
	# Faixas de sombra translúcidas, sem encobrir o pátio central.
	draw_colored_polygon(PackedVector2Array([Vector2(0,250),Vector2(250,240),Vector2(530,420),Vector2(0,340)]), Color(0.03,0.08,0.1,0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(1200,200),Vector2(1600,210),Vector2(1600,390),Vector2(1450,340)]), Color(0.03,0.08,0.1,0.14))

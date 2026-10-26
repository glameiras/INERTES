extends Node2D
## O robô azul com o qual o Sucateiro pode se fundir.
## Fica invisível enquanto está fundido (o jogador passa a desenhar o robô).

const Desenho = preload("res://scripts/desenho.gd")

const Robos = preload("res://scripts/artes_robos.gd")
var relogio := 0.0
var dica := ""

func _process(dt: float) -> void:
	if get_parent().get("modo") == "jogando":
		relogio += dt
	z_index = int(position.y)
	queue_redraw()

func _draw() -> void:
	Robos.desenhar(self, 0, false, relogio, false, 0, true)
	if dica != "":
		Desenho.texto(self, Vector2(-38, -88), dica, 13, "79e9df")

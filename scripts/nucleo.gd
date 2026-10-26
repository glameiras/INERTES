extends Node2D
## O núcleo a ser recuperado.

const Cfg = preload("res://scripts/config.gd")
const Desenho = preload("res://scripts/desenho.gd")

var pego := false
var relogio := 0.0

func _ready() -> void:
	position = Cfg.NUCLEO

func _process(dt: float) -> void:
	relogio += dt
	queue_redraw()

func _draw() -> void:
	if pego:
		return
	draw_circle(Vector2.ZERO, 16.0 + sin(relogio * 3.0) * 2.0, Color(0.4, 1.0, 0.85, 0.12))
	draw_rect(Rect2(-6, -6, 12, 12), Color("8bf2cf"))
	Desenho.texto(self, Vector2(-24, 36), "NÚCLEO", 12, "8bf2cf")

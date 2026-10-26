extends Node2D
## Inimigo comum ou Soberano. Todo golpe tem preparação (área vermelha) e recuperação.

const Cfg = preload("res://scripts/config.gd")
const Desenho = preload("res://scripts/desenho.gd")
const Mundo = preload("res://scripts/mundo.gd")

## O golpe acontece no fim da preparação, na área marcada (posicao, raio).
signal atacou(posicao: Vector2, raio: float, dano: float)

const Robos = preload("res://scripts/artes_robos.gd")
var tipo_visual := 0
var relogio := 0.0
var movendo := false
var esquerda := false
var impacto := 0.0
var velocidade_visual := 0.0

var mundo: Mundo
var noturno := false
var chefe := false
var vida := Cfg.COMUM_VIDA
var vida_max := Cfg.COMUM_VIDA
var fase := "andar" # andar | preparar | recuperar
var tempo := 0.0
var alvo := Vector2.ZERO

func configurar(pos: Vector2, eh_chefe: bool, mundo_ref: Mundo) -> void:
	position = pos
	chefe = eh_chefe
	vida_max = Cfg.CHEFE_VIDA if eh_chefe else Cfg.COMUM_VIDA
	vida = vida_max
	fase = "andar"
	tempo = 0.0
	alvo = pos
	mundo = mundo_ref

func raio() -> float:
	return Cfg.CHEFE_RAIO if chefe else Cfg.COMUM_RAIO

func _area() -> float:
	return Cfg.CHEFE_AREA if chefe else Cfg.COMUM_AREA

func _preparo() -> float:
	return (Cfg.CHEFE_PREPARO if chefe else Cfg.COMUM_PREPARO) * (0.8 if noturno else 1.0)

func vivo() -> bool:
	return vida > 0.0

## Devolve true se este golpe derrotou o inimigo.
func receber_dano(quantidade: float, direcao: Vector2) -> bool:
	vida -= quantidade
	var empurrao := Cfg.CHEFE_EMPURRAO if chefe else Cfg.COMUM_EMPURRAO
	position = mundo.mover(position, direcao * empurrao, raio())
	return vida <= 0.0

func atualizar(dt: float, pos_jogador: Vector2) -> void:
	if not vivo():
		return
	relogio += dt
	impacto = maxf(0.0, impacto - dt * 6.0)
	movendo = false
	if absf(pos_jogador.x - position.x) > 5:
		esquerda = pos_jogador.x < position.x
	var distancia := position.distance_to(pos_jogador)
	if fase == "preparar":
		tempo -= dt
		if tempo <= 0.0:
			impacto = 1.0
			atacou.emit(alvo, _area(), Cfg.CHEFE_DANO if chefe else Cfg.COMUM_DANO)
			fase = "recuperar"
			tempo = Cfg.CHEFE_RECUPERACAO if chefe else Cfg.COMUM_RECUPERACAO
	elif fase == "recuperar":
		tempo -= dt
		if tempo <= 0.0:
			fase = "andar"
	elif distancia < (Cfg.CHEFE_GATILHO if chefe else Cfg.COMUM_GATILHO):
		fase = "preparar"
		alvo = pos_jogador
		tempo = _preparo()
	elif distancia < Cfg.AGRO * (1.65 if noturno else 1.0):
		_andar(pos_jogador, dt)

## Anda na direção do jogador; se bater em um obstáculo, tenta desviar em ângulos maiores.
func _andar(destino: Vector2, dt: float) -> void:
	var direcao := (destino - position).normalized()
	velocidade_visual = move_toward(velocidade_visual, Cfg.CHEFE_VELOCIDADE if chefe else Cfg.COMUM_VELOCIDADE, 450.0 * dt)
	var passo := velocidade_visual * dt
	for desvio in [0.0, 0.9, -0.9, 1.57, -1.57]:
		var novo := mundo.mover(position, direcao.rotated(desvio) * passo, raio())
		if novo.distance_to(position) >= passo * 0.5:
			movendo = true
			position = novo
			return

func _process(_dt: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not vivo():
		Robos.desenhar(self, 2 if chefe else tipo_visual, esquerda, 0, false, 0, false, true)
		return
	if noturno:
		draw_arc(Vector2.ZERO, raio()+7, 0, TAU, 24, Color(0.3,1,0.55,0.6), 1.5)
	if fase == "preparar":
		var centro := alvo - position
		var area := _area()
		var progresso := 1.0 - clampf(tempo / _preparo(), 0.0, 1.0)
		draw_circle(centro, area, Color(1.0, 0.2, 0.3, 0.16))
		draw_circle(centro, area * progresso, Color(1.0, 0.2, 0.3, 0.22))
		draw_arc(centro, area, 0.0, TAU, 32, Color("ff6969"), 2.0)
	Robos.desenhar(self, 2 if chefe else tipo_visual, esquerda, relogio, movendo, impacto)
	draw_rect(Rect2(-22, -94, 44, 4), Color("111a22"))
	draw_rect(Rect2(-22, -94, 44.0 * maxf(0.0, vida) / vida_max, 4), Color("ef7980"))
	if chefe:
		Desenho.texto(self, Vector2(-42, -103), "CÉRBERO", 13, "ef7980")

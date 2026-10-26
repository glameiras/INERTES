extends Node2D
## O Sucateiro (ou o Inerte, quando fundido): movimento, ataque, esquiva e vida.
## Não lê o teclado: recebe a direção de quem o controla (facilita testes e controle).

const Cfg = preload("res://scripts/config.gd")
const Desenho = preload("res://scripts/desenho.gd")
const Mundo = preload("res://scripts/mundo.gd")

signal atacou(origem: Vector2, olhar: Vector2, alcance: float, dano: float)
signal esquivou
signal sofreu_dano

var tipo_robo := 0
var personagem := 0
const Artes = preload("res://scripts/artes_personagens.gd")

const Robos = preload("res://scripts/artes_robos.gd")
var velocidade_atual := Vector2.ZERO
var movendo := false

var mundo: Mundo
var vida := Cfg.VIDA_MAX
var folego := Cfg.FOLEGO_MAX
var pilotando := false
var olhar := Vector2.RIGHT
var invuln := 0.0
var recarga := 0.0
var buffer_ataque := 0.0
var golpe_visual := 0.0
var esquiva_t := 0.0
var esquiva_recarga := 0.0
var esquiva_dir := Vector2.RIGHT
var relogio_visual := 0.0

func reiniciar() -> void:
	velocidade_atual = Vector2.ZERO
	movendo = false
	position = Cfg.SPAWN
	vida = Cfg.VIDA_MAX
	folego = Cfg.FOLEGO_MAX
	pilotando = false
	tipo_robo = 0
	olhar = Vector2.RIGHT
	invuln = 0.0
	recarga = 0.0
	buffer_ataque = 0.0
	golpe_visual = 0.0
	esquiva_t = 0.0
	esquiva_recarga = 0.0

func raio() -> float:
	return Cfg.RAIO_FUSAO if pilotando else Cfg.RAIO_SUCATEIRO

func atualizar(dt: float, direcao: Vector2) -> void:
	invuln = maxf(0.0, invuln - dt)
	recarga = maxf(0.0, recarga - dt)
	golpe_visual = maxf(0.0, golpe_visual - dt)
	esquiva_recarga = maxf(0.0, esquiva_recarga - dt)
	buffer_ataque = maxf(0.0, buffer_ataque - dt)
	folego = minf(Cfg.FOLEGO_MAX, folego + Cfg.FOLEGO_REGEN * dt)
	if direcao.length() > 0.2:
		olhar = direcao.normalized()
	var velocidade: float = [125.0, 190.0, 100.0][tipo_robo] if pilotando else Cfg.VEL_SUCATEIRO
	velocidade_atual = velocidade_atual.move_toward(direcao * velocidade, (1500.0 if direcao.length() < 0.1 else 1100.0) * dt)
	var passo := velocidade_atual * dt
	if esquiva_t > 0.0:
		esquiva_t -= dt
		passo = esquiva_dir * Cfg.ESQUIVA_VELOCIDADE * dt
	var anterior := position
	position = mundo.mover(position, passo, raio())
	movendo = position.distance_to(anterior) > 0.01
	relogio_visual += dt
	if buffer_ataque > 0.0 and recarga <= 0.0:
		buffer_ataque = 0.0
		_disparar_ataque()

func pedir_ataque() -> void:
	if recarga <= 0.0:
		_disparar_ataque()
	else:
		buffer_ataque = Cfg.ATAQUE_BUFFER

func tentar_esquiva() -> bool:
	if esquiva_recarga > 0.0 or folego < Cfg.ESQUIVA_CUSTO:
		return false
	esquiva_t = Cfg.ESQUIVA_DURACAO
	esquiva_recarga = Cfg.ESQUIVA_RECARGA
	esquiva_dir = olhar
	folego -= Cfg.ESQUIVA_CUSTO
	invuln = maxf(invuln, Cfg.ESQUIVA_INVULN)
	esquivou.emit()
	return true

## Devolve true se o dano foi aplicado (false se estava invulnerável).
func receber_dano(quantidade: float) -> bool:
	if invuln > 0.0:
		return false
	vida = maxf(0.0, vida - quantidade * (Cfg.DANO_RECEBIDO_FUSAO if pilotando else 1.0))
	invuln = Cfg.INVULN_APOS_DANO
	sofreu_dano.emit()
	return true

func _disparar_ataque() -> void:
	recarga = Cfg.ATAQUE_RECARGA_FUSAO if pilotando else Cfg.ATAQUE_RECARGA_SUCATEIRO
	golpe_visual = 0.15
	var alcance := Cfg.ATAQUE_ALCANCE_FUSAO if pilotando else Cfg.ATAQUE_ALCANCE_SUCATEIRO
	var dano := Cfg.ATAQUE_DANO_FUSAO if pilotando else Cfg.ATAQUE_DANO_SUCATEIRO
	atacou.emit(position, olhar, alcance, dano * (1.3 if pilotando and tipo_robo == 2 else 1.0))

func _process(_dt: float) -> void:
	queue_redraw()

func _draw() -> void:
	if invuln <= 0.0 or int(relogio_visual * 18.0) % 2 == 0:
		if pilotando:
			Robos.desenhar(self, tipo_robo, olhar.x < -0.1, relogio_visual, movendo, golpe_visual / 0.15, true)
		else:
			Artes.desenhar(self, personagem, olhar.x < -0.1, relogio_visual, movendo, golpe_visual / 0.15)
		draw_line(Vector2.ZERO, olhar * 24.0, Color("c3edf0"), 2.0)
	if golpe_visual > 0.0:
		var angulo := olhar.angle()
		var raio_arco := 77.0 if pilotando else 40.0
		draw_arc(Vector2.ZERO, raio_arco, angulo - 1.1, angulo + 1.1, 12, Color("b6fff3"), 4.0)

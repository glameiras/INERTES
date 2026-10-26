extends Node2D
## Segue posições já percorridas pelo jogador, preservando seu caminho.
const Artes = preload("res://scripts/artes_personagens.gd")
var recarga := 0.0
var tiro_t := 0.0
var tiro_alvo := Vector2.ZERO
var relogio := 0.0
var movendo := false
var velocidade := 0.0
var personagem := 1
var olhar := Vector2.RIGHT
var trilha: Array[Vector2] = []
var ultima := Vector2.ZERO
func reiniciar(origem: Vector2, escolha: int) -> void:
	personagem = 1 - escolha
	position = origem + Vector2(-40, 0)
	ultima = origem
	trilha.clear()
	recarga = 0
	tiro_t = 0
	velocidade = 0.0
	movendo = false
	queue_redraw()
func atualizar(dt: float, alvo: Vector2) -> void:
	if ultima.distance_to(alvo) >= 6.0:
		trilha.append(alvo)
		ultima = alvo
	var restante := 0.0
	var anterior := position
	for ponto in trilha:
		restante += anterior.distance_to(ponto)
		anterior = ponto
	var inicio := position
	velocidade = move_toward(velocidade, minf(240.0, maxf(0.0, restante - 52.0) * 5.0), 1000.0 * dt)
	var passo := minf(velocidade * dt, maxf(0.0, restante - 52.0))
	while passo > 0.0 and not trilha.is_empty():
		var delta := trilha[0] - position
		var distancia := delta.length()
		if distancia > 0.01:
			olhar = delta.normalized()
		if distancia <= passo:
			position = trilha.pop_front()
			passo -= distancia
		else:
			position += delta.normalized() * passo
			passo = 0.0
	movendo = position.distance_to(inicio) > 0.01
	relogio += dt
	z_index = int(position.y)
	queue_redraw()
func _draw() -> void:
	Artes.desenhar(self, personagem, olhar.x < -0.1, relogio, movendo)
	if tiro_t > 0:
		draw_line(Vector2(0,-30), tiro_alvo - position, Color(0.5,0.95,0.85,tiro_t/0.12), 2)
	draw_circle(Vector2(0, 4), 3, Color("78ced5"))

func combater(dt: float, jogo: Node) -> void:
	recarga = maxf(0, recarga - dt)
	tiro_t = maxf(0, tiro_t - dt)
	if recarga > 0 or jogo.farm.municao <= 0: return
	var melhor: Node2D = null
	var distancia := 240.0
	for e in jogo.inimigos:
		if not e.vivo(): continue
		var d := position.distance_to(e.position)
		if d >= distancia: continue
		var livre := true
		for k in range(1,13):
			if jogo.mundo.bloqueado(position.lerp(e.position, k/13.0), 2):
				livre = false
				break
		if livre:
			melhor = e
			distancia = d
	if melhor != null:
		olhar = (melhor.position-position).normalized()
		tiro_alvo = melhor.position + Vector2(0,-28)
		tiro_t = 0.12
		jogo.farm.municao -= 1
		recarga = 0.85
		melhor.receber_dano(12, Vector2.ZERO)
		jogo.efeitos.rajada(melhor.position, Color("78ced5"))

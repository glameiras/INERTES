extends Node2D
const Cfg = preload("res://scripts/config.gd")
const Robos = preload("res://scripts/artes_robos.gd")
const Texto = preload("res://scripts/desenho.gd")
var jogo: Node
var ativa := false
var sucata := 0
var municao := 60
const ICONES = [preload("res://assets/itens/ferragens.svg"), preload("res://assets/itens/celula.svg"), preload("res://assets/itens/kit.svg"), preload("res://assets/itens/municao.svg")]
var kits := 2
var energia := 100.0
var ciclo := 0
var onda_t := 0.0
var coletados: Array[int] = []
var baixas: Array = []
var loot: Array[Dictionary] = []
var guardados: Array = []
var pos_missao := Vector2.ZERO
var robo_missao := Vector2.ZERO
var obstaculos_missao: Array[Rect2] = []
var estacoes := [Vector2(650, 360), Vector2(870, 360), Vector2(1090, 360)]
var saida := Vector2(520, 480)
func reiniciar() -> void:
	if ativa:
		trocar()
	municao = 60
	sucata = 0
	kits = 2
	energia = 100
	ciclo = 0
	loot.clear()
	baixas.clear()
	coletados.clear()
func trocar() -> void:
	if not ativa:
		pos_missao = jogo.jogador.position
		robo_missao = jogo.inerte.position
		obstaculos_missao = jogo.mundo.obstaculos.duplicate()
		guardados = jogo.inimigos.duplicate()
		for e in guardados:
			e.hide()
		jogo.inimigos = []
		jogo.mundo.obstaculos.assign([Rect2(0,0,1600,260), Rect2(0,800,1600,160), Rect2(0,430,440,530), Rect2(1400,430,200,530)])
		ativa = true
		ciclo = 0
		onda_t = 6
		loot = [{"pos":Vector2(600,550), "tipo":0}, {"pos":Vector2(750,590), "tipo":1}, {"pos":Vector2(900,640), "tipo":2}, {"pos":Vector2(1000,560), "tipo":3}]
		baixas.clear()
		jogo.jogador.position = saida + Vector2(80,0)
		jogo.inerte.hide()
	else:
		for e in jogo.inimigos:
			e.queue_free()
		jogo.inimigos = guardados.duplicate()
		for e in jogo.inimigos:
			e.show()
		guardados.clear()
		ativa = false
		jogo.mundo.obstaculos = obstaculos_missao.duplicate()
		jogo.jogador.position = pos_missao
		jogo.inerte.position = robo_missao
		jogo.inerte.visible = not jogo.jogador.pilotando
	jogo.nucleo.visible = not ativa
	jogo.get_node("cenario").visible = not ativa
	jogo.get_node("FarmCenario").visible = ativa
	jogo.get_node("FarmFrente").visible = ativa
	jogo.jogador.velocidade_atual = Vector2.ZERO
	jogo.dupla.reiniciar(jogo.jogador.position, jogo.escolha)
	jogo.dizer("DEPÓSITO: recolha suprimentos, escolha uma máquina com E. F na saída para voltar." if ativa else "De volta à missão. Suprimentos e máquina mantidos.", 7)
func interagir() -> bool:
	if not ativa:
		return false
	if jogo.jogador.position.distance_to(Vector2(540,650)) < 60:
		if sucata >= 10:
			sucata -= 10
			energia = minf(100, energia + 50)
			kits += 1
			jogo.dizer("10 sucatas trocadas por 1 kit e 50 de energia.")
		else:
			jogo.dizer("Bancada: precisa de 10 sucatas para 1 kit e 50 de energia.")
		return true
	for i in estacoes.size():
		if jogo.jogador.position.distance_to(estacoes[i]) < 65:
			if energia < 10:
				jogo.dizer("Sem energia. Recolha células azuis no depósito.")
				return true
			jogo.jogador.tipo_robo = i
			jogo.jogador.pilotando = true
			jogo.dizer("Fusão: " + ["Bípede — equilibrado", "Flutuante — veloz", "Cérbero — pesado"][i])
			return true
	if jogo.jogador.pilotando:
		jogo.jogador.pilotando = false
		jogo.dizer("Fusão encerrada. Escolha outra máquina nas estações.")
	return true
func curar() -> void:
	if kits > 0 and jogo.jogador.vida < 100:
		kits -= 1
		jogo.jogador.vida = minf(100, jogo.jogador.vida + 40)
		jogo.dizer("Kit usado: +40 de integridade.")
func atualizar(dt: float) -> void:
	if jogo.jogador.pilotando:
		energia = maxf(0, energia - dt * 0.5)
		if energia <= 0:
			jogo.jogador.pilotando = false
			jogo.inerte.visible = not ativa
			jogo.dizer("Energia esgotada. Fusão encerrada.")
	if not ativa:
		queue_redraw()
		return
	for e in jogo.inimigos:
		if not e.vivo() and not e in baixas:
			baixas.append(e)
			loot.append({"pos":e.position, "tipo":(ciclo + baixas.size()) % 4})
	for i in range(loot.size()-1,-1,-1):
		if jogo.jogador.position.distance_to(loot[i].pos) < 32:
			match int(loot[i].tipo):
				0: sucata += 5
				1:
					energia = minf(100, energia + 30)
					jogo.jogador.vida = minf(100, jogo.jogador.vida + 10)
				2: kits += 1
				3: municao += 24
			jogo.efeitos.rajada(loot[i].pos, Color("7be2bc"))
			loot.remove_at(i)
	onda_t -= dt
	var vivos := 0
	for e in jogo.inimigos:
		if e.vivo(): vivos += 1
	if onda_t <= 0 and vivos == 0:
		for e in jogo.inimigos: e.queue_free()
		jogo.inimigos.clear()
		baixas.clear()
		ciclo += 1
		for i in mini(2 + ciclo, 5):
			jogo._criar_inimigo(Vector2(1100 + i*65, 340 + (i%2)*300), false)
		onda_t = 12
	queue_redraw()
func _draw() -> void:
	var portal := saida if ativa else Cfg.SPAWN + Vector2(80,0)
	draw_arc(portal, 33, 0, TAU, 40, Color("78ced5"), 2)
	Texto.texto(self, portal + Vector2(-60,45), "[F] VOLTAR" if ativa else "[F] DEPÓSITO", 13, "9beddf")
	if not ativa: return
	for item in loot:
		draw_texture_rect(ICONES[int(item.tipo)], Rect2(item.pos-Vector2(20,30),Vector2(40,40)),false)
		if jogo.jogador.position.distance_to(item.pos) < 100:
			Texto.texto(self, item.pos+Vector2(-30,25), ["FERRAGENS","REGENERAÇÃO","KIT MÉDICO","MUNIÇÃO"][int(item.tipo)], 11)

	Texto.texto(self, Vector2(460,690), "[E] BANCADA / 10 SUCATAS", 13, "e6c48b")
	for i in estacoes.size():
		draw_set_transform(estacoes[i])
		Robos.desenhar(self, i, false, 0, false, 0, true)
		draw_set_transform(Vector2.ZERO)
		Texto.texto(self, estacoes[i]+Vector2(-65,30), ["[E] BÍPEDE", "[E] FLUTUANTE", "[E] CÉRBERO"][i], 13, "9beddf")

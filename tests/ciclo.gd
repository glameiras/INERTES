extends SceneTree
func _initialize() -> void:
	call_deferred("executar")
func executar() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	jogo.set_process(false)
	jogo._escolher(0)
	assert(not jogo.ciclo.noite())
	jogo.ciclo.atualizar(120)
	assert(jogo.ciclo.noite())
	assert(jogo.ciclo.rotulo().begins_with("18:30"))
	var hora: float = jogo.ciclo.hora
	jogo.modo = "pausa"
	jogo._process(0.04)
	assert(jogo.ciclo.hora == hora)
	jogo.modo = "jogando"
	jogo.farm.trocar()
	assert(jogo.mundo.bloqueado(Vector2(250,600),10))
	for item in jogo.farm.loot:
		assert(not jogo.mundo.bloqueado(item.pos,17))
	for pos in jogo.farm.estacoes:
		assert(not jogo.mundo.bloqueado(pos,17))
	assert(jogo.get_node("FarmFrente").visible)
	assert(jogo.get_node("FarmFrente").z_index == 900)
	jogo.farm.energia = 10
	jogo.jogador.vida = 50
	jogo.jogador.position = Vector2(750,590)
	jogo.farm.atualizar(0)
	assert(jogo.farm.energia == 40 and jogo.jogador.vida == 60)
	var municao: int = jogo.farm.municao
	jogo.jogador.position = Vector2(1000,560)
	jogo.farm.atualizar(0)
	assert(jogo.farm.municao == municao+24)
	jogo._criar_inimigo(Vector2(900,500),false)
	var e = jogo.inimigos[0]
	jogo.dupla.position = Vector2(880,500)
	jogo.farm.municao = 0
	jogo.dupla.recarga = 0
	var vida: float = e.vida
	jogo.dupla.combater(0.1,jogo)
	assert(e.vida == vida)
	e.position = Vector2(1000,500)
	e.noturno = true
	e.atualizar(0.016,Vector2(550,500))
	assert(e.movendo)
	e.noturno = false
	e.movendo = false
	e.atualizar(0.016,Vector2(550,500))
	assert(not e.movendo)
	jogo.farm.trocar()
	assert(not jogo.get_node("FarmFrente").visible)
	print("Dia/noite, loot, barreiras e profundidade: OK")
	jogo.free()
	quit()

extends SceneTree
var erros := 0
func verificar(ok: bool, texto: String) -> void:
	if not ok:
		erros += 1
		printerr(texto)
func _initialize() -> void:
	call_deferred("executar")
func executar() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	jogo.set_process(false)
	jogo._escolher(1)
	var farm = jogo.farm
	var inimigo = jogo.inimigos[0]
	inimigo.vida = 33
	var pos: Vector2 = jogo.jogador.position
	farm.trocar()
	verificar(farm.ativa and jogo.inimigos.is_empty(), "Entrada no depósito")
	verificar(not inimigo.visible, "Missão fica suspensa")
	jogo.jogador.position = Vector2(600,550)
	farm.atualizar(0.1)
	verificar(farm.sucata == 5, "Coleta de sucata")
	farm.atualizar(0.1)
	verificar(farm.sucata == 5, "Não coleta duas vezes")
	for i in 3:
		jogo.jogador.position = farm.estacoes[i]
		farm.interagir()
		verificar(jogo.jogador.pilotando and jogo.jogador.tipo_robo == i, "Escolha de fusão")
	farm.energia = 0.01
	farm.atualizar(0.1)
	verificar(not jogo.jogador.pilotando, "Energia esgotada encerra fusão")
	jogo.jogador.vida = 20
	farm.curar()
	verificar(jogo.jogador.vida == 60 and farm.kits == 1, "Kit recupera vida e é consumido")
	farm.sucata = 10
	jogo.jogador.position = Vector2(540,650)
	farm.interagir()
	verificar(farm.sucata == 0 and farm.kits == 2 and farm.energia == 50, "Troca na bancada")
	farm.onda_t = 0
	farm.atualizar(0.1)
	verificar(jogo.inimigos.size() == 3, "Onda de farm")
	for e in jogo.inimigos: e.vida = 0
	farm.atualizar(0.1)
	verificar(farm.loot.size() >= 3, "Inimigos derrubam recursos")
	farm.trocar()
	verificar(not farm.ativa and jogo.inimigos[0] == inimigo and inimigo.vida == 33, "Retorno preserva combate da missão")
	verificar(jogo.jogador.position == pos, "Retorno preserva posição")
	# Dupla combate à distância fora da máquina.
	jogo.dupla.position = Vector2(590,450)
	jogo.dupla.recarga = 0
	inimigo.position = Vector2(620,450)
	var vida: float = inimigo.vida
	jogo.jogador.pilotando = false
	jogo.dupla.combater(0.016,jogo)
	verificar(inimigo.vida == vida-12, "Dupla causa dano sem fusão")
	jogo.dupla.combater(0.016,jogo)
	verificar(inimigo.vida == vida-12, "Recarga da dupla")
	# Uma parede bloqueia o apoio.
	jogo.dupla.recarga = 0
	jogo.dupla.position = Vector2(400,250)
	inimigo.position = Vector2(590,250)
	vida = inimigo.vida
	jogo.dupla.combater(0.016,jogo)
	verificar(inimigo.vida == vida, "Dupla não atira através de paredes")
	farm.trocar()
	jogo.reiniciar()
	verificar(not farm.ativa and jogo.inimigos.size() == 5 and farm.kits == 2, "Reinício no farm restaura missão")
	print("Farm e apoio: ", erros, " falhas")
	jogo.free()
	quit(erros)

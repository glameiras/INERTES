extends SceneTree
var falhas := 0
func check(ok: bool, texto: String) -> void:
	if not ok:
		falhas += 1
		printerr(texto)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	jogo.set_process(false)
	check(jogo.modo == "titulo" and jogo.selecao.visible, "Tela de escolha inicial")
	for i in 2:
		jogo.selecao.botoes[i].pressed.emit()
		check(jogo.jogador.personagem == i, "Escolha do jogador")
		check(jogo.dupla.personagem == 1-i, "Dupla oposta")
		check(jogo.modo == "jogando" and not jogo.selecao.visible, "Iniciar missão")
		for x in range(150, 401, 5):
			jogo.dupla.atualizar(0.03, Vector2(x, 480))
		for n in 120:
			jogo.dupla.atualizar(0.016, Vector2(400,480))
		check(jogo.dupla.position.x > 300 and jogo.dupla.position.x < 400, "Segue e mantém distância")
		jogo.modo = "pausa"
		var antes: Vector2 = jogo.dupla.position
		jogo._process(0.016)
		check(jogo.dupla.position == antes, "Pausa congela dupla")
		jogo.reiniciar()
		check(jogo.dupla.trilha.is_empty(), "Reinício limpa caminho")
		check(jogo.jogador.personagem == i, "Reinício preserva escolha")
	print("Dupla: ", falhas, " falhas")
	quit(falhas)

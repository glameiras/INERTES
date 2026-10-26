extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	jogo.set_process(false)
	jogo._escolher(0)
	var j = jogo.jogador
	j.atualizar(0.016, Vector2.RIGHT)
	assert(j.velocidade_atual.x > 0 and j.velocidade_atual.x < 170)
	for i in 30:
		j.atualizar(0.016, Vector2.RIGHT)
	assert(is_equal_approx(j.velocidade_atual.x, 170.0))
	for i in 20:
		j.atualizar(0.016, Vector2.ZERO)
	assert(j.velocidade_atual == Vector2.ZERO)
	assert(jogo.inimigos[0].tipo_visual == 0 and jogo.inimigos[1].tipo_visual == 1)
	var tempo: float = j.relogio_visual
	jogo.modo = "pausa"
	jogo._process(0.1)
	assert(j.relogio_visual == tempo)
	print("Movimento: aceleração, parada, pausa e variantes aprovadas")
	jogo.free()
	quit()

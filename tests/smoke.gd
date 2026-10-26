extends SceneTree
## Testes de regras. Rodar com:
##   godot --headless --path . --script res://tests/smoke.gd
## Sai com código 0 se tudo passar e 1 se algo falhar.

const Cfg = preload("res://scripts/config.gd")
const Controles = preload("res://scripts/controles.gd")

var falhas := 0
var verificacoes := 0

func _initialize() -> void:
	call_deferred("executar")

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		printerr("FALHOU: " + mensagem)

func executar() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	jogo.set_process(false)
	jogo.reiniciar()
	var jogador = jogo.jogador

	# --- Entrada: todas as ações existem, com teclado e controle ---
	for acao in ["mover_esquerda", "mover_direita", "mover_cima", "mover_baixo", "atacar", "esquivar", "interagir", "pausar", "confirmar"]:
		conferir(InputMap.has_action(acao), "ação registrada: " + acao)
		var tem_teclado := false
		var tem_controle := false
		for ev in InputMap.action_get_events(acao):
			if ev is InputEventKey:
				tem_teclado = true
			if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				tem_controle = true
		conferir(tem_teclado, "ação com tecla: " + acao)
		conferir(tem_controle, "ação com controle: " + acao)

	# --- Estado inicial ---
	conferir(jogo.inimigos.size() == 5, "5 inimigos na missão")
	conferir(jogo.chefe_vivo(), "o Soberano começa vivo")
	conferir(jogo.modo == "jogando", "reiniciar entra em jogo")

	# --- Fusão ---
	jogador.position = jogo.inerte.position
	jogo.interagir()
	conferir(jogador.pilotando, "fusão ao interagir perto do Inerte")

	# --- Ataque, recarga e buffer (fundido: 38 de dano, recarga 0.48) ---
	jogador.position = Vector2(590, 450)
	jogador.olhar = Vector2.RIGHT
	var primeiro = jogo.inimigos[0]
	jogador.pedir_ataque()
	conferir(is_equal_approx(primeiro.vida, Cfg.COMUM_VIDA - Cfg.ATAQUE_DANO_FUSAO), "golpe fundido causa o dano esperado")
	jogador.pedir_ataque()
	conferir(is_equal_approx(primeiro.vida, Cfg.COMUM_VIDA - Cfg.ATAQUE_DANO_FUSAO), "recarga impede segundo golpe imediato")
	conferir(jogador.buffer_ataque > 0.0, "segundo clique fica em buffer")
	jogador.atualizar(Cfg.ATAQUE_RECARGA_FUSAO - 0.05, Vector2.ZERO)
	jogador.pedir_ataque() # ainda em recarga: entra no buffer
	jogador.atualizar(0.10, Vector2.ZERO) # recarga termina com o buffer ainda válido
	conferir(primeiro.vida <= 0.0, "buffer dispara o golpe quando a recarga acaba")

	# --- Dano, invulnerabilidade e redução na fusão ---
	jogador.vida = Cfg.VIDA_MAX
	jogador.invuln = 0.2
	conferir(not jogador.receber_dano(20.0), "invulnerável não recebe dano")
	conferir(is_equal_approx(jogador.vida, Cfg.VIDA_MAX), "vida intacta sob invulnerabilidade")
	jogador.invuln = 0.0
	conferir(jogador.receber_dano(20.0), "dano aplicado fora da invulnerabilidade")
	conferir(is_equal_approx(jogador.vida, Cfg.VIDA_MAX - 20.0 * Cfg.DANO_RECEBIDO_FUSAO), "fusão reduz o dano")

	# --- Esquiva ---
	jogo.reiniciar()
	jogador = jogo.jogador
	conferir(jogador.tentar_esquiva(), "esquiva com fôlego")
	conferir(is_equal_approx(jogador.folego, Cfg.FOLEGO_MAX - Cfg.ESQUIVA_CUSTO), "esquiva consome fôlego")
	conferir(jogador.invuln > 0.0, "esquiva dá invulnerabilidade")
	conferir(not jogador.tentar_esquiva(), "esquiva em recarga é recusada")

	# --- Colisão e saída de dentro de obstáculo ---
	conferir(jogo.mundo.bloqueado(Vector2(460, 230), 10.0), "obstáculo bloqueia")
	conferir(not jogo.mundo.bloqueado(Vector2(600, 480), 10.0), "espaço livre não bloqueia")
	var perto := Vector2(480, 352)
	conferir(not jogo.mundo.bloqueado(perto, Cfg.RAIO_SUCATEIRO) and jogo.mundo.bloqueado(perto, Cfg.RAIO_FUSAO), "ponto livre para o Sucateiro e preso para o Inerte")
	conferir(not jogo.mundo.bloqueado(jogo.mundo.resolver(perto, Cfg.RAIO_FUSAO), Cfg.RAIO_FUSAO), "resolver tira da parede")

	# --- Inimigo: preparação, golpe e recuperação ---
	jogo.reiniciar()
	jogador = jogo.jogador
	var comum = jogo.inimigos[0]
	comum.position = jogador.position + Vector2(30, 0)
	jogo.tick(0.016)
	conferir(comum.fase == "preparar", "inimigo perto prepara o golpe")
	conferir(is_equal_approx(jogador.vida, Cfg.VIDA_MAX), "nenhum dano durante a preparação")
	var passos := 0
	while comum.fase == "preparar" and passos < 100:
		jogo.tick(0.016)
		passos += 1
	conferir(comum.fase == "recuperar", "inimigo entra em recuperação depois do golpe")
	conferir(is_equal_approx(jogador.vida, Cfg.VIDA_MAX - Cfg.COMUM_DANO), "golpe acerta quem não esquivou")

	# --- Inimigo contorna obstáculo (melhora, não garante) ---
	jogo.reiniciar()
	jogador = jogo.jogador
	var contorno = jogo.inimigos[0]
	contorno.position = Vector2(495, 150)
	jogador.position = Vector2(495, 400)
	var inicio: float = contorno.position.distance_to(jogador.position)
	for i in 400:
		contorno.atualizar(0.016, jogador.position)
		if contorno.fase != "andar":
			break
	conferir(contorno.position.distance_to(jogador.position) < inicio - 100.0, "inimigo contorna o obstáculo em direção ao jogador")

	# --- Núcleo, vitória, derrota e reinício ---
	jogo.reiniciar()
	jogador = jogo.jogador
	jogador.position = Cfg.NUCLEO
	jogo.interagir()
	conferir(not jogo.nucleo.pego, "núcleo bloqueado pelo Soberano")
	for e in jogo.inimigos:
		e.vida = 0.0
	jogo.interagir()
	conferir(jogo.nucleo.pego, "núcleo recolhido depois de derrotar o Soberano")
	jogador.position = Cfg.SPAWN
	jogo.tick(0.016)
	conferir(jogo.modo == "vitoria", "vitória ao voltar ao abrigo com o núcleo")
	jogo.reiniciar()
	conferir(not jogo.nucleo.pego and is_equal_approx(jogo.jogador.vida, Cfg.VIDA_MAX) and not jogo.jogador.pilotando, "reiniciar restaura o estado")
	conferir(jogo.inimigos.size() == 5 and jogo.inimigos_no.get_child_count() == 5, "reiniciar recria os 5 inimigos sem sobras")
	jogo.jogador.vida = 0.0
	jogo.tick(0.016)
	conferir(jogo.modo == "derrota", "derrota com vida zerada")
	jogo.reiniciar()
	for i in 600:
		jogo.tick(0.016)

	if falhas == 0:
		print("PASSOU: %d verificações" % verificacoes)
	else:
		printerr("%d de %d verificações falharam" % [falhas, verificacoes])
	quit(1 if falhas > 0 else 0)

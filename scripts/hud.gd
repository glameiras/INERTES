extends Node2D
## Interface em tela: barras, objetivo, mensagens e telas de título/pausa/fim.
## Só lê o estado do Jogo; não altera nada.

const Cfg = preload("res://scripts/config.gd")
const Controles = preload("res://scripts/controles.gd")
const Desenho = preload("res://scripts/desenho.gd")

var jogo: Node

func _process(_dt: float) -> void:
	queue_redraw()

func _caixa(r: Rect2, cor: String) -> void:
	draw_rect(r, Color(cor))

func _t(p: Vector2, conteudo: String, tamanho: int = 16, cor: String = "d7e4e8") -> void:
	Desenho.texto(self, p, conteudo, tamanho, cor)

func _draw() -> void:
	if jogo == null or jogo.modo == "titulo":
		return
	var ctl: bool = jogo.usando_controle
	var j = jogo.jogador
	var k := func(acao: String) -> String: return Controles.rotulo(acao, ctl)
	var mover := "Analógico" if ctl else "WASD / setas"
	var barra := "%s  mover     %s  atacar     %s  esquivar     %s  fundir / sair     %s  pausar" % [
		mover, k.call("atacar"), k.call("esquivar"), k.call("interagir"), k.call("pausar")]

	_caixa(Rect2(0, 0, 960, 74), "0d1721")
	_t(Vector2(22, 26), "INERTES", 21, "e6c48b")
	_t(Vector2(22, 49), jogo.ciclo.rotulo(), 11, "839aa5")
	_t(Vector2(290, 23), "INTEGRIDADE", 11)
	_caixa(Rect2(290, 31, 180, 8), "293945")
	draw_rect(Rect2(290, 31, 180.0 * j.vida / Cfg.VIDA_MAX, 8), Color("ee8b7b"))
	_t(Vector2(290, 58), "FUSÃO ATIVA" if j.pilotando else ("SUCATEIRO" if jogo.escolha == 0 else "SUCATEIRA"), 12, "7be2bc")
	_t(Vector2(500, 23), "FÔLEGO / ESQUIVA", 11)
	_caixa(Rect2(500, 31, 140, 8), "293945")
	draw_rect(Rect2(500, 31, 140.0 * j.folego / Cfg.FOLEGO_MAX, 8), Color("78ced5"))
	_t(Vector2(680, 28), "DEPÓSITO / ONDA %d" % jogo.farm.ciclo if jogo.farm.ativa else ("RETORNE AO ABRIGO" if jogo.nucleo.pego else "RECUPERE O NÚCLEO"), 15, "e6c48b")
	_t(Vector2(680, 51), "[%s] interagir com máquina / núcleo" % k.call("interagir"), 12, "839aa5")
	_caixa(Rect2(0, 506, 960, 34), "0d1721")
	_t(Vector2(20, 528), barra, 14)
	_caixa(Rect2(12,77,790,26), "101c28")
	_t(Vector2(20, 96), "Ferragens %d   Kits %d [R]   Energia %d%%   Munição %d   [F] Depósito" % [jogo.farm.sucata, jogo.farm.kits, int(jogo.farm.energia), jogo.farm.municao], 13, "a4f4da")
	if jogo.tempo_mensagem > 0.0 and jogo.modo == "jogando":
		_caixa(Rect2(30, 456, 900, 38), "101c28")
		_t(Vector2(44, 480), jogo.mensagem, 15, "c9e5df")
	if jogo.modo != "jogando":
		_overlay(ctl, k, barra)

func _overlay(ctl: bool, k: Callable, barra: String) -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.025, 0.05, 0.08, 0.93))
	_t(Vector2(90, 100), "SUCATEIROS  /  ZONA 07", 14, "70cbbf")
	_t(Vector2(86, 165), "INERTES", 62, "e6c48b")
	_t(Vector2(90, 202), "CHUVA DE FERRO", 23, "9cb5c1")
	var titulo := "Uma consciência. Dois corpos. Uma chance de voltar."
	var sub := "Encontre o Inerte azul, derrote o Cérbero e leve o núcleo ao abrigo."
	var acao := "%s  •  INICIAR MISSÃO" % k.call("confirmar")
	match jogo.modo:
		"pausa":
			titulo = "CONEXÃO EM ESPERA"
			sub = "A missão está pausada."
			acao = "%s  •  CONTINUAR" % k.call("pausar")
		"derrota":
			titulo = "SINAL PERDIDO"
			sub = "Esquive das áreas vermelhas. O Inerte reduz o dano recebido."
			acao = "%s  •  TENTAR NOVAMENTE" % k.call("confirmar")
		"vitoria":
			titulo = "NÚCLEO RECUPERADO"
			sub = "O abrigo terá energia por mais uma noite. Fim do protótipo."
			acao = "%s  •  JOGAR NOVAMENTE" % k.call("confirmar")
	_t(Vector2(90, 275), titulo, 24, "dce9eb")
	_t(Vector2(90, 315), sub, 17, "a4b7c3")
	_caixa(Rect2(90, 356, 440, 54), "254c50")
	_t(Vector2(110, 391), acao, 20, "a4f4da")
	_t(Vector2(90, 467), barra, 15, "9cb5c1")
	_t(Vector2(90, 495), "Versão de estudo • Arte provisória • Universo de Gustavo Lameiras", 12, "627e8e")

extends Node2D
## Controlador da missão: estados (título/jogando/pausa/derrota/vitória), entrada,
## combate entre as partes e objetivo. As regras de cada peça ficam nos próprios scripts.

const Cfg = preload("res://scripts/config.gd")
const Controles = preload("res://scripts/controles.gd")
const Mundo = preload("res://scripts/mundo.gd")
const Jogador = preload("res://scripts/jogador.gd")
const Nucleo = preload("res://scripts/nucleo.gd")
const Inerte = preload("res://scripts/inerte.gd")
const Efeitos = preload("res://scripts/efeitos.gd")
const Hud = preload("res://scripts/hud.gd")
const CenaInimigo = preload("res://cenas/inimigo.tscn")

@onready var mundo: Mundo = $Mundo
@onready var nucleo: Nucleo = $Nucleo
@onready var inerte: Inerte = $Inerte
@onready var inimigos_no: Node2D = $Inimigos
@onready var jogador: Jogador = $Jogador
@onready var efeitos: Efeitos = $Efeitos
@onready var camera: Camera2D = $Camera
@onready var hud: Hud = $Interface/Hud

var ciclo: Node
var farm: Node2D
var escolha := 0
var dupla: Node2D
var selecao: CanvasLayer

var modo := "titulo" # titulo | jogando | pausa | derrota | vitoria
var usando_controle := false
var mensagem := ""
var tempo_mensagem := 0.0
var inimigos: Array = []

func _ready() -> void:
	ciclo = preload("res://scripts/ciclo.gd").new()
	add_child(ciclo)
	Controles.registrar()
	hud.jogo = self
	jogador.mundo = mundo
	jogador.atacou.connect(_ao_atacar)
	jogador.esquivou.connect(_ao_esquivar)
	jogador.sofreu_dano.connect(_ao_sofrer_dano)
	dupla = preload("res://scripts/dupla.gd").new()
	dupla.name = "Dupla"
	add_child(dupla)
	selecao = preload("res://scripts/selecao.gd").new()
	add_child(selecao)
	selecao.escolheu.connect(_escolher)
	farm = preload("res://scripts/farm.gd").new()
	farm.jogo = self
	farm.z_index = 1
	add_child(farm)
	var fundo_farm := Sprite2D.new()
	fundo_farm.name = "FarmCenario"
	fundo_farm.texture = load("res://assetscenarios/deposito.png")
	fundo_farm.centered = false
	fundo_farm.scale = Vector2(1600.0/fundo_farm.texture.get_width(), 960.0/fundo_farm.texture.get_height())
	fundo_farm.z_index = -10
	fundo_farm.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fundo_farm.hide()
	add_child(fundo_farm)
	# Recorte da própria textura: camada frontal alinhada sem reconstruir a imagem.
	var frente := Sprite2D.new()
	frente.name = "FarmFrente"
	frente.texture = fundo_farm.texture
	frente.centered = false
	frente.region_enabled = true
	var h: float = frente.texture.get_height()
	frente.region_rect = Rect2(0,h*0.75,frente.texture.get_width(),h*0.25)
	frente.scale = fundo_farm.scale
	frente.position = Vector2(0,720)
	frente.z_index = 900
	frente.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	frente.hide()
	add_child(frente)
	var ambiente := preload("res://scripts/ambiente.gd").new()
	ambiente.jogo = self
	add_child(ambiente)
	reiniciar()
	modo = "titulo"

func reiniciar() -> void:
	if farm != null:
		farm.reiniciar()
	ciclo.hora = 17.5
	jogador.personagem = escolha
	jogador.reiniciar()
	if dupla != null:
		dupla.reiniciar(jogador.position, escolha)
	inerte.position = Cfg.INERTE_INICIAL
	inerte.visible = true
	nucleo.pego = false
	efeitos.limpar()
	for filho in inimigos_no.get_children():
		inimigos_no.remove_child(filho)
		filho.queue_free()
	inimigos.clear()
	for pos in [Vector2(620, 450), Vector2(710, 530), Vector2(1000, 400), Vector2(1070, 560)]:
		_criar_inimigo(pos, false)
	_criar_inimigo(Vector2(1370, 480), true)
	modo = "jogando"
	dizer("Recupere o núcleo. O Inerte com aro azul pode ajudar: aproxime-se e pressione %s." % Controles.rotulo("interagir", usando_controle), 7.0)

func _criar_inimigo(pos: Vector2, chefe: bool) -> void:
	var e = CenaInimigo.instantiate()
	inimigos_no.add_child(e)
	e.tipo_visual = inimigos.size() % 2
	e.configurar(pos, chefe, mundo)
	e.atacou.connect(_ao_golpe_inimigo)
	inimigos.append(e)

func dizer(texto: String, segundos: float = 5.0) -> void:
	mensagem = texto
	tempo_mensagem = segundos

# --- Entrada ---

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		usando_controle = true
	elif event is InputEventJoypadMotion:
		if absf((event as InputEventJoypadMotion).axis_value) > 0.5:
			usando_controle = true
	elif event is InputEventKey:
		usando_controle = false
	if modo == "titulo":
		return
	if event.is_action_pressed("confirmar") and modo in ["derrota", "vitoria"]:
		modo = "titulo"
		selecao.abrir()
	elif event.is_action_pressed("pausar") and modo in ["jogando", "pausa"]:
		modo = "pausa" if modo == "jogando" else "jogando"
	elif modo == "jogando":
		if event is InputEventKey and event.pressed and not event.echo:
			if event.physical_keycode == KEY_F:
				var portal: Vector2 = farm.saida if farm.ativa else Cfg.SPAWN + Vector2(80,0)
				if jogador.position.distance_to(portal) < 95:
					farm.trocar()
				return
			if event.physical_keycode == KEY_R:
				farm.curar()
				return
		if event.is_action_pressed("atacar"):
			jogador.pedir_ataque()
		elif event.is_action_pressed("esquivar"):
			jogador.tentar_esquiva()
		elif event.is_action_pressed("interagir"):
			interagir()

# --- Laço do jogo ---

func _process(dt: float) -> void:
	dt = minf(dt, 0.04)
	if modo == "jogando":
		tick(dt)
	camera.position = jogador.position

func tick(dt: float) -> void:
	ciclo.atualizar(dt)
	tempo_mensagem = maxf(0.0, tempo_mensagem - dt)
	var direcao := Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")
	jogador.atualizar(dt, direcao)
	jogador.z_index = int(jogador.position.y)
	dupla.atualizar(dt, jogador.position)
	dupla.combater(dt, self)
	farm.atualizar(dt)
	if jogador.pilotando:
		inerte.position = jogador.position
		inerte.dica = ""
	elif jogador.position.distance_to(inerte.position) < 60.0:
		inerte.dica = "[%s] FUNDIR" % Controles.rotulo("interagir", usando_controle)
	else:
		inerte.dica = ""
	for e in inimigos:
		e.noturno = ciclo.noite()
		e.atualizar(dt, jogador.position)
		e.z_index = int(e.position.y)
	_separar_inimigos()
	if jogador.vida <= 0.0:
		modo = "derrota"
	elif not farm.ativa and nucleo.pego and jogador.position.distance_to(Cfg.SPAWN) < Cfg.RAIO_ABRIGO:
		modo = "vitoria"

## Evita que os inimigos fiquem empilhados no mesmo ponto.
func _separar_inimigos() -> void:
	for i in inimigos.size():
		var a = inimigos[i]
		if not a.vivo():
			continue
		for j in range(i + 1, inimigos.size()):
			var b = inimigos[j]
			if not b.vivo():
				continue
			var delta: Vector2 = b.position - a.position
			var distancia := delta.length()
			var minimo: float = a.raio() + b.raio()
			if distancia < minimo and distancia > 0.01:
				var empurrao := delta / distancia * (minimo - distancia) * 0.5
				a.position = mundo.mover(a.position, -empurrao, a.raio())
				b.position = mundo.mover(b.position, empurrao, b.raio())

# --- Interação e fusão ---

func chefe_vivo() -> bool:
	for e in inimigos:
		if e.chefe and e.vivo():
			return true
	return false

func interagir() -> void:
	if farm.interagir():
		return
	if jogador.position.distance_to(Cfg.NUCLEO) < Cfg.DISTANCIA_INTERACAO and not nucleo.pego:
		if chefe_vivo():
			dizer("O Cérbero protege o núcleo. Derrote-o primeiro.")
		else:
			nucleo.pego = true
			dizer("Núcleo recuperado! Volte ao abrigo à esquerda.")
			efeitos.som(740, 0.2)
		return
	if jogador.pilotando:
		jogador.pilotando = false
		inerte.position = jogador.position
		inerte.visible = true
		dizer("Consciência desacoplada.")
	elif jogador.position.distance_to(inerte.position) < Cfg.DISTANCIA_INTERACAO:
		if farm.energia <= 0:
			dizer("Recolha energia no depósito antes de fundir.")
			return
		jogador.pilotando = true
		jogador.position = mundo.resolver(jogador.position, Cfg.RAIO_FUSAO)
		inerte.visible = false
		dizer("Fusão estabelecida. Alcance, dano e proteção aumentados.")
		efeitos.som(180, 0.25)

# --- Reações a eventos (sinais) ---

func _ao_atacar(origem: Vector2, olhar: Vector2, alcance: float, dano: float) -> void:
	efeitos.som(120 if jogador.pilotando else 270, 0.055)
	for e in inimigos:
		if not e.vivo():
			continue
		var delta: Vector2 = e.position - origem
		var distancia := delta.length()
		if distancia < alcance and (distancia < 20.0 or olhar.dot(delta / distancia) > 0.25):
			var morreu: bool = e.receber_dano(dano, delta.normalized())
			efeitos.rajada(e.position, Color("ffc77b"))
			if morreu:
				jogador.folego = minf(Cfg.FOLEGO_MAX, jogador.folego + Cfg.FOLEGO_POR_ABATE)
				if e.chefe:
					dizer("Cérbero desativado. Aproxime-se do núcleo e pressione %s." % Controles.rotulo("interagir", usando_controle))

func _ao_golpe_inimigo(posicao: Vector2, raio: float, dano: float) -> void:
	if jogador.position.distance_to(posicao) < raio:
		jogador.receber_dano(dano)
	efeitos.rajada(posicao, Color("ff6669"))

func _ao_esquivar() -> void:
	efeitos.som(440, 0.06)

func _ao_sofrer_dano() -> void:
	efeitos.rajada(jogador.position, Color("ff6669"))
	efeitos.som(65, 0.12)

func _escolher(indice: int) -> void:
	escolha = indice
	selecao.hide()
	reiniciar()
	dizer("Sua dupla acompanha você. Recupere o núcleo e retornem ao abrigo.", 6.0)

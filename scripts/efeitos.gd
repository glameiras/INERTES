extends Node2D
## Partículas e efeitos sonoros sintetizados (sem assets externos).
## Os sons são gerados uma vez, guardados em cache e tocados por um conjunto de players.

var particulas: Array[Dictionary] = []
var _players: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}
var _proximo := 0

func _ready() -> void:
	for i in 6:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func limpar() -> void:
	particulas.clear()

func rajada(posicao: Vector2, cor: Color) -> void:
	for i in 10:
		particulas.append({
			"pos": posicao,
			"vel": Vector2.from_angle(randf() * TAU) * randf_range(35.0, 100.0),
			"vida": 0.3,
			"cor": cor,
		})

func som(frequencia: float, segundos: float) -> void:
	if _players.is_empty():
		return
	var chave := "%d_%d" % [int(frequencia), int(segundos * 1000.0)]
	if not _cache.has(chave):
		_cache[chave] = _gerar(frequencia, segundos)
	var player := _players[_proximo]
	_proximo = (_proximo + 1) % _players.size()
	player.stream = _cache[chave]
	player.play()

func _gerar(frequencia: float, segundos: float) -> AudioStreamWAV:
	var onda := AudioStreamWAV.new()
	onda.format = AudioStreamWAV.FORMAT_8_BITS
	onda.mix_rate = 22050
	var bytes := PackedByteArray()
	var total := int(segundos * 22050.0)
	bytes.resize(total)
	for i in total:
		var quadrada := 1.0 if sin(float(i) * frequencia * TAU / 22050.0) > 0.0 else -1.0
		bytes[i] = int(quadrada * 24.0 * (1.0 - float(i) / total)) & 255
	onda.data = bytes
	return onda

func _process(dt: float) -> void:
	var i := particulas.size() - 1
	while i >= 0:
		var p: Dictionary = particulas[i]
		p["vida"] -= dt
		p["pos"] += p["vel"] * dt
		if p["vida"] <= 0.0:
			particulas.remove_at(i)
		i -= 1
	queue_redraw()

func _draw() -> void:
	for p in particulas:
		draw_rect(Rect2(p["pos"], Vector2(3, 3)), p["cor"])

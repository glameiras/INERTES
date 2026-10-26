extends CanvasLayer
signal escolheu(indice: int)
const Artes = preload("res://scripts/artes_personagens.gd")
var botoes: Array[Button] = []
func _ready() -> void:
	layer = 20
	var fundo := ColorRect.new()
	fundo.color = Color("0d1721")
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	var coluna := VBoxContainer.new()
	coluna.position = Vector2(70, 22)
	coluna.size = Vector2(820, 495)
	coluna.add_theme_constant_override("separation", 10)
	fundo.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "INERTES  /  ESCOLHA SEU PERSONAGEM"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 25)
	coluna.add_child(titulo)
	var sub := Label.new()
	sub.text = "Você controla um. O outro acompanha você na missão."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(sub)
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 28)
	coluna.add_child(linha)
	for i in 2:
		var card := VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha.add_child(card)
		var arte := TextureRect.new()
		arte.texture = Artes.IMAGENS[i]
		arte.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		arte.custom_minimum_size = Vector2(0, 335)
		card.add_child(arte)
		var botao := Button.new()
		botao.text = "Jogar como " + Artes.NOMES[i]
		botao.custom_minimum_size.y = 44
		botao.pressed.connect(func(): escolheu.emit(i))
		card.add_child(botao)
		botoes.append(botao)
	var dica := Label.new()
	dica.text = "Clique para começar • Tab / setas e Enter também funcionam"
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(dica)
	botoes[0].focus_neighbor_right = botoes[1].get_path()
	botoes[1].focus_neighbor_left = botoes[0].get_path()
	botoes[0].grab_focus()
func abrir() -> void:
	show()
	botoes[0].grab_focus()

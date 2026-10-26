extends RefCounted
## Ações de entrada (teclado + controle) registradas no InputMap.
## Como são ações normais do InputMap, dá para remapear depois (menu de opções).

const ROTULOS_TECLADO := {
	"atacar": "J", "esquivar": "ESPAÇO", "interagir": "E", "pausar": "ESC", "confirmar": "ENTER",
}
const ROTULOS_CONTROLE := {
	"atacar": "X", "esquivar": "A", "interagir": "Y", "pausar": "START", "confirmar": "A",
}

static func registrar() -> void:
	_acao("mover_esquerda", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_acao("mover_direita", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_acao("mover_cima", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_acao("mover_baixo", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_acao("atacar", [KEY_J], [JOY_BUTTON_X])
	_acao("esquivar", [KEY_SPACE], [JOY_BUTTON_A])
	_acao("interagir", [KEY_E], [JOY_BUTTON_Y])
	_acao("pausar", [KEY_ESCAPE], [JOY_BUTTON_START])
	_acao("confirmar", [KEY_ENTER, KEY_KP_ENTER], [JOY_BUTTON_A])

static func rotulo(acao: String, controle: bool) -> String:
	return str((ROTULOS_CONTROLE if controle else ROTULOS_TECLADO)[acao])

static func _acao(nome: StringName, teclas: Array, botoes: Array = [], eixos: Array = []) -> void:
	if InputMap.has_action(nome):
		return
	InputMap.add_action(nome, 0.3)
	for tecla in teclas:
		var ev_tecla := InputEventKey.new()
		ev_tecla.physical_keycode = tecla
		InputMap.action_add_event(nome, ev_tecla)
	for botao in botoes:
		var ev_botao := InputEventJoypadButton.new()
		ev_botao.button_index = botao
		InputMap.action_add_event(nome, ev_botao)
	for eixo in eixos:
		var ev_eixo := InputEventJoypadMotion.new()
		ev_eixo.axis = eixo[0]
		ev_eixo.axis_value = eixo[1]
		InputMap.action_add_event(nome, ev_eixo)

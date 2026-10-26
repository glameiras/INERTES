extends Node
var hora := 17.5
func atualizar(dt: float) -> void:
	hora = fmod(hora + dt / 120.0, 24.0)
func noite() -> bool:
	return hora >= 18.5 or hora < 6.0
func escuridao() -> float:
	if hora >= 17.5 and hora < 18.5: return hora - 17.5
	if hora >= 5.0 and hora < 6.0: return 6.0-hora
	return 1.0 if noite() else 0.0
func rotulo() -> String:
	var minutos := int(hora * 60) % 1440
	return "%02d:%02d  %s" % [minutos/60, minutos%60, "NOITE / VISÃO NOTURNA" if noite() else ("ANOITECENDO" if hora >= 17.5 else "DIA")]

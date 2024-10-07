extends Node


###----------CUSTOM SIGNALS----------###

signal ability_used


###----------PROPERTIES----------###

var is_active:bool = false


###----------METHODS----------###

func use_ability() -> void:
	ability_used.emit()


###----------CONNECTED SIGNALS----------###

func _on_toggle_active(active:bool) -> void:
	is_active = active

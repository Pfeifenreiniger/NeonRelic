extends Node


###----------PROPERTIES----------###

var is_active:bool = false


###----------CONNECTED SIGNALS----------###

func _on_toggle_active(active:bool) -> void:
	is_active = active

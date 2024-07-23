extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	print(($Timer as Timer).is_stopped())
	print(($Timer as Timer).time_left)

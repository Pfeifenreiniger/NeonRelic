extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var array = [
		["Erstes 1", "Zweites 1"],
		["Erstes 2", "Zweites 2"],
		["Erstes 3", "Zweites 3"],
	]
	
	for elem in array:
		print(elem[0])
		print(elem[1])

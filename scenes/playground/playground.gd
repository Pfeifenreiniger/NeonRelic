extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var array1 = []
	var array2 = [4, 5, 6]
	
	array1.append_array(array2)
	print(array1)

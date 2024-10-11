extends Node2D

func _ready() -> void:
	var irgendwas:Variant
	
	for elem in ["Hallo", "Du", 111, true, 1.2]:
		irgendwas = elem
		print(irgendwas)

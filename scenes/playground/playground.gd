extends Node2D

var tolle_variable := 6

func _ready() -> void:
	
	match tolle_variable:
		1:
			print("Ist ne eins")
		2:
			print("Ist ne zwei")
		3:
			print("Ist ne drei")
		_:
			print("Ist was anderes")

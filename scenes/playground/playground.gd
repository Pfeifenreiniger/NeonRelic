extends Node2D


var tolle_variable:float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween:Tween = create_tween()
	
	print("Es geht los...")
	
	tween.tween_method(
		func(value): print(value), 0.0, 100.0, 3
	)
	
	await tween.finished
	
	print("Fertig :)")

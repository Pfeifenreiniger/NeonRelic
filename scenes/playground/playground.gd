extends Node2D

var direction:Vector2 = Vector2.ZERO
var direction_former_frame:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# simuliere direction-Aenderung vom Spieler z.B.
	direction.x = 1
	
	
	
	print("Direction im aktuellen Frame:")
	print(direction)
	
	print("Direction davor im Frame:")
	print(direction_former_frame)
	
	direction_former_frame = direction
	
	direction.y = 1

extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# wir erzeugen je 5 Nodes und fuegen sie mal als child-nodes an :)
	for i in 5:
		var tolle_node2d_node = Node2D.new()
		add_child(tolle_node2d_node)
		
		var tolle_sprite2d_node = Sprite2D.new()
		add_child(tolle_sprite2d_node)

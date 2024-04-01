extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var line_start_pos:Vector2 = Vector2(100, 100)
	var line_end_pos:Vector2 = Vector2(500, 300)
	var line_color:Color = Color('B30E0E')
	var line_width:float = 2
	
	draw_line(line_start_pos, line_end_pos, line_color, line_width)

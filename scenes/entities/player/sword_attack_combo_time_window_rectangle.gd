extends Node2D


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------PROPERTIES----------###

var rect_to_draw:bool = false
var current_animation_frame:int = 0
var rect_colors:Dictionary = {
	"white" as String: Color('F9F9F9') as Color,
	"red" as String: Color('B30E0E') as Color
}
var current_rect_color:Color = rect_colors["white"]


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	queue_redraw()


###----------METHODS----------###

func _draw() -> void:
	
	if rect_to_draw:
		
		position = player.position + Vector2(0, 60)
		
		var rect_pos:Vector2 = Vector2.ZERO
		var rect_size:Vector2 = Vector2(150 - (current_animation_frame * 10), 150 - (current_animation_frame * 10))
		var rect:Rect2 = Rect2(rect_pos, rect_size)
		
		draw_set_transform(rect_pos, 3.12)
		draw_rect(rect, current_rect_color, false, 1.4)


func draw_time_window_rect(current_animation_frame:int) -> void:
	self.current_animation_frame = current_animation_frame


func reset_rect_color() -> void:
	current_rect_color = rect_colors["white"]

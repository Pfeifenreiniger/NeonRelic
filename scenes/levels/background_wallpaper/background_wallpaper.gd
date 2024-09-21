@tool
extends Sprite2D


###----------PROPERTIES----------###

@export_file("*.png") var image_file:String
@export var player:Player

# position smoothing
const X_AXIS_OFFSET:int = 160
const Y_AXIS_OFFSET:int = 90
var tween_position_smoothing_x_axis:Tween
var tween_position_smoothing_y_axis:Tween


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	if image_file != null:
		var loaded_texture:Resource = load(image_file)
		self.texture = loaded_texture


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	_let_follow_players_position_with_position_smoothing(delta)


###----------METHODS: POSITIONING----------###

func _let_follow_players_position_with_position_smoothing(delta:float) -> void:
	
	if player == null:
		return
	
	# nur ausfuehren, wenn tatsaechlich im Spiel und nicht im Editor (da tool)
	if !Engine.is_editor_hint():
		
		# x-axis
		if player.velocity.x > 0:
			# player moves to the right side
			if offset.x != (0 - X_AXIS_OFFSET - (X_AXIS_OFFSET / 2)):
				if tween_position_smoothing_x_axis != null:
					tween_position_smoothing_x_axis.kill()
				tween_position_smoothing_x_axis = create_tween()
				
				tween_position_smoothing_x_axis.tween_property(
					$".", "offset:x", 0 - X_AXIS_OFFSET - (X_AXIS_OFFSET / 2), 1.2
				)\
				.set_ease(Tween.EASE_IN)
			
		elif player.velocity.x < 0:
			# player moves to the left side
			if offset.x != -(X_AXIS_OFFSET / 2):
				if tween_position_smoothing_x_axis != null:
					tween_position_smoothing_x_axis.kill()
				tween_position_smoothing_x_axis = create_tween()
				
				tween_position_smoothing_x_axis.tween_property(
					$".", "offset:x", -(X_AXIS_OFFSET / 2), 1.2
				)\
				.set_ease(Tween.EASE_IN)
			
		else:
			# player doesn't move to either right or left
			if offset.x != -X_AXIS_OFFSET:
				if tween_position_smoothing_x_axis != null:
					tween_position_smoothing_x_axis.kill()
				tween_position_smoothing_x_axis = create_tween()
				
				tween_position_smoothing_x_axis.tween_property(
					$".", "offset:x", -X_AXIS_OFFSET, .6
				)\
				.set_ease(Tween.EASE_IN)

		# y-axis
		if player.velocity.y < 0:
			# player moves upwards (jumping)
			if offset.y != -(Y_AXIS_OFFSET / 2):
				if tween_position_smoothing_y_axis != null:
					tween_position_smoothing_y_axis.kill()
				tween_position_smoothing_y_axis = create_tween()
				
				tween_position_smoothing_y_axis.tween_property(
					$".", "offset:y", -(Y_AXIS_OFFSET / 2), .8
				)\
				.set_ease(Tween.EASE_IN)
		
		elif player.velocity.y > 0:
			# player moves downwards (falling)
			if offset.y != (0 - Y_AXIS_OFFSET - (Y_AXIS_OFFSET / 2)):
				if tween_position_smoothing_y_axis != null:
					tween_position_smoothing_y_axis.kill()
				tween_position_smoothing_y_axis = create_tween()
				
				tween_position_smoothing_y_axis.tween_property(
					$".", "offset:y", (0 - Y_AXIS_OFFSET - (Y_AXIS_OFFSET / 2)), .8
				)\
				.set_ease(Tween.EASE_IN)
		
		elif player.movement_handler.check_if_player_is_ducking():
			# player is going to duck
			if offset.y != (0 - Y_AXIS_OFFSET - (Y_AXIS_OFFSET / 4)):
				if tween_position_smoothing_y_axis != null:
					tween_position_smoothing_y_axis.kill()
				tween_position_smoothing_y_axis = create_tween()
				
				tween_position_smoothing_y_axis.tween_property(
					$".", "offset:y", (0 - Y_AXIS_OFFSET - (Y_AXIS_OFFSET / 4)), .3
				)\
				.set_ease(Tween.EASE_IN)
		
		else:
			# player's normal y-position
			if offset.y != -Y_AXIS_OFFSET:
				if tween_position_smoothing_y_axis != null:
					tween_position_smoothing_y_axis.kill()
				tween_position_smoothing_y_axis = create_tween()
				
				tween_position_smoothing_y_axis.tween_property(
					$".", "offset:y", -Y_AXIS_OFFSET, .6
				)\
				.set_ease(Tween.EASE_IN)


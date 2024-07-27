extends Camera2D
class_name IngameCamera

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group("player") as Player


###----------PROPERTIES----------###

var target_position = Vector2.ZERO
const BASE_CAMERA_Y_POS_PADDING:int = 200
var current_camera_y_pos_padding:int

# tweens
var tween_camera_y_axis_descending:Tween
var tween_camera_zoom:Tween


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	current_camera_y_pos_padding = BASE_CAMERA_Y_POS_PADDING

	# set this camera as the current game camera when instantiated
	make_current()


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	# get current frame's target position for game camera.
	acquire_target()
	# set global_position to target_position with an addition of a slight delay.
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))


###----------METHODS: CALCULATE CAMERA POSITION----------###

func acquire_target() -> void:
	## Calculate target position of camera for current frame
	
	target_position = player.global_position - Vector2(0, current_camera_y_pos_padding)


###----------METHODS: ALTER CAMERA Y-AXIS POSITION----------###

func do_desc_y_camera_axis() -> void:
	## lower camera y axis position
	
	if tween_camera_y_axis_descending != null:
		tween_camera_y_axis_descending.kill()
	tween_camera_y_axis_descending = get_tree().create_tween()
	
	tween_camera_y_axis_descending.tween_property($".", "current_camera_y_pos_padding", 40, 1)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_SINE)


func do_asc_y_camera_axis() -> void:
	## araise camera y axis position
	
	if tween_camera_y_axis_descending != null:
		tween_camera_y_axis_descending.kill()
	tween_camera_y_axis_descending = get_tree().create_tween()
	
	tween_camera_y_axis_descending.tween_property($".", "current_camera_y_pos_padding", 200, .5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_SINE)


###----------METHODS: ALTER CAMERA ZOOM FACTOR----------###

func do_zoom_in(zoom_in_factor:Vector2 = Vector2(1.2, 1.2)) -> void:
	if tween_camera_zoom != null:
		tween_camera_zoom.kill()
	tween_camera_zoom = get_tree().create_tween()
	
	tween_camera_zoom.tween_property($".", "zoom", zoom_in_factor, 1.2)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_SINE)


func do_zoom_out() -> void:
	if tween_camera_zoom != null:
		tween_camera_zoom.kill()
	tween_camera_zoom = get_tree().create_tween()
	
	tween_camera_zoom.tween_property($".", "zoom", Vector2(1, 1), .6)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_SINE)

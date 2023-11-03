extends Camera2D

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")

var target_position = Vector2.ZERO
const BASE_CAMERA_Y_POS_PADDING:int = 200
const MAX_CAMERA_Y_POS_PADDING:int = 140
const CAMERA_Y_POS_PADDING_INCREMENT_STEP:int = 2
var current_camera_y_pos_padding:int = BASE_CAMERA_Y_POS_PADDING
var desc_camera_y_axis:bool = false
var asc_camera_y_axis:bool = false


func _ready():
	# set this camera as the current game camera when instantiated
	make_current()


func _process(delta):
	# check if game camera y axis position has to be modified for current frame.
	do_desc_y_camera_axis()
	do_asc_y_camera_axis()
	# get current frame's target position for game camera.
	acquire_target()
	# set global_position to target_position with an addition of a slight delay.
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))


func acquire_target():
	"""
	Calculate target position of camera for current frame.
	Position is based on player's position with y-axis padding.
	"""
	target_position = player.global_position - Vector2(0, current_camera_y_pos_padding)


func do_desc_y_camera_axis():
	"""
	lower camera y axis position by the amoung of padding increment step
	"""
	if desc_camera_y_axis and current_camera_y_pos_padding > MAX_CAMERA_Y_POS_PADDING:
		current_camera_y_pos_padding -= CAMERA_Y_POS_PADDING_INCREMENT_STEP

func do_asc_y_camera_axis():
	"""
	raise camera y axis position by the amoung of padding increment step
	"""
	if asc_camera_y_axis and current_camera_y_pos_padding < BASE_CAMERA_Y_POS_PADDING:
		current_camera_y_pos_padding += CAMERA_Y_POS_PADDING_INCREMENT_STEP

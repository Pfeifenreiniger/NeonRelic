extends Camera2D


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D


###----------PROPERTIES----------###

var target_position = Vector2.ZERO
const BASE_CAMERA_Y_POS_PADDING:int = 200
const MAX_CAMERA_Y_POS_PADDING:int = 140
const CAMERA_Y_POS_PADDING_INCREMENT_STEP:int = 2
var current_camera_y_pos_padding:int = BASE_CAMERA_Y_POS_PADDING
var desc_camera_y_axis:bool = false
var asc_camera_y_axis:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set this camera as the current game camera when instantiated
	self.make_current()

###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	# check if game camera y axis position has to be modified for current frame.
	self.do_desc_y_camera_axis()
	self.do_asc_y_camera_axis()
	# get current frame's target position for game camera.
	self.acquire_target()
	# set global_position to target_position with an addition of a slight delay.
	self.global_position = self.global_position.lerp(self.target_position, 1.0 - exp(-delta * 20))


###----------METHODS: CALCULATE CAMERA POSITION----------###

func acquire_target() -> void:
	"""
	Calculate target position of camera for current frame.
	Position is based on player's position with y-axis padding.
	"""
	self.target_position = self.player.global_position - Vector2(0, self.current_camera_y_pos_padding)


func do_desc_y_camera_axis() -> void:
	"""
	lower camera y axis position by the amoung of padding increment step
	"""
	if self.desc_camera_y_axis and self.current_camera_y_pos_padding > self.MAX_CAMERA_Y_POS_PADDING:
		self.current_camera_y_pos_padding -= self.CAMERA_Y_POS_PADDING_INCREMENT_STEP


func do_asc_y_camera_axis() -> void:
	"""
	raise camera y axis position by the amoung of padding increment step
	"""
	if self.asc_camera_y_axis and self.current_camera_y_pos_padding < self.BASE_CAMERA_Y_POS_PADDING:
		self.current_camera_y_pos_padding += self.CAMERA_Y_POS_PADDING_INCREMENT_STEP

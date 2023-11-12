extends CharacterBody2D


###------MOVEMENT RELATED PROPERTIES------###
@onready var controls_handler:Node = $PlayerControlsHandler

var direction:Vector2 = Vector2.ZERO

const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED

const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int = BASE_JUMP_VELOCITY
const LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER:float = 0.3

var BASE_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = BASE_GRAVITY

#---player y-movement properties---#
var to_duck:bool = false
var is_duck:bool = false
var will_duck:bool = false
var is_jumping:bool = false
var is_falling:bool = false


###------ANIMATION RELATED PROPERTIES------###
@onready var animations:AnimatedSprite2D = $Animations
@onready var animations_handler:Node = $PlayerAnimationsHandler
var current_animation:String
var animation_to_change:bool = false
var start_run_animation:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true


###------HITBOX RELATED PROPERTIES------###
@onready var hit_box:CollisionShape2D = $HitBox
var hit_box_height_full:float = 76
var hit_box_height_reduced:float = 58
var hit_box_y_full:float = 4
var hit_box_y_reduced:float = 12


###------OTHER PROPERTIES------###
@onready var ledge_climb_area:Area2D = $LedgeClimbArea
var current_ledge_to_climb_area:Area2D = null
var is_climbing_ledge:bool = false

func _ready():
	# set up animations
	animations.animation_finished.connect(animations_handler.on_animation_finished)
	current_animation = "run_right"
	loop_animation = true
	
	# set up ledge climbing
	ledge_climb_area.area_entered.connect(on_ledge_area_entered)
	ledge_climb_area.area_exited.connect(on_ledge_area_exited)
	


func _process(_delta):
	# check if player released ducking key
	controls_handler.check_player_duck_key_input_status()
	# select current animation
	if animation_to_change:
		animations_handler.select_animation()


func _physics_process(delta):
	# move player
	controls_handler.move(delta)


func resize_hit_box(to_full:bool=false, reduce:bool=false):
	if to_full:
		hit_box.position.y = hit_box_y_full
		hit_box.shape.set_height(hit_box_height_full)
	elif reduce:
		hit_box.position.y = hit_box_y_reduced
		hit_box.shape.set_height(hit_box_height_reduced)


func on_ledge_area_entered(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = area


func on_ledge_area_exited(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = null

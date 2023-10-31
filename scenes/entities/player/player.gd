extends CharacterBody2D


###------MOVEMENT RELATED PROPERTIES------###
@onready var controls_handler:Node = $PlayerControlsHandler

var direction:Vector2 = Vector2.ZERO

const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED

const BASE_JUMP_VELOCITY:int = -350
var current_jump_velocity:int = BASE_JUMP_VELOCITY

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
var loop_animation:bool = false
var animation_frames_forwards:bool = true


###------HITBOX RELATED PROPERTIES------###
@onready var hit_box:CollisionShape2D = $HitBox
var hit_box_height_full:float = 76
var hit_box_height_reduced:float = 58
var hit_box_y_full:float = 4
var hit_box_y_reduced:float = 12


func _ready():
	animations.animation_finished.connect(animations_handler.on_animation_finished)
	current_animation = "run_right"
	loop_animation = true


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

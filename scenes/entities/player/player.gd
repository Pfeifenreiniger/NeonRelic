extends CharacterBody2D

###------BASIC STATS PROPERTIES------###
## HEALTH ##
var max_health:int = 100
var current_health:int = max_health

## STAMINA ##
var max_stamina:int = 100
var current_stamina:float = max_stamina
var stamina_can_refresh:bool = true
var stamina_refreshment_rate:float = 0.1
var side_roll_stamina_cost:int = 20


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

# player movement properties
var to_duck:bool = false
var is_duck:bool = false
var will_duck:bool = false
var is_jumping:bool = false
var is_falling:bool = false
var is_attacking:bool = false
var is_rolling:bool = false

# ledge climbing properties
@onready var ledge_climb_area:Area2D = $LedgeClimbArea
var current_ledge_to_climb_area:Area2D = null
var is_climbing_ledge:bool = false


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

@onready var left_collision_detection_box:Area2D = $CollisionDetectionBoxes/LeftSideCollision
@onready var right_collision_detection_box: Area2D = $CollisionDetectionBoxes/RightSideCollision
var is_environment_collision_left:bool = false
var is_environment_collision_right:bool = false


###------ATTACKING RELATED PROPERTIES------###
@onready var weapon_handler:Node = $PlayerWeaponHandler
var can_whip_attack_charge:bool = true

@onready var weapon_whip_attack_right_pos:Marker2D = $Markers/WeaponWhipAttackRight
@onready var weapon_whip_attack_left_pos:Marker2D = $Markers/WeaponWhipAttackLeft


func _ready():
	# set up animations
	animations.animation_finished.connect(animations_handler.on_animation_finished)
	current_animation = "run_right"
	loop_animation = true
	
	# set up environment collision checking
	left_collision_detection_box.body_entered.connect(on_left_collision_detection_box_body_entered)
	left_collision_detection_box.body_exited.connect(on_left_collision_detection_box_body_exited)
	right_collision_detection_box.body_entered.connect(on_right_collision_detection_box_body_entered)
	right_collision_detection_box.body_exited.connect(on_right_collision_detection_box_body_exited)
	
	# set up ledge climbing
	ledge_climb_area.area_entered.connect(on_ledge_area_entered)
	ledge_climb_area.area_exited.connect(on_ledge_area_exited)
	

func _process(_delta):
	# check if player released ducking key
	controls_handler.check_player_duck_key_input_status()
	
	# select current animation
	if animation_to_change:
		animations_handler.select_animation()
	
	# refresh player's stamina
	refresh_player_stamina()


func _physics_process(delta):
	# check for player key inputs and move player
	controls_handler.check_ingame_control_key_inputs(delta)


func resize_hit_box(to_full:bool=false, reduce:bool=false):
	if to_full:
		hit_box.position.y = hit_box_y_full
		hit_box.shape.set_height(hit_box_height_full)
	elif reduce:
		hit_box.position.y = hit_box_y_reduced
		hit_box.shape.set_height(hit_box_height_reduced)


func refresh_player_stamina():
	if stamina_can_refresh:
		if current_stamina < max_stamina:
			if current_stamina + stamina_refreshment_rate <= max_stamina:
				current_stamina += stamina_refreshment_rate
			else:
				current_stamina = max_stamina



###----------CONNECTED SIGNALS----------###

func on_ledge_area_entered(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = area


func on_ledge_area_exited(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = null


func on_left_collision_detection_box_body_entered(body):
	is_environment_collision_left = true


func on_left_collision_detection_box_body_exited(body):
	is_environment_collision_left = false


func on_right_collision_detection_box_body_entered(body):
	is_environment_collision_right = true


func on_right_collision_detection_box_body_exited(body):
	is_environment_collision_right = false

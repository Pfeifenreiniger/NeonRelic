extends CharacterBody2D

###------BASIC STATS PROPERTIES------###
## HEALTH ##
@onready var health_handler:Node = $PlayerHealthHandler

var is_invulnerable:bool = false
@onready var invulnerable_handler:Node = $PlayerInvulnerableHandler

## STAMINA ##
@onready var stamina_handler:Node = $PlayerStaminaHandler


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

# ledge climbing handler
@onready var ledge_climb_handler:Node = $PlayerLedgeClimbHandler


###------ANIMATION RELATED PROPERTIES------###
@onready var animations:AnimatedSprite2D = $Animations
@onready var animations_handler:Node = $PlayerAnimationsHandler
var current_animation:String
var animation_to_change:bool = false
var start_run_animation:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true


###------HITBOX RELATED PROPERTIES------###
@onready var hitbox:CollisionShape2D = $HitBox
@onready var hitbox_handler:Node = $PlayerHitboxHandler

## side roll detection boxes ##
@onready var side_collision_boxes_handler:Node = $PlayerSideCollisionBoxesHandler


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


func _process(_delta):
	# check if player released ducking key
	controls_handler.check_player_duck_key_input_status()
	
	# select current animation
	if animation_to_change:
		animations_handler.select_animation()


func _physics_process(delta):
	# check for player key inputs and move player
	controls_handler.check_ingame_control_key_inputs(delta)


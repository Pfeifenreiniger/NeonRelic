extends Node
class_name BaseEnemyMovementHandler


###----------CUSTOM SIGNALS----------###

signal did_fall(pixels_on_y_axis:int)


###----------SCENE REFERENCES----------###

@onready var enemy_scene:CharacterBody2D = $'../' as CharacterBody2D


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# x-axis movement
@export_group('x-axis movement')
@export var BASE_SPEED:int = 100
var current_speed:int
@export var BASE_ACCELERATION_SMOOTHING:int = 900
var current_acceleration_smoothing:int
@export var BASE_DECELERATION_SMOOTHING:int = 1000
var current_deceleration_smoothing:int

# state if enemy is at platform border -> if yes and enemy is aggro, he will not go further to player as border
var is_at_platform_border:bool = false

var x_axis_recoil_tween:Tween

# jumping
@export_group('y-axis movement')
@export var base_jump_velocity:int = -275
var current_jump_velocity:int

# gravity
var BASE_GRAVITY:int = int(ProjectSettings.get_setting("physics/2d/default_gravity"))
var current_gravity:int
## Maximum velocity for y-axis the enemy can fall
@export var MAX_FALLING_VELOCITY:int = 700

# track falling height
var do_fall:bool = false
var y_axis_position_on_falling_start:int


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	current_speed = BASE_SPEED
	current_jump_velocity = base_jump_velocity
	current_gravity = BASE_GRAVITY
	current_acceleration_smoothing = BASE_ACCELERATION_SMOOTHING
	current_deceleration_smoothing = BASE_DECELERATION_SMOOTHING


###----------METHODS----------###

func apply_movement(delta:float) -> void:
	_do_patrol()
	_move_x(delta)
	_move_y(delta)
	_move()


func _move_x(delta:float) -> void:
	var target_x_distance:int
	if direction.x:
		target_x_distance = direction.x * current_speed
		enemy_scene.velocity.x = move_toward(
			enemy_scene.velocity.x,
			target_x_distance,
			current_acceleration_smoothing * delta
		)
	else:
		target_x_distance = 0
		enemy_scene.velocity.x = move_toward(
			enemy_scene.velocity.x,
			target_x_distance,
			current_deceleration_smoothing * delta
		)


func _move_y(delta:float) -> void:
	if !enemy_scene.is_on_floor():
		if !do_fall:
			y_axis_position_on_falling_start = int(enemy_scene.global_position.y)
			do_fall = true
		if x_axis_recoil_tween != null:
			x_axis_recoil_tween.stop()
			x_axis_recoil_tween = null
		enemy_scene.velocity.y += current_gravity * delta
		enemy_scene.velocity.y = min(MAX_FALLING_VELOCITY, enemy_scene.velocity.y) # never exceed max falling velocity speed
	else:
		enemy_scene.velocity.y = 0
		if do_fall:
			var y_axis_pixels_distance_fall:int = int(
				enemy_scene.global_position.y - y_axis_position_on_falling_start
			)
			did_fall.emit(y_axis_pixels_distance_fall)
			do_fall = false


func _move() -> void:
	enemy_scene.move_and_slide()


func _do_patrol() -> void:
	
	# do only patrol when not aggro
	if !enemy_scene.is_aggro:
		if enemy_scene.x_axis_direction == "left" && !direction.x == -1:
			direction.x = -1
		elif enemy_scene.x_axis_direction == "right" && !direction.x == 1:
			direction.x = 1
	
	# else - if is aggro but is not attacking - move to player
	elif enemy_scene.is_aggro && !enemy_scene.is_attacking:
		
		if enemy_scene.is_aggro && is_at_platform_border:
			direction.x = 0
		
		if enemy_scene.player != null && !is_at_platform_border:
			if enemy_scene.player.global_position.x < enemy_scene.global_position.x:
				direction.x = -1
				enemy_scene.x_axis_direction = 'left'
			else:
				direction.x = 1
				enemy_scene.x_axis_direction = 'right'
	
	# else if enemy is in attacking range of player -> stop moving on x-axis
	elif enemy_scene.is_aggro && enemy_scene.is_attacking:
		direction.x = 0


###----------METHODS: MOVEMENT EFFECTS (CAUSED BY OTHER SCENES)----------###

func recoil_on_x_axis(pixels:int) -> void:
	## Get pushed back by amount of pixels on x-axis
	
	if x_axis_recoil_tween != null:
		x_axis_recoil_tween.stop()
	x_axis_recoil_tween = get_tree().create_tween()
	var to_pos:Vector2 = Vector2(enemy_scene.global_position.x + pixels, enemy_scene.global_position.y)
	await x_axis_recoil_tween.tween_property(enemy_scene, "global_position", to_pos, 0.4)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CUBIC)\
	.finished
	x_axis_recoil_tween = null


func effect_get_slow_down(time:float) -> void:
	## Movement (and animation) speed of player get reduced by half for the amount
	## of time passed as argument.
	
	current_speed = int(round(BASE_SPEED / 2))
	current_acceleration_smoothing = int(round(BASE_ACCELERATION_SMOOTHING / 10)) # for slippery movement on floor
	current_deceleration_smoothing = int(round(BASE_DECELERATION_SMOOTHING / 10))
	enemy_scene.animations.speed_scale = 0.5
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", true)
	await get_tree().create_timer(time).timeout
	current_speed = BASE_SPEED
	current_acceleration_smoothing = BASE_ACCELERATION_SMOOTHING
	current_deceleration_smoothing = BASE_DECELERATION_SMOOTHING
	enemy_scene.animations.speed_scale = 1
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", false)

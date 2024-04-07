extends Node


###----------SCENE REFERENCES----------###

@onready var enemy_scene:CharacterBody2D = $'../' as CharacterBody2D


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# x-axis movement
var base_speed:int = 100
var current_speed:int = base_speed

var x_axis_recoil_tween:Tween

# jumping
const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int = BASE_JUMP_VELOCITY

# gravity
var BASE_GRAVITY:int = int(ProjectSettings.get_setting("physics/2d/default_gravity"))
var current_gravity:int = BASE_GRAVITY


###----------METHODS----------###

func apply_movement(delta:float) -> void:
	_do_patrol()
	_move_x()
	_move_y(delta)
	_move()


func _move_x() -> void:
	enemy_scene.velocity.x = direction.x * current_speed


func _move_y(delta:float) -> void:
	if not enemy_scene.is_on_floor():
		if x_axis_recoil_tween != null:
			x_axis_recoil_tween.stop()
			x_axis_recoil_tween = null
		enemy_scene.velocity.y += current_gravity * delta
	else:
		enemy_scene.velocity.y = 0


func _move() -> void:
	enemy_scene.move_and_slide()


func _do_patrol() -> void:
	# do only patrol when not aggro
	if not enemy_scene.is_aggro:
		if enemy_scene.x_axis_direction == "left" and not direction.x == -1:
			direction.x = -1
		elif enemy_scene.x_axis_direction == "right" and not direction.x == 1:
			direction.x = 1
	
	# else - if is aggro but is not attacking - move to player
	elif enemy_scene.is_aggro and not enemy_scene.is_attacking:
		if enemy_scene.player != null and not enemy_scene.is_at_platform_border:
			if enemy_scene.player.global_position.x < enemy_scene.global_position.x:
				direction.x = -1
			else:
				direction.x = 1
	
	# else if enemy is in attacking range of player -> stop moving on x-axis
	elif enemy_scene.is_aggro and enemy_scene.is_attacking:
		direction.x = 0


###----------METHODS: MOVEMENT EFFECTS (CAUSED BY OTHER SCENES)----------###

func recoil_on_x_axis(pixels:int) -> void:
	"""
	Get pushed back by amount of pixels on x-axis
	"""
	if x_axis_recoil_tween != null:
		x_axis_recoil_tween.stop()
	x_axis_recoil_tween = get_tree().create_tween()
	var to_pos:Vector2 = Vector2(enemy_scene.global_position.x + pixels, enemy_scene.global_position.y)
	await x_axis_recoil_tween.tween_property(enemy_scene, "global_position", to_pos, 0.3).finished
	x_axis_recoil_tween = null


func effect_get_slow_down(time:float) -> void:
	"""
	Movement (and animation) speed of player get reduced by half for the amount
	of time passed as argument.
	"""
	current_speed = int(round(base_speed / 2))
	enemy_scene.animations.speed_scale = 0.5
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", true)
	await get_tree().create_timer(time).timeout
	current_speed = base_speed
	enemy_scene.animations.speed_scale = 1
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", false)

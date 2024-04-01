extends Node

# NEXT - Gegner bei Schaden auch zurueckstossen lassen (dafuer hier Methode verfassen), danach Gegner zum Player bewegen lassen

###----------SCENE REFERENCES----------###

@onready var enemy_scene:CharacterBody2D = $'../' as CharacterBody2D


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# x-axis movement speed
const BASE_SPEED:int = 100
var current_speed:int = BASE_SPEED

# jumping
const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int = BASE_JUMP_VELOCITY

# gravity
var BASE_GRAVITY:int = int(ProjectSettings.get_setting("physics/2d/default_gravity"))
var current_gravity:int = BASE_GRAVITY


###----------METHODS----------###

func apply_movement(delta:float) -> void:
	_move_x()
	_move_y(delta)
	_move()


func _move_x() -> void:
	enemy_scene.velocity.x = direction.x * current_speed


func _move_y(delta:float) -> void:
	if not enemy_scene.is_on_floor():
		enemy_scene.velocity.y += current_gravity * delta
	else:
		enemy_scene.velocity.y = 0


func _move() -> void:
	enemy_scene.move_and_slide()


###----------METHODS: MOVEMENT EFFECTS (CAUSED BY OTHER SCENES)----------###

func effect_get_slow_down(time:float) -> void:
	"""
	Movement (and animation) speed of player get reduced by half for the amount
	of time passed as argument.
	"""
	current_speed = int(round(BASE_SPEED / 2))
	enemy_scene.animations.speed_scale = 0.5
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", true)
	await get_tree().create_timer(time).timeout
	current_speed = BASE_SPEED
	enemy_scene.animations.speed_scale = 1
	enemy_scene.animations.material.set_shader_parameter("doFrozenSlowedDown", false)

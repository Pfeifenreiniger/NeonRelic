extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var invulnerable_timer:Timer = $InvulnerableTimer as Timer


###----------PROPERTIES----------###

var is_invulnerable:bool = false

var invulnerability_shader:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	invulnerable_timer.timeout.connect(on_invulnerable_timer_timeout)


###----------METHODS----------###

func become_invulnerable(timer_value:float, with_shader:bool) -> void:
	"""
	Player gets invulnerable to damage for a short time period (defined in argument for parameter timer_value).
	Invulnerability-shader-animation starts only with true-argument of with_shader.
	"""
	invulnerability_shader = with_shader
	is_invulnerable = true
	invulnerable_timer.wait_time = timer_value
	invulnerable_timer.start()
	if invulnerability_shader:
		player.animations_handler.animations.material.set_shader_parameter("doBlink", true)


###----------CONNECTED SIGNALS----------###

func on_invulnerable_timer_timeout() -> void:
	"""
	Time period of invulnerability is over -> player gets vulnerable again.
	"""
	is_invulnerable = false
	if invulnerability_shader:
		player.animations_handler.animations.material.set_shader_parameter("doBlink", false)
		invulnerability_shader = false

extends Node

var is_invulnerable:bool = false

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

@onready var invulnerable_timer:Timer = $InvulnerableTimer

func _ready():
	invulnerable_timer.timeout.connect(on_invulnerable_timer_timeout)


func become_invulnerable(timer_value:float, with_animation:bool) -> void:
	"""
	Player gets invulnerable to damage for a short time period (defined in argument for parameter timer_value).
	Invulnerability-animation starts only with true-argument of with_animation.
	"""
	is_invulnerable = true
	invulnerable_timer.wait_time = timer_value
	invulnerable_timer.start()
	if with_animation:
		pass
		# ToDo: start invulnerability animation (shader)


###----------CONNECTED SIGNALS----------###

func on_invulnerable_timer_timeout() -> void:
	"""
	Time period of invulnerability is over -> player gets vulnerable again.
	"""
	is_invulnerable = false

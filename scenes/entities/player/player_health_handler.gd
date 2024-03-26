extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var health_refresh_timer:Timer = $HealthRefreshTimer as Timer


###----------PROPERTIES----------###

var max_health:int = Globals.player_max_health:
	get:
		return max_health
	set(value):
		max_health = value
		Globals.player_max_health = value

var current_health:int = max_health:
	get:
		return current_health
	set(value):
		current_health = value
		Globals.player_current_health = value

var health_refreshment_rate:int = 1


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	health_refresh_timer.timeout.connect(on_health_refresh_timer_timeout)


###----------METHODS: CHANGE VALUE OF CURRENT HEALTH PROPERTY----------###

func get_damage(amount:int) -> void:
	"""
	Reduces player's health based on damage amount.
	"""
	if not player.invulnerable_handler.is_invulnerable:
		if current_health - amount <= 0:
			print("Spieler tot :(")
			current_health = 0
		else:
			current_health -= amount
			player.invulnerable_handler.become_invulnerable(1, true)
			health_refresh_timer.start()


func heal_health(amount:int) -> void:
	"""
	Raises player's health based on healing amount.
	"""
	if current_health + amount >= max_health:
		current_health = max_health
	else:
		current_health += amount


func refresh_player_health() -> void:
	if current_health < max_health:
		if current_health + health_refreshment_rate <= max_health:
			current_health += health_refreshment_rate
		else:
			current_health = max_health
	else:
		health_refresh_timer.stop()


###----------CONNECTED SIGNALS----------###

func on_health_refresh_timer_timeout() -> void:
	refresh_player_health()

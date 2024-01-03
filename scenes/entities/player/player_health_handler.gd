extends Node

var max_health:int = 100
var current_health:int = max_health

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


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


func heal_health(amount:int) -> void:
	"""
	Raises player's health based on healing amount.
	"""
	if current_health + amount >= max_health:
		current_health = max_health
	else:
		current_health += amount

extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

var hitbox_height_full:float = 76
var hitbox_height_reduced:float = 58
var hitbox_y_full:float = 4
var hitbox_y_reduced:float = 12


func resize_hitbox(to_full:bool=false, reduce:bool=false):
	"""
	Changes the hitbox-size between full (standing) and reduced (ducking).
	"""
	if to_full:
		player.hitbox.position.y = hitbox_y_full
		player.hitbox.shape.set_height(hitbox_height_full)
	elif reduce:
		player.hitbox.position.y = hitbox_y_reduced
		player.hitbox.shape.set_height(hitbox_height_reduced)

extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------PROPERTIES----------###

var hitbox_height_full:float = 76
var hitbox_height_reduced:float = 58
var hitbox_y_full:float = 4
var hitbox_y_reduced:float = 12


###----------METHODS: ADJUST HITBOX SIZE----------###

func resize_hitbox(to_full:bool=false, reduce:bool=false) -> void:
	"""
	Changes the hitbox-size between full (standing) and reduced (ducking).
	"""
	if to_full:
		self.player.hitbox.position.y = self.hitbox_y_full
		self.player.hitbox.shape.set_height(self.hitbox_height_full)
	elif reduce:
		self.player.hitbox.position.y = self.hitbox_y_reduced
		self.player.hitbox.shape.set_height(self.hitbox_height_reduced)

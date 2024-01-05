extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var animation_handler:Node = $".."


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_player_whip_attack()

func check_player_whip_attack():
	if "whip_attack" in player.current_animation:
		if "1" in player.current_animation:
			if not player.animations.is_playing():
				animation_handler.on_animation_finished()
		else:
			# if player is in second whip attack animation and whip's attack animation is also done -> change to standing animation 
			if player.weapon_handler.current_weapon.do_attack_animation and player.weapon_handler.current_weapon.done_attack_animation:
				animation_handler.on_animation_finished()

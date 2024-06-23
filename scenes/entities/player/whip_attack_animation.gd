extends Node


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var animations_handler:PlayerAnimationsHandler = $".." as PlayerAnimationsHandler


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	check_player_whip_attack()


###----------METHODS----------###

func check_player_whip_attack() -> void:
	if "whip_attack" in animations_handler.current_animation:
		if "1" in animations_handler.current_animation:
			if !animations_handler.animations.is_playing():
				animations_handler.on_animation_finished()
		else:
			# if player is in second whip attack animation and whip's attack animation is also done -> change to standing animation 
			if player.weapon_handler.current_weapon.do_attack_animation\
			&& player.weapon_handler.current_weapon.done_attack_animation:
				animations_handler.on_animation_finished()

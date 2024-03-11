extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D
@onready var animations_handler:Node = $".." as Node


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.check_player_whip_attack()


###----------METHODS----------###

func check_player_whip_attack() -> void:
	if "whip_attack" in self.animations_handler.current_animation:
		if "1" in self.animations_handler.current_animation:
			if not self.animations_handler.animations.is_playing():
				self.animations_handler.on_animation_finished()
		else:
			# if player is in second whip attack animation and whip's attack animation is also done -> change to standing animation 
			if self.player.weapon_handler.current_weapon.do_attack_animation and self.player.weapon_handler.current_weapon.done_attack_animation:
				self.animations_handler.on_animation_finished()

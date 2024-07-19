extends Node
class_name PlayerPowerUpsHandler


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------PROPERTIES----------###

## Multiplicator of damage done by player's primary weapon: whip
@export_range(1, 3) var whip_damage_increase_multiplicator:float = 2

## Multiplicator of damage done by player's primary weapon: sword
@export_range(1, 5) var sword_damage_increase_multiplicator:float = 3

## Multiplicator of player's movement speed
@export_range(1, 3) var player_movement_speed_increase_multiplicator:float = 1.5

###----------METHODS----------###

func get_power_up_whip_damage_increase(time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	var power_up_buff_name = "whip"
	# add power up to weapons handler only if power up is not already present
	if !(player.weapon_handler.active_power_up_buffs.has(power_up_buff_name)):
		# value is the damage value multiplicator
		player.weapon_handler.active_power_up_buffs[power_up_buff_name] = whip_damage_increase_multiplicator
		
		# if whip is currently equiped -> update whip-instance stats as well
		if 'IS_WHIP' in player.weapon_handler.current_weapon:
			player.weapon_handler.current_weapon.whip_attack_init_damage *= whip_damage_increase_multiplicator
			player.weapon_handler.current_weapon.whip_attack_max_damage *= whip_damage_increase_multiplicator
			player.weapon_handler.current_weapon.whip_attack_damage_increase *= whip_damage_increase_multiplicator
	
	await get_tree().create_timer(time_duration_in_s).timeout
	player.weapon_handler.active_power_up_buffs.erase(power_up_buff_name)
	
	# TODO: Buffanzeige aus UI nehmen
	
	# if whip is currently equipted by player, update its stats back to normal as well
	if player.weapon_handler.current_weapon == null:
		return
	if !('IS_WHIP' in player.weapon_handler.current_weapon):
		return
	
	# by dividing value by multiplicator -> back to normal stats
	player.weapon_handler.current_weapon.whip_attack_init_damage /= whip_damage_increase_multiplicator
	player.weapon_handler.current_weapon.whip_attack_max_damage /= whip_damage_increase_multiplicator
	player.weapon_handler.current_weapon.whip_attack_damage_increase /= whip_damage_increase_multiplicator


func get_power_up_sword_damage_increase(time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	var power_up_buff_name = "sword"
	# add power up to weapons handler only if power up is not already present
	if !(player.weapon_handler.active_power_up_buffs.has(power_up_buff_name)):
		# value is the damage value multiplicator
		player.weapon_handler.active_power_up_buffs[power_up_buff_name] = sword_damage_increase_multiplicator
		
		# if whip is currently equiped -> update whip-instance stats as well
		if 'IS_SWORD' in player.weapon_handler.current_weapon:
			player.weapon_handler.current_weapon.damage_combo_1 *= sword_damage_increase_multiplicator
			player.weapon_handler.current_weapon.damage_combo_2 *= sword_damage_increase_multiplicator
			player.weapon_handler.current_weapon.damage_combo_3 *= sword_damage_increase_multiplicator
	
	await get_tree().create_timer(time_duration_in_s).timeout
	player.weapon_handler.active_power_up_buffs.erase(power_up_buff_name)
	
	# TODO: Buffanzeige aus UI nehmen
	
	# if sword is currently equipted by player, update its stats back to normal as well
	if player.weapon_handler.current_weapon == null:
		return
	if !('IS_SWORD' in player.weapon_handler.current_weapon):
		return
	
	player.weapon_handler.current_weapon.damage_combo_1 /= sword_damage_increase_multiplicator
	player.weapon_handler.current_weapon.damage_combo_2 /= sword_damage_increase_multiplicator
	player.weapon_handler.current_weapon.damage_combo_3 /= sword_damage_increase_multiplicator


func get_power_up_movement_speed_increase(time_duration_in_s:int) -> void:
	
	if player.movement_handler.BASE_SPEED != player.movement_handler.current_speed:
		return
	
	player.movement_handler.current_speed = int(round(player.movement_handler.BASE_SPEED * player_movement_speed_increase_multiplicator))
	player.animations_handler.animations.speed_scale = 1 * player_movement_speed_increase_multiplicator
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	player.movement_handler.current_speed = player.movement_handler.BASE_SPEED
	player.animations_handler.animations.speed_scale = 1
	
	# TODO: Buffanzeige aus UI nehmen


func get_power_up_unlimited_stamina(time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	if player.stamina_handler.stamina_cost_multiplier == 0:
		return
	
	player.stamina_handler.stamina_cost_multiplier = 0
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	player.stamina_handler.stamina_cost_multiplier = 1 # TODO: ggnf hier Aenderungen vornehmen, sollte sich der Kosten-Multiplier durch dauerhafte Upgrades veraendern
	
	# TODO: Buffanzeige aus UI nehmen

extends Node
class_name PlayerPowerUpsHandler


###----------CUSTOM SIGNALS----------###

signal got_power_up(buff_type:String, time_in_s:int)
signal refresh_power_up(buff_type:String, time_in_s:int)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------PROPERTIES----------###

## Multiplicator of damage done by player's primary weapon: whip
@export_range(1, 3) var whip_damage_increase_multiplicator:float = 2

## Multiplicator of damage done by player's primary weapon: sword
@export_range(1, 5) var sword_damage_increase_multiplicator:float = 3

## Multiplicator of player's movement speed
@export_range(1, 3) var player_movement_speed_increase_multiplicator:float = 1.5

var currently_active_power_ups:Dictionary = {}


###----------METHODS----------###

func get_power_up_whip_damage_increase(buff_type:String, time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	var power_up_buff_name = "whip"
	
	# if buff is already active -> remove buff before applying again
	if currently_active_power_ups.has(buff_type):
		_remove_power_up_whip_damage_increase(power_up_buff_name)
		refresh_power_up.emit(buff_type, time_duration_in_s)
	else:
		currently_active_power_ups[buff_type] = true
		got_power_up.emit(buff_type, time_duration_in_s)
	
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
	
	currently_active_power_ups.erase(buff_type)
	
	_remove_power_up_whip_damage_increase(power_up_buff_name)


func _remove_power_up_whip_damage_increase(power_up_buff_name:String) -> void:
	player.weapon_handler.active_power_up_buffs.erase(power_up_buff_name)
	
	# if whip is currently equipted by player, update its stats back to normal as well
	if player.weapon_handler.current_weapon == null:
		return
	if !('IS_WHIP' in player.weapon_handler.current_weapon):
		return
	# by dividing value by multiplicator -> back to normal stats
	player.weapon_handler.current_weapon.whip_attack_init_damage /= whip_damage_increase_multiplicator
	player.weapon_handler.current_weapon.whip_attack_max_damage /= whip_damage_increase_multiplicator
	player.weapon_handler.current_weapon.whip_attack_damage_increase /= whip_damage_increase_multiplicator


func get_power_up_sword_damage_increase(buff_type:String, time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	var power_up_buff_name = "sword"
	
	# if buff is already active -> remove buff before applying again
	if currently_active_power_ups.has(buff_type):
		_remove_power_up_sword_damage_increase(power_up_buff_name)
		refresh_power_up.emit(buff_type, time_duration_in_s)
	else:
		currently_active_power_ups[buff_type] = true
		got_power_up.emit(buff_type, time_duration_in_s)
	
	# add power up to weapons handler only if power up is not already present
	if !(player.weapon_handler.active_power_up_buffs.has(power_up_buff_name)):
		# value is the damage value multiplicator
		player.weapon_handler.active_power_up_buffs[power_up_buff_name] = sword_damage_increase_multiplicator
		
		# if sword is currently equiped -> update sword-instance stats as well
		if 'IS_SWORD' in player.weapon_handler.current_weapon:
			player.weapon_handler.current_weapon.damage_combo_1 *= sword_damage_increase_multiplicator
			player.weapon_handler.current_weapon.damage_combo_2 *= sword_damage_increase_multiplicator
			player.weapon_handler.current_weapon.damage_combo_3 *= sword_damage_increase_multiplicator
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	currently_active_power_ups.erase(buff_type)
	
	_remove_power_up_sword_damage_increase(power_up_buff_name)


func _remove_power_up_sword_damage_increase(power_up_buff_name) -> void:
	player.weapon_handler.active_power_up_buffs.erase(power_up_buff_name)
	
	# if sword is currently equipted by player, update its stats back to normal as well
	if player.weapon_handler.current_weapon == null:
		return
	if !('IS_SWORD' in player.weapon_handler.current_weapon):
		return
	player.weapon_handler.current_weapon.damage_combo_1 /= sword_damage_increase_multiplicator
	player.weapon_handler.current_weapon.damage_combo_2 /= sword_damage_increase_multiplicator
	player.weapon_handler.current_weapon.damage_combo_3 /= sword_damage_increase_multiplicator


func get_power_up_movement_speed_increase(buff_type:String, time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	# if buff is already active -> remove buff before applying again
	if currently_active_power_ups.has(buff_type):
		_remove_power_up_movement_speed_increase()
		refresh_power_up.emit(buff_type, time_duration_in_s)
	else:
		currently_active_power_ups[buff_type] = true
		got_power_up.emit(buff_type, time_duration_in_s)
	
	player.movement_handler.current_speed = int(round(player.movement_handler.BASE_SPEED * player_movement_speed_increase_multiplicator))
	player.animations_handler.animations.speed_scale = 1 * player_movement_speed_increase_multiplicator
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	currently_active_power_ups.erase(buff_type)
	
	_remove_power_up_movement_speed_increase()


func _remove_power_up_movement_speed_increase() -> void:
	player.movement_handler.current_speed = player.movement_handler.BASE_SPEED
	player.animations_handler.animations.speed_scale = 1


func get_power_up_unlimited_stamina(buff_type:String, time_duration_in_s:int) -> void:
	if time_duration_in_s == null:
		return
	
	# if buff is already active -> remove buff before applying again
	if currently_active_power_ups.has(buff_type):
		_remove_power_up_unlimited_stamina()
		refresh_power_up.emit(buff_type, time_duration_in_s)
	else:
		currently_active_power_ups[buff_type] = true
		got_power_up.emit(buff_type, time_duration_in_s)
	
	player.stamina_handler.stamina_cost_multiplier = 0
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	currently_active_power_ups.erase(buff_type)
	
	_remove_power_up_unlimited_stamina()


func _remove_power_up_unlimited_stamina() -> void:
	player.stamina_handler.stamina_cost_multiplier = 1 # TODO: ggnf hier Aenderungen vornehmen, sollte sich der Kosten-Multiplier durch dauerhafte Upgrades veraendern

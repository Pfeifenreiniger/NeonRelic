extends Node
class_name PlayerCollectablesHandler


###----------CUSTOM SIGNALS----------###

signal got_heal_up(heal_category:String, heal_percentage:float)


###----------SCENE REFERENCES----------###

@onready var player_power_ups_handler: PlayerPowerUpsHandler = $PlayerPowerUpsHandler as PlayerPowerUpsHandler


###----------METHODS----------###

func get_power_up(power_up_stats:PowerUpStats) -> void:
	print("Spieler erhaelt Power Up!!")
	print(power_up_stats.buff_type)
	print(power_up_stats.buff_duration)
	
	if "whip" in power_up_stats.buff_type:
		player_power_ups_handler.get_power_up_whip_damage_increase(power_up_stats.buff_duration)
	
	if "sword" in power_up_stats.buff_type:
		player_power_ups_handler.get_power_up_sword_damage_increase(power_up_stats.buff_duration)
	
	if "movement_speed" in power_up_stats.buff_type:
		player_power_ups_handler.get_power_up_movement_speed_increase(power_up_stats.buff_duration)
	
	if "stamina" in power_up_stats.buff_type:
		player_power_ups_handler.get_power_up_unlimited_stamina(power_up_stats.buff_duration)


func get_heal_up(heal_up_stats:HealUpStats) -> void:
	got_heal_up.emit(heal_up_stats.heal_category, heal_up_stats.heal_percentage)

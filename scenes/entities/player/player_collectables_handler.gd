extends Node
class_name PlayerCollectablesHandler


###----------CUSTOM SIGNALS----------###

signal got_heal_up(heal_category:String, heal_percentage:float)


###----------METHODS----------###

func get_power_up(power_up_stats:PowerUpStats) -> void:
	print("Spieler erhält Power Up!!")
	print(power_up_stats.buff_type)
	print(power_up_stats.buff_duration)

func get_heal_up(heal_up_stats:HealUpStats) -> void:
	got_heal_up.emit(heal_up_stats.heal_category, heal_up_stats.heal_percentage)

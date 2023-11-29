extends Node

var current_weapon


func select_current_weapon(weapon_name:String) -> void:
	if weapon_name == "whip":
		current_weapon = $Weapons/Whip
	else:
		return

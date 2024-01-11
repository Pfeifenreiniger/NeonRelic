extends Node

###----------NODE REFERENCES----------###

@onready var whip_weapon:AnimatedSprite2D = $Weapons/Whip


###----------PROPERTIES----------###

@onready var weapons:Array = [
	whip_weapon, # ind 0 - laser whip (standard weapon)
	null, # ind 1 - other weapon
	null # ind 2 - another weapon
]
var current_weapon


###----------METHODS----------###

func select_current_weapon(weapon_name:String) -> void:
	if weapon_name == "whip":
		current_weapon = weapons[0]
	else:
		return

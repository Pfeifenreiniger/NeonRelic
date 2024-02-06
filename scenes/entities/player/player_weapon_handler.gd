extends Node


###----------NODE REFERENCES----------###

@onready var whip_weapon:AnimatedSprite2D = $Weapons/Whip
@onready var secondary_weapons:Node2D = $SecondaryWeapons

###----------PROPERTIES----------###

@onready var weapons:Array = [
	whip_weapon, # ind 0 - laser whip (standard weapon)
	null, # ind 1 - other weapon
	null # ind 2 - another weapon
]
var current_weapon

@onready var available_secondary_weapons:Dictionary = {
	"fire_grenade" : preload("res://scenes/weapons/grenade/grenade.tscn")
}


###----------METHODS----------###

func select_current_weapon(weapon_name:String) -> void:
	if weapon_name == "whip":
		current_weapon = weapons[0]
	else:
		return


func aim_secondary_weapon(start_pos:Vector2, side:String) -> void:
	secondary_weapons.draw_aim_line(start_pos, side)


func stop_aim_secondary_weapon() -> float:
	return secondary_weapons.stop_draw_aim_line()


func use_secondary_weapon(secondary_weapon_name:String, start_velocity:Vector2) -> void:
	if secondary_weapon_name == "fire_grenade":
		var fire_grenade:RigidBody2D = available_secondary_weapons[secondary_weapon_name].instantiate()
		fire_grenade.GRENADE_TYPE = secondary_weapon_name
		fire_grenade.linear_velocity = start_velocity
		$"SecondaryWeapons".add_child(fire_grenade)
	else:
		return


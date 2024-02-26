extends Node


###----------NODE REFERENCES----------###

@onready var primary_weapons:Node2D = $PrimaryWeapons
@onready var secondary_weapons:Node2D = $SecondaryWeapons

###----------PROPERTIES----------###

@onready var available_primary_weapons:Dictionary = {
	"whip" : preload("res://scenes/weapons/whip/whip.tscn")
}

const valid_primary_weapon_names:Array[String] = [
	"whip", "sword"
]

var current_weapon:Node2D

@onready var available_secondary_weapons:Dictionary = {
	"fire_grenade" : preload("res://scenes/weapons/grenade/grenade.tscn")
}


func _ready() -> void:
	# at start -> select a primary weapon
	select_current_weapon(Globals.currently_used_primary_weapon)

###----------METHODS----------###

func select_current_weapon(weapon_name:String) -> void:
	"""
	Selects primary weapon of player
	"""
	
	if weapon_name not in valid_primary_weapon_names:
		return

	var primary_weapon:Node2D = available_primary_weapons[weapon_name].instantiate() as Node2D
	
	# add loaded primary weapon to Node2D (and remove any older Nodes)
	if primary_weapons.get_children().size() > 0:
		for primary_weapon_child in primary_weapons.get_children():
			primary_weapons.remove_child(primary_weapon_child)
			primary_weapon_child.queue_free()
	primary_weapons.add_child(primary_weapon)
	
	current_weapon = primary_weapon


func aim_secondary_weapon(start_pos:Vector2, side:String) -> void:
	secondary_weapons.draw_aim_line(start_pos, side)


func stop_aim_secondary_weapon() -> float:
	return secondary_weapons.stop_draw_aim_line()


func use_secondary_weapon(secondary_weapon_name:String, start_velocity:Vector2) -> void:
	if secondary_weapon_name == "fire_grenade":
		var fire_grenade:RigidBody2D = available_secondary_weapons[secondary_weapon_name].instantiate()
		fire_grenade.GRENADE_TYPE = secondary_weapon_name
		fire_grenade.linear_velocity = start_velocity
		secondary_weapons.add_child(fire_grenade)
	else:
		return


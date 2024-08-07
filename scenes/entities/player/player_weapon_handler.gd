extends Node
class_name PlayerWeaponHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var primary_weapons:Node2D = $PrimaryWeapons as Node2D
@onready var secondary_weapons:Node2D = $SecondaryWeapons as Node2D


###----------PROPERTIES----------###

@onready var available_primary_weapons:Dictionary = {
	"whip" as String : preload("res://scenes/weapons/whip/whip.tscn") as PackedScene,
	"sword" as String: preload("res://scenes/weapons/sword/sword.tscn") as PackedScene
}

const valid_primary_weapon_names:Array[String] = [
	"whip" as String, "sword" as String
]

var current_weapon:Node

@onready var available_secondary_weapons:Dictionary = {
	"grenade" as String : preload("res://scenes/weapons/grenade/grenade.tscn") as PackedScene
}

var active_power_up_buffs:Dictionary = {}


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	# at start -> select a primary weapon
	select_current_weapon(Globals.currently_used_primary_weapon)


###----------METHODS----------###

func select_current_weapon(weapon_name:String) -> void:
	# Selects primary weapon of player
	
	if weapon_name not in valid_primary_weapon_names:
		return
	
	var primary_weapon:Node = available_primary_weapons[weapon_name].instantiate() as Node
	
	# add loaded primary weapon to Node2D (and remove any older Nodes)
	if primary_weapons.get_children().size() > 0:
		for primary_weapon_child in primary_weapons.get_children():
			primary_weapons.remove_child(primary_weapon_child)
			primary_weapon_child.queue_free()
	primary_weapons.add_child(primary_weapon)
	
	# check for active power ups
	if !(active_power_up_buffs.is_empty()):
		for active_power_up_buff in active_power_up_buffs:
			if active_power_up_buff == weapon_name:
				if weapon_name == "whip":
					primary_weapon.whip_attack_init_damage *= active_power_up_buffs[weapon_name]
					primary_weapon.whip_attack_max_damage *= active_power_up_buffs[weapon_name]
					primary_weapon.whip_attack_damage_increase *= active_power_up_buffs[weapon_name]
				elif weapon_name == "sword":
					primary_weapon.damage_combo_1 *= active_power_up_buffs[weapon_name]
					primary_weapon.damage_combo_2 *= active_power_up_buffs[weapon_name]
					primary_weapon.damage_combo_3 *= active_power_up_buffs[weapon_name]
	
	current_weapon = primary_weapon


func aim_secondary_weapon(start_pos:Vector2, side:String) -> void:
	secondary_weapons.draw_aim_line(start_pos, side)


func stop_aim_secondary_weapon() -> float:
	return secondary_weapons.stop_draw_aim_line()


func use_secondary_weapon(secondary_weapon_name:String, start_velocity:Vector2) -> void:
	if secondary_weapon_name.contains("grenade"):
		var grenade:RigidBody2D = available_secondary_weapons["grenade"].instantiate() as RigidBody2D
		grenade.GRENADE_TYPE = secondary_weapon_name
		grenade.linear_velocity = start_velocity
		secondary_weapons.add_child(grenade)
		player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["use_secondary_weapon"])
	# ToDo - noch andere secondary_weapon Arten (ausser Granaten) implementieren und mit elifs abfragen
	else:
		return

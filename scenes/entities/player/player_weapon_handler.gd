extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var primary_weapons:Node2D = $PrimaryWeapons as Node2D
@onready var secondary_weapons:Node2D = $SecondaryWeapons as Node2D


###----------PROPERTIES----------###

@onready var available_primary_weapons:Dictionary = {
	"whip" as String : preload("res://scenes/weapons/whip/whip.tscn") as PackedScene
}

const valid_primary_weapon_names:Array[String] = [
	"whip" as String, "sword" as String
]

var current_weapon:Node2D

@onready var available_secondary_weapons:Dictionary = {
	"grenade" as String : preload("res://scenes/weapons/grenade/grenade.tscn") as PackedScene
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# at start -> select a primary weapon
	self.select_current_weapon(Globals.currently_used_primary_weapon)


###----------METHODS----------###

func select_current_weapon(weapon_name:String) -> void:
	"""
	Selects primary weapon of player
	"""
	
	if weapon_name not in self.valid_primary_weapon_names:
		return

	var primary_weapon:Node2D = self.available_primary_weapons[weapon_name].instantiate() as Node2D
	
	# add loaded primary weapon to Node2D (and remove any older Nodes)
	if self.primary_weapons.get_children().size() > 0:
		for primary_weapon_child in self.primary_weapons.get_children():
			self.primary_weapons.remove_child(primary_weapon_child)
			primary_weapon_child.queue_free()
	self.primary_weapons.add_child(primary_weapon)
	
	self.current_weapon = primary_weapon


func aim_secondary_weapon(start_pos:Vector2, side:String) -> void:
	self.secondary_weapons.draw_aim_line(start_pos, side)


func stop_aim_secondary_weapon() -> float:
	return secondary_weapons.stop_draw_aim_line()


func use_secondary_weapon(secondary_weapon_name:String, start_velocity:Vector2) -> void:
	if secondary_weapon_name.contains("grenade"):
		var grenade:RigidBody2D = self.available_secondary_weapons["grenade"].instantiate() as RigidBody2D
		grenade.GRENADE_TYPE = secondary_weapon_name
		grenade.linear_velocity = start_velocity
		self.secondary_weapons.add_child(grenade)
		self.player.stamina_handler.cost_player_stamina(self.player.stamina_handler.stamina_costs["use_secondary_weapon"])
	# ToDo - noch andere secondary_weapon Arten (ausser Granaten) implementieren und mit elifs abfragen
	else:
		return

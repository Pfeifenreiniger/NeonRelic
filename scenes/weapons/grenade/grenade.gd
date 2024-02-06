extends RigidBody2D

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------PROPERTIES----------###

@export_enum("fire_grenade", "freeze_grenade") var GRENADE_TYPE:String


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set position to player's position
	global_position = player.secondary_weapon_start_pos.global_position


###----------METHODS: PER FRAME CALLED----------###

func _process(delta):
	pass


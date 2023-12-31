extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

# ledge climbing properties
@onready var ledge_climb_area:Area2D = $LedgeClimbArea
var current_ledge_to_climb_area:Area2D = null
var is_climbing_ledge:bool = false


func _ready():
	# set up ledge climbing
	ledge_climb_area.area_entered.connect(on_ledge_area_entered)
	ledge_climb_area.area_exited.connect(on_ledge_area_exited)


func _process(_delta):
	# put ledge climb area at player's global position
	ledge_climb_area.global_position = player.global_position


###----------CONNECTED SIGNALS----------###

func on_ledge_area_entered(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = area


func on_ledge_area_exited(area):
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = null

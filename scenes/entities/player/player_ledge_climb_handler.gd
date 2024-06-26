extends Node
class_name PlayerLedgeClimbHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var ledge_climb_area:Area2D = $LedgeClimbArea as Area2D
var current_ledge_to_climb_area:Area2D = null


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	
	# set up ledge climbing
	ledge_climb_area.area_entered.connect(_on_ledge_area_entered)
	ledge_climb_area.area_exited.connect(_on_ledge_area_exited)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	
	# put ledge climb area at player's global position
	ledge_climb_area.global_position = player.global_position


###----------METHODS----------###

func check_movements_for_climbing() -> bool:
	# Checks player's movements which do not allow to climb up any ledge.
	# Returns true when player can climb, otherwise false.
	
	var not_allowed_movements:Array[bool] = [
		player.movement_handler.to_duck,
		player.movement_handler.is_duck,
		player.movement_handler.will_duck,
		player.movement_handler.is_attacking,
		player.movement_handler.is_throwing,
		player.movement_handler.is_rolling,
		player.movement_handler.is_climbing_ledge
	]
	if true in not_allowed_movements:
		return false
	else:
		return true


###----------CONNECTED SIGNALS----------###

func _on_ledge_area_entered(area:Area2D) -> void:
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = area


func _on_ledge_area_exited(area:Area2D) -> void:
	if "ledge_to_climb" in area:
		current_ledge_to_climb_area = null

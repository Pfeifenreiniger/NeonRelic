extends Node
class_name PlayerInvulnerableHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var invulnerability_component:InvulnerabilityComponent = $InvulnerabilityComponent as InvulnerabilityComponent


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	invulnerability_component.entity = player

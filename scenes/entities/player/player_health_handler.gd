extends Node
class_name PlayerHealthHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var health_component:HealthComponent = $HealthComponent as HealthComponent


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	health_component.entity = player

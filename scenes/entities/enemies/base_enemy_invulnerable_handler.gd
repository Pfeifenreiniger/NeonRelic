extends Node
class_name BaseEnemyInvulnerableHandler


###----------SCENE REFERENCES----------###

@onready var base_enemy_root_node:BaseEnemy = $".." as BaseEnemy


###----------NODE REFERENCES----------###

@onready var invulnerability_component:InvulnerabilityComponent = $InvulnerabilityComponent as InvulnerabilityComponent


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	invulnerability_component.entity = base_enemy_root_node

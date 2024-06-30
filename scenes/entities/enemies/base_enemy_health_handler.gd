extends Node
class_name BaseEnemyHealthHandler


###----------SCENE REFERENCES----------###

@onready var base_enemy_root_node:BaseEnemy = $".." as BaseEnemy


###----------NODE REFERENCES----------###

@onready var health_component:HealthComponent = $HealthComponent as HealthComponent


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	health_component.entity = base_enemy_root_node
	health_component.died.connect(_on_died)


###----------CONNECTED SIGNALS----------###

func _on_died():
	base_enemy_root_node.do_die()

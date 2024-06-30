extends Node2D
class_name BaseEnemyAnimationsHandler


###----------SCENE REFERENCES----------###

@onready var base_enemy_root_node:BaseEnemy = $".." as BaseEnemy


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	_follow_root_node_global_position()


###----------METHODS----------###

func _follow_root_node_global_position() -> void:
	global_position = base_enemy_root_node.global_position

extends CharacterBody2D
class_name BaseEnemy


###----------SCENE REFERENCES----------###

@onready var player:Player = null


###----------NODE REFERENCES----------###

@onready var movement_handler:BaseEnemyMovementHandler = $MovementHandler as BaseEnemyMovementHandler
@onready var health_handler:BaseEnemyHealthHandler = $HealthHandler as BaseEnemyHealthHandler
@onready var invulnerable_handler:BaseEnemyInvulnerableHandler = $InvulnerableHandler as BaseEnemyInvulnerableHandler
@onready var animations_handler: BaseEnemyAnimationsHandler = $AnimationsHandler as BaseEnemyAnimationsHandler
@onready var aggro_area:Area2D = $AggroArea as Area2D
@onready var attack_area:Area2D = $AttackArea as Area2D
@onready var drop_collectable_component: DropCollectableComponent = $DropCollectableComponent as DropCollectableComponent


###----------PROPERTIES----------###

var IS_ENEMY:bool = true

# aggro state -> if true, enemy will move forwards player
var is_aggro:bool = false

# attacking state - if true, enemy performs attack actions
var is_attacking:bool = false

# state if enemy is at platform border -> if yes and enemy is aggro, he will not go further to player as border
var is_at_platform_border:bool = false


# x-axis movement direction
@export_enum("left", "right") var x_axis_direction:String = "left"


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	aggro_area.body_exited.connect(_on_aggro_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	movement_handler.apply_movement(delta)


###----------METHODS: CONNECTED SIGNALS----------###

func _on_aggro_area_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		is_aggro = true
		player = body


func _on_aggro_area_body_exited(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		is_aggro = false
		player = null


func _on_attack_area_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		is_attacking = true


func _on_attack_area_body_exited(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		is_attacking = false

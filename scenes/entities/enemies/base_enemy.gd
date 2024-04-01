extends CharacterBody2D
class_name BaseEnemy


###----------NODE REFERENCES----------###

@onready var movement_handler:Node = $MovementHandler as Node
@onready var health_handler:Node = $HealthHandler as Node
@onready var aggro_area:Area2D = $AggroArea as Area2D


###----------PROPERTIES----------###

var IS_ENEMY:bool = true

# aggro state
var is_aggro:bool = false

# health
var health:int = 100


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	aggro_area.body_exited.connect(_on_aggro_area_body_exited)


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	movement_handler.apply_movement(delta)


###----------METHODS: CONNECTED SIGNALS----------###

func _on_aggro_area_body_entered(body:Node2D) -> void:
	is_aggro = true


func _on_aggro_area_body_exited(body:Node2D) -> void:
	is_aggro = false

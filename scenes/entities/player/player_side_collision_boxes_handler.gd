extends Node
class_name PlayerSideCollisionBoxesHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var left_collision_detection_box:Area2D = $CollisionDetectionBoxes/LeftSideCollision as Area2D
@onready var right_collision_detection_box: Area2D = $CollisionDetectionBoxes/RightSideCollision as Area2D


###----------PROPERTIES----------###

var is_environment_collision_left:bool = false
var is_environment_collision_right:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set up environment collision checking
	left_collision_detection_box.body_entered.connect(_on_left_collision_detection_box_body_entered)
	left_collision_detection_box.body_exited.connect(_on_left_collision_detection_box_body_exited)
	right_collision_detection_box.body_entered.connect(_on_right_collision_detection_box_body_entered)
	right_collision_detection_box.body_exited.connect(_on_right_collision_detection_box_body_exited)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	
	# put detection boxes at player's global position
	left_collision_detection_box.global_position = player.global_position
	right_collision_detection_box.global_position = player.global_position


###----------CONNECTED SIGNALS----------###

func _on_left_collision_detection_box_body_entered(_body:Node2D) -> void:
	is_environment_collision_left = true


func _on_left_collision_detection_box_body_exited(_body:Node2D) -> void:
	is_environment_collision_left = false


func _on_right_collision_detection_box_body_entered(_body:Node2D) -> void:
	is_environment_collision_right = true


func _on_right_collision_detection_box_body_exited(_body:Node2D) -> void:
	is_environment_collision_right = false

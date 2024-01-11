extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------NODE REFERENCES----------###

@onready var left_collision_detection_box:Area2D = $CollisionDetectionBoxes/LeftSideCollision
@onready var right_collision_detection_box: Area2D = $CollisionDetectionBoxes/RightSideCollision


###----------PROPERTIES----------###

var is_environment_collision_left:bool = false
var is_environment_collision_right:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set up environment collision checking
	left_collision_detection_box.body_entered.connect(on_left_collision_detection_box_body_entered)
	left_collision_detection_box.body_exited.connect(on_left_collision_detection_box_body_exited)
	right_collision_detection_box.body_entered.connect(on_right_collision_detection_box_body_entered)
	right_collision_detection_box.body_exited.connect(on_right_collision_detection_box_body_exited)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta) -> void:
	# put detection boxes at player's global position
	left_collision_detection_box.global_position = player.global_position
	right_collision_detection_box.global_position = player.global_position


###----------CONNECTED SIGNALS----------###

func on_left_collision_detection_box_body_entered(body):
	is_environment_collision_left = true


func on_left_collision_detection_box_body_exited(body):
	is_environment_collision_left = false


func on_right_collision_detection_box_body_entered(body):
	is_environment_collision_right = true


func on_right_collision_detection_box_body_exited(body):
	is_environment_collision_right = false

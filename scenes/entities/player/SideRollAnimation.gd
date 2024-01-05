extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

@onready var side_roll_tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_side_roll_environment_collision()


func do_side_roll(direction:String) -> void:
	# tween config
	side_roll_tween = get_tree().create_tween()
	var animation_duration:float = 0.9
	
	# player pos offset
	var player_x_offset:int = 250
	
	var to_pos_x:int
	if direction == "left":
		to_pos_x = player.global_position.x - player_x_offset
	else:
		to_pos_x = player.global_position.x + player_x_offset

	var to_pos_y:int = player.global_position.y
	
	side_roll_tween.tween_property(player, "global_position", Vector2(to_pos_x, to_pos_y), animation_duration)


func check_side_roll_environment_collision() -> void:
	if player.is_environment_collision_left or player.is_environment_collision_right:
		if side_roll_tween != null:
			side_roll_tween.stop()


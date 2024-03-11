extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------PROPERTIES----------###

@onready var side_roll_tween:Tween


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.check_side_roll_environment_collision()


###----------METHODS----------###

func do_side_roll(direction:String) -> void:
	# tween config
	self.side_roll_tween = get_tree().create_tween()
	var animation_duration:float = 0.9
	
	# player pos offset
	var player_x_offset:float = 250
	
	var to_pos_x:float
	if direction == "left":
		to_pos_x = self.player.global_position.x - player_x_offset
	else:
		to_pos_x = self.player.global_position.x + player_x_offset

	var to_pos_y:float = self.player.global_position.y
	
	self.side_roll_tween.tween_property(self.player, "global_position", Vector2(to_pos_x, to_pos_y), animation_duration)


func check_side_roll_environment_collision() -> void:
	if self.player.side_collision_boxes_handler.is_environment_collision_left or self.player.side_collision_boxes_handler.is_environment_collision_right:
		if self.side_roll_tween != null:
			self.side_roll_tween.stop()


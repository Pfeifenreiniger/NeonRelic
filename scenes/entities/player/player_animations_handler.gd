extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


func select_animation() -> void:
	player.animations.stop()
	player.animations.play(player.current_animation)
	if player.start_run_animation:
		player.animations.set_frame(4)
		player.start_run_animation = false
	player.animation_to_change = false
	if player.loop_animation:
		player.animation_frames_forwards = true


func on_animation_finished():
	if player.loop_animation:
		player.animations.stop()
		if player.animation_frames_forwards:
			player.animations.play_backwards(player.current_animation)
			player.animation_frames_forwards = false
		else:
			player.animations.play(player.current_animation)
			player.animation_frames_forwards = true
	
	# to-duck animation is a one-way animation (to ducking-animation or to stand-animation)
	elif player.to_duck:
		player.to_duck = false
		if player.will_duck:
			player.will_duck = false
			player.is_duck = true
			player.resize_hit_box(false, true)
			if "left" in player.current_animation:
				player.current_animation = "duck_left"
			else:
				player.current_animation = "duck_right"
		else:
			if "left" in player.current_animation:
				player.current_animation = "stand_left"
			else:
				player.current_animation = "stand_right"
		
		player.loop_animation = true
		player.animation_to_change = true


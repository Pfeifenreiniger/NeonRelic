extends Sprite2D
class_name BaseHealUp


###----------METHODS----------###

func _delay_animation_player_play_start_time() -> void:
	# get random delay time for animation player start
	var delay_time_for_animation_player:float = randf_range(0, 0.5)
	delay_time_for_animation_player = snapped(delay_time_for_animation_player, 0.01)
	# wait delay time
	await get_tree().create_timer(delay_time_for_animation_player).timeout
	($AnimationPlayer as AnimationPlayer).play("default")

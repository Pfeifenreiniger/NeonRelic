extends Node


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var animations_handler:PlayerAnimationsHandler = $".." as PlayerAnimationsHandler


###----------NODE REFERENCES----------###

@onready var sword_attack_combo_time_window_rectangle:Node2D = $SwordAttackComboTimeWindowRectangle as Node2D


###----------PROPERTIES----------###

var is_combo_time_window:bool = false

@onready var x_movement_tween:Tween


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	if player.movement_handler.is_attacking && 'IS_SWORD' in player.weapon_handler.current_weapon:
		_check_if_combo_time_window()


###----------METHODS----------###

func attack_combo(combo_phase:int, player_position:String) -> void:
	if player.animations_handler.loop_animation:
		player.animations_handler.loop_animation = false
	player.animations_handler.animation_to_change = true
	
	if "right" in player.animations_handler.current_animation:
		player.animations_handler.current_animation = "%s_sword_attack_right_%s" % [player_position, str(combo_phase)]
	else:
		player.animations_handler.current_animation = "%s_sword_attack_left_%s" % [player_position, str(combo_phase)]
	
	# rect drawing for time window only for combo phases 1 and 2
	if combo_phase > 2:
		sword_attack_combo_time_window_rectangle.rect_to_draw = false
	else:
		x_movement_tween = get_tree().create_tween()
		var animation_duration:float
		
		# player pos offset
		var player_x_offset:float
		if combo_phase == 1:
			player_x_offset = 5
			animation_duration = 1
		else:
			player_x_offset = 10
			animation_duration = 0.5
		
		var to_pos_x:float
		if "right" in player.animations_handler.current_animation:
			to_pos_x = player.global_position.x + player_x_offset
		else:
			to_pos_x = player.global_position.x - player_x_offset
		
		x_movement_tween.tween_property(player, "global_position", Vector2(to_pos_x, player.global_position.y), animation_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_SINE)


func _check_if_combo_time_window() -> void:
	var current_animation_frame:int = player.animations_handler.animations.get_frame()
	
	if current_animation_frame > 6 && current_animation_frame <= 8:
		is_combo_time_window = true
		sword_attack_combo_time_window_rectangle.current_rect_color = sword_attack_combo_time_window_rectangle.rect_colors["red"]
	else:
		if is_combo_time_window:
			is_combo_time_window = false
			sword_attack_combo_time_window_rectangle.reset_rect_color()
	
	sword_attack_combo_time_window_rectangle.draw_time_window_rect(current_animation_frame)

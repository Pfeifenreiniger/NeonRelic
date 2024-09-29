extends Node


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var animations_handler:PlayerAnimationsHandler = $".." as PlayerAnimationsHandler


###----------NODE REFERENCES----------###

@onready var sword_attack_combo_time_window_rectangle:Node2D = $SwordAttackComboTimeWindowRectangle as Node2D

@onready var animations: AnimatedSprite2D = $"../Animations" as AnimatedSprite2D

# glow nodes
@onready var glow_rights: Node2D = $GlowRights as Node2D
@onready var glow_lefts: Node2D = $GlowLefts as Node2D
var currently_used_glow:PointLight2D
const GLOWS_POSITION_OFFSETS := {
	"GlowLeft_1_4" : Vector2(-12, 5),
	"GlowLeft_1_5" : Vector2(-10, -8),
	"GlowLeft_1_6" : Vector2(-16, -30),
	"GlowLeft_1_7" : Vector2(-34, -24),
	"GlowLeft_1_8" : Vector2(-35, -26),
	"GlowLeft_2_0" : Vector2(-11, -29),
	"GlowLeft_2_1" : Vector2(7, -30),
	"GlowLeft_2_2" : Vector2(14, -20),
	"GlowLeft_2_3" : Vector2(10, -30),
	"GlowLeft_2_4" : Vector2(-12, -32),
	"GlowLeft_2_5" : Vector2(-30, -4.5),
	"GlowLeft_2_6" : Vector2(-27.5, 11),
	"GlowLeft_2_7" : Vector2(-21.5, 18.5),
	"GlowLeft_2_8" : Vector2(-21.5, 18.5),
	"GlowLeft_3_0" : Vector2(-26, 13),
	"GlowLeft_3_1" : Vector2(-15, 14),
	"GlowLeft_3_2" : Vector2(-12, 14),
	"GlowLeft_3_3" : Vector2(-43, -4),
	"GlowLeft_3_4" : Vector2(-43, -4),
	"GlowLeft_3_5" : Vector2(-34, 2),
	"GlowLeft_3_6" : Vector2(-20, 20),
	"GlowRight_1_4" : Vector2(16, -3),
	"GlowRight_1_5" : Vector2(10, -14),
	"GlowRight_1_6" : Vector2(14.5, -29),
	"GlowRight_1_7" : Vector2(32.5, -24),
	"GlowRight_1_8" : Vector2(32.5, -24),
	"GlowRight_2_0" : Vector2(6, -31),
	"GlowRight_2_1" : Vector2(-5, -31),
	"GlowRight_2_2" : Vector2(-14, -26),
	"GlowRight_2_3" : Vector2(-9, -29),
	"GlowRight_2_4" : Vector2(10, -30),
	"GlowRight_2_5" : Vector2(29, -9.5),
	"GlowRight_2_6" : Vector2(27.5, 3),
	"GlowRight_2_7" : Vector2(25.5, 12.5),
	"GlowRight_2_8" : Vector2(25.5, 12.5),
	"GlowRight_3_0" : Vector2(26, 11),
	"GlowRight_3_1" : Vector2(15, 10),
	"GlowRight_3_2" : Vector2(12, 8),
	"GlowRight_3_3" : Vector2(43, 0),
	"GlowRight_3_4" : Vector2(43, 0),
	"GlowRight_3_5" : Vector2(30, 4),
	"GlowRight_3_6" : Vector2(20, 25)
}


###----------PROPERTIES----------###

# states
var is_combo_time_window := false
var is_currently_sword_attacking := false

@onready var x_movement_tween:Tween


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	if player.movement_handler.is_attacking && 'IS_SWORD' in player.weapon_handler.current_weapon:
		_check_if_combo_time_window()
		_check_for_glow_effect_sword_combo()


###----------METHODS----------###

func attack_combo(combo_phase:int, player_position:String) -> void:
	if player.animations_handler.loop_animation:
		player.animations_handler.loop_animation = false
	player.animations_handler.animation_to_change = true
	
	var animation_frame_i:int = 0 if combo_phase > 1 else 4
	if "right" in player.animations_handler.current_animation:
		_glow_effect_sword_combo("right", combo_phase, animation_frame_i)
		player.animations_handler.current_animation = "%s_sword_attack_right_%s" % [player_position, str(combo_phase)]
	else:
		_glow_effect_sword_combo("left", combo_phase, animation_frame_i)
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


func start_attack() -> void:
	is_currently_sword_attacking = true


func stop_attack() -> void:
	if currently_used_glow != null:
		currently_used_glow.enabled = false
		currently_used_glow = null
		
	is_combo_time_window = false
	is_currently_sword_attacking = false
	
	sword_attack_combo_time_window_rectangle.rect_to_draw = false
	sword_attack_combo_time_window_rectangle.reset_rect_color()
	x_movement_tween = null


func _check_for_glow_effect_sword_combo() -> void:
	
	if !is_currently_sword_attacking:
		return
	
	if !("sword_attack" in player.animations_handler.current_animation):
		return
	
	var animation_no:int = int(player.animations_handler.current_animation.split("_")[-1])
	var animation_frame_i:int = animations.frame
	
	if animation_no == 1 && animation_frame_i < 4:
		return
	
	var side:String = "right" if "right" in player.animations_handler.current_animation else "left"
	
	_glow_effect_sword_combo(
		side, animation_no, animation_frame_i
	)


func _glow_effect_sword_combo(
	side:String,
	animation_no:int,
	animation_frame_i:int
	) -> void:
	
	var identifier:String = "Glow%s_%s_%s" % [side.capitalize(), str(animation_no), str(animation_frame_i)]
	
	if currently_used_glow != null:
		currently_used_glow.enabled = false
	
	currently_used_glow = glow_rights.get_node(identifier) if side == "right" else glow_lefts.get_node(identifier)
	
	# adjust position
	currently_used_glow.global_position = animations.global_position
	currently_used_glow.global_position += GLOWS_POSITION_OFFSETS[identifier]
	
	currently_used_glow.enabled = true


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

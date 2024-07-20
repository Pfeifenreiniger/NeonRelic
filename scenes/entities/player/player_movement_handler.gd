extends Node
class_name PlayerMovementHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var ingame_camera:IngameCamera = get_tree().get_first_node_in_group('ingame_camera') as IngameCamera


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# run speed
const BASE_SPEED:int = 200
var current_speed:int
const BASE_ACCELERATION_SMOOTHING:int = 55
var current_acceleration_smoothing:int

# jumping
const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int
const LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER:float = 0.3
var can_coyote_jump:bool = false

# gravity
var BASE_GRAVITY:int = int(ProjectSettings.get_setting("physics/2d/default_gravity"))
var current_gravity:int

# movement states
var to_duck:bool = false
var is_duck:bool = false
var will_duck:bool = false
var is_jumping:bool = false
var is_falling:bool = false
var is_attacking:bool = false
var is_throwing:bool = false
var is_rolling:bool = false
var is_climbing_ledge:bool = false
var is_blocking:bool = false


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	current_speed = BASE_SPEED
	current_acceleration_smoothing = BASE_ACCELERATION_SMOOTHING
	current_jump_velocity = BASE_JUMP_VELOCITY
	current_gravity = BASE_GRAVITY


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	_apply_movement(delta)


###----------METHODS: 2-DIMENSIONAL MOVEMENT----------###

func _move_x(delta:float) -> void:
	if check_if_player_can_horizontally_move():
		# run right / left or stand idle
		player.controls_handler.check_input_run_x_axis_key()

		# check roll-action to right / left
		player.controls_handler.check_input_side_roll_x_axis_key()

		# apply movement to player's velocity (and apply current acceleration smoothing to x-axis movement)
		var target_velocity:Vector2 = direction * current_speed
		target_velocity = player.velocity.lerp(target_velocity, 1 - exp(-delta * current_acceleration_smoothing))
		
		player.velocity.x = target_velocity.x


func _move_y(delta:float) -> void:
	if !player.is_on_floor(): # player not on ground
		_move_y_player_not_on_floor(delta)
	else: # player on ground
		_move_y_player_on_floor()


func _move_y_player_not_on_floor(delta:float) -> void:
	# Player's y-axis movement when he's not on the floor.
	
	# apply gravity when player is not ducking nor climbing a ledge
	if !check_if_player_is_ducking()\
	&& !is_climbing_ledge:
		player.velocity.y += current_gravity * delta
	
	# checks for short jump input (via jump-key release)
	if !is_climbing_ledge:
		player.controls_handler.check_input_jump_key()
	
	# if gravity influenced player's physic -> check if he is falling
	if player.velocity.y > 0\
	&& !is_climbing_ledge:
		if !is_falling:
			if !is_jumping: # coyote jump only when player falls from platform
				check_coyote_jump()
			is_jumping = false
			is_rolling = false
			player.stamina_handler.stamina_can_refresh = true
			if player.animations_handler.side_roll_animation.side_roll_tween != null:
				player.animations_handler.side_roll_animation.side_roll_tween.stop()
			if player.animations_handler.sword_attack_animation.x_movement_tween != null:
				player.animations_handler.sword_attack_animation.x_movement_tween.stop()
				player.movement_handler.is_attacking = false
				player.animations_handler.sword_attack_animation.sword_attack_combo_time_window_rectangle.rect_to_draw = false
			is_falling = true
			direction.y = 1
			if "left" in player.animations_handler.current_animation:
				player.animations_handler.current_animation = "fall_down_left"
			else:
				player.animations_handler.current_animation = "fall_down_right"
			player.animations_handler.loop_animation = false
			player.animations_handler.animation_to_change = true


func _move_y_player_on_floor() -> void:
	# Player's y-axis movement when he's on the floor.
	
	# player got onto the floor last frame from a falling movement state -> he's not falling anymore
	if is_falling:
		is_falling = false
		direction.y = 0
	# ground-y-movement only possible when player's not currently climbing up a ledge, is attacking or is rolling
	if !is_climbing_ledge\
	&& !is_attacking\
	&& !is_rolling:
		# player jumping
		player.controls_handler.check_input_jump_key()
		# or player ducking
		player.controls_handler.check_input_duck_key()


func _move() -> void:
	player.move_and_slide()


func _apply_movement(delta:float) -> void:
	_move_x(delta)
	_move_y(delta)
	_move()


###----------METHODS: MOVEMENT CONDITION CHECKS----------###

func check_if_player_can_horizontally_move() -> bool:
	if !to_duck\
	&& !is_duck\
	&& !is_jumping\
	&& !is_falling\
	&& !is_climbing_ledge\
	&& !is_attacking\
	&& !is_throwing\
	&& !is_rolling\
	&& !is_blocking:
		return true
	else:
		return false


func check_if_player_can_vertically_move() -> bool:
	if !to_duck\
	&& !will_duck\
	&& !is_duck\
	&& !is_climbing_ledge\
	&& !is_attacking\
	&& !is_throwing\
	&& !is_rolling\
	&& !is_blocking:
		return true
	else:
		return false


func check_if_player_is_vertically_moving() -> bool:
	if is_falling or is_jumping:
		return true
	else:
		return false


func check_coyote_jump() -> void:
	# Player gains ability of coyote-jump for a very short amount of time after he loses touch to the level's floor.
	
	if not can_coyote_jump:
		can_coyote_jump = true
		# OPT - Zeitraum fuer den Coyote-Jump spaeter noch verbessern. Sind 0.2 Sekunden vom Spielgefuehl her gut?
		await get_tree().create_timer(0.2).timeout
		can_coyote_jump = false


func check_if_player_is_ducking() -> bool:
	if to_duck || is_duck:
		return true
	else:
		return false


func check_if_player_can_climb_up_ledge() -> bool:
	var can_climb_up:bool = false
	
	# doesn't player do any movements which do not allow to climb?
	if player.ledge_climb_handler.check_movements_for_climbing():
		# is player in front of a ledge?
		if player.ledge_climb_handler.current_ledge_to_climb_area != null\
		&& player.ledge_climb_handler.ledge_climb_area.overlaps_area(player.ledge_climb_handler.current_ledge_to_climb_area):
			# and finally, does player face in the correct direction?
			if check_if_ledge_side_fits(player.ledge_climb_handler.current_ledge_to_climb_area):
				can_climb_up = true
	
	return can_climb_up


func check_if_ledge_side_fits(ledge_area:Area2D) -> bool:
	if ("right" in player.animations_handler.current_animation && ledge_area.ledge_side == "left")\
	|| ("left" in player.animations_handler.current_animation && ledge_area.ledge_side == "right"):
		return true
	else:
		return false


func check_if_player_can_block() -> bool:
	if !is_blocking:
		if player.velocity.y == 0\
		&& !to_duck\
		&& !will_duck\
		&& !is_jumping\
		&& !is_falling\
		&& !is_attacking\
		&& !is_throwing\
		&& !is_rolling\
		&& !is_climbing_ledge\
		&& player.stamina_handler.check_player_has_enough_stamina(
			player.stamina_handler.stamina_costs["block_laser"]
		):
			return true
		
		else:
			return false
	
	else:
		return false


###----------METHODS: CONTROL INPUTS BASED MOVEMENT ACTIONS----------###

func action_input_run_x_axis(side:String) -> void:
	if side == 'right':
		direction.x = 1
		if player.animations_handler.current_animation != "run_right":
			player.animations_handler.current_animation = "run_right"
			player.animations_handler.animation_to_change = true
			player.animations_handler.loop_animation = true
			player.animations_handler.start_run_animation = true
	elif side == 'left':
		direction.x = -1
		if player.animations_handler.current_animation != "run_left":
			player.animations_handler.current_animation = "run_left"
			player.animations_handler.animation_to_change = true
			player.animations_handler.loop_animation = true
			player.animations_handler.start_run_animation = true
	else:
		# idle
		direction.x = 0
		if !"stand" in player.animations_handler.current_animation\
		&& check_if_player_can_horizontally_move():
			if "right" in player.animations_handler.current_animation:
				player.animations_handler.current_animation = "stand_right"
				player.animations_handler.loop_animation = true
			else:
				player.animations_handler.current_animation = "stand_left"
				player.animations_handler.loop_animation = true
			player.animations_handler.animation_to_change = true


func action_input_side_roll_x_axis(side:String) -> void:
	if side == 'right':
		var button_move_right_press_timestamp:int = round(Time.get_ticks_msec() / 10.0)
		if !is_rolling:
			if button_move_right_press_timestamp - player.controls_handler.player_roll_action_inputs["right"] <= 50\
			&& player.stamina_handler.check_player_has_enough_stamina(player.stamina_handler.stamina_costs["side_roll"]):
				player.animations_handler.current_animation = "roll_right"
				player.animations_handler.loop_animation = false
				player.animations_handler.animation_to_change = true
				is_rolling = true
				player.stamina_handler.stamina_can_refresh = false
				player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["side_roll"])
				player.animations_handler.side_roll_animation.do_side_roll("right")
				if !player.invulnerable_handler.invulnerability_component.is_invulnerable:
					player.invulnerable_handler.invulnerability_component.become_invulnerable(0.5, false)
			else:
				player.controls_handler.player_roll_action_inputs["right"] = button_move_right_press_timestamp
	else:
		# left
		var button_move_left_press_timestamp:int = round(Time.get_ticks_msec() / 10.0)
		if !is_rolling:
			if button_move_left_press_timestamp - player.controls_handler.player_roll_action_inputs["left"] <= 50\
			&& player.stamina_handler.check_player_has_enough_stamina(player.stamina_handler.stamina_costs["side_roll"]):
				player.animations_handler.current_animation = "roll_left"
				player.animations_handler.loop_animation = false
				player.animations_handler.animation_to_change = true
				is_rolling = true
				player.stamina_handler.stamina_can_refresh = false
				player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["side_roll"])
				player.animations_handler.side_roll_animation.do_side_roll("left")
				if !player.invulnerable_handler.invulnerability_component.is_invulnerable:
					player.invulnerable_handler.invulnerability_component.become_invulnerable(0.5, false)
			else:
				player.controls_handler.player_roll_action_inputs["left"] = button_move_left_press_timestamp


func action_input_jump() -> void:
	if (direction.y == 0 && !check_if_player_is_vertically_moving() || can_coyote_jump)\
	&& !(is_attacking || is_throwing || is_blocking):
		direction.y = -1
		is_jumping = true
		if can_coyote_jump:
			is_falling = false
			player.velocity.y = 0
			can_coyote_jump = false
		if "left" in player.animations_handler.current_animation:
			player.animations_handler.current_animation = "jump_up_left"
		else:
			player.animations_handler.current_animation = "jump_up_right"
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true
		player.velocity.y += current_jump_velocity
		player.controls_handler.jump_button_press_timer.start()


func action_input_duck() -> void:
	if direction.x == 0\
	&& abs(int(player.velocity.x)) == 0\
	&& !check_if_player_is_ducking()\
	&& !(is_attacking || is_throwing || is_rolling || is_blocking):
		to_duck = true
		will_duck = true
		player.velocity.x = 0
		if "left" in player.animations_handler.current_animation:
			player.animations_handler.current_animation = "to_duck_left"
		else:
			player.animations_handler.current_animation = "to_duck_right"
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true
		ingame_camera.asc_camera_y_axis = false
		ingame_camera.desc_camera_y_axis = true


func action_input_duck_release() -> void:
	if is_duck:
		is_duck = false
		to_duck = true
		player.hitbox_handler.resize_hitbox(true, false)
		player.weapon_handler.secondary_weapons.adjust_secondary_weapon_start_position('stand')

	elif to_duck:
		# play remaining to-duck animation backwards
		var last_frame:int = player.animations_handler.animations.frame
		player.animations_handler.animations.stop()
		player.animations_handler.animations.set_frame(last_frame)
	
	will_duck = false
	player.animations_handler.loop_animation = false
	ingame_camera.desc_camera_y_axis = false
	ingame_camera.asc_camera_y_axis = true
	
	if "left" in player.animations_handler.current_animation:
		player.animations_handler.current_animation = "to_duck_left"
		player.animations_handler.animations.play_backwards(player.animations_handler.current_animation)
	else:
		player.animations_handler.current_animation = "to_duck_right"
		player.animations_handler.animations.play_backwards(player.animations_handler.current_animation)


func action_input_climb_up_ledge() -> void:
	if is_jumping:
		is_jumping = false
	is_jumping = false
	is_falling = false
	is_climbing_ledge = true
	direction.y = 0
	player.velocity.y = 0
	player.animations_handler.animation_to_change = true
	player.animations_handler.loop_animation = false
	if "right" in player.animations_handler.current_animation:
		player.animations_handler.current_animation = "climb_up_ledge_right"
		player.animations_handler.climb_up_ledge_animation.climb_up_ledge("right")
	else:
		player.animations_handler.current_animation = "climb_up_ledge_left"
		player.animations_handler.climb_up_ledge_animation.climb_up_ledge("left")


func action_input_init_whip_attack() -> void:
	
	# check if player has enough stamina to perform whip-attack. if not -> cancel action
	if !player.stamina_handler.check_player_has_enough_stamina(
			player.stamina_handler.stamina_costs["whip_attack"]
		):
		return
	
	var position:String
	
	if is_duck:
		position = "duck"
	else:
		# do standing whip attack if player's on ground and is not acceleration sliding
		
		if abs(int(player.velocity.x)) != 0:
			return
		
		if check_if_player_can_horizontally_move():
			position = "stand"
		else:
			return
	
	player.weapon_handler.current_weapon.can_whip_attack_charge = true
	direction.x = 0
	player.velocity.x = 0
	is_attacking = true
	player.stamina_handler.stamina_can_refresh = false
	player.stamina_handler.cost_player_stamina(
		player.stamina_handler.stamina_costs["whip_attack"]
	)
	player.animations_handler.loop_animation = false
	player.animations_handler.animation_to_change = true
	if "right" in player.animations_handler.current_animation:
		player.animations_handler.current_animation = "%s_whip_attack_right_1" % position
	else:
		player.animations_handler.current_animation = "%s_whip_attack_left_1" % position


func action_input_init_sword_attack() -> void:
	
	# check if player has enough stamina to perform sword-attack. if not -> cancel action
	if !player.stamina_handler.check_player_has_enough_stamina(
			player.stamina_handler.stamina_costs["sword_attack"]
		):
		return
	
	var position:String
	
	if is_duck:
		# no sword attack while player's ducking
		return
	else:
		# do standing sword attack if player's on ground and is not acceleration sliding
		
		if abs(int(player.velocity.x)) != 0:
			return
		
		if check_if_player_can_horizontally_move():
			position = "stand"
		else:
			return
	
	is_attacking = true
	direction.x = 0
	player.velocity.x = 0
	player.stamina_handler.stamina_can_refresh = false
	player.stamina_handler.cost_player_stamina(
		player.stamina_handler.stamina_costs["sword_attack"]
	)
	player.weapon_handler.current_weapon.adjust_hitbox_position(1)
	player.animations_handler.sword_attack_animation.attack_combo(1, position)
	player.animations_handler.sword_attack_animation.sword_attack_combo_time_window_rectangle.rect_to_draw = true


func action_input_combo_sword_attack(last_combo_phase:int) -> void:
	
	# check if player has enough stamina to perform sword-attack. if not -> cancel action
	if !player.stamina_handler.check_player_has_enough_stamina(
			player.stamina_handler.stamina_costs["sword_attack"]
		):
		return
	else:
		player.stamina_handler.cost_player_stamina(
			player.stamina_handler.stamina_costs["sword_attack"]
		)
	
	var position:String = player.animations_handler.current_animation.split('_')[0]
	var next_combo_phase:int = last_combo_phase + 1
	
	player.weapon_handler.current_weapon.adjust_hitbox_position(next_combo_phase)
	player.weapon_handler.current_weapon.deactivate_hitbox(last_combo_phase)
	
	player.animations_handler.sword_attack_animation.attack_combo(next_combo_phase, position)


func action_input_use_secondary_weapon() -> void:
	
	# no use of secondary weapon if player is currently already throwing a secondary weapon or is in duck-transition movement states
	# or is attacking with primary weapon, or is falling/jumping, or isn't in standing or ducking animation
	if is_throwing\
	|| is_attacking\
	|| will_duck\
	|| to_duck\
	|| check_if_player_is_vertically_moving()\
	|| !("stand" in player.animations_handler.current_animation || "duck" in player.animations_handler.current_animation):
			return
	
	# check if player has enough stamina to perform use of secondary weapon. if not -> cancel action
	if !player.stamina_handler.check_player_has_enough_stamina(
			player.stamina_handler.stamina_costs["use_secondary_weapon"]
		):
		return
	
	# if player is currently still x-axis-sliding (from acceleration) -> cancel action
	if abs(int(player.velocity.x)) != 0:
		return
	
	is_throwing = true
	
	# aim for secondary weapon throw
	var start_pos:Vector2
	var offset_x:int = 10
	var offset_y:int = -12
	var side:String

	if "left" in player.animations_handler.current_animation:
		start_pos = Vector2(player.secondary_weapon_start_pos.global_position.x - offset_x, player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "left"
	else:
		start_pos = Vector2(player.secondary_weapon_start_pos.global_position.x + offset_x, player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "right"
	
	player.weapon_handler.aim_secondary_weapon(start_pos, side)


func action_input_block() -> void:
	if !check_if_player_can_block():
		return
	
	is_blocking = true
	player.velocity.x = 0
	
	# change animation to go_block animation
	var start_animation_name:String = ""
	
	if "stand" in player.animations_handler.current_animation\
	|| "run" in player.animations_handler.current_animation:
		start_animation_name += "stand_go_block_"
	else:
		start_animation_name += "duck_go_block_"
	
	if "left" in player.animations_handler.current_animation:
		start_animation_name += "left"
	else:
		start_animation_name += "right"
	
	player.animations_handler.current_animation = start_animation_name
	player.animations_handler.loop_animation = false
	player.animations_handler.animation_to_change = true
	
	# activate shield hitbox
	var shield_hitbox_name:String = start_animation_name.split("_")[0] + "_" + start_animation_name.split("_")[-1]
	player.block_shield_handler.activate_hitbox(shield_hitbox_name)


func action_input_block_release() -> void:
	if is_blocking:
		
		var end_animation_name:String = ""
		
		if "stand" in player.animations_handler.current_animation:
			end_animation_name += "stand_done_block_"
		else:
			end_animation_name += "duck_done_block_"
		
		end_animation_name += player.animations_handler.current_animation.split("_")[-1]
		
		player.animations_handler.current_animation = end_animation_name
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true


###----------METHODS: MOVEMENT EFFECTS (CAUSED BY OTHER SCENES)----------###

func effect_get_slow_down(time:float) -> void:
	# Movement (and animation) speed of player get reduced by half for the amount
	# of time passed as argument.
	
	current_speed = int(round(BASE_SPEED / 2))
	current_acceleration_smoothing = int(round(BASE_ACCELERATION_SMOOTHING / 10)) # for slippery movement on floor
	player.animations_handler.animations.speed_scale = 0.5
	player.animations_handler.animations.material.set_shader_parameter("doFrozenSlowedDown", true)
	player.animations_handler.side_roll_animation.current_player_x_offset = int(player.animations_handler.side_roll_animation.BASE_PLAYER_X_OFFSET / 2)
	player.animations_handler.side_roll_animation.current_animation_duration = int(player.animations_handler.side_roll_animation.BASE_ANIMATION_DURATION * 2)
	await get_tree().create_timer(time).timeout
	current_speed = BASE_SPEED
	current_acceleration_smoothing = BASE_ACCELERATION_SMOOTHING
	player.animations_handler.animations.speed_scale = 1
	player.animations_handler.animations.material.set_shader_parameter("doFrozenSlowedDown", false)
	player.animations_handler.side_roll_animation.current_player_x_offset = player.animations_handler.side_roll_animation.BASE_PLAYER_X_OFFSET
	player.animations_handler.side_roll_animation.current_animation_duration = player.animations_handler.side_roll_animation.BASE_ANIMATION_DURATION

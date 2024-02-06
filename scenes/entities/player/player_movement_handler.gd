extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var ingame_camera:Camera2D = get_tree().get_first_node_in_group('ingame_camera')


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# run speed
const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED

# jumping
const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int = BASE_JUMP_VELOCITY
const LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER:float = 0.3

# gravity
var BASE_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = BASE_GRAVITY

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


###----------METHODS: PER FRAME CALLED----------###

func _physics_process(delta):
	apply_movement(delta)


###----------METHODS: 2-DIMENSIONAL MOVEMENT----------###

func move_x() -> void:
	if check_if_player_can_horizontally_move():
		# run right / left or stand idle
		player.controls_handler.check_input_run_x_axis_key()

		# check roll-action to right / left
		player.controls_handler.check_input_side_roll_x_axis_key()

		# apply movement to player's velocity
		player.velocity.x = direction.x * current_speed


func move_y(delta) -> void:
	if not player.is_on_floor(): # player not on ground
		# apply gravity when player is not ducking nor climbing a ledge
		if not check_if_player_is_ducking() and not is_climbing_ledge:
			player.velocity.y += current_gravity * delta
		
		# checks for short jump input (via jump-key release)
		if not is_climbing_ledge:
			player.controls_handler.check_input_jump_key()
		
		player.controls_handler.check_input_climb_up_ledge_key()
		
		# if gravity influenced player's physic -> check if he is falling
		if player.velocity.y > 0  and not is_climbing_ledge:
			if not is_falling:
				is_jumping = false
				is_rolling = false
				player.stamina_handler.stamina_can_refresh = true
				if player.animations_handler.side_roll_animation.side_roll_tween != null:
					player.animations_handler.side_roll_animation.side_roll_tween.stop()
				is_falling = true
				direction.y = 1
				if "left" in player.animations_handler.current_animation:
					player.animations_handler.current_animation = "fall_down_left"
				else:
					player.animations_handler.current_animation = "fall_down_right"
				player.animations_handler.loop_animation = false
				player.animations_handler.animation_to_change = true
	else: # player on ground
		if is_falling:
			is_falling = false
			direction.y = 0
		# ground-y-movement only possible when player's not currently climbing up a ledge, is attacking or is rolling
		if not is_climbing_ledge and not is_attacking and not is_rolling:
			# player jumping
			player.controls_handler.check_input_jump_key()
			# or player ducking
			player.controls_handler.check_input_duck_key()


func move(_delta) -> void:
	player.move_and_slide()


func apply_movement(delta) -> void:
	move_x()
	move_y(delta)
	move(delta)


###----------METHODS: MOVEMENT CONDITION CHECKS----------###

func check_if_player_can_horizontally_move() -> bool:
	if not to_duck and not is_duck and not is_jumping and not is_falling and not is_climbing_ledge and not is_attacking and not is_throwing and not is_rolling:
		return true
	else:
		return false


func check_if_player_can_vertically_move() -> bool:
	if not to_duck and not will_duck and not is_duck and not is_climbing_ledge and not is_attacking and not is_throwing and not is_rolling:
		return true
	else:
		return false


func check_if_player_is_vertically_moving() -> bool:
	if is_falling or is_jumping:
		return true
	else:
		return false


func check_if_player_is_ducking() -> bool:
	if to_duck or is_duck:
		return true
	else:
		return false


func check_if_player_can_climb_up_ledge() -> bool:
	var can_climb_up = false
	
	# doesn't player do any movements which do not allow to climb?
	if player.ledge_climb_handler.check_movements_for_climbing():
		# is player in front of a ledge?
		if player.ledge_climb_handler.current_ledge_to_climb_area != null and player.ledge_climb_handler.ledge_climb_area.overlaps_area(player.ledge_climb_handler.current_ledge_to_climb_area):
			# and finally, does player face in the correct direction?
			if check_if_ledge_side_fits(player.ledge_climb_handler.current_ledge_to_climb_area):
				can_climb_up = true	
	
	return can_climb_up


func check_if_ledge_side_fits(ledge_area:Area2D) -> bool:
	if ("right" in player.animations_handler.current_animation and ledge_area.ledge_side == "left") or ("left" in player.animations_handler.current_animation and ledge_area.ledge_side == "right"):
		return true
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
		if not "stand" in player.animations_handler.current_animation and check_if_player_can_horizontally_move():
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
		if not is_rolling:
			if button_move_right_press_timestamp - player.controls_handler.player_roll_action_inputs["right"] <= 50 and player.stamina_handler.check_player_has_enough_stamina(player.stamina_handler.stamina_costs["side_roll"]):
				player.animations_handler.current_animation = "roll_right"
				player.animations_handler.loop_animation = false
				player.animations_handler.animation_to_change = true
				is_rolling = true
				player.stamina_handler.stamina_can_refresh = false
				player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["side_roll"])
				player.animations_handler.side_roll_animation.do_side_roll("right")
				player.invulnerable_handler.become_invulnerable(0.5, false)
			else:
				player.controls_handler.player_roll_action_inputs["right"] = button_move_right_press_timestamp
	else:
		# left
		var button_move_left_press_timestamp:int = round(Time.get_ticks_msec() / 10.0)
		if not is_rolling:
			if button_move_left_press_timestamp - player.controls_handler.player_roll_action_inputs["left"] <= 50 and player.stamina_handler.check_player_has_enough_stamina(player.stamina_handler.stamina_costs["side_roll"]):
				player.animations_handler.current_animation = "roll_left"
				player.animations_handler.loop_animation = false
				player.animations_handler.animation_to_change = true
				is_rolling = true
				player.stamina_handler.stamina_can_refresh = false
				player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["side_roll"])
				player.animations_handler.side_roll_animation.do_side_roll("left")
				player.invulnerable_handler.become_invulnerable(0.5, false)
			else:
				player.controls_handler.player_roll_action_inputs["left"] = button_move_left_press_timestamp


func action_input_jump() -> void:
	if direction.y == 0 and not check_if_player_is_vertically_moving() and not (is_attacking or is_throwing):
		direction.y = -1
		is_jumping = true
		if "left" in player.animations_handler.current_animation:
			player.animations_handler.current_animation = "jump_up_left"
		else:
			player.animations_handler.current_animation = "jump_up_right"
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true
		player.velocity.y += current_jump_velocity
		player.controls_handler.jump_button_press_timer.start()


func action_input_duck() -> void:
	if direction.x == 0 and not check_if_player_is_ducking() and not (is_attacking or is_throwing):
		to_duck = true
		will_duck = true
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
	
	if check_if_player_can_climb_up_ledge():
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
	
	var position:String
	
	if is_duck:
		position = "duck"
	else:
		# do standing whip attack if player's on ground
		if check_if_player_can_horizontally_move():
			position = "stand"
		else:
			return
	
	player.weapon_handler.current_weapon.can_whip_attack_charge = true
	direction.x = 0
	player.velocity.x = 0
	is_attacking = true
	player.stamina_handler.stamina_can_refresh = false
	player.stamina_handler.cost_player_stamina(player.stamina_handler.stamina_costs["whip_attack"])
	player.animations_handler.loop_animation = false
	player.animations_handler.animation_to_change = true
	if "right" in player.animations_handler.current_animation:
		player.animations_handler.current_animation = "%s_whip_attack_right_1" % position
	else:
		player.animations_handler.current_animation = "%s_whip_attack_left_1" % position


func action_input_use_secondary_weapon() -> void:
	
	# no use of secondary weapon if player is currently already throwing a secondary weapon or is in duck-transition movement states
	# or is attacking with primary weapon, or is falling/jumping, or isn't in standing or ducking animation
	if is_throwing or is_attacking or will_duck or to_duck or check_if_player_is_vertically_moving() or not ("stand" in player.animations_handler.current_animation or "duck" in player.animations_handler.current_animation):
			return
	
	is_throwing = true
	
	# aim for secondary weapon throw
	var start_pos
	var offset_x = 10
	var offset_y = 16
	var side
	if "left" in player.animations_handler.current_animation:
		start_pos = Vector2(player.secondary_weapon_start_pos.global_position.x - offset_x, player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "left"
	else:
		start_pos = Vector2(player.secondary_weapon_start_pos.global_position.x + offset_x, player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "right"
	
	player.weapon_handler.aim_secondary_weapon(start_pos, side)

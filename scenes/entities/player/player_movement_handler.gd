extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D
@onready var ingame_camera:Camera2D = get_tree().get_first_node_in_group('ingame_camera') as Camera2D


###----------PROPERTIES----------###

# movement direction
var direction:Vector2 = Vector2.ZERO

# run speed
const BASE_SPEED:int = 200
var current_speed:int = self.BASE_SPEED

# jumping
const BASE_JUMP_VELOCITY:int = -275
var current_jump_velocity:int = self.BASE_JUMP_VELOCITY
const LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER:float = 0.3
var can_coyote_jump:bool = false

# gravity
var BASE_GRAVITY:int = int(ProjectSettings.get_setting("physics/2d/default_gravity"))
var current_gravity:int = 980

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

func _process(delta:float) -> void:
	self.apply_movement(delta)


###----------METHODS: 2-DIMENSIONAL MOVEMENT----------###

func move_x() -> void:
	if check_if_player_can_horizontally_move():
		# run right / left or stand idle
		self.player.controls_handler.check_input_run_x_axis_key()

		# check roll-action to right / left
		self.player.controls_handler.check_input_side_roll_x_axis_key()

		# apply movement to player's velocity
		self.player.velocity.x = self.direction.x * self.current_speed


func move_y(delta:float) -> void:
	if not self.player.is_on_floor(): # player not on ground
		# apply gravity when player is not ducking nor climbing a ledge
		if not self.check_if_player_is_ducking() and not self.is_climbing_ledge:
			self.player.velocity.y += self.current_gravity * delta
		
		# checks for short jump input (via jump-key release)
		if not self.is_climbing_ledge:
			self.player.controls_handler.check_input_jump_key()
		
		# if gravity influenced player's physic -> check if he is falling
		if self.player.velocity.y > 0  and not self.is_climbing_ledge:
			if not self.is_falling:
				if not self.is_jumping: # coyote jump only when player falls from platform
					self.check_coyote_jump()
				self.is_jumping = false
				self.is_rolling = false
				self.player.stamina_handler.stamina_can_refresh = true
				if self.player.animations_handler.side_roll_animation.side_roll_tween != null:
					self.player.animations_handler.side_roll_animation.side_roll_tween.stop()
				self.is_falling = true
				self.direction.y = 1
				if "left" in self.player.animations_handler.current_animation:
					self.player.animations_handler.current_animation = "fall_down_left"
				else:
					self.player.animations_handler.current_animation = "fall_down_right"
				self.player.animations_handler.loop_animation = false
				self.player.animations_handler.animation_to_change = true
	else: # player on ground
		if self.is_falling:
			self.is_falling = false
			self.direction.y = 0
		# ground-y-movement only possible when player's not currently climbing up a ledge, is attacking or is rolling
		if not self.is_climbing_ledge and not self.is_attacking and not self.is_rolling:
			# player jumping
			self.player.controls_handler.check_input_jump_key()
			# or player ducking
			self.player.controls_handler.check_input_duck_key()


func move() -> void:
	self.player.move_and_slide()


func apply_movement(delta:float) -> void:
	self.move_x()
	self.move_y(delta)
	self.move()


###----------METHODS: MOVEMENT CONDITION CHECKS----------###

func check_if_player_can_horizontally_move() -> bool:
	if not self.to_duck and not self.is_duck and not self.is_jumping and not self.is_falling and not self.is_climbing_ledge and not self.is_attacking and not self.is_throwing and not self.is_rolling:
		return true
	else:
		return false


func check_if_player_can_vertically_move() -> bool:
	if not self.to_duck and not self.will_duck and not self.is_duck and not self.is_climbing_ledge and not self.is_attacking and not self.is_throwing and not self.is_rolling:
		return true
	else:
		return false


func check_if_player_is_vertically_moving() -> bool:
	if self.is_falling or self.is_jumping:
		return true
	else:
		return false


func check_coyote_jump() -> void:
	"""
	Player gains ability of coyote-jump for a very short amount of time after he loses touch to the level's floor.
	"""
	if not self.can_coyote_jump:
		self.can_coyote_jump = true
		# OPT - Zeitraum fuer den Coyote-Jump spaeter noch verbessern. Sind 0.2 Sekunden vom Spielgefuehl her gut?
		await get_tree().create_timer(0.2).timeout
		self.can_coyote_jump = false


func check_if_player_is_ducking() -> bool:
	if self.to_duck or self.is_duck:
		return true
	else:
		return false


func check_if_player_can_climb_up_ledge() -> bool:
	var can_climb_up:bool = false
	
	# doesn't player do any movements which do not allow to climb?
	if self.player.ledge_climb_handler.check_movements_for_climbing():
		# is player in front of a ledge?
		if self.player.ledge_climb_handler.current_ledge_to_climb_area != null and self.player.ledge_climb_handler.ledge_climb_area.overlaps_area(self.player.ledge_climb_handler.current_ledge_to_climb_area):
			# and finally, does player face in the correct direction?
			if self.check_if_ledge_side_fits(self.player.ledge_climb_handler.current_ledge_to_climb_area):
				can_climb_up = true
	
	return can_climb_up


func check_if_ledge_side_fits(ledge_area:Area2D) -> bool:
	if ("right" in self.player.animations_handler.current_animation and ledge_area.ledge_side == "left") or ("left" in self.player.animations_handler.current_animation and ledge_area.ledge_side == "right"):
		return true
	else:
		return false


###----------METHODS: CONTROL INPUTS BASED MOVEMENT ACTIONS----------###

func action_input_run_x_axis(side:String) -> void:
	if side == 'right':
		self.direction.x = 1
		if self.player.animations_handler.current_animation != "run_right":
			self.player.animations_handler.current_animation = "run_right"
			self.player.animations_handler.animation_to_change = true
			self.player.animations_handler.loop_animation = true
			self.player.animations_handler.start_run_animation = true
	elif side == 'left':
		self.direction.x = -1
		if self.player.animations_handler.current_animation != "run_left":
			self.player.animations_handler.current_animation = "run_left"
			self.player.animations_handler.animation_to_change = true
			self.player.animations_handler.loop_animation = true
			self.player.animations_handler.start_run_animation = true
	else:
		# idle
		direction.x = 0
		if not "stand" in self.player.animations_handler.current_animation and self.check_if_player_can_horizontally_move():
			if "right" in self.player.animations_handler.current_animation:
				self.player.animations_handler.current_animation = "stand_right"
				self.player.animations_handler.loop_animation = true
			else:
				self.player.animations_handler.current_animation = "stand_left"
				self.player.animations_handler.loop_animation = true
			self.player.animations_handler.animation_to_change = true


func action_input_side_roll_x_axis(side:String) -> void:
	if side == 'right':
		var button_move_right_press_timestamp:int = round(Time.get_ticks_msec() / 10.0)
		if not self.is_rolling:
			if button_move_right_press_timestamp - self.player.controls_handler.player_roll_action_inputs["right"] <= 50 and self.player.stamina_handler.check_player_has_enough_stamina(self.player.stamina_handler.stamina_costs["side_roll"]):
				self.player.animations_handler.current_animation = "roll_right"
				self.player.animations_handler.loop_animation = false
				self.player.animations_handler.animation_to_change = true
				self.is_rolling = true
				self.player.stamina_handler.stamina_can_refresh = false
				self.player.stamina_handler.cost_player_stamina(self.player.stamina_handler.stamina_costs["side_roll"])
				self.player.animations_handler.side_roll_animation.do_side_roll("right")
				self.player.invulnerable_handler.become_invulnerable(0.5, false)
			else:
				self.player.controls_handler.player_roll_action_inputs["right"] = button_move_right_press_timestamp
	else:
		# left
		var button_move_left_press_timestamp:int = round(Time.get_ticks_msec() / 10.0)
		if not self.is_rolling:
			if button_move_left_press_timestamp - self.player.controls_handler.player_roll_action_inputs["left"] <= 50 and self.player.stamina_handler.check_player_has_enough_stamina(self.player.stamina_handler.stamina_costs["side_roll"]):
				self.player.animations_handler.current_animation = "roll_left"
				self.player.animations_handler.loop_animation = false
				self.player.animations_handler.animation_to_change = true
				self.is_rolling = true
				self.player.stamina_handler.stamina_can_refresh = false
				self.player.stamina_handler.cost_player_stamina(self.player.stamina_handler.stamina_costs["side_roll"])
				self.player.animations_handler.side_roll_animation.do_side_roll("left")
				self.player.invulnerable_handler.become_invulnerable(0.5, false)
			else:
				self.player.controls_handler.player_roll_action_inputs["left"] = button_move_left_press_timestamp


func action_input_jump() -> void:
	if (self.direction.y == 0 and not self.check_if_player_is_vertically_moving() or self.can_coyote_jump) and not (self.is_attacking or self.is_throwing):
		self.direction.y = -1
		self.is_jumping = true
		if self.can_coyote_jump:
			self.is_falling = false
			self.player.velocity.y = 0
			self.can_coyote_jump = false
		if "left" in self.player.animations_handler.current_animation:
			self.player.animations_handler.current_animation = "jump_up_left"
		else:
			self.player.animations_handler.current_animation = "jump_up_right"
		self.player.animations_handler.loop_animation = false
		self.player.animations_handler.animation_to_change = true
		self.player.velocity.y += self.current_jump_velocity
		self.player.controls_handler.jump_button_press_timer.start()


func action_input_duck() -> void:
	if self.direction.x == 0 and not self.check_if_player_is_ducking() and not (self.is_attacking or self.is_throwing or self.is_rolling):
		self.to_duck = true
		self.will_duck = true
		if "left" in self.player.animations_handler.current_animation:
			self.player.animations_handler.current_animation = "to_duck_left"
		else:
			self.player.animations_handler.current_animation = "to_duck_right"
		self.player.animations_handler.loop_animation = false
		self.player.animations_handler.animation_to_change = true
		self.ingame_camera.asc_camera_y_axis = false
		self.ingame_camera.desc_camera_y_axis = true


func action_input_duck_release() -> void:
	if self.is_duck:
		self.is_duck = false
		self.to_duck = true
		self.player.hitbox_handler.resize_hitbox(true, false)
		self.player.weapon_handler.secondary_weapons.adjust_secondary_weapon_start_position('stand')

	elif self.to_duck:
		# play remaining to-duck animation backwards
		var last_frame:int = self.player.animations_handler.animations.frame
		self.player.animations_handler.animations.stop()
		self.player.animations_handler.animations.set_frame(last_frame)
	
	self.will_duck = false
	self.player.animations_handler.loop_animation = false
	self.ingame_camera.desc_camera_y_axis = false
	self.ingame_camera.asc_camera_y_axis = true
	
	if "left" in self.player.animations_handler.current_animation:
		self.player.animations_handler.current_animation = "to_duck_left"
		self.player.animations_handler.animations.play_backwards(self.player.animations_handler.current_animation)
	else:
		self.player.animations_handler.current_animation = "to_duck_right"
		self.player.animations_handler.animations.play_backwards(self.player.animations_handler.current_animation)


func action_input_climb_up_ledge() -> void:
	
	if self.is_jumping:
		self.is_jumping = false
	self.is_jumping = false
	self.is_falling = false
	self.is_climbing_ledge = true
	self.direction.y = 0
	self.player.velocity.y = 0
	self.player.animations_handler.animation_to_change = true
	self.player.animations_handler.loop_animation = false
	if "right" in self.player.animations_handler.current_animation:
		self.player.animations_handler.current_animation = "climb_up_ledge_right"
		self.player.animations_handler.climb_up_ledge_animation.climb_up_ledge("right")
	else:
		self.player.animations_handler.current_animation = "climb_up_ledge_left"
		self.player.animations_handler.climb_up_ledge_animation.climb_up_ledge("left")


func action_input_init_whip_attack() -> void:
	
	# check if player has enough stamina to perform whip-attack. if not -> cancel action
	if not self.player.stamina_handler.check_player_has_enough_stamina(self.player.stamina_handler.stamina_costs["whip_attack"]):
		return
	
	var position:String
	
	if self.is_duck:
		position = "duck"
	else:
		# do standing whip attack if player's on ground
		if self.check_if_player_can_horizontally_move():
			position = "stand"
		else:
			return
	
	self.player.weapon_handler.current_weapon.can_whip_attack_charge = true
	self.direction.x = 0
	self.player.velocity.x = 0
	self.is_attacking = true
	self.player.stamina_handler.stamina_can_refresh = false
	self.player.stamina_handler.cost_player_stamina(self.player.stamina_handler.stamina_costs["whip_attack"])
	self.player.animations_handler.loop_animation = false
	self.player.animations_handler.animation_to_change = true
	if "right" in self.player.animations_handler.current_animation:
		self.player.animations_handler.current_animation = "%s_whip_attack_right_1" % position
	else:
		self.player.animations_handler.current_animation = "%s_whip_attack_left_1" % position


func action_input_use_secondary_weapon() -> void:
	# no use of secondary weapon if player is currently already throwing a secondary weapon or is in duck-transition movement states
	# or is attacking with primary weapon, or is falling/jumping, or isn't in standing or ducking animation
	if self.is_throwing or self.is_attacking or self.will_duck or self.to_duck or self.check_if_player_is_vertically_moving() or not ("stand" in self.player.animations_handler.current_animation or "duck" in self.player.animations_handler.current_animation):
			return
	
	# check if player has enough stamina to perform use of secondary weapon. if not -> cancel action
	if not self.player.stamina_handler.check_player_has_enough_stamina(self.player.stamina_handler.stamina_costs["use_secondary_weapon"]):
		return
	
	self.is_throwing = true
	
	# aim for secondary weapon throw
	var start_pos:Vector2
	var offset_x:int = 10
	var offset_y:int = -12
	var side:String

	if "left" in self.player.animations_handler.current_animation:
		start_pos = Vector2(self.player.secondary_weapon_start_pos.global_position.x - offset_x, self.player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "left"
	else:
		start_pos = Vector2(self.player.secondary_weapon_start_pos.global_position.x + offset_x, self.player.secondary_weapon_start_pos.global_position.y - offset_y)
		side = "right"
	
	self.player.weapon_handler.aim_secondary_weapon(start_pos, side)


###----------METHODS: MOVEMENT EFFECTS (CAUSED BY OTHER SCENES)----------###

func effect_get_slow_down(time:float) -> void:
	"""
	Movement (and animation) speed of player get reduced by half for the amount
	of time passed as argument.
	"""
	self.current_speed = int(self.BASE_SPEED / 2)
	self.player.animations_handler.animations.speed_scale = 0.5
	self.player.animations_handler.animations.material.set_shader_parameter("doFrozenSlowedDown", true)
	await get_tree().create_timer(time).timeout
	self.current_speed = self.BASE_SPEED
	self.player.animations_handler.animations.speed_scale = 1
	self.player.animations_handler.animations.material.set_shader_parameter("doFrozenSlowedDown", false)

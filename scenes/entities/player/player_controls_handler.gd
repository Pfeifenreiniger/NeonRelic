extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var jump_button_press_timer:Timer = $ButtonPressTimers/JumpButtonPressTimer as Timer
@onready var secondary_weapon_used_timer:Timer = $ButtonPressTimers/SecondaryWeaponUsedTimer as Timer

###----------CUSTOM SIGNALS----------###

signal select_primary_weapon(dir:String)
signal select_secondary_weapon(dir:String)


###----------PROPERTIES----------###

# dictionary map for side-roll action input timestamps (for checking double key presses for left/right)
var player_roll_action_inputs:Dictionary = {
	"right" as String : 0 as int,
	"left" as String : 0 as int
}

var secondary_weapon_used:bool = false

var can_select_primary_weapon:bool = true
var can_select_secondary_weapon:bool = true
var is_selecting_primary_weapon:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.jump_button_press_timer.timeout.connect(on_jump_button_press_timer_timeout)
	self.secondary_weapon_used_timer.timeout.connect(on_secondary_weapon_used_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.check_ingame_control_key_inputs()


###----------METHODS: TEST METHODS FOR DEVELOPMENT----------###

func test_player_damage() -> void:
	# TEMP - nur um sich per Knopfdruck Schaden (Keyboard K) zuzufuegen. Wird hinterher entfernt.
	if Input.is_action_just_pressed("ingame_player_damage"):
		self.player.health_handler.get_damage(20)


###----------METHODS: CONTROL KEY INPUT CHECKS----------###

func check_ingame_control_key_inputs() -> void:
	self.check_input_duck_key_release()
	self.check_input_environment_action_key()
	self.check_input_primary_weapon_usage_key()
	self.check_input_secondary_weapon_usage_key()
	self.check_input_primary_weapon_selection_keys()
	self.check_input_secondary_weapon_selection_keys()
	
	Globals.input_toggle_full_screen()
	
	# Temp: test function to inflict player damage via key press
	self.test_player_damage()


func check_input_run_x_axis_key() -> void:
	"""
	Checks if either key for movement to right or left was pressed.
	"""
	if Input.is_action_pressed("right") and not Input.is_action_pressed("ingame_weapon_select"):
		self.player.movement_handler.action_input_run_x_axis('right')
	elif Input.is_action_pressed("left") and not Input.is_action_pressed("ingame_weapon_select"):
		self.player.movement_handler.action_input_run_x_axis('left')
	else:
		self.player.movement_handler.action_input_run_x_axis('idle')


func check_input_side_roll_x_axis_key() -> void:
	"""
	Check roll-action to the right / left.
	"""
	if Input.is_action_just_released("right") and not Input.is_action_pressed("ingame_weapon_select"):
		self.player.movement_handler.action_input_side_roll_x_axis('right')
	elif Input.is_action_just_released("left") and not Input.is_action_pressed("ingame_weapon_select"):
		self.player.movement_handler.action_input_side_roll_x_axis('left')


func check_input_jump_key() -> void:
	# TEMP - Jumps nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not self.is_selecting_primary_weapon:
		if Input.is_action_pressed("up") and not self.player.movement_handler.check_if_player_is_ducking():
			self.player.movement_handler.action_input_jump()
		
		# checks if jump button was just released (-> short jump)
		if Input.is_action_just_released("up") and self.player.movement_handler.is_jumping:
			if not self.jump_button_press_timer.is_stopped():
				self.jump_button_press_timer.stop()


func check_input_duck_key() -> void:
	# TERMP - Ducks nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not self.is_selecting_primary_weapon:
		if Input.is_action_pressed("down") and not self.player.movement_handler.check_if_player_is_vertically_moving():
			self.player.movement_handler.action_input_duck()


func check_input_duck_key_release() -> void:
	"""
	Check if player does not want to duck anymore -> go back to stand idle animation
	"""
	# TEMP - Duck releases nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not self.is_selecting_primary_weapon:
		if self.player.movement_handler.direction.x == 0 and not self.player.movement_handler.is_attacking and not self.player.movement_handler.is_throwing:
			# player has released duck-button or player may have released duck-button in the middle of the duck-attack-animation
			if Input.is_action_just_released("down") or (self.player.movement_handler.is_duck and not Input.is_action_pressed("down")):
				self.player.movement_handler.action_input_duck_release()


func check_input_environment_action_key() -> void:
	if Input.is_action_pressed("ingame_environment_action"):
		# climb up ledges
		if self.player.movement_handler.check_if_player_can_climb_up_ledge():
			self.player.movement_handler.action_input_climb_up_ledge()
		# ToDo - noch andere environment actions via elifs einfuegen (wie Automaten benutzen oder sowas)


func check_input_primary_weapon_usage_key() -> void:
	if Input.is_action_pressed("ingame_primary_weapon_usage"):
		# checks if primary weapon is equiped
		if self.player.weapon_handler.current_weapon == null:
			# no weapon equipted
			return
		# primary weapon is whip
		if 'IS_WHIP' in self.player.weapon_handler.current_weapon:
			if not self.player.movement_handler.is_attacking:
				# initial input
				self.player.movement_handler.action_input_init_whip_attack()
			else:
				if not self.player.weapon_handler.current_weapon.charges_whip_attack and self.player.weapon_handler.current_weapon.can_whip_attack_charge:
					self.player.weapon_handler.current_weapon.charges_whip_attack = true
					self.player.weapon_handler.current_weapon.can_whip_attack_charge = false
		
		elif 'IS_SWORD' in self.player.weapon_handler.current_weapon:
			# ToDo: Schwert als primary weapon implementieren
			pass
	else:
		if self.player.weapon_handler.current_weapon != null:
			if 'IS_WHIP' in self.player.weapon_handler.current_weapon:
				if self.player.weapon_handler.current_weapon.charges_whip_attack:
					self.player.weapon_handler.current_weapon.charges_whip_attack = false
					self.player.weapon_handler.current_weapon.can_whip_attack_charge = false
			elif 'IS_SWORD' in self.player.weapon_handler.current_weapon:
				# ToDo - was passiert, wenn der Spieler das Schwert als prim weapon equipted hat, und die Attack Taste los laesst?
				pass


func check_input_secondary_weapon_usage_key() -> void:
	if Input.is_action_pressed("ingame_secondary_weapon_usage") and not self.secondary_weapon_used:
		self.player.movement_handler.action_input_use_secondary_weapon()
		
	elif Input.is_action_just_released("ingame_secondary_weapon_usage") and not self.secondary_weapon_used and self.player.movement_handler.is_throwing:
		self.secondary_weapon_used = true
		
		# stop aim line animation and get velocity values
		var extra_velocity_y:float = player.weapon_handler.stop_aim_secondary_weapon()
		var extra_velocity_x:float = 200
		
		if extra_velocity_y < 0.75:
			extra_velocity_x *= 1.4
		
		if "left" in self.player.animations_handler.current_animation:
			extra_velocity_x = -1 * extra_velocity_x
		
		extra_velocity_y *= 600
		
		self.player.animations_handler.current_animation = self.player.animations_handler.current_animation.split('_')[0] + "_throw_" + self.player.animations_handler.current_animation.split('_')[-1]
		self.player.animations_handler.loop_animation = false
		self.player.animations_handler.animation_to_change = true
		# connect throw signal
		await self.player.animations_handler.throw_secondary_weapon_frame
		
		# start timer
		self.secondary_weapon_used_timer.start()
		
		# OPT - noch pruefen, ob ueberhaupt eine Secondary Weapon zur Verfuegung steht
		self.player.weapon_handler.use_secondary_weapon(Globals.currently_used_secondary_weapon, Vector2(extra_velocity_x, -extra_velocity_y))


func check_input_primary_weapon_selection_keys() -> void:
	"""
	emits signal to primary weapon selection ui scene if up or down and prim-weapon-select key (currently shift) is pressed
	"""

	if not self.player.movement_handler.is_attacking:
		if Input.is_action_just_pressed("up") and Input.is_action_pressed("ingame_weapon_select") and self.can_select_primary_weapon:
			self.is_selecting_primary_weapon = true
			self.select_primary_weapon.emit("up")
			self.can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			self.can_select_primary_weapon = true
		
		elif Input.is_action_just_pressed("down") and Input.is_action_pressed("ingame_weapon_select"):
			self.is_selecting_primary_weapon = true
			self.select_primary_weapon.emit("down")
			self.can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			self.can_select_primary_weapon = true
	
	#  checks if ingame_weapon_select key (currently shift) is pressed or not 
	if Input.is_action_just_pressed("ingame_weapon_select"):
		self.is_selecting_primary_weapon = true	
	if Input.is_action_just_released("ingame_weapon_select"):
		self.is_selecting_primary_weapon = false


func check_input_secondary_weapon_selection_keys() -> void:
	if not self.player.movement_handler.is_throwing:
		if Input.is_action_just_pressed("left") and Input.is_action_pressed("ingame_weapon_select") and self.can_select_secondary_weapon:
			self.can_select_secondary_weapon = false
			self.select_secondary_weapon.emit("left")
			await get_tree().create_timer(0.25).timeout
			self.can_select_secondary_weapon = true
		
		elif Input.is_action_just_pressed("right") and Input.is_action_pressed("ingame_weapon_select") and self.can_select_secondary_weapon:
			self.can_select_secondary_weapon = false
			self.select_secondary_weapon.emit("right")
			await get_tree().create_timer(0.25).timeout
			self.can_select_secondary_weapon = true


###----------METHODS: CONNECTED SIGNALS----------###

func on_jump_button_press_timer_timeout() -> void:
	var current_large_jump_velocity_addition:int = int(abs(self.player.movement_handler.current_jump_velocity) * self.player.movement_handler.LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER)
	self.player.velocity.y -= current_large_jump_velocity_addition


func on_secondary_weapon_used_timer_timeout() -> void:
	self.secondary_weapon_used = false

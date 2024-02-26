extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------NODE REFERENCES----------###

@onready var jump_button_press_timer:Timer = $ButtonPressTimers/JumpButtonPressTimer
@onready var secondary_weapon_used_timer:Timer = $ButtonPressTimers/SecondaryWeaponUsedTimer

###----------CUSTOM SIGNALS----------###

signal select_primary_weapon(dir:String)


###----------PROPERTIES----------###

# dictionary map for side-roll action input timestamps (for checking double key presses for left/right)
var player_roll_action_inputs:Dictionary = {
	"right" : 0,
	"left" : 0
}

var secondary_weapon_used:bool = false

var can_select_primary_weapon:bool = true
var can_select_secondary_weapon:bool = true


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	jump_button_press_timer.timeout.connect(on_jump_button_press_timer_timeout)
	secondary_weapon_used_timer.timeout.connect(on_secondary_weapon_used_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	check_ingame_control_key_inputs()


###----------METHODS: TEST METHODS FOR DEVELOPMENT----------###

func test_player_damage() -> void:
	"""
	Test function to inflict player damage. Will be removed later in development process.
	Keyboard K
	"""
	if Input.is_action_just_pressed("ingame_player_damage"):
		player.health_handler.get_damage(20)


###----------METHODS: CONTROL KEY INPUT CHECKS----------###

func check_ingame_control_key_inputs() -> void:
	check_input_duck_key_release()
	check_input_environment_action_key()
	check_input_primary_weapon_usage_key()
	check_input_secondary_weapon_usage_key()
	check_input_primary_weapon_selection_keys()
	check_input_secondary_weapon_selection_keys()
	
	Globals.input_toggle_full_screen()
	
	# Temp: test function to inflict player damage via key press
	test_player_damage()


func check_input_run_x_axis_key() -> void:
	"""
	Checks if either key for movement to right or left was pressed.
	"""
	if Input.is_action_pressed("right") and not Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_run_x_axis('right')
	elif Input.is_action_pressed("left") and not Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_run_x_axis('left')
	else:
		player.movement_handler.action_input_run_x_axis('idle')


func check_input_side_roll_x_axis_key() -> void:
	# check roll-action to right / left
	if Input.is_action_just_released("right") and not Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_side_roll_x_axis('right')
	elif Input.is_action_just_released("left") and not Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_side_roll_x_axis('left')


func check_input_jump_key() -> void:
	# Temp: Jumps nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not Input.is_action_pressed("ingame_weapon_select"):
		
		if Input.is_action_pressed("up") and not player.movement_handler.check_if_player_is_ducking():
			player.movement_handler.action_input_jump()
		
		# checks if jump button was just released (-> short jump)
		if Input.is_action_just_released("up") and player.movement_handler.is_jumping:
			if not jump_button_press_timer.is_stopped():
				jump_button_press_timer.stop()


func check_input_duck_key() -> void:
	# Temp: Ducks nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not Input.is_action_pressed("ingame_weapon_select"):
		if Input.is_action_pressed("down") and not player.movement_handler.check_if_player_is_vertically_moving():
			player.movement_handler.action_input_duck()


func check_input_duck_key_release() -> void:
	"""
	Check if player does not want to duck anymore -> go back to stand idle animation
	"""
	
	# Temp: Duck releases nur, wenn nicht gerade eine primary weapon in der ui ausgewaehlt wird. Muss spaeter besser geloest werden
	if not Input.is_action_pressed("ingame_weapon_select"):
		if player.movement_handler.direction.x == 0 and not player.movement_handler.is_attacking and not player.movement_handler.is_throwing:
			# player has released duck-button or player may have released duck-button in the middle of the duck-attack-animation
			if Input.is_action_just_released("down") or (player.movement_handler.is_duck and not Input.is_action_pressed("down")):
				player.movement_handler.action_input_duck_release()


func check_input_environment_action_key() -> void:
	if Input.is_action_pressed("ingame_environment_action"):
		# climb up ledges
		if player.movement_handler.check_if_player_can_climb_up_ledge():
			player.movement_handler.action_input_climb_up_ledge()
		# ToDo: noch andere environment actions via elifs einfuegen (wie Automaten benutzen oder sowas)


func check_input_primary_weapon_usage_key() -> void:
	if Input.is_action_pressed("ingame_primary_weapon_usage"):
		# checks if primary weapon is equiped
		if player.weapon_handler.current_weapon == null:
			# no weapon equipted
			return
			#player.weapon_handler.select_current_weapon("whip")
		# primary weapon is whip
		if 'IS_WHIP' in player.weapon_handler.current_weapon:
			if not player.movement_handler.is_attacking:
				# initial input
				player.movement_handler.action_input_init_whip_attack()
			else:
				if not player.weapon_handler.current_weapon.charges_whip_attack and player.weapon_handler.current_weapon.can_whip_attack_charge:
					player.weapon_handler.current_weapon.charges_whip_attack = true
					player.weapon_handler.current_weapon.can_whip_attack_charge = false
		
		elif 'IS_SWORD' in player.weapon_handler.current_weapon:
			# ToDo: Schwert als primary weapon implementieren
			pass
	else:
		if player.weapon_handler.current_weapon != null:
			if 'IS_WHIP' in player.weapon_handler.current_weapon:
				if player.weapon_handler.current_weapon.charges_whip_attack:
					player.weapon_handler.current_weapon.charges_whip_attack = false
					player.weapon_handler.current_weapon.can_whip_attack_charge = false
			elif 'IS_SWORD' in player.weapon_handler.current_weapon:
				# ToDo: was passiert, wenn der Spieler das Schwert als prim weapon equipted hat, und die Attack Taste los laesst?
				pass


func check_input_secondary_weapon_usage_key() -> void:
	if Input.is_action_pressed("ingame_secondary_weapon_usage") and not secondary_weapon_used:
		player.movement_handler.action_input_use_secondary_weapon()
		
	elif Input.is_action_just_released("ingame_secondary_weapon_usage") and not secondary_weapon_used and player.movement_handler.is_throwing:
		secondary_weapon_used = true
		
		# stop aim line animation and get velocity values
		var extra_velocity_y:float = player.weapon_handler.stop_aim_secondary_weapon()
		var extra_velocity_x:float = 200
		
		if extra_velocity_y < 0.75:
			extra_velocity_x *= 1.4
		
		if "left" in player.animations_handler.current_animation:
			extra_velocity_x = -1 * extra_velocity_x
		
		extra_velocity_y *= 600
		
		player.animations_handler.current_animation = player.animations_handler.current_animation.split('_')[0] + "_throw_" + player.animations_handler.current_animation.split('_')[-1]
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true
		# connect throw signal
		await player.animations_handler.throw_secondary_weapon_frame
		
		# start timer
		secondary_weapon_used_timer.start()
		
		# Temp: Weapon Name als Variable (wird in der UI vom Spieler ausgewaehlt). zZt hard-coded als "fire_grenade"
		player.weapon_handler.use_secondary_weapon("fire_grenade", Vector2(extra_velocity_x, -extra_velocity_y))


func check_input_primary_weapon_selection_keys() -> void:
	"""
	emits signal to primary weapon selection ui scene if up or down and prim-weapon-select key (currently shift) is pressed
	"""

	if not player.movement_handler.is_attacking:
		if Input.is_action_just_pressed("up") and Input.is_action_pressed("ingame_weapon_select") and can_select_primary_weapon:
			select_primary_weapon.emit("up")
			can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			can_select_primary_weapon = true
		
		elif Input.is_action_just_pressed("down") and Input.is_action_pressed("ingame_weapon_select"):
			select_primary_weapon.emit("down")
			can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			can_select_primary_weapon = true


func check_input_secondary_weapon_selection_keys() -> void:
	# NEXT: Auswahlmoeglichkeiten fuer secondary weapons schaffen (ui, etc)
	if not player.movement_handler.is_throwing:
		if Input.is_action_just_pressed("left") and Input.is_action_pressed("ingame_weapon_select") and can_select_secondary_weapon:
			print("Waehle eine secondary weapon nach links aus...")
		
		elif Input.is_action_just_pressed("right") and Input.is_action_pressed("ingame_weapon_select") and can_select_secondary_weapon:
			print("Waehle eine secondary weapon nach rechts aus...")


###----------METHODS: CONNECTED SIGNALS----------###

func on_jump_button_press_timer_timeout() -> void:
	var current_large_jump_velocity_addition:int = int(abs(player.movement_handler.current_jump_velocity) * player.movement_handler.LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER)
	player.velocity.y -= current_large_jump_velocity_addition


func on_secondary_weapon_used_timer_timeout() -> void:
	secondary_weapon_used = false

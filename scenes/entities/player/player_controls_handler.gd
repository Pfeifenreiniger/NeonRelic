extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------NODE REFERENCES----------###

@onready var jump_button_press_timer:Timer = $ButtonPressTimers/JumpButtonPressTimer
@onready var secondary_weapon_used_timer:Timer = $ButtonPressTimers/SecondaryWeaponUsedTimer

###----------PROPERTIES----------###

# dictionary map for side-roll action input timestamps (for checking double key presses for left/right)
var player_roll_action_inputs:Dictionary = {
	"right" : 0,
	"left" : 0
}

var secondary_weapon_used = false

###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	jump_button_press_timer.timeout.connect(on_jump_button_press_timer_timeout)
	secondary_weapon_used_timer.timeout.connect(on_secondary_weapon_used_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta) -> void:
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
	check_input_climb_up_ledge_key()
	check_input_whip_attack_key()
	check_input_secondary_weapon_usage_key()
	# test function to inflict player damage via key press
	test_player_damage()


func check_input_run_x_axis_key() -> void:
	"""
	Checks if either key for movement to right or left was pressed.
	"""
	if Input.is_action_pressed("ingame_move_right"):
		player.movement_handler.action_input_run_x_axis('right')
	elif Input.is_action_pressed("ingame_move_left"):
		player.movement_handler.action_input_run_x_axis('left')
	else:
		player.movement_handler.action_input_run_x_axis('idle')


func check_input_side_roll_x_axis_key() -> void:
	# check roll-action to right / left
	if Input.is_action_just_released("ingame_move_right"):
		player.movement_handler.action_input_side_roll_x_axis('right')
	elif Input.is_action_just_released("ingame_move_left"):
		player.movement_handler.action_input_side_roll_x_axis('left')


func check_input_jump_key() -> void:
	if Input.is_action_pressed("ingame_jump") and not player.movement_handler.check_if_player_is_ducking():
		player.movement_handler.action_input_jump()
	
	# checks if jump button was just released (-> short jump)
	if Input.is_action_just_released("ingame_jump") and player.movement_handler.is_jumping:
		if not jump_button_press_timer.is_stopped():
			jump_button_press_timer.stop()


func check_input_duck_key() -> void:
	if Input.is_action_pressed("ingame_duck") and not player.movement_handler.check_if_player_is_vertically_moving():
		player.movement_handler.action_input_duck()


func check_input_duck_key_release() -> void:
	# check if player does not want to duck anymore
	if player.movement_handler.direction.x == 0 and not player.movement_handler.is_attacking and not player.movement_handler.is_throwing:
		# player has released duck-button or player may have released duck-button in the middle of the duck-attack-animation
		if Input.is_action_just_released("ingame_duck") or (player.movement_handler.is_duck and not Input.is_action_pressed("ingame_duck")):
			player.movement_handler.action_input_duck_release()


func check_input_climb_up_ledge_key() -> void:
	if Input.is_action_pressed("ingame_climb_up_ledge"):
		player.movement_handler.action_input_climb_up_ledge()


func check_input_whip_attack_key() -> void:
	if Input.is_action_pressed("ingame_whip_attack"):
		# checks if whip is equiped
		if player.weapon_handler.current_weapon == null or not 'IS_WHIP' in player.weapon_handler.current_weapon:
			player.weapon_handler.select_current_weapon("whip")
		if not player.movement_handler.is_attacking:
			# initial input
			player.movement_handler.action_input_init_whip_attack()
		else:
			if not player.weapon_handler.current_weapon.charges_whip_attack and player.weapon_handler.current_weapon.can_whip_attack_charge:
				player.weapon_handler.current_weapon.charges_whip_attack = true
				player.weapon_handler.current_weapon.can_whip_attack_charge = false
	else:
		if player.weapon_handler.current_weapon != null and 'IS_WHIP' in player.weapon_handler.current_weapon:
			if player.weapon_handler.current_weapon.charges_whip_attack:
				player.weapon_handler.current_weapon.charges_whip_attack = false
				player.weapon_handler.current_weapon.can_whip_attack_charge = false


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
		
		# ToDo: Wurfanimation starten --> wenn Animation fertig -> Timer starten
		player.animations_handler.current_animation = player.animations_handler.current_animation.split('_')[0] + "_throw_" + player.animations_handler.current_animation.split('_')[-1]
		player.animations_handler.loop_animation = false
		player.animations_handler.animation_to_change = true
		# connect throw signal
		await player.animations_handler.throw_secondary_weapon_frame
		
		# start timer
		secondary_weapon_used_timer.start()
		# ToDo: Weapon Name als Variable (wird in der UI vom Spieler ausgewaehlt)
		
		player.weapon_handler.use_secondary_weapon("fire_grenade", Vector2(extra_velocity_x, -extra_velocity_y))



###----------CONNECTED SIGNALS----------###

func on_jump_button_press_timer_timeout() -> void:
	var current_large_jump_velocity_addition:int = int(abs(player.movement_handler.current_jump_velocity) * player.movement_handler.LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER)
	player.velocity.y -= current_large_jump_velocity_addition


func on_secondary_weapon_used_timer_timeout() -> void:
	secondary_weapon_used = false

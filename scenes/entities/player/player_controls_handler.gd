extends Node
class_name PlayerControlsHandler

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var jump_button_press_timer:Timer = $ButtonPressTimers/JumpButtonPressTimer as Timer
@onready var secondary_weapon_used_timer:Timer = $ButtonPressTimers/SecondaryWeaponUsedTimer as Timer


###----------CUSTOM SIGNALS----------###

signal select_primary_weapon(direction:String)
signal select_secondary_weapon(direction:String)


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
	jump_button_press_timer.timeout.connect(on_jump_button_press_timer_timeout)
	secondary_weapon_used_timer.timeout.connect(on_secondary_weapon_used_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	check_ingame_control_key_inputs()


###----------METHODS: TEST METHODS FOR DEVELOPMENT----------###

func test_player_damage() -> void:
	# TEMP - nur um sich per Knopfdruck Schaden (Keyboard K) zuzufuegen. Wird hinterher entfernt.
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
	check_input_block()
	check_input_block_release()
	
	Globals.input_toggle_full_screen()
	
	# TEMP - um sich probehalber als Spieler Schaden zuzufuegen
	test_player_damage()


func check_input_run_x_axis_key() -> void:
	## Checks if either key for movement to right or left was pressed.
	
	var direction:String
	if Input.is_action_pressed("right")\
	&& !Input.is_action_pressed("ingame_weapon_select"):
		direction = "right"
	elif Input.is_action_pressed("left")\
	&& !Input.is_action_pressed("ingame_weapon_select"):
		direction = "left"
	else:
		direction = "idle"
	player.movement_handler.action_input_run_x_axis(direction)


func check_input_side_roll_x_axis_key() -> void:
	## Check roll-action to the right / left.
	
	if Input.is_action_just_released("right")\
	&& !Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_side_roll_x_axis('right')
	elif Input.is_action_just_released("left")\
	&& !Input.is_action_pressed("ingame_weapon_select"):
		player.movement_handler.action_input_side_roll_x_axis('left')


func check_input_jump_key() -> void:
	if !is_selecting_primary_weapon:
		if Input.is_action_pressed("up")\
		&& !player.movement_handler.check_if_player_is_ducking():
			player.movement_handler.action_input_jump()
		
		# checks if jump button was just released (-> short jump)
		if Input.is_action_just_released("up")\
		&& player.movement_handler.is_jumping:
			if !jump_button_press_timer.is_stopped():
				jump_button_press_timer.stop()


func check_input_duck_key() -> void:
	if !is_selecting_primary_weapon:
		if Input.is_action_pressed("down")\
		&& !player.movement_handler.check_if_player_is_vertically_moving():
			player.movement_handler.action_input_duck()


func check_input_duck_key_release() -> void:
	## Check if player does not want to duck anymore -> go back to stand idle animation
	
	if !is_selecting_primary_weapon:
		if player.movement_handler.direction.x == 0\
		&& !player.movement_handler.is_attacking\
		&& !player.movement_handler.is_throwing\
		&& !player.movement_handler.is_blocking:
			# player has released duck-button or player may have released duck-button in the middle of the duck-attack-animation
			if Input.is_action_just_released("down")\
			|| (player.movement_handler.is_duck && !Input.is_action_pressed("down")):
				player.movement_handler.action_input_duck_release()


func check_input_environment_action_key() -> void:
	if Input.is_action_pressed("ingame_environment_action"):
		# climb up ledges
		if player.movement_handler.check_if_player_can_climb_up_ledge():
			player.movement_handler.action_input_climb_up_ledge()
		# ToDo - noch andere environment actions via elifs einfuegen (wie Automaten benutzen oder sowas)


func check_input_primary_weapon_usage_key() -> void:
	if player.movement_handler.is_blocking:
		return
	
	if Input.is_action_pressed("ingame_primary_weapon_usage"):
		# checks if primary weapon is equiped
		if player.weapon_handler.current_weapon == null:
			# no weapon equipted
			return
		# primary weapon is whip
		if 'IS_WHIP' in player.weapon_handler.current_weapon:
			if !player.movement_handler.is_attacking:
				# initial input
				player.movement_handler.action_input_init_whip_attack()
			else:
				if !player.weapon_handler.current_weapon.charges_whip_attack\
				&& player.weapon_handler.current_weapon.can_whip_attack_charge:
					player.weapon_handler.current_weapon.charges_whip_attack = true
					player.weapon_handler.current_weapon.can_whip_attack_charge = false
		
		elif 'IS_SWORD' in player.weapon_handler.current_weapon:
			if !player.movement_handler.is_attacking:
				player.movement_handler.action_input_init_sword_attack()
	else:
		# if player charges whip weapon and releases attack key -> start attack
		if player.weapon_handler.current_weapon != null\
		&& 'IS_WHIP' in player.weapon_handler.current_weapon:
			if player.weapon_handler.current_weapon.charges_whip_attack:
				player.weapon_handler.current_weapon.charges_whip_attack = false
				player.weapon_handler.current_weapon.can_whip_attack_charge = false
	
	if Input.is_action_just_pressed("ingame_primary_weapon_usage"):
		# sword combo
		if 'IS_SWORD' in player.weapon_handler.current_weapon:
			if player.animations_handler.sword_attack_animation.is_combo_time_window: # pressed within time window
				var last_combo_phase:int = int(player.animations_handler.current_animation.split('_')[-1])
				if last_combo_phase < 3:
					player.movement_handler.action_input_combo_sword_attack(last_combo_phase)


func check_input_secondary_weapon_usage_key() -> void:
	if player.movement_handler.is_blocking:
		return
	
	if Input.is_action_pressed("ingame_secondary_weapon_usage")\
	&& !secondary_weapon_used:
		player.movement_handler.action_input_use_secondary_weapon()
		
	elif Input.is_action_just_released("ingame_secondary_weapon_usage")\
	&& !secondary_weapon_used\
	&& player.movement_handler.is_throwing:
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
		
		# OPT - noch pruefen, ob ueberhaupt eine Secondary Weapon zur Verfuegung steht
		player.weapon_handler.use_secondary_weapon(Globals.currently_used_secondary_weapon, Vector2(extra_velocity_x, -extra_velocity_y))


func check_input_primary_weapon_selection_keys() -> void:
	## emits signal to primary weapon selection ui scene if up or down and prim-weapon-select key (currently shift) is pressed
	
	if !player.movement_handler.is_attacking:
		if Input.is_action_just_pressed("up")\
		&& Input.is_action_pressed("ingame_weapon_select")\
		&& can_select_primary_weapon:
			is_selecting_primary_weapon = true
			select_primary_weapon.emit("up")
			can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			can_select_primary_weapon = true
		
		elif Input.is_action_just_pressed("down")\
		&& Input.is_action_pressed("ingame_weapon_select"):
			is_selecting_primary_weapon = true
			select_primary_weapon.emit("down")
			can_select_primary_weapon = false
			await get_tree().create_timer(0.5).timeout
			can_select_primary_weapon = true
	
	#  checks if ingame_weapon_select key (currently shift) is pressed or not 
	if Input.is_action_just_pressed("ingame_weapon_select"):
		is_selecting_primary_weapon = true
	if Input.is_action_just_released("ingame_weapon_select"):
		is_selecting_primary_weapon = false


func check_input_secondary_weapon_selection_keys() -> void:
	if !player.movement_handler.is_throwing:
		if Input.is_action_just_pressed("left")\
		&& Input.is_action_pressed("ingame_weapon_select")\
		&& can_select_secondary_weapon:
			can_select_secondary_weapon = false
			select_secondary_weapon.emit("left")
			await get_tree().create_timer(0.25).timeout
			can_select_secondary_weapon = true
		
		elif Input.is_action_just_pressed("right")\
		&& Input.is_action_pressed("ingame_weapon_select")\
		&& can_select_secondary_weapon:
			can_select_secondary_weapon = false
			select_secondary_weapon.emit("right")
			await get_tree().create_timer(0.25).timeout
			can_select_secondary_weapon = true


func check_input_block() -> void:
	if Input.is_action_just_pressed("ingame_block"):
		player.movement_handler.action_input_block()


func check_input_block_release() -> void:
	if Input.is_action_just_released("ingame_block"):
		player.movement_handler.action_input_block_release()


###----------METHODS: CONNECTED SIGNALS----------###

func on_jump_button_press_timer_timeout() -> void:
	var current_large_jump_velocity_addition:int = int(abs(player.movement_handler.current_jump_velocity) * player.movement_handler.LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER)
	player.velocity.y -= current_large_jump_velocity_addition


func on_secondary_weapon_used_timer_timeout() -> void:
	secondary_weapon_used = false

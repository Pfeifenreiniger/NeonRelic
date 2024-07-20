# globally accessable Script which will automatically be intatiated by every scene

extends Node


###----------PROPERTIES----------###

### game settings ###
var is_full_screen:bool = false

### ingame values ###
# player related #
# ToDo - Player Stats spaeter in lokale DB schreiben und beim Start/Laden daraus lesen
var player_max_health:int = 100
var player_current_health:int = player_max_health

var player_max_stamina:int = 100
var player_current_stamina:int = player_max_stamina

var currently_used_primary_weapon:String = "whip" # at first start-up -> use whip as primary weapon
var currently_used_secondary_weapon:String = "fire_grenade" # at first start-up -> use fire grenade as secondary weapon

# others #

# TODO - andere ingame Variablen fuer den Global Scope finden


###----------METHODS: SCREEN PROPERTIES----------###

func input_toggle_full_screen() -> void:
	# Keyboard button press to switch between full-screen and windowed game window
	
	if Input.is_action_just_pressed("toggle_full_screen"):
		if !is_full_screen:
			# set mode to full screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			is_full_screen = true
		else:
			# set mode to windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			is_full_screen = false

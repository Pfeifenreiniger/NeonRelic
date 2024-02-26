# globally accessable Script which will automatically be intatiated by every scene

extends Node


###----------PROPERTIES----------###

# game settings
var is_full_screen:bool = false

# ingame values
var currently_used_primary_weapon:String = "whip" # at first start-up -> use whip as primary weapon

###----------METHODS: SCREEN PROPERTIES----------###

func input_toggle_full_screen() -> void:
	"""
	Keyboard button press to switch between full-screen and windowed game window
	"""
	
	if Input.is_action_just_pressed("toggle_full_screen"):
		if not is_full_screen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			is_full_screen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			is_full_screen = false

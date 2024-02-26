# globally accessable Script which will automatically be intatiated by every scene

extends Node


###----------PROPERTIES----------###

var is_full_screen:bool = false


###----------METHODS: SCREEN PROPERTIES----------###

func toggle_full_screen() -> void:
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

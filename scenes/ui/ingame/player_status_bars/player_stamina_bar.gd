extends BasePlayerStatus


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	super._ready()
	# overrides properties of base scene
	tint_under_color = Color(0.427, 0.565, 0.276, 1)
	tint_over_color = Color(0, 0.902, 0, 1)
	tint_progress_color = Color(0.736, 1, 0.626, 1)
	progress_bar = $MarginContainer/StaminaProgressBar

###----------METHODS: PER FRAME CALLED----------###

func _process(_delta):
	check_current_player_stamina()


###----------METHODS: CHECK CURRENT STAMINA PROPERTY----------###

func check_current_player_stamina():
	# check for stamina progress bar
	# max value
	var max_player_stamina:float = player.stamina_handler.max_stamina
	var max_stamina_bar_value:int = int(progress_bar.max_value)
	if max_player_stamina != max_stamina_bar_value:
		progress_bar.max_value = max_player_stamina

	# current value
	var current_player_stamina:float = player.stamina_handler.current_stamina
	var current_stamina_bar_value:int = int(progress_bar.value)
	if current_player_stamina != current_stamina_bar_value:
		if current_stamina_bar_value > current_player_stamina: # -> player lost stamina
			apply_tint_colors_to_progress_bar()
		progress_bar.value = current_player_stamina

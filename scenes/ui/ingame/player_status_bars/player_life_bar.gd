extends BasePlayerStatus


###----------NODE REFERENCES----------###

@onready var heart_animation:AnimatedSprite2D = $MarginContainer/HeartAnimation as AnimatedSprite2D


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	super._ready()
	# overrides properties of base scene
	self.tint_under_color = Color(0.871, 0.267, 0, 1)
	self.tint_over_color = Color(1, 0, 0, 1)
	self.tint_progress_color = Color(1, 0, 0, 1)
	self.progress_bar = $MarginContainer/LifeProgressBar as TextureProgressBar
	
	self.start_heart_animation()


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.check_current_player_health()


###----------METHODS: CHECK CURRENT HEALTH PROPERTY----------###

func check_current_player_health() -> void:
	# check for life progress bar
	var max_player_health:float = Globals.player_max_health
	var max_life_bar_value:int = int(self.progress_bar.max_value)
	if max_player_health != max_life_bar_value:
		self.progress_bar.max_value = int(max_player_health)
	
	var current_player_health:float = Globals.player_current_health
	var current_life_bar_value:int = int(progress_bar.value)
	if current_player_health != current_life_bar_value:
		if current_life_bar_value > current_player_health: # -> player lost health
			self.apply_tint_colors_to_progress_bar()
		self.progress_bar.value = current_player_health

	# check for heart beat animation
	var do_speed_scale:int
	var current_player_health_in_percent:int = round((current_player_health / max_player_health) * 100)
	
	if current_player_health_in_percent < 10:
		do_speed_scale = 5
	elif current_player_health_in_percent < 20:
		do_speed_scale = 4
	elif current_player_health_in_percent < 40:
		do_speed_scale = 3
	elif current_player_health_in_percent < 70:
		do_speed_scale = 2
	else:
		do_speed_scale = 1

	if self.heart_animation.speed_scale != do_speed_scale:
		self.heart_animation.set_speed_scale(do_speed_scale)


###----------METHODS: UI ANIMATIONS----------###

func start_heart_animation() -> void:
	self.heart_animation.play("heartbeat")

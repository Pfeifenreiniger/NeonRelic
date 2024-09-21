extends BasePlayerStatus


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var ingame_ui:IngameUi = get_tree().get_first_node_in_group('ingame_ui') as IngameUi

var player_low_health_overlay_scene:PackedScene = preload("res://scenes/ui/ingame/effects/player_low_health_overlay/player_low_health_overlay.tscn") as PackedScene
var player_low_health_overlay_instance:TextureRect = null


###----------NODE REFERENCES----------###

@onready var heart_animation:AnimatedSprite2D = $MarginContainer/HeartAnimation as AnimatedSprite2D


###----------PROPERTIES----------###

var current_player_health_in_percent:float = 100


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	super._ready()
	
	player.health_handler.update_current_player_health_in_percent.connect(_on_update_current_player_health_in_percent)
	
	# overrides properties of base scene
	tint_under_color = Color(0.871, 0.267, 0, 1)
	tint_over_color = Color(1, 0, 0, 1)
	tint_progress_color = Color(1, 0, 0, 1)
	progress_bar = $MarginContainer/LifeProgressBar as TextureProgressBar
	
	_start_heart_animation()


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	_check_current_player_health()


###----------METHODS: CHECK CURRENT HEALTH PROPERTY----------###

func _check_current_player_health() -> void:
	
	# check for life progress bar
	var max_player_health:float = Globals.player_max_health
	var max_life_bar_value:int = int(progress_bar.max_value)
	if max_player_health != max_life_bar_value:
		progress_bar.max_value = int(max_player_health)
	
	var current_player_health:float = Globals.player_current_health
	var current_life_bar_value:int = int(progress_bar.value)
	if current_player_health != current_life_bar_value:
		if current_life_bar_value > current_player_health: # -> player lost health
			apply_tint_colors_to_progress_bar()
		progress_bar.value = current_player_health

	# check for heart beat animation
	var do_speed_scale:int
	
	if current_player_health_in_percent < 10.:
		do_speed_scale = 5
		_start_player_low_health_overlay_animation()
	elif current_player_health_in_percent < 20.:
		do_speed_scale = 4
		_start_player_low_health_overlay_animation()
	elif current_player_health_in_percent < 40.:
		do_speed_scale = 3
		_end_player_low_health_overlay_animation()
	elif current_player_health_in_percent < 70.:
		do_speed_scale = 2
		_end_player_low_health_overlay_animation()
	else:
		do_speed_scale = 1
		_end_player_low_health_overlay_animation()

	if heart_animation.speed_scale != do_speed_scale:
		heart_animation.set_speed_scale(do_speed_scale)


###----------METHODS: UI ANIMATIONS----------###

func _start_heart_animation() -> void:
	heart_animation.play("heartbeat")


func _start_player_low_health_overlay_animation() -> void:
	if player_low_health_overlay_instance != null:
		return
	
	player_low_health_overlay_instance = player_low_health_overlay_scene.instantiate() as TextureRect
	
	ingame_ui.get_node("Effects").add_child(player_low_health_overlay_instance)


func _end_player_low_health_overlay_animation() -> void:
	if player_low_health_overlay_instance == null:
		return
	
	player_low_health_overlay_instance.queue_free()
	player_low_health_overlay_instance = null


###----------CONNECTED SIGNALS----------###

func _on_update_current_player_health_in_percent(percentage:float) -> void:
	current_player_health_in_percent = percentage

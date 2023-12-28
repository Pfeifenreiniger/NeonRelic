extends CanvasLayer

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var life_progress_bar:TextureProgressBar = $LifeBar/LifeProgressBar
@onready var heart_animation:AnimatedSprite2D = $LifeBar/HeartAnimation


func _ready():
	start_heart_animation()


func _process(_delta):
	check_current_player_health()


func check_current_player_health():
	# check for life progress bar
	var max_player_health:float = player.max_health
	var max_life_bar_value:int = life_progress_bar.max_value
	if max_player_health != max_life_bar_value:
		life_progress_bar.max_value = max_player_health
	
	var current_player_health:float = player.current_health
	var current_life_bar_value:int = life_progress_bar.value
	if current_player_health != current_life_bar_value:
		life_progress_bar.value = current_player_health

	# check for heart beat animation
	var do_speed_scale:float
	var current_player_health_in_percent:int = (current_player_health / max_player_health) * 100
	
	if current_player_health_in_percent < 10:
		do_speed_scale = 2
	elif current_player_health_in_percent < 20:
		do_speed_scale = 1.8
	elif current_player_health_in_percent < 40:
		do_speed_scale = 1.5
	elif current_player_health_in_percent < 70:
		do_speed_scale = 2
	else:
		do_speed_scale = 1

	if heart_animation.speed_scale != do_speed_scale:
		heart_animation.speed_scale = do_speed_scale


func start_heart_animation():
	heart_animation.play("heartbeat")

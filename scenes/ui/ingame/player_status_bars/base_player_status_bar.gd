extends Node
class_name BasePlayerStatus

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###------NODE REFERENCES------###

@onready var progress_bar:TextureProgressBar
@onready var timer_tint_progress_bar_colors:Timer = $TimerTintProgressBarColors

###----------PROPERTIES----------###

var tint_under_color:Color
var tint_over_color:Color
var tint_progress_color:Color


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	timer_tint_progress_bar_colors.timeout.connect(on_timer_tint_progress_bar_colors_timeout)


###----------METHODS----------###

func apply_tint_colors_to_progress_bar() -> void:
	progress_bar.tint_under = tint_under_color
	progress_bar.tint_over = tint_over_color
	progress_bar.tint_progress = tint_progress_color
	timer_tint_progress_bar_colors.start()


func reset_tint_colors_at_progress_bar() -> void:
	var no_tint_color:Color = Color(1, 1, 1, 1)
	progress_bar.tint_under = no_tint_color
	progress_bar.tint_over = no_tint_color
	progress_bar.tint_progress = no_tint_color


###----------CONNECTED SIGNALS----------###

func on_timer_tint_progress_bar_colors_timeout() -> void:
	reset_tint_colors_at_progress_bar()

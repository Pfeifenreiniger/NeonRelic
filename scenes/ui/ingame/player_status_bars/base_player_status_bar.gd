extends Node
class_name BasePlayerStatus

###----------SCENE REFERENCES----------###

#@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###------NODE REFERENCES------###

@onready var progress_bar:TextureProgressBar
@onready var timer_tint_progress_bar_colors:Timer = $TimerTintProgressBarColors as Timer

###----------PROPERTIES----------###

var tint_under_color:Color
var tint_over_color:Color
var tint_progress_color:Color


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.timer_tint_progress_bar_colors.timeout.connect(self._on_timer_tint_progress_bar_colors_timeout)


###----------METHODS----------###

func apply_tint_colors_to_progress_bar() -> void:
	self.progress_bar.tint_under = tint_under_color
	self.progress_bar.tint_over = tint_over_color
	self.progress_bar.tint_progress = tint_progress_color
	self.timer_tint_progress_bar_colors.start()


func reset_tint_colors_at_progress_bar() -> void:
	var no_tint_color:Color = Color(1, 1, 1, 1)
	self.progress_bar.tint_under = no_tint_color
	self.progress_bar.tint_over = no_tint_color
	self.progress_bar.tint_progress = no_tint_color


###----------CONNECTED SIGNALS----------###

func _on_timer_tint_progress_bar_colors_timeout() -> void:
	self.reset_tint_colors_at_progress_bar()

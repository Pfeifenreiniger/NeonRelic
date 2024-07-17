extends CanvasLayer
class_name ScreenFlashComponent


###----------NODE REFERENCES----------###

@onready var color_rect: ColorRect = $ColorRect as ColorRect


###----------PROPERTIES----------###

@export var color:Color
var color_no_alpha:Color
var color_medium_alpha:Color


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	color_no_alpha = color
	color_no_alpha.a = 0
	
	color_medium_alpha = color
	color_medium_alpha.a = .33
	
	color_rect.color = color_no_alpha


###----------METHODS----------###

func play_flash_animation() -> void:
	var tween:Tween = get_tree().create_tween()
	
	tween.tween_property(color_rect, "color", color_medium_alpha, .25)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(color_rect, "color", color_no_alpha, .25)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CIRC)
	
	await tween.finished
	
	queue_free()

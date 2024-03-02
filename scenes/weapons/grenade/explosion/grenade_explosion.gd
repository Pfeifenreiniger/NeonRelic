extends AnimatedSprite2D


###----------CUSTOM SIGNALS----------###

signal hide_grenade
signal destroy_grenade


###----------PROPERTIES----------###

var grenade_hidden:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


###----------METHODS: PER FRAME CALLED----------###

func _process(delta: float) -> void:
	check_to_hide_grenade()


###----------METHODS----------###

func check_to_hide_grenade() -> void:
	if not grenade_hidden and frame >= 2:
		hide_grenade.emit()
		grenade_hidden = true


###----------CONNECTED SIGNALS----------###

func _on_animation_finished():
	destroy_grenade.emit()

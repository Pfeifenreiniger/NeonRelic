extends Sprite2D

###----------CUSTOM SIGNALS----------###

signal toggle_active(active:bool)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var label: Label = $Label as Label
@onready var gray_off: ColorRect = $GrayOff as ColorRect


###----------PROPERTIES----------###

var cooldown_time_left:int


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	player.special_abilities_handler.all_or_nothing_ability.update_remaining_cooldown_time.connect(_on_update_remaining_cooldown_time)
	gray_off.visible = false
	label.text = ''


###----------METHODS----------###

func _update_cooldown_label() -> void:
	var text = str(cooldown_time_left) if cooldown_time_left > 0 else ""
	label.text = text


func _gray_off_when_cooldown() -> void:
	if cooldown_time_left == 0:
		if gray_off.visible:
			gray_off.visible = false
		return

	if !gray_off.visible:
		gray_off.visible = true


###----------CONNECTED SIGNALS----------###

func _on_update_remaining_cooldown_time(time_left:int) -> void:
	cooldown_time_left = time_left
	_update_cooldown_label()
	_gray_off_when_cooldown()


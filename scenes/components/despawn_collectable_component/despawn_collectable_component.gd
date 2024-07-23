extends Node
class_name DespawnCollectableComponent


###----------CUSTOM SIGNALS----------###

signal despawn_animation_done


###----------SCENE REFERENCES----------###

var collectable_sprite:Sprite2D


###----------NODE REFERENCES----------###

@onready var timer: Timer = $Timer as Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer


###----------PROPERTIES----------###

## Time in seconds at which the despawn animation starts (from 5 up to 30 seconds)
@export_range(5, 30) var time_in_seconds_left_start_despawn_animation:int = 5

var despawn_animation_started:bool = false


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta: float) -> void:
	_check_to_start_despawn_animation()


func _check_to_start_despawn_animation() -> void:
	if timer.is_stopped() || despawn_animation_started || collectable_sprite == null:
		return
	
	if timer.time_left <= time_in_seconds_left_start_despawn_animation:
		despawn_animation_started = true
		_do_despawn_blink_animation_fade_out()


###----------METHODS----------###

func start_despawn_timer(collectable_sprite:Sprite2D) -> void:
	
	self.collectable_sprite = collectable_sprite
	
	timer.start()


func _do_despawn_blink_animation_fade_out() -> void:
	if collectable_sprite == null || !despawn_animation_started:
		return
	
	var tween:Tween = get_tree().create_tween()
	
	tween.tween_property(collectable_sprite, "modulate", Color(1, 1, 1, .33), .25)
	await tween.finished
	_do_despawn_blink_animation_fade_in()


func _do_despawn_blink_animation_fade_in() -> void:
	if collectable_sprite == null || !despawn_animation_started:
		return
	
	var tween:Tween = get_tree().create_tween()
	
	tween.tween_property(collectable_sprite, "modulate", Color(1, 1, 1, 1), .25)
	await tween.finished
	_do_despawn_blink_animation_fade_out()


###----------CONNECTED SIGNALS----------###

func _on_timer_timeout() -> void:
	despawn_animation_done.emit()

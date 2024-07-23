extends Sprite2D
class_name BaseHealUp


###----------SCENE REFERENCES----------###

@onready var despawn_collectable_component: DespawnCollectableComponent = $DespawnCollectableComponent as DespawnCollectableComponent


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	despawn_collectable_component.despawn_animation_done.connect(_on_despawn_animation_done)


###----------METHODS----------###

func _delay_animation_player_play_start_time() -> void:
	# get random delay time for animation player start
	var delay_time_for_animation_player:float = randf_range(0, 0.5)
	delay_time_for_animation_player = snapped(delay_time_for_animation_player, 0.01)
	# wait delay time
	await get_tree().create_timer(delay_time_for_animation_player).timeout
	($AnimationPlayer as AnimationPlayer).play("default")


###----------CONNECTED SIGNALS----------###

func _on_despawn_animation_done() -> void:
	queue_free()

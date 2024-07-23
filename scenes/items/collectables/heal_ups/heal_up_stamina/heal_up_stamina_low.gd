extends BaseHealUp


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	super._ready()
	despawn_collectable_component.start_despawn_timer(self)
	_delay_animation_player_play_start_time()


extends Sprite2D

###----------CUSTOM SIGNALS----------###

signal toggle_active(active:bool)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var particles_effect_on_usage: GPUParticles2D = $ParticlesEffectOnUsage as GPUParticles2D


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	player.special_abilities_handler.platzhalter_ability.ability_used.connect(_on_ability_used)


###----------METHODS----------###

func _play_use_animation() -> void:
	particles_effect_on_usage.emitting = true
	var tween:Tween = create_tween()
	const SCALE_MAX:Vector2 = Vector2(1.4, 1.4)
	const SCALE_NORM:Vector2 = Vector2(1.0, 1.0)
	
	tween.tween_property(self, 'scale', SCALE_MAX, .25)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, 'scale', SCALE_NORM, .25)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_SINE)


###----------CONNECTED SIGNALS----------###

func _on_ability_used() -> void:
	_play_use_animation()

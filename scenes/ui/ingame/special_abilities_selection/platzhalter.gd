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


###----------CONNECTED SIGNALS----------###

func _on_ability_used() -> void:
	particles_effect_on_usage.emitting = true

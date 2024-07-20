extends Area2D


###----------CUSTOM SIGNAL----------###

signal got_collected


###----------PROPERTIES----------###

@export_enum("power_up", "heal_up") var collectable_type:String
@export var collectable_resource_stats:Resource
@export var collect_effect_particles_color:Color


###----------NODE REFERENCES----------###

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D as GPUParticles2D


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	gpu_particles_2d.global_position = (get_parent() as Sprite2D).global_position
	gpu_particles_2d.modulate = collect_effect_particles_color


###----------CONNECTED SIGNALS----------###

func _on_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		if collectable_type == "power_up":
			body.collectables_handler.get_power_up(collectable_resource_stats)
			
		elif collectable_type == "heal_up":
			body.collectables_handler.get_heal_up(collectable_resource_stats)
			
		else:
			printerr("No valid value of variable collectable_type")
		
		got_collected.emit()
		
		# disconnect custom signal to avoid another collect-action with this node
		# while particle animation is playing
		body_entered.disconnect(_on_body_entered)
		# hide parent scene root node (is a Sprite2D) without hiding
		# the child nodes (like the particles node)
		(get_parent() as Sprite2D).texture = null
		# start particles animation (is a one-shot) and wait
		# for finish
		gpu_particles_2d.emitting = true
		await gpu_particles_2d.finished
		# kill parent scene's root node
		get_parent().queue_free()

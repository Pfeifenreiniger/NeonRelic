extends Node


###----------SCENE REFERENCES----------###

@onready var animations_handler:Node = $"../.."


###----------PROPERTIES----------###

## Speed how fast the progress of color changing and sprite-stretching goes.
@export var progress_speed:float = 1

var do_whip_attack_shader_animation:bool = false
var is_currently_stretching:bool = false


###----------METHODS: PER FRAME CALLED----------###

func _process(delta) -> void:
	play_whip_attack_shader_animation(delta)


###----------METHODS----------###

func play_whip_attack_shader_animation(delta) -> void:

	if do_whip_attack_shader_animation:
		
		
		var shader_material:ShaderMaterial = animations_handler.animations.material
		
		var current_strech_progress = shader_material.get_shader_parameter("stretchProgress")
		
		var progress:float = progress_speed * delta
		current_strech_progress += progress
		
		if current_strech_progress >= 1:
			current_strech_progress = 0
			is_currently_stretching = !is_currently_stretching
		
		shader_material.set_shader_parameter("widenX", is_currently_stretching)
		shader_material.set_shader_parameter("stretchProgress", current_strech_progress)


func start_whip_attack_shader_animation() -> void:
	is_currently_stretching = true
	do_whip_attack_shader_animation = true
	animations_handler.animations.material.set_shader_parameter("doStretch", do_whip_attack_shader_animation)
	animations_handler.animations.material.set_shader_parameter("widenX", is_currently_stretching)


func stop_whip_attack_shader_animation() -> void:
	is_currently_stretching = false
	do_whip_attack_shader_animation = false
	animations_handler.animations.material.set_shader_parameter("stretchProgress", 0)
	animations_handler.animations.material.set_shader_parameter("doStretch", do_whip_attack_shader_animation)
	animations_handler.animations.material.set_shader_parameter("widenX", is_currently_stretching)

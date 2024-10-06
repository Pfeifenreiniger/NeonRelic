extends Node


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $"../../Animations" as AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D as PointLight2D


###----------PROPERTIES----------###

## Speed how fast the progress of color changing and sprite-stretching goes.
@export var progress_speed:float = 1

var do_whip_attack_shader_animation:bool = false
var is_currently_stretching:bool = false


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	play_whip_attack_shader_animation(delta)


###----------METHODS----------###

func play_whip_attack_shader_animation(delta:float) -> void:
	if do_whip_attack_shader_animation:
		var shader_material:ShaderMaterial = animations.material as ShaderMaterial
		var current_strech_progress:float = shader_material.get_shader_parameter("stretchProgress") as float
		
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
	(animations.material as ShaderMaterial).set_shader_parameter("doStretch", do_whip_attack_shader_animation)
	(animations.material as ShaderMaterial).set_shader_parameter("widenX", is_currently_stretching)
	point_light_2d.global_position = animations.global_position
	point_light_2d.enabled = true


func stop_whip_attack_shader_animation() -> void:
	is_currently_stretching = false
	do_whip_attack_shader_animation = false
	(animations.material as ShaderMaterial).set_shader_parameter("stretchProgress", 0)
	(animations.material as ShaderMaterial).set_shader_parameter("doStretch", do_whip_attack_shader_animation)
	(animations.material as ShaderMaterial).set_shader_parameter("widenX", is_currently_stretching)
	point_light_2d.enabled = false

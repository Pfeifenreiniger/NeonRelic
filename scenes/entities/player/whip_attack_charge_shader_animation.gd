extends Node


###----------SCENE REFERENCES----------###

@onready var animations_handler:Node = $"../.." as Node


###----------PROPERTIES----------###

## Speed how fast the progress of color changing and sprite-stretching goes.
@export var progress_speed:float = 1

var do_whip_attack_shader_animation:bool = false
var is_currently_stretching:bool = false


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	self.play_whip_attack_shader_animation(delta)


###----------METHODS----------###

func play_whip_attack_shader_animation(delta:float) -> void:

	if self.do_whip_attack_shader_animation:
		
		
		var shader_material:ShaderMaterial = self.animations_handler.animations.material as ShaderMaterial
		
		var current_strech_progress:float = shader_material.get_shader_parameter("stretchProgress") as float
		
		var progress:float = self.progress_speed * delta
		current_strech_progress += progress
		
		if current_strech_progress >= 1:
			current_strech_progress = 0
			self.is_currently_stretching = !self.is_currently_stretching
		
		shader_material.set_shader_parameter("widenX", self.is_currently_stretching)
		shader_material.set_shader_parameter("stretchProgress", current_strech_progress)


func start_whip_attack_shader_animation() -> void:
	self.is_currently_stretching = true
	self.do_whip_attack_shader_animation = true
	self.animations_handler.animations.material.set_shader_parameter("doStretch", self.do_whip_attack_shader_animation)
	self.animations_handler.animations.material.set_shader_parameter("widenX", self.is_currently_stretching)


func stop_whip_attack_shader_animation() -> void:
	self.is_currently_stretching = false
	self.do_whip_attack_shader_animation = false
	self.animations_handler.animations.material.set_shader_parameter("stretchProgress", 0)
	self.animations_handler.animations.material.set_shader_parameter("doStretch", self.do_whip_attack_shader_animation)
	self.animations_handler.animations.material.set_shader_parameter("widenX", self.is_currently_stretching)

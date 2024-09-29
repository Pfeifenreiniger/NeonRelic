extends Node

###----------NODE REFERENCES----------###

@onready var glow_stand_right: PointLight2D = $Glows/GlowStandRight as PointLight2D
@onready var glow_stand_left: PointLight2D = $Glows/GlowStandLeft as PointLight2D
@onready var glow_duck_right: PointLight2D = $Glows/GlowDuckRight as PointLight2D
@onready var glow_duck_left: PointLight2D = $Glows/GlowDuckLeft as PointLight2D
@onready var glow_nodes:Array[PointLight2D] = [
	glow_stand_right, glow_stand_left, glow_duck_right, glow_duck_left
]

@onready var animations: AnimatedSprite2D = $"../Animations" as AnimatedSprite2D


###----------PROPERTIES----------###

const BLOCK_STATI:Dictionary = {
	'GO' : 'go',
	'DO' : 'do',
	'DONE' : 'done'
}


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:

	get_parent().start_or_end_block_animation.connect(_on_start_or_end_block_animation)
	get_parent().change_block_animation_status.connect(_change_block_animation_status)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	glow_stand_right.global_position = animations.global_position
	glow_stand_right.global_position.x += 19
	glow_stand_right.global_position.y -= 13.5
	
	glow_stand_left.global_position = animations.global_position
	glow_stand_left.global_position.x -= 19
	glow_stand_left.global_position.y -= 13.5
	
	glow_duck_right.global_position = animations.global_position
	glow_duck_right.global_position.x += 19
	glow_duck_right.global_position.y += 6.5
	
	glow_duck_left.global_position = animations.global_position
	glow_duck_left.global_position.x -= 19
	glow_duck_left.global_position.y += 6.5


###----------METHODS----------###

func _get_glow_node(
	block_side:String,
	player_is_ducking:bool
	) -> PointLight2D:
	
	if player_is_ducking:
		if block_side == 'right':
			return glow_duck_right
		else:
			return glow_duck_left
	
	else:
		if block_side == 'right':
			return glow_stand_right
		else:
			return glow_stand_left


###----------METHODS: ANIMATIONS----------###

func _toggle_glow(
	block_side:String,
	player_is_ducking:bool,
	on:bool
	) -> void:
	
	var glow_node:PointLight2D = _get_glow_node(block_side, player_is_ducking)
	glow_node.enabled = on


func _adjust_glow_intensity_based_on_block_status(
	status:String,
	block_side:String,
	player_is_ducking:bool
	) -> void:
		
	var glow_node:PointLight2D = _get_glow_node(block_side, player_is_ducking)
	
	if status == BLOCK_STATI.GO\
	|| status == BLOCK_STATI.DONE:	
		glow_node.energy = 1.43
	
	elif status == BLOCK_STATI.DO:
		glow_node.energy = 3.26


func play_laser_beam_steam_animation(
	laser_from_side:String,
	laser_beam_global_position:Vector2
	) -> void:
	
	var laser_beam_steam_particles:GPUParticles2D = $LaserBeamSteamParticles as GPUParticles2D
	var laser_beam_steam_particles_point_light_2d:PointLight2D = laser_beam_steam_particles.get_node('PointLight2D')
	laser_beam_steam_particles_point_light_2d.enabled = true
	
	# duplicate original particles node for individual particles effect for every blocked laser beam
	laser_beam_steam_particles = laser_beam_steam_particles.duplicate() as GPUParticles2D
	
	# position particles node at laser beam entry point to shield
	var x_position_offset:int
	if laser_from_side == "left":
		# mirror particles to the left side
		laser_beam_steam_particles.process_material.gravity.x = -45
		x_position_offset = 8
	else:
		laser_beam_steam_particles.process_material.gravity.x = 45
		x_position_offset = -12
	var laser_beam_position_with_offset:Vector2 = Vector2(laser_beam_global_position.x + x_position_offset, laser_beam_global_position.y)
	laser_beam_steam_particles.global_position = laser_beam_position_with_offset
	
	# append particles node to scene tree
	add_child(laser_beam_steam_particles)
	
	# start its emitting
	laser_beam_steam_particles.emitting = true
	# and wait for one-shot to be done -> eventually, get rid of particles node
	await laser_beam_steam_particles.finished
	laser_beam_steam_particles.queue_free()
	laser_beam_steam_particles_point_light_2d.enabled = false


###----------CONNECTED SIGNALS----------###

func _on_start_or_end_block_animation(start:bool, side:String, player_is_ducking:bool) -> void:
	_toggle_glow(side, player_is_ducking, start)


func _change_block_animation_status(status:String, side:String, player_is_ducking:bool) -> void:
	_adjust_glow_intensity_based_on_block_status(status, side, player_is_ducking)

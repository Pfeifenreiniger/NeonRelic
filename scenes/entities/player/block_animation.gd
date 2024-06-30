extends Node


###----------METHODS: PARTICLES ANIMATION----------###

func play_laser_beam_steam_animation(
	laser_from_side:String,
	laser_beam_global_position:Vector2
	) -> void:
	
	var laser_beam_steam_particles:GPUParticles2D = $LaserBeamSteamParticles as GPUParticles2D
	
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

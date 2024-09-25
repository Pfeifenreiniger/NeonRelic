@tool
extends GPUParticles2D

@export_enum("short", "large") var type:String = "short":
	get:
		return type
	set(value):
		if value == "short":
			process_material.lifetime_randomness = .2
			process_material.emission_sphere_radius = 5.56
			process_material.spread = 45
			process_material.initial_velocity_min = 11.91
			process_material.angular_velocity_max = 77.14
			process_material.orbit_velocity_min = .048
			process_material.orbit_velocity_max = .096
			process_material.radial_velocity_min = 2
			process_material.radial_velocity_max = 6
			process_material.gravity.y = -65
			process_material.linear_accel_min = 19.04
			process_material.linear_accel_max = 48.81
			process_material.radial_accel_min = 11.9
			process_material.radial_accel_max = 15.47
			process_material.tangential_accel_min = 5.95
			process_material.tangential_accel_max = 7.14
			process_material.damping_min = 45.239
			process_material.damping_max = 51.191
			process_material.scale_min = .5
			process_material.scale_max = 1.5
			lifetime = .8
		
		elif value == 'large':
			process_material.lifetime_randomness = .4
			process_material.emission_sphere_radius = 8.61
			process_material.spread = 22.5
			process_material.initial_velocity_min = 17
			process_material.angular_velocity_max = 17
			process_material.orbit_velocity_min = .119
			process_material.orbit_velocity_max = .143
			process_material.radial_velocity_min = 2
			process_material.radial_velocity_max = 3
			process_material.gravity.y = -105
			process_material.linear_accel_min = 8.32
			process_material.linear_accel_max = 41.66
			process_material.radial_accel_min = 23.8
			process_material.radial_accel_max = 27.38
			process_material.tangential_accel_min = 46.42
			process_material.tangential_accel_max = 64.28
			process_material.damping_min = 83.334
			process_material.damping_max = 84.525
			process_material.scale_min = .8
			process_material.scale_max = 2
			lifetime = 1.2
		
		type = value


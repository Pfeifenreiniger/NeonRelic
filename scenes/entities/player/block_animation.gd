extends Node

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var animations_handler:PlayerAnimationsHandler = $".." as PlayerAnimationsHandler


###----------NODE REFERENCES----------###

@onready var shield_hitboxes:Dictionary = {
	"stand_left" as String : $"ShieldHitboxes/StandLeftArea2D" as Area2D,
	"stand_right" as String : $"ShieldHitboxes/StandRightArea2D" as Area2D,
	"duck_left" as String : $"ShieldHitboxes/DuckLeftArea2D" as Area2D,
	"duck_right" as String : $"ShieldHitboxes/DuckRightArea2D" as Area2D
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	shield_hitboxes["stand_left"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("stand_left")
	)
	shield_hitboxes["stand_right"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("stand_right")
	)
	shield_hitboxes["duck_left"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("duck_left")
	)
	shield_hitboxes["duck_right"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("duck_right")
	)


###----------METHODS: PER FRAME CALLED----------###

func _physics_process(_delta: float) -> void:
	$"ShieldHitboxes".global_position = player.global_position


###----------METHODS----------###


func activate_hitbox(shield_hitbox_name:String) -> void:
	if !(shield_hitbox_name in ["stand_left", "stand_right", "duck_left", "duck_right"]):
		return
	
	var hitbox_collision_shape:CollisionShape2D = shield_hitboxes[shield_hitbox_name].get_children()[0]
	hitbox_collision_shape.disabled = false


func deactivate_hitbox(shield_hitbox_name:String) -> void:
	if !(shield_hitbox_name in ["stand_left", "stand_right", "duck_left", "duck_right"]):
		return
	
	var hitbox_collision_shape:CollisionShape2D = shield_hitboxes[shield_hitbox_name].get_children()[0]
	hitbox_collision_shape.disabled = true


func _play_laser_beam_steam_animation(
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


func _subtract_block_laser_stamina_from_stamina_pool() -> void:
	player.stamina_handler.cost_player_stamina(
		player.stamina_handler.stamina_costs["block_laser"]
	)
	# check if player has still enough stamina for blockings
	# if not -> cancel block
	if !player.stamina_handler.check_player_has_enough_stamina(
		player.stamina_handler.stamina_costs["block_laser"]
		):
			Input.action_release("ingame_block")


###----------METHODS: CONNECTED SIGNALS----------###

func _on_shield_hitbox_area_entered(other_area:Area2D, shield_hitbox:String) -> void:
	if "IS_LASER_BEAM" in other_area:
		var laser_from_side:String
		if other_area.global_position.x > shield_hitboxes[shield_hitbox].global_position.x:
			laser_from_side = "right"
		else:
			laser_from_side = "left"
		_play_laser_beam_steam_animation(laser_from_side, other_area.global_position)
		other_area.get_parent().queue_free()
		
		_subtract_block_laser_stamina_from_stamina_pool()

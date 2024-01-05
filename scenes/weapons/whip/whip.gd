extends AnimatedSprite2D


const IS_WHIP = true

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

# hitbox start pos and sizes
@onready var hitbox_zone:Area2D = $HitboxZone
@onready var hitbox:CollisionShape2D = $HitboxZone/Hitbox
var x_start_pos_right:int = -58
var x_start_pos_left:int = 56
var x_sizes:Array = [
	12, 22, 34, 45, 56, 65, 76, 88, 100, 110, 120, 129
]

# attack damage
const WHIP_ATTACK_INIT_DAMAGE:int = 15
const WHIP_ATTACK_MAX_DAMAGE:int = 60
const WHIP_ATTACK_DAMAGE_INCREASE:int = 4
var current_whip_attack_damage:int = WHIP_ATTACK_INIT_DAMAGE

# attack charge
var charges_whip_attack:bool = false
@onready var charge_timer:Timer = $ChargeTimer
var started_charge_timer:bool = false

# attack animation
var do_attack_animation:bool = false
var done_attack_animation:bool = true
var attack_side:String = ""

# attack particles
@onready var whip_attack_particles:GPUParticles2D = $WhipAttackParticles
@onready var whip_attack_particles_left_markers:Node2D = $WhipAttackParticles/AttackLeftParticleMarkers
@onready var whip_attack_particles_right_markers:Node2D = $WhipAttackParticles/AttackRightParticleMarkers
var whip_attack_particles_right_markers_offset:int = 50

func _ready():
	charge_timer.timeout.connect(on_charge_timer_timeout)
	
	self.animation_finished.connect(on_animation_finished)
	visible = false
	
	hitbox_zone.body_entered.connect(on_hitbox_zone_body_entered)


func _process(delta):
	# charge attack
	if charges_whip_attack and not started_charge_timer:
		charge_timer.start()
		started_charge_timer = true
		print("Starte Charge")
	elif not charges_whip_attack and started_charge_timer:
		print("Stoppe Charge")
		charge_timer.stop()
		started_charge_timer = false

	# hitbox size adjustment and particles position while attack animation
	if do_attack_animation and not done_attack_animation:
		adjust_hitbox_size()
		set_attack_particles_pos_to_whips_end()


func init_attack_animation(side:String) -> void:
	do_attack_animation = true
	done_attack_animation = false
	init_particles_pos(side)
	whip_attack_particles.emitting = true
	whip_attack_particles.restart()


func init_particles_pos(side:String) -> void:
	var go_to_pos:Vector2
	if side == "right":
		go_to_pos = whip_attack_particles_right_markers.get_child(0).position
		go_to_pos.x += whip_attack_particles_right_markers_offset
		whip_attack_particles.position = go_to_pos
		whip_attack_particles.process_material.gravity.x = -3
		whip_attack_particles.process_material.initial_velocity_min = -6
		whip_attack_particles.process_material.initial_velocity_max = -2
	else:
		go_to_pos = whip_attack_particles_left_markers.get_child(0).position
		whip_attack_particles.position = go_to_pos
		whip_attack_particles.process_material.gravity.x = 3
		whip_attack_particles.process_material.initial_velocity_min = 2
		whip_attack_particles.process_material.initial_velocity_max = 6


func finish_attack_animation() -> void:
	do_attack_animation = false


func increase_whip_attack_damage() -> void:
	current_whip_attack_damage += WHIP_ATTACK_DAMAGE_INCREASE
	if current_whip_attack_damage > WHIP_ATTACK_MAX_DAMAGE:
		current_whip_attack_damage = WHIP_ATTACK_MAX_DAMAGE
	print("CHARGE! MEIN DAMAGE LAUTET %s" % current_whip_attack_damage)


func reset_whip_attack_damage() -> void:
	current_whip_attack_damage = WHIP_ATTACK_INIT_DAMAGE


func set_pos_to_player(side:String) -> void:
	var whip_handle_pos:Vector2 = Vector2.ZERO
	if side == "right":
		whip_handle_pos = player.weapon_whip_attack_right_pos.global_position
		whip_handle_pos.x += 65
	else:
		whip_handle_pos = player.weapon_whip_attack_left_pos.global_position
		whip_handle_pos.x -= 65
	whip_handle_pos.y -= 4
	global_position = whip_handle_pos


func set_attack_particles_pos_to_whips_end() -> void:
	var current_frame:int = self.get_frame()
	var marker:Marker2D
	var go_to_pos:Vector2
	if attack_side == "left":
		marker = whip_attack_particles_left_markers.get_child(current_frame - 1)
		go_to_pos = marker.position
	else:
		marker = whip_attack_particles_right_markers.get_child(current_frame - 1)
		go_to_pos = marker.position
		go_to_pos.x += whip_attack_particles_right_markers_offset
	whip_attack_particles.position = go_to_pos


func reset_hitbox_size():
	hitbox.shape.size.x = x_sizes[0]
	if attack_side == "right":
		hitbox.position.x = x_start_pos_right
	else:
		hitbox.position.x = x_start_pos_left
	hitbox.disabled = true


func adjust_hitbox_size():
	if hitbox.disabled:
		hitbox.disabled = false
	var current_frame:int = self.get_frame()
	var current_size_x = x_sizes[current_frame]
	if current_size_x != hitbox.shape.size.x:
		hitbox.shape.size.x = current_size_x
		var size_x_diff = (current_size_x - x_sizes[0]) / 2
		if attack_side == "right":
			hitbox.position.x = -(abs(x_start_pos_right) - size_x_diff)
		else:
			hitbox.position.x = abs(x_start_pos_left) - size_x_diff


###----------CONNECTED SIGNALS----------###

func on_charge_timer_timeout():
	if current_whip_attack_damage < WHIP_ATTACK_MAX_DAMAGE:
		print("und erhoehe damage!")
		increase_whip_attack_damage()
	else:
		print("Am Maximum angekommen")
		charges_whip_attack = false


func on_animation_finished():
	visible = false
	done_attack_animation = true
	whip_attack_particles.emitting = false


func on_hitbox_zone_body_entered(body:Node2D):
	if do_attack_animation:
		if "IS_ENEMY" in body:
			pass
			# do damage to enemy
		elif "IS_OBJECT" in body:
			pass
			# give object to player
		on_animation_finished()

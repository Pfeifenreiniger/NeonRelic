extends AnimatedSprite2D


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

# hitbox
@onready var hitbox_zone:Area2D = $HitboxZone as Area2D

# attack charge
@onready var charge_timer:Timer = $ChargeTimer as Timer

# attack particles
@onready var whip_attack_particles:GPUParticles2D = $WhipAttackParticles as GPUParticles2D
@onready var whip_attack_particles_left_markers:Node2D = $WhipAttackParticles/AttackLeftParticleMarkers as Node2D
@onready var whip_attack_particles_right_markers:Node2D = $WhipAttackParticles/AttackRightParticleMarkers as Node2D


###----------PROPERTIES----------###

const IS_WHIP:bool = true

# attack damage
const WHIP_ATTACK_INIT_DAMAGE:int = 15
const WHIP_ATTACK_MAX_DAMAGE:int = 60
const WHIP_ATTACK_DAMAGE_INCREASE:int = 4
var current_whip_attack_damage:int = self.WHIP_ATTACK_INIT_DAMAGE

# attack charge
var can_whip_attack_charge:bool = true
var charges_whip_attack:bool = false
var started_charge_timer:bool = false

# attack animation
var do_attack_animation:bool = false
var done_attack_animation:bool = true
var attack_side:String = ""

# attack particles
var whip_attack_particles_right_markers_offset:int = 50

# position offsets
const WHIP_HANDLE_POS_X_OFFSET:int = 65
const WHIP_HANDLE_POS_Y_OFFSET:int = 4


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.charge_timer.timeout.connect(self._on_charge_timer_timeout)
	
	self.animation_finished.connect(self._on_animation_finished)
	self.visible = false
	
	self.hitbox_zone.hitbox_zone_gone_entered.connect(self._on_hitbox_zone_gone_entered)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.do_attack_charge()


###----------METHODS: WHIP'S ATTACK CHARGE----------###

func do_attack_charge() -> void:
	if self.charges_whip_attack and not self.started_charge_timer:
		self.charge_timer.start()
		self.started_charge_timer = true
	elif not self.charges_whip_attack and self.started_charge_timer:
		self.charge_timer.stop()
		self.started_charge_timer = false


func increase_whip_attack_damage() -> void:
	self.current_whip_attack_damage += self.WHIP_ATTACK_DAMAGE_INCREASE
	if self.current_whip_attack_damage > self.WHIP_ATTACK_MAX_DAMAGE:
		self.current_whip_attack_damage = self.WHIP_ATTACK_MAX_DAMAGE
	# OPT: Spaeter im Entwicklungsprozess schauen, wie die Stats der Schadenserhoehung sein sollen
	print("CHARGE! MEIN DAMAGE LAUTET %s" % self.current_whip_attack_damage)


func reset_whip_attack_damage() -> void:
	self.current_whip_attack_damage = self.WHIP_ATTACK_INIT_DAMAGE


###----------METHODS: WHIP'S ANIMATIONS----------###

func init_attack_animation(side:String) -> void:
	self.init_particles_pos(side)
	self.do_attack_animation = true
	self.done_attack_animation = false
	self.whip_attack_particles.restart()
	self.whip_attack_particles.emitting = true


func init_particles_pos(side:String) -> void:
	var go_to_pos:Vector2
	if side == "right":
		go_to_pos = self.whip_attack_particles_right_markers.get_child(0).position
		go_to_pos.x += self.whip_attack_particles_right_markers_offset
		self.whip_attack_particles.position = go_to_pos
		self.whip_attack_particles.process_material.gravity.x = -3
		self.whip_attack_particles.process_material.initial_velocity_min = -6
		self.whip_attack_particles.process_material.initial_velocity_max = -2
	else:
		go_to_pos = self.whip_attack_particles_left_markers.get_child(0).position
		self.whip_attack_particles.position = go_to_pos
		self.whip_attack_particles.process_material.gravity.x = 3
		self.whip_attack_particles.process_material.initial_velocity_min = 2
		self.whip_attack_particles.process_material.initial_velocity_max = 6


func finish_attack_animation() -> void:
	self.do_attack_animation = false


###----------METHODS: WHIP'S POSITION TO PLAYER'S POSITION----------###

func set_pos_to_player(side:String) -> void:
	var whip_handle_pos:Vector2 = Vector2.ZERO
	
	if side == "right":
		if self.player.movement_handler.is_duck:
			whip_handle_pos = self.player.weapon_duck_whip_attack_right_pos.global_position
		else:
			whip_handle_pos = self.player.weapon_stand_whip_attack_right_pos.global_position
		whip_handle_pos.x += self.WHIP_HANDLE_POS_X_OFFSET
	else:
		if self.player.movement_handler.is_duck:
			whip_handle_pos = self.player.weapon_duck_whip_attack_left_pos.global_position
		else:
			whip_handle_pos = self.player.weapon_stand_whip_attack_left_pos.global_position
		whip_handle_pos.x -= self.WHIP_HANDLE_POS_X_OFFSET
	whip_handle_pos.y -= self.WHIP_HANDLE_POS_Y_OFFSET
	self.global_position = whip_handle_pos


func set_attack_particles_pos_to_whips_end() -> void:
	var current_frame:int = self.get_frame()
	var marker:Marker2D
	var go_to_pos:Vector2
	if self.attack_side == "left":
		marker = self.whip_attack_particles_left_markers.get_child(current_frame - 1) as Marker2D
		go_to_pos = marker.position
	else:
		marker = self.whip_attack_particles_right_markers.get_child(current_frame - 1) as Marker2D
		go_to_pos = marker.position
		go_to_pos.x += whip_attack_particles_right_markers_offset
	self.whip_attack_particles.position = go_to_pos


###----------CONNECTED SIGNALS----------###

func _on_charge_timer_timeout():
	if self.current_whip_attack_damage < self.WHIP_ATTACK_MAX_DAMAGE:
		self.increase_whip_attack_damage()
	else:
		self.charges_whip_attack = false


func _on_animation_finished():
	self.visible = false
	self.done_attack_animation = true
	self.whip_attack_particles.emitting = false


func _on_hitbox_zone_gone_entered():
	self._on_animation_finished()

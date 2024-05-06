extends BaseEnemy


###----------SCENE REFERENCES----------###

var drone_laser_beam_scene:PackedScene = preload("res://scenes/projectiles/laser_beams/drone_laser_beam.tscn") as PackedScene


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D
@onready var lift_particles:GPUParticles2D = $LiftParticles as GPUParticles2D
@onready var damage_animation:AnimatedSprite2D = $DamageAnimation as AnimatedSprite2D
@onready var explosion_animation_player:AnimationPlayer = $ExplosionAnimationPlayer as AnimationPlayer
@onready var laser_beams:Node2D = $LaserBeams as Node2D
@onready var laser_beam_start_position:Marker2D = $LaserBeamStartPosition as Marker2D


###----------PROPERTIES----------###

var face_player_to_side:String = ""
var laser_shot:bool = false


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	super._ready()
	animations.animation_finished.connect(_on_animations_animation_finished)
	health = 20
	movement_handler.base_speed = 30
	movement_handler.current_speed = movement_handler.base_speed
	damage_animation.visible = false


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	super._process(delta)
	_face_drone_on_x_axis()
	
	if is_attacking:
		_shot_laser_beam(laser_beam_start_position.global_position, player.global_position)


###----------METHODS: FACE DRONE ON X AXIS TO LEFT OR RIGHT----------###

func _face_drone_on_x_axis() -> void:
	if player != null:
		_face_player()
	else:
		_face_to_patrol_direction()


func _face_player() -> void:
	if face_player_to_side == "":
		if player.global_position.x < global_position.x:
			_face_to_left()
			face_player_to_side = "left"
		else:
			_face_to_right()
			face_player_to_side = "right"
	elif face_player_to_side == "left":
		if player.global_position.x > global_position.x:
			_face_to_right()
			face_player_to_side = "right"
	else:
		if player.global_position.x < global_position.x:
			_face_to_left()
			face_player_to_side = "left"


func _face_to_patrol_direction() -> void:
	if x_axis_direction == "left":
		_face_to_left()
	else:
		_face_to_right()


func _face_to_left() -> void:
	animations.flip_h = true
	lift_particles.position.x = -1
	laser_beam_start_position.position.x = -13


func _face_to_right() -> void:
	animations.flip_h = false
	lift_particles.position.x = 2
	laser_beam_start_position.position.x = 13


###----------METHODS----------###

func _shot_laser_beam(from_position:Vector2, to_position:Vector2) -> void:
	if not laser_shot:
		var drone_laser_beam:Sprite2D = drone_laser_beam_scene.instantiate() as Sprite2D
		laser_beams.add_child(drone_laser_beam)
		drone_laser_beam.shot(from_position, to_position)
		laser_shot = true
		await get_tree().create_timer(3).timeout
		laser_shot = false


func death_animation() -> void:
	IS_ENEMY = false
	movement_handler.current_speed = 0
	is_aggro = false
	is_attacking = false
	explosion_animation_player.play('explosion')

###----------METHODS: CONNECTED SIGNALS----------###

func _on_aggro_area_body_entered(body:Node2D) -> void:
	if not is_aggro:
		animations.stop()
		animations.play("alarm_right")
	super._on_aggro_area_body_entered(body)


func _on_aggro_area_body_exited(body:Node2D) -> void:
	if is_aggro:
		animations.stop()
		animations.play("right")
	super._on_aggro_area_body_exited(body)
	face_player_to_side = ""


func _on_attack_area_body_entered(body:Node2D) -> void:
	super._on_attack_area_body_entered(body)


func _on_animations_animation_finished() -> void:
	if is_aggro:
		if animations.frame == 0:
			animations.play("alarm_right")
		else:
			animations.play_backwards("alarm_right")

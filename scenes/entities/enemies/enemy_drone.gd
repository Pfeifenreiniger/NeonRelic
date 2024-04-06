extends BaseEnemy


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D
@onready var lift_particles:GPUParticles2D = $LiftParticles as GPUParticles2D
@onready var damage_animation:AnimatedSprite2D = $DamageAnimation as AnimatedSprite2D


###----------PROPERTIES----------###

var face_player_to_side:String = ""


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	super._ready()
	animations.animation_finished.connect(_on_animations_animation_finished)
	health = 2000
	movement_handler.base_speed = 30
	movement_handler.current_speed = movement_handler.base_speed
	damage_animation.visible = false


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	super._process(delta)
	_face_drone_on_x_axis()


###----------METHODS: FACE DRONE ON X AXIS TO LEFT OR RIGHT----------###

func _face_drone_on_x_axis() -> void:
	if player != null:
		_face_player()
	else:
		_face_to_patrol_direction()

func _face_player() -> void:
	if face_player_to_side == "":
		if player.global_position.x < global_position.x:
			animations.flip_h = true
			lift_particles.position.x = -1
			face_player_to_side = "left"
		else:
			face_player_to_side = "right"
	elif face_player_to_side == "left":
		if player.global_position.x > global_position.x:
			animations.flip_h = false
			lift_particles.position.x = 2
			face_player_to_side = "right"
	else:
		if player.global_position.x < global_position.x:
			animations.flip_h = true
			lift_particles.position.x = -1
			face_player_to_side = "left"


func _face_to_patrol_direction() -> void:
	if x_axis_direction == "left":
		animations.flip_h = true
	else:
		animations.flip_h = false


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


func _on_animations_animation_finished() -> void:
	if is_aggro:
		if animations.frame == 0:
			animations.play("alarm_right")
		else:
			animations.play_backwards("alarm_right")

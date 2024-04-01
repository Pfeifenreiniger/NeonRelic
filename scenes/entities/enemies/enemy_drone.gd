extends BaseEnemy


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = null


###----------PROPERTIES----------###

var face_player_to_side:String = ""


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	super._ready()
	animations.animation_finished.connect(_on_animations_animation_finished)
	health = 20


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	super._process(delta)
	_face_player()


###----------METHODS----------###

func _face_player() -> void:
	if player != null:
		if face_player_to_side == "":
			if player.global_position.x < global_position.x:
				animations.flip_h = true
				face_player_to_side = "left"
			else:
				face_player_to_side = "right"
		elif face_player_to_side == "left":
			if player.global_position.x > global_position.x:
				animations.flip_h = false
				face_player_to_side = "right"
		else:
			if player.global_position.x < global_position.x:
				animations.flip_h = true
				face_player_to_side = "left"


###----------METHODS: CONNECTED SIGNALS----------###

func _on_aggro_area_body_entered(body:Node2D) -> void:
	if not is_aggro:
		animations.stop()
		animations.play("alarm_right")
	super._on_aggro_area_body_entered(body)
	player = body


func _on_aggro_area_body_exited(body:Node2D) -> void:
	if is_aggro:
		animations.stop()
		animations.play("right")
	super._on_aggro_area_body_exited(body)
	player = null
	face_player_to_side = ""


func _on_animations_animation_finished() -> void:
	if is_aggro:
		if animations.frame == 0:
			animations.play("alarm_right")
		else:
			animations.play_backwards("alarm_right")

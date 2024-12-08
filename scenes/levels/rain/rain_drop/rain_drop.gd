extends CharacterBody2D
class_name RainDrop

###----------PROPERTIES----------###

var can_move:bool = true
var direction:Vector2 = Vector2(0, 1)

var gravity:int = 350 * randf_range(1.0, 1.2)
var wind_x_axis:int = 200


###----------NODE REFERENCES----------###

@onready var sprite_2d: Sprite2D = $Sprite2D as Sprite2D
@onready var hit_box: Area2D = $HitBox as Area2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D as GPUParticles2D
@onready var despawn_timer: Timer = $DespawnTimer as Timer


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	hit_box.body_entered.connect(_on_hit_box_body_entered)
	despawn_timer.timeout.connect(_on_despawn_timer_timeout)


###----------METHODS: PER FRAME CALLED----------###

func _process(delta: float) -> void:
	_move(delta)


###----------METHODS----------###

func _move(delta:float) -> void:
	
	if !can_move:
		return
	
	direction.x = abs(direction.x)
	
	var movement:Vector2 = Vector2(
		(direction.x * wind_x_axis) * delta,
		(direction.y * gravity) * delta
	)
	global_position.x += movement.x
	global_position.y += movement.y


func _play_splash_animation() -> void:
	direction = Vector2.ZERO
	can_move = false
	sprite_2d.visible = false
	gpu_particles_2d.emitting = true
	await gpu_particles_2d.finished
	queue_free()


###----------METHODS: CONNECTED SIGNALS----------###

func _on_hit_box_body_entered(body:Node2D) -> void:
	_play_splash_animation()


func _on_despawn_timer_timeout() -> void:
	queue_free()



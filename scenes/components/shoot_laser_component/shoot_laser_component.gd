extends Node
class_name ShootLaserComponent


###----------SCENE REFERENCES----------###

@export var shooting_entity_scene:Node2D
@export var laser_beam_scene:PackedScene


###----------NODE REFERENCES----------###

@onready var laser_beams:Node2D = $LaserBeams as Node2D
@onready var cannot_shoot_timer: Timer = $CannotShootTimer as Timer

@export var laser_beam_start_position:Marker2D


###----------PROPERTIES----------###

var laser_shot:bool = false
var can_shoot:bool = true


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	cannot_shoot_timer.timeout.connect(_on_cannot_shoot_timer_timeout)
	
	await shooting_entity_scene.ready
	shooting_entity_scene.health_handler.health_component.got_damage.connect(_on_shooting_entity_got_damage)


###----------METHODS----------###

func _start_cannot_shoot_timer() -> void:
	if can_shoot:
		can_shoot = false
		cannot_shoot_timer.start()
	if cannot_shoot_timer.time_left > 0:
		cannot_shoot_timer.stop()
		cannot_shoot_timer.start()


func shoot_laser_beam(to_position:Vector2) -> void:
	## Creates instance of laser beam scene and calls their shoot()-method.
	## Params:
	##   - to_position: Vector2 of target position

	if !laser_shot && can_shoot:
		
		# sets the laser_beams Node2D's global_position equal to the global_position
		# of the shooting entity
		laser_beams.global_position = shooting_entity_scene.global_position
		
		var laser_beam_instance:Sprite2D = laser_beam_scene.instantiate() as Sprite2D
		laser_beams.add_child(laser_beam_instance)
		laser_beam_instance.shoot(laser_beam_start_position.global_position, to_position)
		laser_shot = true
		await get_tree().create_timer(3).timeout
		laser_shot = false


###----------METHODS: CONNECTED SIGNALS----------###

func _on_shooting_entity_got_damage() -> void:
	_start_cannot_shoot_timer()


func _on_cannot_shoot_timer_timeout() -> void:
	can_shoot = true

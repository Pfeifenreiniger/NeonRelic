extends RigidBody2D

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D

var grenade_explosion_scene:PackedScene = preload("res://scenes/weapons/grenade/explosion/grenade_explosion.tscn") as PackedScene


###----------NODE REFERENCES----------###

@onready var animations:AnimatedSprite2D = $Animations
@onready var explosion_timer:Timer = $ExplosionTimer


###----------PROPERTIES----------###

@export_enum("fire_grenade", "freeze_grenade") var GRENADE_TYPE:String


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set position to player's position
	global_position = player.secondary_weapon_start_pos.global_position
	# connect timer timeout signal
	explosion_timer.timeout.connect(_on_explosion_timer_timeout)


###----------CONNECTED SIGNALS----------###

func _on_explosion_timer_timeout() -> void:
	# instantiate explosion scene
	var grenade_explosion:AnimatedSprite2D = grenade_explosion_scene.instantiate()
	grenade_explosion.grenade_type = GRENADE_TYPE
	add_child(grenade_explosion)
	# connect explosion scene signals
	grenade_explosion.hide_grenade.connect(_on_hide_grenade)
	grenade_explosion.destroy_grenade.connect(_on_destroy_grenade)
	# start animation and stop grenade from moving
	grenade_explosion.play()
	linear_velocity = Vector2.ZERO
	lock_rotation = true


func _on_hide_grenade() -> void:
	animations.visible = false


func _on_destroy_grenade() -> void:
	queue_free()

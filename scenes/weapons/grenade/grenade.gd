extends RigidBody2D

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------NODE REFERENCES----------###

@onready var explosion_timer:Timer = $ExplosionTimer


###----------PROPERTIES----------###

@export_enum("fire_grenade", "freeze_grenade") var GRENADE_TYPE:String


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set position to player's position
	global_position = player.secondary_weapon_start_pos.global_position
	
	# connect timer timeout signal
	explosion_timer.timeout.connect(on_explosion_timer_timeout)


###----------CONNECTED SIGNALS----------###

func on_explosion_timer_timeout() -> void:
	# ToDo: Eigentliche Explosion (abhaengig von der Explosionsart wie Fire, Freeze...) aufrufen (evtl. eigene Scene?)
	
	queue_free()


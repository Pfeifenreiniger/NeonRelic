extends Area2D


###----------NODE REFERENCES----------###

@onready var life_timer:Timer = $LifeTimer as Timer
@onready var particles:GPUParticles2D = $Particles as GPUParticles2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer as AnimationPlayer


###----------PROPERTIES----------###

var grenade_type:String

# attack damage stats
var damage:int
var can_do_damage:bool = true


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	life_timer.timeout.connect(_on_life_timer_timeout)
	body_entered.connect(_on_body_entered)
	_calculate_damage_over_time()
	_set_color_based_on_grenade_type()
	animation_player.play("spreading")


###----------METHODS----------###

func _calculate_damage_over_time() -> void:
	"""
	Based on the grenade type, damage of area will be calculated.
	"""
	
	# TEMP - den Schaden spaeter noch balancen
	if grenade_type == "fire_grenade":
		damage  = 10
	elif grenade_type == "freeze_grenade":
		damage = 5
	else:
		damage = 0


func _set_color_based_on_grenade_type() -> void:
	"""
	Change particle process material's color based on the grenade type
	"""
	
	var color:Color
	
	if grenade_type == "fire_grenade":
		color = Color('#e96343c5')
	elif grenade_type == "freeze_grenade":
		color = Color('#6cd7f3c5')
	else:
		color = Color('#ffffff')
	particles.process_material.color = color


###----------CONNECTED SIGNALS----------###

func _on_life_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body:Node2D) -> void:
	if can_do_damage and ("IS_ENEMY" in body or "IS_PLAYER" in body):
		# ToDo - auch Enemies benoetigen einen health_handler
		body.health_handler.get_damage(damage)
		
		if grenade_type == "freeze_grenade":
			# ToDo - auch Enemies benoetigfen einen movement_handler
			body.movement_handler.effect_get_slow_down(2)
		
		# damage only every 0.5 seconds
		can_do_damage = false
		await get_tree().create_timer(0.5).timeout
		can_do_damage = true

extends Area2D


###----------NODE REFERENCES----------###

@onready var life_timer:Timer = $LifeTimer as Timer
@onready var particles:GPUParticles2D = $Particles as GPUParticles2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer as AnimationPlayer


###----------PROPERTIES----------###

var grenade_type:String

var color:Color

# attack damage stats
var damage:int
var can_do_damage:bool = true


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.life_timer.timeout.connect(self._on_life_timer_timeout)
	self.body_entered.connect(self._on_body_entered)
	self._calculate_damage_over_time()
	self._set_color_based_on_grenade_type()
	self.animation_player.play("spreading")


###----------METHODS----------###

func _calculate_damage_over_time() -> void:
	"""
	Based on the grenade type, damage of area will be calculated.
	"""
	# TEMP - den Schaden spaeter noch balancen
	if self.grenade_type == "fire_grenade":
		self.damage  = 15
	elif self.grenade_type == "freeze_grenade":
		self.damage = 5
	else:
		self.damage = 0


func _set_color_based_on_grenade_type() -> void:
	"""
	Change particle process material's color based on the grenade type
	"""
	if self.grenade_type == "fire_grenade":
		self.color = Color('#e96343c5')
	elif self.grenade_type == "freeze_grenade":
		self.color = Color('#6cd7f3c5')
	else:
		self.color = Color('#ffffff')
	self.particles.process_material.color = color


###----------CONNECTED SIGNALS----------###

func _on_life_timer_timeout() -> void:
	self.queue_free()


func _on_body_entered(body:Node2D) -> void:
	if self.can_do_damage and ("IS_ENEMY" in body or "IS_PLAYER" in body):
		# ToDo - auch Enemies benoetigen einen health_handler
		body.health_handler.get_damage(damage)
		
		if self.grenade_type == "freeze_grenade":
			# ToDo - auch Enemies benoetigen einen movement_handler
			body.movement_handler.effect_get_slow_down(2)
		
		# damage only every 0.5 seconds
		self.can_do_damage = false
		await get_tree().create_timer(0.5).timeout
		self.can_do_damage = true

extends Area2D


###----------SCENE REFERENCES----------###

@onready var whip:Whip = $".." as Whip


###----------NODE REFERENCES----------###

@onready var hitbox:CollisionShape2D = $Hitbox as CollisionShape2D


###----------CUSTOM SIGNALS----------###

signal hitbox_zone_gone_entered


###----------PROPERTIES----------###

# hitbox start pos and sizes
var x_start_pos_right:int = -58
var x_start_pos_left:int = 56
var x_sizes:Array[int] = [
	12, 22, 34, 45, 56, 65, 76, 88, 100, 110, 120, 129
]


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	body_entered.connect(_on_hitbox_zone_body_entered)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	if whip.do_attack_animation && !whip.done_attack_animation:
		adjust_hitbox_size()
		whip.set_attack_particles_pos_to_whips_end()


###----------METHODS----------###

func reset_hitbox_size() -> void:
	hitbox.shape.size.x = x_sizes[0]
	if whip.attack_side == "right":
		hitbox.position.x = x_start_pos_right
	else:
		hitbox.position.x = x_start_pos_left
	hitbox.disabled = true


func adjust_hitbox_size() -> void:
	if hitbox.disabled:
		hitbox.disabled = false
	var current_frame:int = whip.get_frame()
	var current_size_x:int = x_sizes[current_frame]
	if current_size_x != hitbox.shape.size.x:
		hitbox.shape.size.x = current_size_x
		var size_x_diff:int = int(round((current_size_x - x_sizes[0]) / 2))
		if whip.attack_side == "right":
			hitbox.position.x = -(abs(x_start_pos_right) - size_x_diff)
		else:
			hitbox.position.x = abs(x_start_pos_left) - size_x_diff


###----------CONNECTED SIGNALS----------###

func _on_hitbox_zone_body_entered(body:Node2D) -> void:
	if whip.do_attack_animation:
		if "IS_ENEMY" in body:
			# TEMP - Schaden spaeter noch balancen
			body.health_handler.health_component.get_damage(15)
		elif "IS_OBJECT" in body:
			pass
			# ToDo: give object to player
		hitbox_zone_gone_entered.emit()

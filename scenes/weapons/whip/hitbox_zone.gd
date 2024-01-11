extends Area2D


###----------SCENE REFERENCES----------###

@onready var whip:AnimatedSprite2D = $".."


###----------NODE REFERENCES----------###

@onready var hitbox:CollisionShape2D = $Hitbox


###----------PROPERTIES----------###

# hitbox start pos and sizes
var x_start_pos_right:int = -58
var x_start_pos_left:int = 56
var x_sizes:Array = [
	12, 22, 34, 45, 56, 65, 76, 88, 100, 110, 120, 129
]


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.body_entered.connect(on_hitbox_zone_body_entered)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta) -> void:
	if whip.do_attack_animation and not whip.done_attack_animation:
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
	var current_size_x = x_sizes[current_frame]
	if current_size_x != hitbox.shape.size.x:
		hitbox.shape.size.x = current_size_x
		var size_x_diff = (current_size_x - x_sizes[0]) / 2
		if whip.attack_side == "right":
			hitbox.position.x = -(abs(x_start_pos_right) - size_x_diff)
		else:
			hitbox.position.x = abs(x_start_pos_left) - size_x_diff


###----------CONNECTED SIGNALS----------###

func on_hitbox_zone_body_entered(body:Node2D):
	if whip.do_attack_animation:
		if "IS_ENEMY" in body:
			pass
			# do damage to enemy
		elif "IS_OBJECT" in body:
			pass
			# give object to player
		whip.on_animation_finished()

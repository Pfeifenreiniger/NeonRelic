extends Area2D


###----------SCENE REFERENCES----------###

@onready var whip:AnimatedSprite2D = $".." as AnimatedSprite2D


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
	self.body_entered.connect(self._on_hitbox_zone_body_entered)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	if self.whip.do_attack_animation and not self.whip.done_attack_animation:
		self.adjust_hitbox_size()
		self.whip.set_attack_particles_pos_to_whips_end()


###----------METHODS----------###

func reset_hitbox_size() -> void:
	self.hitbox.shape.size.x = self.x_sizes[0]
	if self.whip.attack_side == "right":
		self.hitbox.position.x = self.x_start_pos_right
	else:
		self.hitbox.position.x = self.x_start_pos_left
	self.hitbox.disabled = true


func adjust_hitbox_size() -> void:
	if self.hitbox.disabled:
		self.hitbox.disabled = false
	var current_frame:int = self.whip.get_frame()
	var current_size_x:int = self.x_sizes[current_frame]
	if current_size_x != self.hitbox.shape.size.x:
		self.hitbox.shape.size.x = current_size_x
		var size_x_diff:int = round((current_size_x - self.x_sizes[0]) / 2)
		if self.whip.attack_side == "right":
			self.hitbox.position.x = -(abs(self.x_start_pos_right) - size_x_diff)
		else:
			self.hitbox.position.x = abs(self.x_start_pos_left) - size_x_diff


###----------CONNECTED SIGNALS----------###

func _on_hitbox_zone_body_entered(body:Node2D) -> void:
	if self.whip.do_attack_animation:
		if "IS_ENEMY" in body:
			pass
			# ToDo: do damage to enemy
		elif "IS_OBJECT" in body:
			pass
			# ToDo: give object to player
		self.hitbox_zone_gone_entered.emit()

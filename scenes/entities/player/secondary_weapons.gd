"""
Aim-line for throwing secondary weapon (such as grenades)
"""

extends Node2D

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------PROPERTIES----------###

var to_draw:bool = false

# positions
var start_pos:Vector2 = Vector2.ZERO
var to_pos:Vector2 = Vector2.ZERO

# tween animation
@onready var tween_angle_animation:Tween

# positions angle animation goes between
var to_pos_x_angle_for_y_upper_end:float
var to_pos_x_angle_for_y_lower_end:float
var to_pos_y_angle_upper_end:float
var to_pos_y_angle_lower_end:float

# appearance
var color:Color = Color('cc0000')
var line_width:float = 1.4


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	if to_draw:
		self.queue_redraw()


func _draw() -> void:
	if self.to_draw:
		self.draw_line(self.start_pos, self.to_pos, self.color, self.line_width)


###----------METHODS----------###

func draw_aim_line(start_pos:Vector2, side:String) -> void:
	self.to_draw = true
	
	self.start_pos = start_pos
	
	# calculate to_pos
	var offset_x:int = 24
	var offset_y:int = 54
	var pos_x:float
	var pos_y:float = self.start_pos.y - offset_y
	if side == "left":
		pos_x = self.start_pos.x - offset_x
		self.to_pos = Vector2(pos_x, pos_y)
		self.to_pos_x_angle_for_y_lower_end = self.to_pos.x - offset_x
	else:
		pos_x = self.start_pos.x + offset_x
		self.to_pos = Vector2(pos_x, pos_y)
		self.to_pos_x_angle_for_y_lower_end = self.to_pos.x + offset_x
	
	self.to_pos_x_angle_for_y_upper_end = self.to_pos.x
	self.to_pos_y_angle_upper_end = self.to_pos.y
	self.to_pos_y_angle_lower_end = self.to_pos.y + offset_y
	
	self.start_angle_animation_aim_line("down")


func start_angle_animation_aim_line(dir:String) -> void:
	self.tween_angle_animation = get_tree().create_tween()
	self.tween_angle_animation.finished.connect(self._on_tween_angle_animation_finished)
	
	var pos_to_go:Vector2
	
	if dir == "down":
		pos_to_go = Vector2(self.to_pos_x_angle_for_y_lower_end, self.to_pos_y_angle_lower_end)
	else:
		pos_to_go = Vector2(self.to_pos_x_angle_for_y_upper_end, self.to_pos_y_angle_upper_end)
	
	self.tween_angle_animation.tween_property($".", "to_pos", pos_to_go, 1)
 

func stop_draw_aim_line() -> float:
	"""
	Stops the aim line animation and returns a value between 0.0 and 1.0.
	0.0 = no extra (negative) velocity for y of thrown secondary weapon.
	1.0 = 100% extra (negative) velocity for y of thrown secondary weapon.
	"""
	self.tween_angle_animation.stop()
	self.to_draw = false
	self.queue_redraw()
	
	# calculate return value
	var extra_velocity_power_y:float
	var difference_between_y_lower_and_upper_end:float = abs(self.to_pos_y_angle_lower_end - self.to_pos_y_angle_upper_end)
	var difference_between_y_lower_end_and_current_y:float = abs(self.to_pos.y - self.to_pos_y_angle_lower_end)
	
	extra_velocity_power_y = difference_between_y_lower_end_and_current_y / difference_between_y_lower_and_upper_end
	
	return extra_velocity_power_y


func adjust_secondary_weapon_start_position(to_player_position:String) -> void:
	"""
	Depending on to_player_position ('duck' or 'stand') the Player's Marker2D Node's y-position will be updated.
	"""
	if to_player_position == "stand":
		self.player.secondary_weapon_start_pos.position.y -= 20
	else:
		self.player.secondary_weapon_start_pos.position.y += 20


###----------CONNECTED SIGNALS----------###

func _on_tween_angle_animation_finished() -> void:
	if self.to_draw:
		if self.to_pos.y == self.to_pos_y_angle_lower_end:
			self.start_angle_animation_aim_line("up")
		elif self.to_pos.y == self.to_pos_y_angle_upper_end:
			self.start_angle_animation_aim_line("down")

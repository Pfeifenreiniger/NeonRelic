
# Aim-line for throwing secondary weapon (such as grenades)

extends Node2D


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var point_light_2d: PointLight2D = $PointLight2D as PointLight2D


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
		queue_redraw()


func _draw() -> void:
	if to_draw:
		draw_line(start_pos, to_pos, color, line_width)
		point_light_2d.global_position = start_pos


###----------METHODS----------###

func draw_aim_line(start_pos:Vector2, side:String) -> void:
	to_draw = true
	
	self.start_pos = start_pos
	
	# calculate to_pos
	var offset_x:int = 24
	var offset_y:int = 54
	var pos_x:float
	var pos_y:float = self.start_pos.y - offset_y
	if side == "left":
		pos_x = self.start_pos.x - offset_x
		to_pos = Vector2(pos_x, pos_y)
		to_pos_x_angle_for_y_lower_end = to_pos.x - offset_x
	else:
		pos_x = self.start_pos.x + offset_x
		to_pos = Vector2(pos_x, pos_y)
		to_pos_x_angle_for_y_lower_end = to_pos.x + offset_x
	
	to_pos_x_angle_for_y_upper_end = to_pos.x
	to_pos_y_angle_upper_end = to_pos.y
	to_pos_y_angle_lower_end = to_pos.y + offset_y
	
	start_angle_animation_aim_line("down")


func start_angle_animation_aim_line(direction:String) -> void:
	tween_angle_animation = get_tree().create_tween()
	tween_angle_animation.finished.connect(_on_tween_angle_animation_finished)
	
	var pos_to_go:Vector2
	
	if direction == "down":
		pos_to_go = Vector2(to_pos_x_angle_for_y_lower_end, to_pos_y_angle_lower_end)
	else:
		pos_to_go = Vector2(to_pos_x_angle_for_y_upper_end, to_pos_y_angle_upper_end)
	
	tween_angle_animation.tween_property($".", "to_pos", pos_to_go, 1)
 

func stop_draw_aim_line() -> float:
	## Stops the aim line animation and returns a value between 0.0 and 1.0.
	## 0.0 = no extra (negative) velocity for y of thrown secondary weapon.
	## 1.0 = 100% extra (negative) velocity for y of thrown secondary weapon.
	
	tween_angle_animation.stop()
	to_draw = false
	queue_redraw()
	
	# calculate return value
	var extra_velocity_power_y:float
	var difference_between_y_lower_and_upper_end:float = abs(to_pos_y_angle_lower_end - to_pos_y_angle_upper_end)
	var difference_between_y_lower_end_and_current_y:float = abs(to_pos.y - to_pos_y_angle_lower_end)
	
	extra_velocity_power_y = difference_between_y_lower_end_and_current_y / difference_between_y_lower_and_upper_end
	
	return extra_velocity_power_y


func adjust_secondary_weapon_start_position(to_player_position:String) -> void:
	## Depending on to_player_position ('duck' or 'stand') the Player's Marker2D Node's y-position will be updated.
	
	if to_player_position == "stand":
		player.secondary_weapon_start_pos.position.y -= 20
	else:
		player.secondary_weapon_start_pos.position.y += 20


###----------CONNECTED SIGNALS----------###

func _on_tween_angle_animation_finished() -> void:
	if to_draw:
		if to_pos.y == to_pos_y_angle_lower_end:
			start_angle_animation_aim_line("up")
		elif to_pos.y == to_pos_y_angle_upper_end:
			start_angle_animation_aim_line("down")

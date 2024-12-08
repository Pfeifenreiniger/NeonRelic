extends Node2D
class_name RainArea


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
var rain_drop_scene:PackedScene = preload("res://scenes/levels/rain/rain_drop/rain_drop.tscn")


###----------NODE REFERENCES----------###

@onready var rain_drop_spawn_area: CollisionShape2D = $Area2D/RainDropSpawnArea as CollisionShape2D
@onready var spawn_timer: Timer = $SpawnTimer


###----------PROPERTIES----------###

const OFFSET:Vector2 = Vector2(
		-636,
		-558
	)

@export var rain_drops_container_node:Node2D

var rain_drops_spawn_loops:int = 20
@export_enum("light", "medium", "heavy") var rain_intensity:String = "medium":
	set(value):
		rain_intensity = value
		if value == "light":
			rain_drops_spawn_loops = 10
		
		elif value == "medium":
			rain_drops_spawn_loops = 20
		
		elif value == "heavy":
			rain_drops_spawn_loops = 30

var wind_intensity_int:int = 0
@export_enum("no", "light", "medium", "heavy") var wind_intensity:String = "no":
	set(value):
		wind_intensity = value
		if value == "no":
			wind_intensity_int = 0
		
		elif value == "light":
			wind_intensity_int = 200
		
		elif value == "medium":
			wind_intensity_int = 400
		
		elif value == "heavy":
			wind_intensity_int = 600

@export_enum("left", "right") var wind_direction:String = "left":
	set(value):
		wind_direction = value
		if value == "left":
			wind_intensity_int = wind_intensity_int * -1
		
		elif value == "right":
			wind_intensity_int = abs(wind_intensity_int)


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	await get_parent().ready
	wind_direction = wind_direction


func _process(delta: float) -> void:
	_follow_player_with_scene()


###----------METHODS----------###


func _set(property: StringName, value:Variant) -> bool:
	if property == "wind_direction":
		wind_direction = value  # Ruft den Setter explizit auf
		return true
	elif property == "rain_intensity":
		rain_intensity = value
		return true
	elif property == "wind_intensity":
		wind_intensity = value
		return true
	return false


func _follow_player_with_scene() -> void:
	if player == null:
		return
	
	global_position = player.global_position + OFFSET


func _get_random_spawn_position() -> Vector2:
	
	var rect:Rect2 = (rain_drop_spawn_area.shape as Shape2D).get_rect()
	var rect_size:Vector2 = rect.size
	var rect_center_pos:Vector2 = rain_drop_spawn_area.global_position
	
	var top:int = rect_center_pos.y - (rect_size.y / 2)
	var bottom:int = rect_center_pos.y + (rect_size.y / 2)
	var left:int = rect_center_pos.y - (rect_size.x / 2)
	var right:int = rect_center_pos.y + (rect_size.x / 2)
	
	return Vector2(
		randi_range(left, right),
		randi_range(top, bottom)
	)


func _spawn_rain_drops() -> void:
	if rain_drops_container_node == null:
		return
	
	for i in rain_drops_spawn_loops:
		var rain_drop:RainDrop = rain_drop_scene.instantiate()
		rain_drop.position = _get_random_spawn_position()
		rain_drops_container_node.add_child(rain_drop)
		if wind_intensity_int != 0:
			rain_drop.wind_x_axis = wind_intensity_int
			if wind_intensity_int > 0:
				rain_drop.direction.x = 1
			else:
				rain_drop.direction.x = -1


###----------METHODS: CONNECTED SIGNALS----------###

func _on_spawn_timer_timeout() -> void:
	_spawn_rain_drops()

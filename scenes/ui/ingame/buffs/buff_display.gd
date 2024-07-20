extends MarginContainer
class_name BuffDisplay


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var h_box_container: HBoxContainer = $HBoxContainer as HBoxContainer


###----------PROPERTIES----------###

var buff_texture_rects:Dictionary = {}


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	buff_texture_rects = _init_buff_texture_rects()
	
	player.collectables_handler.player_power_ups_handler.got_power_up.connect(_on_player_got_power_up)
	player.collectables_handler.player_power_ups_handler.refresh_power_up.connect(_on_player_refresh_power_up)


func _init_buff_texture_rects() -> Dictionary:
	
	var texture_rect_properties:Array = [
		["whip_damage_increase", "res://scenes/ui/ingame/buffs/images/whip_damage_increase.png", "Your whip's damage is increased"],
		["sword_damage_increase", "res://scenes/ui/ingame/buffs/images/sword_damage_increase.png", "Your sword's damage is increased"],
		["movement_speed_increase", "res://scenes/ui/ingame/buffs/images/movement_speed_increase.png", "Your movement speed is increased"],
		["unlimited_stamina", "res://scenes/ui/ingame/buffs/images/unlimited_stamina.png", "You don't consume any of your stamina"]
	]
	
	var temp_dictionary:Dictionary = {}
	
	for texture_rect_property in texture_rect_properties:
		var texture_rect:TextureRect = TextureRect.new()
		texture_rect.texture = load(texture_rect_property[1])
		texture_rect.tooltip_text = texture_rect_property[2] #TODO - Tooltip noch huebsch machen
		temp_dictionary[texture_rect_property[0]] = texture_rect
	
	return temp_dictionary


###----------METHODS----------###

func _add_buff_icon(buff_type:String, time_duration_in_s:int) -> void:
	if !(buff_texture_rects.has(buff_type)):
		return
	
	h_box_container.add_child(
		buff_texture_rects[buff_type]
	)
	
	await get_tree().create_timer(time_duration_in_s).timeout
	
	_remove_buff_icon(buff_type)


func _remove_buff_icon(buff_type:String) -> void:
	h_box_container.remove_child(
		buff_texture_rects[buff_type]
	)


###----------CONNECTED SIGNALS----------###

func _on_player_got_power_up(buff_type:String, time_duration_in_s:int) -> void:
	_add_buff_icon(buff_type, time_duration_in_s)


func _on_player_refresh_power_up(buff_type:String, time_duration_in_s:int) -> void:
	_remove_buff_icon(buff_type)
	_add_buff_icon(buff_type, time_duration_in_s)
	# OPT - es duerfte zu Problemen kommen, sobald der Spieler einen Buff refreshed. Der Timer vom erstmaligem adden duerfte noch laufen und danach die _remove-Funktion aufrufen, obwohl die Zeit resettet wurde

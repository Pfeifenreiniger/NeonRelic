extends MarginContainer
class_name BuffDisplay


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var h_box_container: HBoxContainer = $HBoxContainer as HBoxContainer
@onready var buff_duration_timers: Node = $BuffDurationTimers as Node


###----------PROPERTIES----------###

@export var resources_power_up_stats:Array[PowerUpStats] = []

var buff_icons:Dictionary = {}
@onready var buff_icons_properties:Array = [
	[resources_power_up_stats[0].buff_type, "res://scenes/ui/ingame/buffs/images/whip_damage_increase.png", resources_power_up_stats[0].buff_description, resources_power_up_stats[0].buff_duration],
	[resources_power_up_stats[1].buff_type, "res://scenes/ui/ingame/buffs/images/sword_damage_increase.png", resources_power_up_stats[1].buff_description, resources_power_up_stats[1].buff_duration],
	[resources_power_up_stats[2].buff_type, "res://scenes/ui/ingame/buffs/images/movement_speed_increase.png", resources_power_up_stats[2].buff_description, resources_power_up_stats[2].buff_duration],
	[resources_power_up_stats[3].buff_type, "res://scenes/ui/ingame/buffs/images/unlimited_stamina.png", resources_power_up_stats[3].buff_description, resources_power_up_stats[3].buff_duration]
]


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:	
	buff_icons = _init_buff_icons()
	
	player.collectables_handler.player_power_ups_handler.got_power_up.connect(_on_player_got_power_up)
	player.collectables_handler.player_power_ups_handler.refresh_power_up.connect(_on_player_refresh_power_up)


###----------METHODS: PER FRAME CALLED----------###

func _process(delta: float) -> void:
	_update_buff_duration_labels()


###----------METHODS----------###

func _init_buff_icons() -> Dictionary:
	
	var temp_dictionary:Dictionary = {}
	
	for buff_icon_property in buff_icons_properties:
		# build texture rect
		var texture_rect:TextureRect = TextureRect.new()
		texture_rect.texture = load(buff_icon_property[1])
		texture_rect.tooltip_text = buff_icon_property[2] #TODO - Tooltip noch huebsch machen
		
		# build label
		var label:Label = Label.new() # TODO - Label auch noch huebsch machen
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = str(buff_icon_property[3])
		
		# build vboxcontainer
		var v_box_container:VBoxContainer = VBoxContainer.new()
		
		# build timer
		var timer:Timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = buff_icon_property[3]
		
		var icon_elements:Dictionary = {
			"texture_rect" : texture_rect,
			"label" : label,
			"v_box_container" : v_box_container,
			"timer" : timer
		}
		
		temp_dictionary[buff_icon_property[0]] = icon_elements
	
	return temp_dictionary


func _update_buff_duration_labels() -> void:
	for child in buff_duration_timers.get_children():
		for buff_icon in buff_icons:
			if (buff_icons[buff_icon]["timer"] == child):
				buff_icons[buff_icon]["label"].text = str(round(buff_icons[buff_icon]["timer"].time_left))


func _add_buff_icon(buff_type:String) -> void:
	if !(buff_icons.has(buff_type)):
		return
	
	h_box_container.add_child(
		buff_icons[buff_type]["v_box_container"]
	)

	h_box_container.get_child(-1).add_child(
		buff_icons[buff_type]["texture_rect"]
	)
	
	
	h_box_container.get_child(-1).add_child(
		buff_icons[buff_type]["label"]
	)
	
	buff_duration_timers.add_child(
		buff_icons[buff_type]["timer"]
	)
	
	buff_icons[buff_type]["timer"].start()
	await buff_icons[buff_type]["timer"].timeout
	
	_remove_buff_icon(buff_type)


func _remove_buff_icon(buff_type:String) -> void:
	h_box_container.remove_child(
		buff_icons[buff_type]["v_box_container"]
	)
	buff_duration_timers.remove_child(
		buff_icons[buff_type]["timer"]
	)
	
	_restore_buff_duration_label_text_to_default(buff_type)


func _restore_buff_duration_label_text_to_default(buff_type:String) -> void:
	
	var index_of_buff_type:int
	
	for i in buff_icons_properties.size():
		if buff_icons_properties[i][0] == buff_type:
			index_of_buff_type = i
			break
	
	buff_icons[buff_type]["label"].text = str(buff_icons_properties[index_of_buff_type][3])


###----------CONNECTED SIGNALS----------###

func _on_player_got_power_up(buff_type:String) -> void:
	_add_buff_icon(buff_type)


func _on_player_refresh_power_up(buff_type:String) -> void:
	_remove_buff_icon(buff_type)
	_add_buff_icon(buff_type)

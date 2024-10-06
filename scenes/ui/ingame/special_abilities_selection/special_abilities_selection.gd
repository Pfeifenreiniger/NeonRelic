extends Node

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var timer: Timer = $Timer as Timer
@onready var all_or_nothing: Sprite2D = $AllOrNothing as Sprite2D
@onready var platzhalter: Sprite2D = $Platzhalter as Sprite2D


###----------PROPERTIES----------###

var all_abilities:Dictionary


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	player.controls_handler.select_special_ability.connect(_on_select_special_ability)
	
	all_abilities['all_or_nothing'] = all_or_nothing
	(all_abilities['all_or_nothing'] as Sprite2D).material.set_shader_parameter('active', true)
	all_abilities['platzhalter'] = platzhalter # TEMP: wirklich nur termporaer als Platzhalter hier
	
	_connect_toggle_active_signals()


###----------METHODS----------###

func _connect_toggle_active_signals() -> void:
	for ability in all_abilities:
		if ability == 'all_or_nothing':
			all_abilities[ability].toggle_active.connect(
				player.special_abilities_handler.all_or_nothing_ability._on_toggle_active
			)
		
		elif ability == 'platzhalter':
			all_abilities[ability].toggle_active.connect(
				player.special_abilities_handler.platzhalter_ability._on_toggle_active
			)


func _select_ability(side:int) -> void:
	## side wird entweder 1 oder -1 sein, fuer rechts oder links
	
	var available_abilities:Array = all_abilities.keys()
	
	var i_of_currently_active_ability:int
	var i:int
	for ability in all_abilities:
		if (all_abilities[ability] as Sprite2D).material.get('shader_parameter/active'):
			i_of_currently_active_ability = i
			(all_abilities[ability] as Sprite2D).material.set_shader_parameter('active', false)
			all_abilities[ability].toggle_active.emit(false)
			break
		i += 1
	
	var i_of_now_selected_ability:int
	if side > 0:
		i_of_now_selected_ability = i_of_currently_active_ability + side if i_of_currently_active_ability + side <= available_abilities.size() - 1 else 0
	
	else:
		i_of_now_selected_ability = i_of_currently_active_ability + side if i_of_currently_active_ability - side >= 0 else -1
	
	(all_abilities[available_abilities[i_of_now_selected_ability]] as Sprite2D).material.set_shader_parameter('active', true)
	all_abilities[available_abilities[i_of_now_selected_ability]].toggle_active.emit(true)


###----------CONNECTED SIGNALS----------###

func _on_select_special_ability(side:int) -> void:
	if timer.time_left:
		return

	_select_ability(side)
	timer.start()

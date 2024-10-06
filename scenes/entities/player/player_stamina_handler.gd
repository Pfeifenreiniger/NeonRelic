extends Node
class_name PlayerStaminaHandler

###----------CUSTOM SIGNALS----------###

signal update_current_player_stamina_in_percent(percentage:float)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var stamina_refresh_timer:Timer = $StaminaRefreshTimer as Timer


###----------PROPERTIES----------###

var stamina_cost_multiplier:float = 1 # ToDo - mit Upgrades wird die Zahl kleiner, um die Ausdauerkosten zu senken

var max_stamina:int = Globals.player_max_stamina:
	get:
		return max_stamina
	set(value):
		max_stamina = value
		Globals.player_max_stamina = value

var current_stamina:float:
	get:
		return current_stamina
	set(value):
		current_stamina = value
		Globals.player_current_stamina = value
		_calc_players_stamina_in_percent()

var stamina_can_refresh:bool = true
var stamina_refreshment_rate:int = 1
var stamina_costs:Dictionary = {
	"side_roll" : 20,
	"whip_attack" : 10,
	"sword_attack" : 5,
	"use_secondary_weapon" : 5,
	"block_laser" : 5
}


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	current_stamina = max_stamina
	stamina_refresh_timer.timeout.connect(_on_stamina_refresh_timer_timeout)
	
	await player.ready
	player.collectables_handler.got_heal_up.connect(_on_got_heal_up)


###----------METHODS----------###

func _calc_players_stamina_in_percent() -> void:
	var current_player_stamina:float = Globals.player_current_stamina
	var max_player_stamina:float = Globals.player_max_stamina
	
	var current_player_stamina_in_percent:float = snapped(
		(current_player_stamina / max_player_stamina) * 100, 0.01
	)
	
	update_current_player_stamina_in_percent.emit(current_player_stamina_in_percent)


func get_real_number_of_percentage_max_stamina(percentage:float) -> int:
	if percentage <= 0:
		percentage = 1
	
	var perc:float = snapped(percentage / 100, 0.01) # rounded to two digits (e.g. 0.52)
	
	return round(max_stamina * perc)


func check_player_has_enough_stamina(amount_stamina:int) -> bool:
	## Checks if the current stamina amount is high enough to perform an action.
	
	return current_stamina >= amount_stamina * stamina_cost_multiplier


func add_player_stamina(amount_stamina:int) -> void:
	# Add stamina to player's current stamina amount
	
	current_stamina = min(current_stamina + amount_stamina, max_stamina)


func cost_player_stamina(amount_stamina:int) -> void:
	## Reduce stamina with actions like attacks/rolls.
	
	current_stamina -= amount_stamina * stamina_cost_multiplier


func update_stamina_costs(ability_name:String, stamina_amount:int) -> void:
	## Updates stamina cost of ability by amount
	
	if !stamina_costs.has(ability_name):
		return
	
	stamina_costs[ability_name] = stamina_amount


func refresh_player_stamina() -> void:
	## Refreshes the current stamina by the stamina refreshment rate amount.
	
	if stamina_can_refresh:
		if current_stamina < max_stamina:
			add_player_stamina(stamina_refreshment_rate)


###----------CONNECTED SIGNALS----------###

func _on_stamina_refresh_timer_timeout() -> void:
	refresh_player_stamina()


func _on_got_heal_up(heal_category:String, heal_percentage:float) -> void:
	if heal_category == "stamina":
		var amount_to_heal:int = roundi(float(max_stamina) * heal_percentage)
		add_player_stamina(amount_to_heal)

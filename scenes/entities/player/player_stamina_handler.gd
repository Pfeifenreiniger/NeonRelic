extends Node
class_name PlayerStaminaHandler


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

var stamina_can_refresh:bool = true
var stamina_refreshment_rate:int = 1
var stamina_costs:Dictionary = {
	"side_roll" as String : 20 as int,
	"whip_attack" as String : 10 as int,
	"sword_attack" as String: 5 as int,
	"use_secondary_weapon" as String : 5 as int,
	"block_laser" as String : 5 as int
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	current_stamina = max_stamina
	stamina_refresh_timer.timeout.connect(_on_stamina_refresh_timer_timeout)
	
	await player.ready
	player.collectables_handler.got_heal_up.connect(_on_got_heal_up)


###----------METHODS----------###

func check_player_has_enough_stamina(amount_stamina:int) -> bool:
	## Checks if the current stamina amount is high enough to perform an action.
	
	return current_stamina >= amount_stamina * stamina_cost_multiplier


func cost_player_stamina(amount_stamina:int) -> void:
	## Reduce stamina with actions like attacks/rolls.
	
	current_stamina -= amount_stamina * stamina_cost_multiplier


func refresh_player_stamina() -> void:
	## Refreshes the current stamina by the stamina refreshment rate amount.
	
	if stamina_can_refresh:
		if current_stamina < max_stamina:
			if current_stamina + stamina_refreshment_rate <= max_stamina:
				current_stamina += stamina_refreshment_rate
			else:
				current_stamina = max_stamina


###----------CONNECTED SIGNALS----------###

func _on_stamina_refresh_timer_timeout() -> void:
	refresh_player_stamina()


func _on_got_heal_up(heal_category:String, heal_percentage:float) -> void:
	if heal_category == "stamina":
		var amount_to_heal:int = roundi(float(max_stamina) * heal_percentage)
		current_stamina = min(current_stamina + amount_to_heal, max_stamina)

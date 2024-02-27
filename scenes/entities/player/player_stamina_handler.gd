extends Node


###----------NODE REFERENCES----------###

@onready var stamina_refresh_timer:Timer = $StaminaRefreshTimer as Timer


###----------PROPERTIES----------###

var stamina_cost_multiplier:float = 1 # mit Upgrades wird die Zahl kleiner, um die Ausdauerkosten zu senken
var max_stamina:int = 100
var current_stamina:float = max_stamina
var stamina_can_refresh:bool = true
var stamina_refreshment_rate:int = 1
var stamina_costs:Dictionary = {
	"side_roll" as String : 20 as int,
	"whip_attack" as String : 10 as int
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	stamina_refresh_timer.timeout.connect(on_stamina_refresh_timer_timeout)


###----------METHODS----------###

func check_player_has_enough_stamina(amount_stamina:int) -> bool:
	"""
	Checks if the current stamina amount is high enough to perform an action. 
	"""
	return current_stamina >= amount_stamina * stamina_cost_multiplier


func cost_player_stamina(amount_stamina:int) -> void:
	"""
	Reduce stamina with actions like attacks/rolls.
	"""
	current_stamina -= amount_stamina * stamina_cost_multiplier


func refresh_player_stamina() -> void:
	"""
	Refreshes the current stamina by the stamina refreshment rate amount.
	"""
	if stamina_can_refresh:
		if current_stamina < max_stamina:
			if current_stamina + stamina_refreshment_rate <= max_stamina:
				current_stamina += stamina_refreshment_rate
			else:
				current_stamina = max_stamina


###----------CONNECTED SIGNALS----------###

func on_stamina_refresh_timer_timeout() -> void:
	refresh_player_stamina()

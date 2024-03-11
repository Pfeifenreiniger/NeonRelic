extends Node


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

var current_stamina:float = self.max_stamina:
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
	"use_secondary_weapon" as String : 5 as int
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.stamina_refresh_timer.timeout.connect(self._on_stamina_refresh_timer_timeout)


###----------METHODS----------###

func check_player_has_enough_stamina(amount_stamina:int) -> bool:
	"""
	Checks if the current stamina amount is high enough to perform an action. 
	"""
	return self.current_stamina >= amount_stamina * self.stamina_cost_multiplier


func cost_player_stamina(amount_stamina:int) -> void:
	"""
	Reduce stamina with actions like attacks/rolls.
	"""
	self.current_stamina -= amount_stamina * self.stamina_cost_multiplier


func refresh_player_stamina() -> void:
	"""
	Refreshes the current stamina by the stamina refreshment rate amount.
	"""
	if self.stamina_can_refresh:
		if self.current_stamina < self.max_stamina:
			if self.current_stamina + self.stamina_refreshment_rate <= self.max_stamina:
				self.current_stamina += self.stamina_refreshment_rate
			else:
				self.current_stamina = self.max_stamina


###----------CONNECTED SIGNALS----------###

func _on_stamina_refresh_timer_timeout() -> void:
	self.refresh_player_stamina()

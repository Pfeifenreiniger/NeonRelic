extends Node

@onready var stamina_refresh_timer:Timer = $StaminaRefreshTimer
@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')

var stamina_can_refresh:bool = true
var stamina_refreshment_rate:int = 1
var side_roll_stamina_cost:int = 20
var whip_attack_stamina_cost:int = 10


func _ready():
	stamina_refresh_timer.timeout.connect(on_stamina_refresh_timer_timeout)


func check_player_has_enough_stamina(amount_stamina:int) -> bool:
	return player.current_stamina >= amount_stamina


func refresh_player_stamina():
	if stamina_can_refresh:
		if player.current_stamina < player.max_stamina:
			if player.current_stamina + stamina_refreshment_rate <= player.max_stamina:
				player.current_stamina += stamina_refreshment_rate
			else:
				player.current_stamina = player.max_stamina


###----------CONNECTED SIGNALS----------###

func on_stamina_refresh_timer_timeout():
	refresh_player_stamina()

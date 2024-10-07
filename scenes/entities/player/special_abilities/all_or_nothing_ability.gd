class_name AllOrNothingAbility
extends Node

###----------CUSTOM SIGNALS----------###

signal ability_used
signal update_remaining_cooldown_time(time_left_in_secs:int)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var cooldown_timer: Timer = $CooldownTimer as Timer


###----------PROPERTIES----------###

var is_active:bool = false

@export_range(5, 20) var ability_effect_duration_in_seconds:int = 10:
	get:
		return ability_effect_duration_in_seconds
	set(value):
		ability_effect_duration_in_seconds = round(int(value))

var player_current_stamina_in_percent:float = 100.
var last_emitted_remaining_cooldown_time:int


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	await player.ready
	player.stamina_handler.update_current_player_stamina_in_percent.connect(_on_update_current_player_stamina_in_percent)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta: float) -> void:
	_emit_update_remaining_cooldown_time()


###----------METHODS----------###

func use_ability() -> void:
	# pre-conditions
	if cooldown_timer.time_left:
		return
	if player == null:
		return
	if player_current_stamina_in_percent < 50:
		return
	
	ability_used.emit()
	
	cooldown_timer.start()
	
	# calc 20% of player's max health
	var twenty_percent_of_players_max_health:float = player.health_handler.get_real_number_of_percentage_max_health(20)
	
	# calc 50% of player's max stamina
	var fifty_percent_of_players_max_stamina:float = player.stamina_handler.get_real_number_of_percentage_max_stamina(50)
	
	# reduce player's stamina by the 50%
	player.stamina_handler.cost_player_stamina(fifty_percent_of_players_max_stamina)
	
	# now heal player by 20% over the effect-duration time
	var amount_of_heal_per_second:float = twenty_percent_of_players_max_health / ability_effect_duration_in_seconds
	
	for i in ability_effect_duration_in_seconds:
		_add_health_to_player(amount_of_heal_per_second)
		await get_tree().create_timer(1.).timeout


func _add_health_to_player(amount:float) -> void:
	
	if amount < 1.:
		amount = 1.
	
	var amount_int:int = int(
		round(amount)
	)
	
	player.health_handler.health_component.heal_health(amount_int)


func _emit_update_remaining_cooldown_time() -> void:
	
	var time_left_in_secs:int = int(round(cooldown_timer.time_left))
	
	# emit only, if time left has actually changed (as whole seconds)
	if last_emitted_remaining_cooldown_time != null:
		if time_left_in_secs == last_emitted_remaining_cooldown_time:
			return
	
	last_emitted_remaining_cooldown_time = time_left_in_secs
	
	update_remaining_cooldown_time.emit(time_left_in_secs)


###----------CONNECTED SIGNALS----------###

func _on_update_current_player_stamina_in_percent(percentage:float) -> void:
	player_current_stamina_in_percent = percentage


func _on_toggle_active(active:bool) -> void:
	is_active = active

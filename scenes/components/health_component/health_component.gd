extends Node
class_name HealthComponent


###----------CUSTOM SIGNALS----------###

signal got_damage
signal died


###----------SCENE REFERENCES----------###

@export var entity:Node2D


###----------NODE REFERENCES----------###

@export var health_refresh_timer:Timer


###----------PROPERTIES----------###

@export var max_health:int:
	get:
		return max_health
	set(value):
		max_health = value
		if entity != null:
			if "IS_PLAYER" in entity:
				Globals.player_max_health = value

var current_health:int:
	get:
		return current_health
	set(value):
		current_health = value
		if entity != null:
			if "IS_PLAYER" in entity:
				Globals.player_current_health = value

@export var health_refreshment_rate:int

@export var minimum_amount_of_pixels_for_fallen_damage:int = 200


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	health_refresh_timer.timeout.connect(_on_health_refresh_timer_timeout)
	
	await get_parent().ready
	if "IS_PLAYER" in entity:
		max_health = Globals.player_max_health
	current_health = max_health


###----------METHODS: CHANGE VALUE OF CURRENT HEALTH PROPERTY----------###

func get_damage(amount:int) -> void:
	## Reduces entity's health based on damage amount.
	
	if !entity.invulnerable_handler.invulnerability_component.is_invulnerable:
		if current_health - amount <= 0:
			print("Bin tot :(")
			current_health = 0
			died.emit()
		else:
			current_health -= amount
			got_damage.emit()
			
			# invulnerability-time depends on if entity is player or enemy
			var invulnerability_time:float
			if "IS_PLAYER" in entity:
				invulnerability_time = .5
			else:
				invulnerability_time = .25
			
			entity.invulnerable_handler.invulnerability_component.become_invulnerable(invulnerability_time, true)
			health_refresh_timer.start()


func heal_health(amount:int) -> void:
	## Increases entity's health based on healing amount.
	
	if current_health + amount >= max_health:
		current_health = max_health
	else:
		current_health += amount


func refresh_health() -> void:
	
	if health_refreshment_rate == null:
		return
	
	if current_health < max_health:
		if current_health + health_refreshment_rate <= max_health:
			current_health += health_refreshment_rate
		else:
			current_health = max_health
	else:
		health_refresh_timer.stop()


###----------CONNECTED SIGNALS----------###

func _on_health_refresh_timer_timeout() -> void:
	refresh_health()


func _on_enitity_did_fall(pixels:int) -> void:
	
	if pixels < minimum_amount_of_pixels_for_fallen_damage:
		return
	
	var percentage_for_fallen_damage:float = float((pixels - minimum_amount_of_pixels_for_fallen_damage)) / float(minimum_amount_of_pixels_for_fallen_damage) * 100
	
	# reduce fallen damage percentage to 1/4 of its value
	percentage_for_fallen_damage = percentage_for_fallen_damage / 4
	
	var amount_of_damage:int = int(
		round((percentage_for_fallen_damage / 100) * max_health)
	)
	
	get_damage(amount_of_damage)


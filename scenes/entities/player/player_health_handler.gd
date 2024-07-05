extends Node
class_name PlayerHealthHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var health_component:HealthComponent = $HealthComponent as HealthComponent


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	health_component.entity = player
	
	await player.ready
	player.collectables_handler.got_heal_up.connect(_on_got_heal_up)


###----------CONNECTED SIGNALS----------###

func _on_got_heal_up(heal_category:String, heal_percentage:float) -> void:
	if heal_category == "health":
		var amount_to_heal:int = roundi(float(health_component.max_health) * heal_percentage)
		health_component.heal_health(amount_to_heal)

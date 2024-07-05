extends Area2D


###----------PROPERTIES----------###

@export_enum("power_up", "heal_up") var collectable_type:String
@export var collectable_resource_stats:Resource


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	body_entered.connect(_on_body_entered)


###----------CONNECTED SIGNALS----------###

func _on_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		if collectable_type == "power_up":
			body.collectables_handler.get_power_up(collectable_resource_stats)
			
		elif collectable_type == "heal_up":
			body.collectables_handler.get_heal_up(collectable_resource_stats)
			
		else:
			printerr("No valid value of variable collectable_type")
		
		get_parent().queue_free()

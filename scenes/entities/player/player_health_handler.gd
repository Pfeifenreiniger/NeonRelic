extends Node
class_name PlayerHealthHandler

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
var screen_flash_effect_component_scene:PackedScene = preload("res://scenes/components/screen_flash_component/screen_flash_component.tscn")


###----------NODE REFERENCES----------###

@onready var health_component:HealthComponent = $HealthComponent as HealthComponent


###----------PROPERTIES----------###

## Color for flash effect on received damage
@export var color_screen_flash:Color


###----------PROPERTIES: CUSTOM SIGNALS----------###

signal update_current_player_health_in_percent(percentage:float)


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	health_component.got_healed.connect(_on_got_healed)
	health_component.got_damage.connect(_on_got_damage)
	health_component.entity = player
	
	await player.ready
	player.collectables_handler.got_heal_up.connect(_on_got_heal_up)
	player.movement_handler.did_fall.connect(health_component._on_enitity_did_fall)


###----------METHODS----------###

func calc_players_health_in_percent() -> void:
	## errechnet die derzeitige Spieler HP in % (mit zwei Nachkommastellen),
	## also z.B. 31.01
	
	var current_player_health:float = Globals.player_current_health
	var max_player_health:float = Globals.player_max_health
	
	var current_player_health_in_percent:float = snapped(
		(current_player_health / max_player_health) * 100, 0.01
	)
	
	update_current_player_health_in_percent.emit(current_player_health_in_percent)


###----------CONNECTED SIGNALS----------###

func _on_got_healed() -> void:
	# calculate new health percentage
	calc_players_health_in_percent()


func _on_got_damage() -> void:
	# play screen flash animation
	var screen_flash_effect_component_instance:ScreenFlashComponent = screen_flash_effect_component_scene.instantiate() as ScreenFlashComponent
	screen_flash_effect_component_instance.color = color_screen_flash
	screen_flash_effect_component_instance.layer = 999
	add_child(screen_flash_effect_component_instance)
	screen_flash_effect_component_instance.play_flash_animation()
	
	# calculate new health percentage
	calc_players_health_in_percent()


func _on_got_heal_up(heal_category:String, heal_percentage:float) -> void:
	if heal_category == "health":
		# heal health by amount
		var amount_to_heal:int = roundi(float(health_component.max_health) * heal_percentage)
		health_component.heal_health(amount_to_heal)

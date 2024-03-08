extends BasePlayerWeaponSelection


###----------NODE REFERENCES----------###

@onready var arrow_left:Sprite2D = $Arrow1 as Sprite2D
@onready var arrow_right:Sprite2D = $Arrow2 as Sprite2D


###----------PROPERTIES----------###

# NEXT: Spaeter hier noch weitere hinzufuegen
var secondary_weapons_available:Array[String] = [
	"fire_grenade", "freeze_grenade"
]

var currently_selected_secondary_weapon_index:int = 0

var weapon_icon_images:Dictionary = {
	"fire_grenade" as String : preload("res://assets/graphics/ui/ingame/secondary_weapon_icons/fire_grenade_icon.png") as Resource,
	"freeze_grenade" as String : preload("res://assets/graphics/ui/ingame/secondary_weapon_icons/freeze_grenade_icon.png") as Resource
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	player.controls_handler.select_secondary_weapon.connect(_on_select_secondary_weapon)
	icon.texture = weapon_icon_images[Globals.currently_used_secondary_weapon]


###----------METHODS----------###

func _secondary_weapon_right() -> void:
	currently_selected_secondary_weapon_index -= 1
	if currently_selected_secondary_weapon_index < 0:
		currently_selected_secondary_weapon_index = secondary_weapons_available.size() - 1
	
	Globals.currently_used_secondary_weapon = secondary_weapons_available[currently_selected_secondary_weapon_index]
	
	# updates icon
	icon.texture = weapon_icon_images[Globals.currently_used_secondary_weapon]


func _secondary_weapon_left() -> void:
	currently_selected_secondary_weapon_index += 1
	if currently_selected_secondary_weapon_index > secondary_weapons_available.size() - 1:
		currently_selected_secondary_weapon_index = 0
	
	Globals.currently_used_secondary_weapon = secondary_weapons_available[currently_selected_secondary_weapon_index]
	
	# updates icon
	icon.texture = weapon_icon_images[Globals.currently_used_secondary_weapon]


###----------METHODS: CONNECTED SIGNALS----------###

func _on_select_secondary_weapon(dir:String) -> void:
	if dir == "right":
		_secondary_weapon_right()
		arrow_left.modulate = normal_color
		arrow_right.modulate = red_color
		_arrow_back_to_normal_color_timer(arrow_right, 0.25)
	else:
		_secondary_weapon_left()
		arrow_right.modulate = normal_color
		arrow_left.modulate = red_color
		_arrow_back_to_normal_color_timer(arrow_left, 0.25)

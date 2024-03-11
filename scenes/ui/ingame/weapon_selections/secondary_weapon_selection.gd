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
	self.player.controls_handler.select_secondary_weapon.connect(self._on_select_secondary_weapon)
	self.icon.texture = self.weapon_icon_images[Globals.currently_used_secondary_weapon]


###----------METHODS----------###

func _secondary_weapon_right() -> void:
	self.currently_selected_secondary_weapon_index -= 1
	if self.currently_selected_secondary_weapon_index < 0:
		self.currently_selected_secondary_weapon_index = self.secondary_weapons_available.size() - 1
	
	Globals.currently_used_secondary_weapon = self.secondary_weapons_available[self.currently_selected_secondary_weapon_index]
	
	# updates icon
	self.icon.texture = self.weapon_icon_images[Globals.currently_used_secondary_weapon]


func _secondary_weapon_left() -> void:
	self.currently_selected_secondary_weapon_index += 1
	if self.currently_selected_secondary_weapon_index > self.secondary_weapons_available.size() - 1:
		self.currently_selected_secondary_weapon_index = 0
	
	Globals.currently_used_secondary_weapon = self.secondary_weapons_available[self.currently_selected_secondary_weapon_index]
	
	# updates icon
	self.icon.texture = self.weapon_icon_images[Globals.currently_used_secondary_weapon]


###----------METHODS: CONNECTED SIGNALS----------###

func _on_select_secondary_weapon(dir:String) -> void:
	if dir == "right":
		self._secondary_weapon_right()
		self.arrow_left.modulate = self.normal_color
		self.arrow_right.modulate = self.red_color
		self._arrow_back_to_normal_color_timer(self.arrow_right, 0.25)
	else:
		self._secondary_weapon_left()
		self.arrow_right.modulate = self.normal_color
		self.arrow_left.modulate = self.red_color
		self._arrow_back_to_normal_color_timer(self.arrow_left, 0.25)

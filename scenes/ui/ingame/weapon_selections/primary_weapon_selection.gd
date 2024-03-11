extends BasePlayerWeaponSelection


###----------NODE REFERENCES----------###

@onready var arrow_up:Sprite2D = $Arrow1 as Sprite2D
@onready var arrow_down:Sprite2D = $Arrow2 as Sprite2D

# NEXT: auch die "sword" Particles Node hinzufuegen, sobald vorhanden
@onready var particle_nodes:Dictionary = {
	"whip" : $WhipParticles as GPUParticles2D
}

###----------PROPERTIES----------###

# NEXT: Spaeter hier noch sword hinzufuegen
var primary_weapons_available:Array[String] = [
	"whip"
]

var currently_selected_primary_weapon_index:int = 0

var weapon_icon_images:Dictionary = {
	"whip" as String : preload("res://assets/graphics/ui/ingame/primary_weapon_icons/whip_icon.png") as Resource
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.player.controls_handler.select_primary_weapon.connect(self._on_select_primary_weapon)


###----------METHODS----------###

func _primary_weapon_down() -> void:
	self.currently_selected_primary_weapon_index -= 1
	if self.currently_selected_primary_weapon_index < 0:
		self.currently_selected_primary_weapon_index = self.primary_weapons_available.size() - 1
	
	Globals.currently_used_primary_weapon = self.primary_weapons_available[self.currently_selected_primary_weapon_index]
	
	self.player.weapon_handler.select_current_weapon(Globals.currently_used_primary_weapon)
	
	# updates icon
	self.icon.texture = self.weapon_icon_images[Globals.currently_used_primary_weapon]
	
	# disables the emission of the former used particles node and enables the one currently used
	if self.currently_selected_primary_weapon_index + 1 == self.primary_weapons_available.size():
		self._disable_particle_emission(self.particle_nodes[self.primary_weapons_available[0]])
	else:
		self._disable_particle_emission(self.particle_nodes[self.primary_weapons_available[self.currently_selected_primary_weapon_index + 1]])
	self._enable_particle_emission(self.particle_nodes[self.primary_weapons_available[self.currently_selected_primary_weapon_index]])


func _primary_weapon_up() -> void:
	self.currently_selected_primary_weapon_index += 1
	if self.currently_selected_primary_weapon_index > self.primary_weapons_available.size() - 1:
		self.currently_selected_primary_weapon_index = 0
	
	Globals.currently_used_primary_weapon = self.primary_weapons_available[self.currently_selected_primary_weapon_index]
	
	self.player.weapon_handler.select_current_weapon(Globals.currently_used_primary_weapon)
	
	# updates icon
	self.icon.texture = self.weapon_icon_images[Globals.currently_used_primary_weapon]
	
	# disables the emission of the former used particles node and enables the one currently used
	self._disable_particle_emission(self.particle_nodes[self.primary_weapons_available[self.currently_selected_primary_weapon_index - 1]])
	self._enable_particle_emission(self.particle_nodes[self.primary_weapons_available[self.currently_selected_primary_weapon_index]])


func _disable_particle_emission(particles_node:GPUParticles2D) -> void:
	particles_node.emitting = false
	particles_node.visible = false


func _enable_particle_emission(particles_node:GPUParticles2D) -> void:
	particles_node.restart()
	particles_node.emitting = true
	particles_node.visible = true


###----------METHODS: CONNECTED SIGNALS----------###

func _on_select_primary_weapon(dir:String) -> void:
	if dir == "down":
		self._primary_weapon_down()
		self.arrow_up.modulate = self.normal_color
		self.arrow_down.modulate = self.red_color
		self._arrow_back_to_normal_color_timer(self.arrow_down, 0.5)
	else:
		self._primary_weapon_up()
		self.arrow_down.modulate = self.normal_color
		self.arrow_up.modulate = self.red_color
		self._arrow_back_to_normal_color_timer(self.arrow_up, 0.5)

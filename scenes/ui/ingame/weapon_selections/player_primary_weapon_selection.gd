extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var arrow_up:Sprite2D = $ArrowUp as Sprite2D
@onready var arrow_down:Sprite2D = $ArrowDown as Sprite2D

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

var normal_color:Color = Color('#0d0d0d')
var red_color:Color = Color('#c10019')


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	player.controls_handler.select_primary_weapon.connect(_on_select_primary_weapon)


###----------METHODS----------###

func _primary_weapon_down() -> void:
	currently_selected_primary_weapon_index -= 1
	if currently_selected_primary_weapon_index < 0:
		currently_selected_primary_weapon_index = primary_weapons_available.size() - 1
	
	Globals.currently_used_primary_weapon = primary_weapons_available[currently_selected_primary_weapon_index]
	
	player.weapon_handler.select_current_weapon(Globals.currently_used_primary_weapon)
	
	# disables the emission of the former used particles node and enables the one currently used
	if currently_selected_primary_weapon_index + 1 == primary_weapons_available.size():
		_disable_particle_emission(particle_nodes[primary_weapons_available[0]])
	else:
		_disable_particle_emission(particle_nodes[primary_weapons_available[currently_selected_primary_weapon_index + 1]])
	_enable_particle_emission(particle_nodes[primary_weapons_available[currently_selected_primary_weapon_index]])


func _primary_weapon_up() -> void:
	currently_selected_primary_weapon_index += 1
	if currently_selected_primary_weapon_index > primary_weapons_available.size() - 1:
		currently_selected_primary_weapon_index = 0
	
	Globals.currently_used_primary_weapon = primary_weapons_available[currently_selected_primary_weapon_index]
	
	player.weapon_handler.select_current_weapon(Globals.currently_used_primary_weapon)
	
	# disables the emission of the former used particles node and enables the one currently used
	_disable_particle_emission(particle_nodes[primary_weapons_available[currently_selected_primary_weapon_index - 1]])
	_enable_particle_emission(particle_nodes[primary_weapons_available[currently_selected_primary_weapon_index]])


func _arrow_back_to_normal_color_timer(arrow:Sprite2D) -> void:
	await get_tree().create_timer(0.5).timeout
	arrow.modulate = normal_color


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
		_primary_weapon_down()
		arrow_up.modulate = normal_color
		arrow_down.modulate = red_color
		_arrow_back_to_normal_color_timer(arrow_down)
	else:
		_primary_weapon_up()
		arrow_down.modulate = normal_color
		arrow_up.modulate = red_color
		_arrow_back_to_normal_color_timer(arrow_up)

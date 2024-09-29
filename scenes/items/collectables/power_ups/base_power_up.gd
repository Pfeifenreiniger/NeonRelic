extends Sprite2D
class_name BasePowerUp


###----------SCENE REFERENCES----------###

@onready var collectable_component: Area2D = $CollectableComponent as Area2D
@onready var despawn_collectable_component: DespawnCollectableComponent = $DespawnCollectableComponent as DespawnCollectableComponent

var screen_flash_effect_component_scene:PackedScene = preload("res://scenes/components/screen_flash_component/screen_flash_component.tscn")


###----------NODE REFERENCES----------###

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D as GPUParticles2D


###----------PROPERTIES----------###

## Color for flash effect on pick-up
@export var color_screen_flash:Color = Color(.706, 0, .737, 1)
# BUG - eigentlich muesste der Wert aus dem Inspector genommen werden. Aber zZt erkennt er den Wert dort einfach nicht an und nimmt stattdessen immer nur den Standardwert
# TEMP - deshalb hier, solange der Bug in der Engine noch vorliegt, hard coded ein Standardwert... schade!


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	collectable_component.got_collected.connect(_on_got_collected)
	
	despawn_collectable_component.despawn_animation_done.connect(_on_despawn_animation_done)
	
	gpu_particles_2d.emitting = true
	gpu_particles_2d.modulate = collectable_component.collect_effect_particles_color


###----------CONNECTED SIGNALS----------###

func _on_got_collected() -> void:
	gpu_particles_2d.emitting = false
	
	var screen_flash_effect_component_instance:ScreenFlashComponent = screen_flash_effect_component_scene.instantiate() as ScreenFlashComponent
	screen_flash_effect_component_instance.color = color_screen_flash
	screen_flash_effect_component_instance.layer = 999
	add_child(screen_flash_effect_component_instance)
	screen_flash_effect_component_instance.play_flash_animation()


func _on_despawn_animation_done() -> void:
	queue_free()

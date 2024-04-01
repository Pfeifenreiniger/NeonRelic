extends Node

###----------SCENE REFERENCES----------###

@onready var enemy_scene:CharacterBody2D = $'../' as CharacterBody2D


###----------PROPERTIES----------###

var is_invulnerable:bool = false


###----------METHODS----------###

func get_damage(amount:int) -> void:
	if not is_invulnerable:
		enemy_scene.health -= amount
		if enemy_scene.health <= 0:
			print("Gegner tot :(")
			enemy_scene.queue_free()
		else:
			_become_invulnerable(0.5)


func _become_invulnerable(timer_value:float) -> void:
	enemy_scene.animations.material.set_shader_parameter("doBlink", true)
	is_invulnerable = true
	await get_tree().create_timer(timer_value).timeout
	enemy_scene.animations.material.set_shader_parameter("doBlink", false)
	is_invulnerable = false

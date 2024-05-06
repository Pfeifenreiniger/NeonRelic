extends Node

###----------SCENE REFERENCES----------###

@onready var enemy_scene:CharacterBody2D = $'../' as CharacterBody2D


###----------PROPERTIES----------###

var is_invulnerable:bool = false


###----------METHODS----------###

func get_damage(amount:int) -> void:
	if not is_invulnerable:
		enemy_scene.health -= amount
		
		# some enemies do have an extra damage_animation AnimatedSprite2D node for damage animations
		if "damage_animation" in enemy_scene:
			enemy_scene.damage_animation.visible = true
			enemy_scene.damage_animation.play("damage")
			enemy_scene.damage_animation.animation_finished.connect(func(): enemy_scene.damage_animation.visible = false)
			await enemy_scene.damage_animation.animation_finished
		
		if enemy_scene.health <= 0:
			enemy_scene.death_animation()
		else:
			_become_invulnerable(0.3)


func _become_invulnerable(timer_value:float) -> void:
	enemy_scene.animations.material.set_shader_parameter("doBlink", true)
	is_invulnerable = true
	await get_tree().create_timer(timer_value).timeout
	enemy_scene.animations.material.set_shader_parameter("doBlink", false)
	is_invulnerable = false

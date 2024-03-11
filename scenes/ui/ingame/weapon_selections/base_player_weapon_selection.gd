extends Node
class_name BasePlayerWeaponSelection

###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var icon:Sprite2D = $Icon as Sprite2D


###----------PROPERTIES----------###

var normal_color:Color = Color('#0d0d0d')
var red_color:Color = Color('#c10019')


###----------METHODS----------###


func _arrow_back_to_normal_color_timer(arrow:Sprite2D, time:float) -> void:
	await get_tree().create_timer(time).timeout
	arrow.modulate = self.normal_color

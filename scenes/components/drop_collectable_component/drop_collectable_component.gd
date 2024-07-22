extends Node2D
class_name DropCollectableComponent


###----------PROPERTIES----------###

## Scenes of Power Ups
@export var power_up_scenes:Array[PackedScene]

## Scenes of Heal Ups
@export var heal_up_scenes:Array[PackedScene]

## General drop chance of dropping an collectable item (power- or heal-ups)
@export_range(0, 100) var drop_chance:float = 10


###----------METHODS----------###

func drop_collectable(drop_from_instance:Node2D) -> void:
	
	# if no power-up or heal-up scene was added -> no drop
	if power_up_scenes.size() == 0 && heal_up_scenes.size() == 0:
		return
	
	# check drop chance
	if randf_range(0, 101) > drop_chance:
		return
	
	# randomly pick a scene
	var all_packed_scenes:Array[PackedScene] = power_up_scenes.duplicate(true)
	all_packed_scenes.append_array(heal_up_scenes)
	var randomly_picked_scene:PackedScene = all_packed_scenes.pick_random()
	
	# instantiate randomly picked scene
	var randomly_picked_scene_instance:Sprite2D = randomly_picked_scene.instantiate() as Sprite2D
	
	# move position to the drop-from-instance's position (which droped the power-/heal-up instance)
	randomly_picked_scene_instance.global_position = drop_from_instance.global_position
	
	# add to level-scene-tree
	var collectables_node:Node = get_tree().root.get_child(-1).find_child('Collectables')
	if collectables_node == null:
		printerr("Collectables-Node des Levels konnte zum Platzieren eines Collectables Items nicht gefunden werden.") # TEMP - solange mehrere Level noch in Arbeit sind, Konsolenausgabe hier lassen
		return
	collectables_node.add_child(randomly_picked_scene_instance)

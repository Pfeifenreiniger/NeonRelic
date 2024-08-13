extends Node2D
class_name DropCollectableComponent


###----------PROPERTIES----------###

## Scenes of Power Ups
@export var power_up_scenes:Array[PackedScene]

## Scenes of Heal Ups
@export var heal_up_scenes:Array[PackedScene]

## General drop chance of dropping an collectable item (power- or heal-ups)
@export_range(0, 100) var drop_chance:float = 10

## Amount of doppable items (from 1 to 3)
@export_range(1, 3) var amount_of_drops:int = 1


###----------METHODS----------###

func drop_collectable(drop_from_instance:Node2D) -> void:
	
	# if no power-up or heal-up scene was added -> no drop
	if power_up_scenes.size() == 0 && heal_up_scenes.size() == 0:
		return
	
	# check drop chance
	if randf_range(0, 101) > drop_chance:
		return
	
	# access level-scene-tree
	var collectables_node:Node = get_tree().root.get_child(-1).find_child('Collectables')
	if collectables_node == null:
		printerr("Collectables-Node des Levels konnte zum Platzieren eines Collectables Items nicht gefunden werden.") # TEMP - solange mehrere Level noch in Arbeit sind, Konsolenausgabe hier lassen
		return
	
	# merge both packed scnes arrays
	var all_packed_scenes:Array[PackedScene] = power_up_scenes.duplicate(true)
	all_packed_scenes.append_array(heal_up_scenes)
	
	# spawn position's x-axis offset in pixels
	var x_axis_offsets:Array[int] = [0, -25, 25]
	var y_axis_offset:int = -10
	
	for i in amount_of_drops:
		# randomly pick a scene
		var randomly_picked_scene:PackedScene = all_packed_scenes.pick_random()
		
		# instantiate randomly picked scene
		var randomly_picked_scene_instance:Sprite2D = randomly_picked_scene.instantiate() as Sprite2D
		
		# move position to the drop-from-instance's position (which droped the power-/heal-up instance), apply x- and y-axis-offset
		var spawn_position:Vector2 = drop_from_instance.global_position
		spawn_position.x += x_axis_offsets[i]
		spawn_position.y += y_axis_offset
		randomly_picked_scene_instance.global_position = spawn_position
		
		# add to level-scene-tree
		collectables_node.call_deferred("add_child", randomly_picked_scene_instance)

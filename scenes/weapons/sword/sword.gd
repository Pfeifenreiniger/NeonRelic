extends Node2D


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

# hitbox zones
@onready var hitbox_zone_combo_1:Area2D = $HitboxZoneCombo1 as Area2D
@onready var hitbox_zone_combo_2:Area2D = $HitboxZoneCombo2 as Area2D
@onready var hitbox_zone_combo_3:Area2D = $HitboxZoneCombo3 as Area2D
# hitboxes
@onready var hitbox_combo_1:CollisionShape2D = $HitboxZoneCombo1/Hitbox as CollisionShape2D
@onready var hitbox_combo_2:CollisionShape2D = $HitboxZoneCombo2/Hitbox as CollisionShape2D
@onready var hitbox_combo_3:CollisionShape2D = $HitboxZoneCombo3/Hitbox as CollisionShape2D


###----------PROPERTIES----------###

const IS_SWORD:bool = true

const hitbox_positions:Dictionary = {
	1 as int : {
		"right" as String : Vector2i(19, -21) as Vector2i,
		"left" as String : Vector2i(-17, -21) as Vector2i
	},
	2 as int : {
		"right" as String : Vector2i(12, -11) as Vector2i,
		"left" as String : Vector2i(-14, -11) as Vector2i
	},
	3 as int : {
		"right" as String : Vector2i(35, 6) as Vector2i,
		"left" as String : Vector2i(-35, 6) as Vector2i
	}
}

###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	global_position = player.global_position
	if player.movement_handler.is_attacking and 'IS_SWORD' in player.weapon_handler.current_weapon:
		check_current_hitbox_state()


###----------METHODS----------###

func adjust_hitbox_position(combo_phase:int) -> void:
	
	var player_side:String
	
	if "right" in player.animations_handler.current_animation:
		player_side = "right"
	else:
		player_side = "left"

	if combo_phase == 1:
		hitbox_combo_1.position = hitbox_positions[combo_phase][player_side]
	elif combo_phase == 2:
		hitbox_combo_2.position = hitbox_positions[combo_phase][player_side]
	else:
		hitbox_combo_3.position = hitbox_positions[combo_phase][player_side]


func activate_hitbox(combo_phase:int, current_frame:int) -> void:
	if combo_phase == 1:
		if current_frame >= 5 or current_frame <= 7:
			hitbox_combo_1.disabled = false
	elif combo_phase == 2:
		if current_frame >= 3 or current_frame <= 7:
			hitbox_combo_2.disabled = false
	else:
		if current_frame >= 3 or current_frame <= 4:
			hitbox_combo_3.disabled = false


func deactivate_hitbox(combo_phase:int) -> void:
	if combo_phase == 1:
		hitbox_combo_1.disabled = true
	elif combo_phase == 2:
		hitbox_combo_2.disabled = true
	else:
		hitbox_combo_3.disabled = true


func check_current_hitbox_state() -> void:
	var current_combo_phase:int = int(player.animations_handler.current_animation.split('_')[-1])
	var current_animation_frame:int = player.animations_handler.animations.get_frame()
	activate_hitbox(current_combo_phase, current_animation_frame)


# ToDo - Signals schreiben, die beim Eintritt in die HitboxZones getriggert werden, um Gegner Schaden zuzufuegen und zurueckzustossen

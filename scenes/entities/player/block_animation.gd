extends Node

###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player
@onready var animations_handler:PlayerAnimationsHandler = $".." as PlayerAnimationsHandler


###----------NODE REFERENCES----------###

@onready var shield_hitboxes:Dictionary = {
	"stand_left" as String : $"ShieldHitboxes/StandLeftArea2D" as Area2D,
	"stand_right" as String : $"ShieldHitboxes/StandRightArea2D" as Area2D,
	"duck_left" as String : $"ShieldHitboxes/DuckLeftArea2D" as Area2D,
	"duck_right" as String : $"ShieldHitboxes/DuckRightArea2D" as Area2D
}


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	shield_hitboxes["stand_left"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("stand_left")
	)
	shield_hitboxes["stand_right"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("stand_right")
	)
	shield_hitboxes["duck_left"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("duck_left")
	)
	shield_hitboxes["duck_right"].area_entered.connect(
		_on_shield_hitbox_area_entered.bind("duck_right")
	)


###----------METHODS: PER FRAME CALLED----------###

func _physics_process(_delta: float) -> void:
	$"ShieldHitboxes".global_position = player.global_position


###----------METHODS----------###


func activate_hitbox(shield_hitbox_name:String) -> void:
	if !(shield_hitbox_name in ["stand_left", "stand_right", "duck_left", "duck_right"]):
		return
	
	var hitbox_collision_shape:CollisionShape2D = shield_hitboxes[shield_hitbox_name].get_children()[0]
	hitbox_collision_shape.disabled = false


func deactivate_hitbox(shield_hitbox_name:String) -> void:
	if !(shield_hitbox_name in ["stand_left", "stand_right", "duck_left", "duck_right"]):
		return
	
	var hitbox_collision_shape:CollisionShape2D = shield_hitboxes[shield_hitbox_name].get_children()[0]
	hitbox_collision_shape.disabled = true


###----------METHODS: CONNECTED SIGNALS----------###

func _on_shield_hitbox_area_entered(other_area:Area2D, shield_hitbox:String) -> void:
	if "IS_LASER_BEAM" in other_area:
		# TODO: Verpuff-Animation mit Partikeln abspielen
		other_area.get_parent().queue_free()

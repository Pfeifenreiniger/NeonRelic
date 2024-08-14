extends AnimatedSprite2D
class_name BaseCollectablesContainer


###----------NODE REFERENCES----------###

@onready var hitbox: Area2D = $Hitbox as Area2D
@onready var drop_collectable_component: DropCollectableComponent = $DropCollectableComponent as DropCollectableComponent


###----------PROPERTIES----------###

var collapsing_animation_started:bool = false


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.body_exited.connect(_on_hitbox_body_exited)


###----------METHODS----------###

func _deactivate_hitbox_collision_layers_and_masks() -> void:
	## deactivate hitbox layer and masks when it got hit in first instance
	
	hitbox.set_collision_layer_value(4, false)
	hitbox.set_collision_mask_value(1, false)
	hitbox.set_collision_mask_value(2, false)


func _play_collapsing_animation_and_drop_collectables() -> void:
	
	# BUG - anscheinend haben manche Instanzen der Scene bei der Animation looping aktiv, obwohl es im Editor so nicht eingestellt ist, daher wird hier der loop im Code nochmal deaktiviert
	sprite_frames.set_animation_loop('collapsing', false)
	
	play('collapsing')
	await animation_finished
	drop_collectable_component.drop_collectable(self)
	queue_free()


###----------CONNECTED SIGNALS----------###

func _on_hitbox_area_entered(other_area:Area2D) -> void:
	# only player's sword or whip can affect collectables container
	if "IS_SWORD" in other_area.owner || "IS_WHIP" in other_area.owner:
		_deactivate_hitbox_collision_layers_and_masks()
		_play_collapsing_animation_and_drop_collectables()


func _on_hitbox_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		if body.movement_handler.is_rolling:
			_deactivate_hitbox_collision_layers_and_masks()
			_play_collapsing_animation_and_drop_collectables()


func _on_hitbox_body_exited(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		if body.movement_handler.is_rolling:
			_deactivate_hitbox_collision_layers_and_masks()
			_play_collapsing_animation_and_drop_collectables()

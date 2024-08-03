extends AnimatedSprite2D
class_name BaseCollectablesContainer


###----------NODE REFERENCES----------###

@onready var hitbox: Area2D = $Hitbox as Area2D
@onready var drop_collectable_component: DropCollectableComponent = $DropCollectableComponent as DropCollectableComponent


###----------PROPERTIES----------###

var collapsing_animation_started:bool = false


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	hitbox.area_entered.connect(_in_hitbox_area_entered)


###----------METHODS----------###

func _play_collapsing_animation_and_drop_collectables() -> void:
	
	# BUG - anscheinend haben manche Instanzen der Scene bei der Animation looping aktiv, obwohl es im Editor so nicht eingestellt ist, daher wird hier der loop im Code nochmal deaktiviert
	sprite_frames.set_animation_loop('collapsing', false)
	
	play('collapsing')
	await animation_finished
	drop_collectable_component.drop_collectable(self)
	queue_free()


###----------CONNECTED SIGNALS----------###

func _in_hitbox_area_entered(other_area:Area2D) -> void:
	# only player's sword or whip can affect collectables container
	if "IS_SWORD" in other_area.owner || "IS_WHIP" in other_area.owner:
		# deactivate hitbox layer and mask when it got hit in first instance
		hitbox.set_collision_layer_value(4, false)
		hitbox.set_collision_mask_value(2, false)
		
		_play_collapsing_animation_and_drop_collectables()

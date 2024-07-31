extends AnimatedSprite2D
class_name BaseCollectablesContainer


###----------NODE REFERENCES----------###

@onready var hitbox: Area2D = $Hitbox as Area2D
@onready var drop_collectable_component: DropCollectableComponent = $DropCollectableComponent as DropCollectableComponent


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	hitbox.area_entered.connect(_in_hitbox_area_entered)


###----------METHODS----------###

func _play_collapsing_animation_and_drop_components() -> void:
	
	play('collapsing')
	await animation_looped
	drop_collectable_component.drop_collectable(self)
	queue_free()


###----------CONNECTED SIGNALS----------###

func _in_hitbox_area_entered(other_area:Area2D) -> void:
	# only player's sword or whip can affect collectables container
	if "IS_SWORD" in other_area.owner || "IS_WHIP" in other_area.owner:
		_play_collapsing_animation_and_drop_components()

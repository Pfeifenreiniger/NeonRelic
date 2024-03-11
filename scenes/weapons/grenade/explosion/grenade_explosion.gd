extends AnimatedSprite2D


###----------SCENE REFERENCES----------###

@onready var grenade_effect_scene = preload("res://scenes/weapons/grenade/effect/grenade_effect.tscn") as PackedScene
var grenade_effect_node:Area2D

@onready var current_level_scene:Node2D = $'../../../../../../' as Node2D


###----------NODE REFERENCES----------###

@onready var hit_area:Area2D = $HitArea as Area2D


###----------CUSTOM SIGNALS----------###

signal hide_grenade
signal destroy_grenade


###----------PROPERTIES----------###

var grenade_type:String

# status
var grenade_hidden:bool = false
var done_damage_to_enemy:bool = false

# attack damage stats
var damage:int = 40 # TEMP - den Schaden spaeter noch balancen


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	self.animation_finished.connect(self._on_animation_finished)
	self.hit_area.body_entered.connect(self._on_hit_area_body_entered)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta: float) -> void:
	self._check_to_hide_grenade()


###----------METHODS----------###

func _check_to_hide_grenade() -> void:
	if not self.grenade_hidden and frame >= 2:
		# hide parent scene (grenade sprite)
		self.hide_grenade.emit()
		self.grenade_hidden = true
		
		# add grenade effect scene to current level (main) scene
		self._add_grenade_effect_to_level_scene()


func _add_grenade_effect_to_level_scene() -> void:
	self.grenade_effect_node = grenade_effect_scene.instantiate() as Area2D
	self.grenade_effect_node.grenade_type = grenade_type
	self.grenade_effect_node.global_position = global_position
	self.current_level_scene.get_node('FloorEffects').add_child(grenade_effect_node)


###----------CONNECTED SIGNALS----------###

func _on_animation_finished():	
	# emits destroy_grenade signal to get rid of parent scene (grenade scene)
	self.destroy_grenade.emit()
	self.queue_free()


func _on_hit_area_body_entered(body:Node2D) -> void:
	if not self.done_damage_to_enemy and "IS_ENEMY" in body:
		self.done_damage_to_enemy = true
		# ToDo - do actual damage to enemy

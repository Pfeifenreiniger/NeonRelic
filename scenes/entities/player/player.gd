extends CharacterBody2D


###------NODE REFERENCES------###

@onready var hitbox:CollisionShape2D = $HitBox as CollisionShape2D

# Markers
@onready var weapon_stand_whip_attack_right_pos:Marker2D = $Markers/WeaponStandWhipAttackRight as Marker2D
@onready var weapon_stand_whip_attack_left_pos:Marker2D = $Markers/WeaponStandWhipAttackLeft as Marker2D
@onready var weapon_duck_whip_attack_right_pos:Marker2D = $Markers/WeaponDuckWhipAttackRight as Marker2D
@onready var weapon_duck_whip_attack_left_pos:Marker2D = $Markers/WeaponDuckWhipAttackLeft as Marker2D
@onready var secondary_weapon_start_pos:Marker2D = $Markers/SecondaryWeaponStart as Marker2D


###----------SCENE REFERENCES----------###

@onready var movement_handler:Node = $PlayerMovementHandler as Node
@onready var health_handler:Node = $PlayerHealthHandler as Node
@onready var invulnerable_handler:Node = $PlayerInvulnerableHandler as Node
@onready var stamina_handler:Node = $PlayerStaminaHandler as Node
@onready var controls_handler:Node = $PlayerControlsHandler as Node
@onready var ledge_climb_handler:Node = $PlayerLedgeClimbHandler as Node
@onready var animations_handler:Node = $PlayerAnimationsHandler as Node
@onready var hitbox_handler:Node = $PlayerHitboxHandler as Node
@onready var side_collision_boxes_handler:Node = $PlayerSideCollisionBoxesHandler as Node
@onready var weapon_handler:Node = $PlayerWeaponHandler as Node


###----------PROPERTIES----------###

const IS_PLAYER:bool = true


extends CharacterBody2D
class_name Player

###----------SCENE REFERENCES----------###

@onready var movement_handler:PlayerMovementHandler = $PlayerMovementHandler as PlayerMovementHandler
@onready var health_handler:PlayerHealthHandler = $PlayerHealthHandler as PlayerHealthHandler
@onready var invulnerable_handler:PlayerInvulnerableHandler = $PlayerInvulnerableHandler as PlayerInvulnerableHandler
@onready var stamina_handler:PlayerStaminaHandler = $PlayerStaminaHandler as PlayerStaminaHandler
@onready var controls_handler:PlayerControlsHandler = $PlayerControlsHandler as PlayerControlsHandler
@onready var ledge_climb_handler:PlayerLedgeClimbHandler = $PlayerLedgeClimbHandler as PlayerLedgeClimbHandler
@onready var animations_handler:PlayerAnimationsHandler = $PlayerAnimationsHandler as PlayerAnimationsHandler
@onready var hitbox_handler:PlayerHitboxHandler = $PlayerHitboxHandler as PlayerHitboxHandler
@onready var side_collision_boxes_handler:PlayerSideCollisionBoxesHandler = $PlayerSideCollisionBoxesHandler as PlayerSideCollisionBoxesHandler
@onready var weapon_handler:PlayerWeaponHandler = $PlayerWeaponHandler as PlayerWeaponHandler


###------NODE REFERENCES------###

@onready var hitbox:CollisionShape2D = $HitBox as CollisionShape2D

# Markers
@onready var weapon_stand_whip_attack_right_pos:Marker2D = $Markers/WeaponStandWhipAttackRight as Marker2D
@onready var weapon_stand_whip_attack_left_pos:Marker2D = $Markers/WeaponStandWhipAttackLeft as Marker2D
@onready var weapon_duck_whip_attack_right_pos:Marker2D = $Markers/WeaponDuckWhipAttackRight as Marker2D
@onready var weapon_duck_whip_attack_left_pos:Marker2D = $Markers/WeaponDuckWhipAttackLeft as Marker2D
@onready var secondary_weapon_start_pos:Marker2D = $Markers/SecondaryWeaponStart as Marker2D


###----------PROPERTIES----------###

const IS_PLAYER:bool = true

extends CharacterBody2D


###----------SCENE REFERENCES----------###

@onready var movement_handler:Node = $PlayerMovementHandler
@onready var health_handler:Node = $PlayerHealthHandler
@onready var invulnerable_handler:Node = $PlayerInvulnerableHandler
@onready var stamina_handler:Node = $PlayerStaminaHandler
@onready var controls_handler:Node = $PlayerControlsHandler
@onready var ledge_climb_handler:Node = $PlayerLedgeClimbHandler
@onready var animations_handler:Node = $PlayerAnimationsHandler
@onready var hitbox_handler:Node = $PlayerHitboxHandler
@onready var side_collision_boxes_handler:Node = $PlayerSideCollisionBoxesHandler
@onready var weapon_handler:Node = $PlayerWeaponHandler


###------NODE REFERENCES------###

@onready var hitbox:CollisionShape2D = $HitBox

# Markers
@onready var weapon_stand_whip_attack_right_pos:Marker2D = $Markers/WeaponStandWhipAttackRight
@onready var weapon_stand_whip_attack_left_pos:Marker2D = $Markers/WeaponStandWhipAttackLeft
@onready var weapon_duck_whip_attack_right_pos:Marker2D = $Markers/WeaponDuckWhipAttackRight
@onready var weapon_duck_whip_attack_left_pos:Marker2D = $Markers/WeaponDuckWhipAttackLeft
@onready var secondary_weapon_start_pos:Marker2D = $Markers/SecondaryWeaponStart

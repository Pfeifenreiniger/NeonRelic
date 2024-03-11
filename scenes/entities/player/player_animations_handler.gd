extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------NODE REFERENCES----------###

@onready var climb_up_ledge_animation:Node = $ClimbUpLedgeAnimation as Node
@onready var side_roll_animation:Node = $SideRollAnimation as Node
@onready var whip_attack_charge_shader_animation:Node = $WhipAttackAnimation/WhipAttackChargeShaderAnimation as Node
@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D


###----------PROPERTIES----------###

var current_animation:String
var animation_to_change:bool = false
var start_run_animation:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true


###----------PROPERTIES: CUSTOM SIGNALS----------###

signal from_to_duck_to_is_duck
signal from_to_duck_to_stand
signal throw_secondary_weapon_frame


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set up animations
	self.animations.animation_finished.connect(on_animation_finished)
	self.animations.frame_changed.connect(on_frame_changed)
	self.current_animation = "run_right"
	self.loop_animation = true


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	self.place_animations_sprites_at_players_position()
	if self.animation_to_change:
		self.select_animation()


###----------METHODS----------###

func place_animations_sprites_at_players_position() -> void:
	self.animations.global_position = player.global_position


func select_animation() -> void:
	self.animations.stop()
	self.animations.play(current_animation)
	if self.start_run_animation:
		self.animations.set_frame(4)
		self.start_run_animation = false
	self.animation_to_change = false
	if self.loop_animation:
		self.animation_frames_forwards = true


###----------CONNECTED SIGNALS----------###

func on_animation_finished() -> void:
	if self.loop_animation:
		self.animations.stop()
		if self.animation_frames_forwards:
			self.animations.play_backwards(self.current_animation)
			self.animation_frames_forwards = false
		else:
			self.animations.play(self.current_animation)
			self.animation_frames_forwards = true
	
	# to-duck animation is a one-way animation (to ducking-animation or to stand-animation)
	elif self.player.movement_handler.to_duck:
		self.player.movement_handler.to_duck = false
		if self.player.movement_handler.will_duck:
			self.player.movement_handler.will_duck = false
			self.player.movement_handler.is_duck = true
			self.player.hitbox_handler.resize_hitbox(false, true)
			self.player.weapon_handler.secondary_weapons.adjust_secondary_weapon_start_position('duck')
			if "left" in self.current_animation:
				self.current_animation = "duck_left"
			else:
				self.current_animation = "duck_right"
		else:
			if "left" in self.current_animation:
				self.current_animation = "stand_left"
			else:
				self.current_animation = "stand_right"
		
		self.loop_animation = true
		self.animation_to_change = true

	elif self.player.movement_handler.is_climbing_ledge:
		self.player.movement_handler.is_climbing_ledge = false
		self.loop_animation = true
		self.animation_to_change = true
		if "left" in self.current_animation:
			self.current_animation = "stand_left"
		else:
			self.current_animation = "stand_right"
	
	elif self.player.movement_handler.is_rolling:
		self.player.movement_handler.is_rolling = false
		self.player.stamina_handler.stamina_can_refresh = true
		self.loop_animation = true
		self.animation_to_change = true
		self.side_roll_animation.side_roll_tween = null
	
	elif self.player.movement_handler.is_attacking:
		# whip attack
		if "whip_attack" in self.current_animation:
			var side:String = ""
			if "right" in self.current_animation:
				side = "right"
			else:
				side = "left"
			if "1" in self.current_animation:
				if not self.player.weapon_handler.current_weapon.charges_whip_attack:
					# if charge animation was played -> stop it
					if "stand" in self.current_animation:
						self.current_animation = "stand_whip_attack_%s_2" % side
					else:
						self.current_animation = "duck_whip_attack_%s_2" % side
					self.animation_to_change = true
					self.player.weapon_handler.current_weapon.can_whip_attack_charge = false
					self.player.weapon_handler.current_weapon.reset_whip_attack_damage()
					self.player.invulnerable_handler.become_invulnerable(0.5, false)
					self.whip_attack_charge_shader_animation.stop_whip_attack_shader_animation()
				else:
					if not self.whip_attack_charge_shader_animation.do_whip_attack_shader_animation:
						self.animations.pause()
						self.whip_attack_charge_shader_animation.start_whip_attack_shader_animation()
			elif "2" in self.current_animation:
				# play whip attack
				if not self.player.weapon_handler.current_weapon.do_attack_animation:
					self.player.weapon_handler.current_weapon.attack_side = side
					self.player.weapon_handler.current_weapon.visible = true
					self.player.weapon_handler.current_weapon.set_pos_to_player(side)
					self.player.weapon_handler.current_weapon.hitbox_zone.reset_hitbox_size()
					self.player.weapon_handler.current_weapon.play('attack_%s' % side)
					self.player.weapon_handler.current_weapon.init_attack_animation(side)
				# change to attack 3 animation
				if self.player.weapon_handler.current_weapon.do_attack_animation and self.player.weapon_handler.current_weapon.done_attack_animation:
					self.player.weapon_handler.current_weapon.finish_attack_animation()
					self.animation_to_change = true
					if "stand" in current_animation:
						self.current_animation = "stand_whip_attack_%s_3" % side
					else:
						self.current_animation = "duck_whip_attack_%s_3" % side
			elif "3" in self.current_animation:
				# change to idle animation
				self.loop_animation = true
				self.animation_to_change = true
				self.player.movement_handler.is_attacking = false
				self.player.weapon_handler.current_weapon.can_whip_attack_charge = true
				self.player.stamina_handler.stamina_can_refresh = true
				if "stand" in self.current_animation:
					self.current_animation = "stand_%s" % side
				else:
					self.current_animation = "duck_%s" % side
					if not Input.is_action_pressed("down"):
						# simulate duck-input and key-release from player for proper animation
						Input.action_press("down")
						await get_tree().create_timer(0.25).timeout
						Input.action_release("down")
					
	elif self.player.movement_handler.is_throwing:
		self.player.movement_handler.is_throwing = false
		self.current_animation = self.current_animation.split('_throw_')[0] + "_" + self.current_animation.split('_throw_')[1]
		self.loop_animation = true
		self.animation_to_change = true
		if "duck" in self.current_animation and not Input.is_action_pressed("down"):
			# simulate duck-input and key-release from player for proper animation
			Input.action_press("down")
			await get_tree().create_timer(0.25).timeout
			Input.action_release("down")


func on_frame_changed() -> void:
	# frame index 4 starts actually throw of secondary weapon (e.g. grenade)
	if "throw" in self.current_animation:
		if self.animations.frame == 4:
			self.throw_secondary_weapon_frame.emit()
			

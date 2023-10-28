extends CharacterBody2D

# movement related properties
var direction:Vector2 = Vector2.ZERO

const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED

const JUMP_VELOCITY:int = -200

var BASE_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = BASE_GRAVITY

var to_duck:bool = false
var is_duck:bool = false
var will_duck:bool = false

# animation related properties
@onready var animations:AnimatedSprite2D = $Animations
var current_animation:String
var animation_to_change:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true


func _ready():
	animations.animation_finished.connect(on_animation_finished)
	current_animation = "run_right"
	loop_animation = true


func _process(_delta):
	# check if player released an animation status key (e.g. duck key)
	check_player_key_input_status()
	# select current animation
	if animation_to_change:
		select_animation()


func _physics_process(delta):
	# move player
	move(delta)


func check_player_key_input_status():
	# check if player does not want to duck anymore
	if Input.is_action_just_released("ingame_duck"):
		if is_duck:
			is_duck = false
			to_duck = true

		elif to_duck:
			# play remaining to-duck animation backwards
			var last_frame:int = animations.frame
			animations.stop()
			animations.set_frame(last_frame)
		
		will_duck = false
		loop_animation = false
		
		if "left" in current_animation:
			current_animation = "to_duck_left"
			animations.play_backwards(current_animation)
		else:
			current_animation = "to_duck_right"
			animations.play_backwards(current_animation)


func move_x() -> void:
	if not to_duck and not is_duck:
		if Input.is_action_pressed("ingame_move_right"):
			direction.x = 1
			if current_animation != "run_right":
				current_animation = "run_right"
				animation_to_change = true
				loop_animation = true
		elif Input.is_action_pressed("ingame_move_left"):
			direction.x = -1
			if current_animation != "run_left":
				current_animation = "run_left"
				animation_to_change = true
				loop_animation = true
		else:
			direction.x = 0
			if current_animation != "stand_right" and current_animation != "stand_left" and (not to_duck or not is_duck):
				if current_animation == "run_right":
					current_animation = "stand_right"
					loop_animation = true
				else:
					current_animation = "stand_left"
					loop_animation = true
				animation_to_change = true
		velocity.x = direction.x * current_speed


func move_y(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y += current_gravity * delta
	
	# player ducks
	if direction.x == 0:
		if Input.is_action_pressed("ingame_duck"):
			if is_on_floor():
				if not to_duck and not is_duck:
					to_duck = true
					will_duck = true
					if "left" in current_animation:
						current_animation = "to_duck_left"
					else:
						current_animation = "to_duck_right"
					loop_animation = false
					animation_to_change = true


func move(delta):
	move_x()
	move_y(delta)
	move_and_slide()


func select_animation() -> void:
	animations.stop()
	animations.play(current_animation)
	animation_to_change = false
	if loop_animation:
		animation_frames_forwards = true


func on_animation_finished():
	
	if loop_animation:
		animations.stop()
		if animation_frames_forwards:
			animations.play_backwards(current_animation)
			animation_frames_forwards = false
		else:
			animations.play(current_animation)
			animation_frames_forwards = true
	
	# to-duck animation is a one-way animation (to ducking-animation or to stand-animation)
	elif to_duck:
		to_duck = false
		if will_duck:
			will_duck = false
			is_duck = true
			if "left" in current_animation:
				current_animation = "duck_left"
			else:
				current_animation = "duck_right"
		else:
			if "left" in current_animation:
				current_animation = "stand_left"
			else:
				current_animation = "stand_right"
		
		loop_animation = true
		animation_to_change = true


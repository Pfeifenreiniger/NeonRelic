extends CharacterBody2D

# movement related properties
var direction:Vector2 = Vector2.ZERO

const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED

const BASE_JUMP_VELOCITY:int = -350
var current_jump_velocity:int = BASE_JUMP_VELOCITY

var BASE_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = BASE_GRAVITY

# player y-movement properties
var to_duck:bool = false
var is_duck:bool = false
var will_duck:bool = false
var is_jumping:bool = false
var is_falling:bool = false


# animation related properties
@onready var animations:AnimatedSprite2D = $Animations
var current_animation:String
var animation_to_change:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true

# hitbox related properties
@onready var hit_box:CollisionShape2D = $HitBox
var hit_box_height_full:float = 76
var hit_box_height_reduced:float = 58
var hit_box_y_full:float = 4
var hit_box_y_reduced:float = 12


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
	if direction.x == 0 and Input.is_action_just_released("ingame_duck"):
		if is_duck:
			is_duck = false
			to_duck = true
			resize_hit_box(true, false)

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
	if not to_duck and not is_duck and not is_jumping and not is_falling:
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
			if not "stand" in current_animation and not to_duck and not is_duck and not is_falling and not is_jumping:
				if "right" in current_animation:
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
		if not is_duck and not to_duck:
			velocity.y += current_gravity * delta
		if velocity.y > 0:
			if not is_falling:
				is_jumping = false
				is_falling = true
				direction.y = 1
				if "left" in current_animation:
					current_animation = "fall_down_left"
				else:
					current_animation = "fall_down_right"
				loop_animation = false
				animation_to_change = true
	else:
		if is_falling:
			is_falling = false
			direction.y = 0
		# player jumping
		if Input.is_action_pressed("ingame_jump") and not is_duck and not to_duck:
			if direction.y == 0 and not is_jumping and not is_falling:
				direction.y = -1
				is_jumping = true
				if "left" in current_animation:
					current_animation = "jump_up_left"
				else:
					current_animation = "jump_up_right"
				loop_animation = false
				animation_to_change = true
				velocity.y += current_jump_velocity
		# player ducking
		elif Input.is_action_pressed("ingame_duck") and not is_jumping and not is_falling:
			if direction.x == 0 and not to_duck and not is_duck:
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


func resize_hit_box(to_full:bool=false, reduce:bool=false):
	if to_full:
		hit_box.position.y = hit_box_y_full
		hit_box.shape.set_height(hit_box_height_full)
	elif reduce:
		hit_box.position.y = hit_box_y_reduced
		hit_box.shape.set_height(hit_box_height_reduced)


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
			resize_hit_box(false, true)
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

	elif is_jumping or is_falling:
		var last_frame:int = animations.frame
		print("Hallo")

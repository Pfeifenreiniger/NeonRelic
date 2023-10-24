extends CharacterBody2D

# movement related properties
var direction:Vector2 = Vector2.ZERO
const BASE_SPEED:int = 200
var current_speed:int = BASE_SPEED
const JUMP_VELOCITY:int = -200
var BASE_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = BASE_GRAVITY

# animation related properties
@onready var animations:AnimatedSprite2D = $Animations
var current_animation:String
var animation_to_change:bool = false
var animation_frames_forwards:bool = true


func _ready():
	animations.animation_finished.connect(on_animation_finished)
	current_animation = "run_right"


func _process(_delta):
	# select current animation
	if animation_to_change:
		select_animation()


func _physics_process(delta):
	# move player
	move(delta)


func move_x() -> void:
	if Input.is_action_pressed("ingame_move_right"):
		direction.x = 1
		if current_animation != "run_right":
			current_animation = "run_right"
			animation_to_change = true
	elif Input.is_action_pressed("ingame_move_left"):
		direction.x = -1
		if current_animation != "run_left":
			current_animation = "run_left"
			animation_to_change = true
	else:
		direction.x = 0
		if current_animation != "stand_right" and current_animation != "stand_left":
			if current_animation == "run_right":
				current_animation = "stand_right"
			else:
				current_animation = "stand_left"
			animation_to_change = true
	velocity.x = direction.x * current_speed


func move_y(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y += current_gravity * delta


func move(delta):
	move_x()
	move_y(delta)
	move_and_slide()


func select_animation() -> void:
	animations.stop()
	animations.play(current_animation)
	animation_to_change = false
	animation_frames_forwards = true


func on_animation_finished():
	animations.stop()
	
	if animation_frames_forwards:
		animations.play_backwards(current_animation)
		animation_frames_forwards = false
	else:
		animations.play(current_animation)
		animation_frames_forwards = true

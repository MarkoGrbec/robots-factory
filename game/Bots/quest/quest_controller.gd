class_name QuestController extends Node2D

# Keep this in sync with the AnimationTree's state names.
const States = {
	IDLE = "idle",
	WALK = "walk",
	RUN = "run",
	FLY = "fly",
	FALL = "fall",
}

const RUN_SPEED = 200.0
const WALK_SPEED = 100.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
#const JUMP_VELOCITY = -400.0
## Maximum speed at which the player can fall.
#const TERMINAL_VELOCITY = 400

#var falling_slow = false
#var falling_fast = false
#var no_move_horizontal_time = 0.0

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var visuals: Node2D
@onready var sprite_scale = visuals.scale.x
@export var body: CharacterBody2D
@export var animation_tree: AnimationTree

func _ready():
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	#var is_jumping = false
	#if Input.is_action_just_pressed("jump"):
		#is_jumping = try_jump()
	#elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		## The player let go of jump early, reduce vertical momentum.
		#velocity.y *= 0.6
	## Fall.
	#velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	var speed = RUN_SPEED
	if Input.is_action_pressed("walk"):
		speed = WALK_SPEED
	
	
	var y_direction := 0 #Input.get_axis("move_up", "move_down")
	var x_direction := 0 #Input.get_axis("move_left", "move_right")
	var direction = Vector2(x_direction, y_direction).normalized() * speed
	body.velocity.y = move_toward(body.velocity.y, direction.y, ACCELERATION_SPEED * delta)
	body.velocity.x = move_toward(body.velocity.x, direction.x, ACCELERATION_SPEED * delta)

	#if no_move_horizontal_time > 0.0:
		## After doing a hard fall, don't move for a short time.
		#velocity.x = 0.0
		#no_move_horizontal_time -= delta
	
	# turn sprite
	if not is_zero_approx(body.velocity.x):
		if body.velocity.x > 0.0:
			visuals.scale.x = 1.0 * sprite_scale
		else:
			visuals.scale.x = -1.0 * sprite_scale
	elif not is_zero_approx(body.velocity.y):
		if body.velocity.y < 0.0:
			visuals.scale.x = 1.0 * sprite_scale
		else:
			visuals.scale.x = -1.0 * sprite_scale
	body.move_and_slide()

	# After applying our motion, update our animation to match.

	# Calculate falling speed for animation purposes.
	#if velocity.y >= TERMINAL_VELOCITY:
		#falling_fast = true
		#falling_slow = false
	#elif velocity.y > 300:
		#falling_slow = true

	#if is_jumping:
		#animation_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	#if is_on_floor():
	# Most animations change when we run, land, or take off.
		#if falling_fast:
			#animation_tree["parameters/land_hard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			#no_move_horizontal_time = 0.4
		#elif falling_slow:
			#animation_tree["parameters/land/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	
	var time_scale = abs(body.velocity.x)
	if time_scale or body.velocity.y:
		if body.velocity.y:
			time_scale += abs(body.velocity.y)
			if body.velocity.x:
				time_scale *= 0.701
	elif body.velocity.y:
		time_scale = abs(body.velocity.x)
	if abs(body.velocity.x) > 50 or abs(body.velocity.y) > 50:
		animation_tree["parameters/state/transition_request"] = States.RUN
		animation_tree["parameters/run_timescale/scale"] = time_scale / 75
	elif body.velocity.x or body.velocity.y:
		animation_tree["parameters/state/transition_request"] = States.WALK
		animation_tree["parameters/walk_timescale/scale"] = time_scale / 12
	else:
		animation_tree["parameters/state/transition_request"] = States.IDLE

	#falling_fast = false
	#falling_slow = false
	#else:
		#if velocity.y > 0:
			#animation_tree["parameters/state/transition_request"] = States.FALL
		#else:
			#animation_tree["parameters/state/transition_request"] = States.FLY



#func try_jump() -> bool:
	#if is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#return true
	#return false

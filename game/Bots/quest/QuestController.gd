class_name QuestController extends Node2D

enum State{
	CHASE,
	RUN,
	RUN_AWAY,
	RETRIVE,
	RETRIVE_AWAY,
	BROKEN,
	BRING_MATS,
	PATROL
}

@export var movement: Movement
@export var body: CPMob
@export var agent: NavigationAgent2D
@export var timer: Timer

var state: State = State.CHASE
var target
var direction: Vector2 = Vector2.ZERO
var starting_point: Vector2
## [Vector2i, [position, id_tile]]
var coords
## [[bots], coords]
var enemy_tunnel

var next_position: Vector2
var avoid_direction: Vector2

var target_position

var nav_dir

var nav_time = 0
var nav_angle: float = 90
var nav_int: int = 0
var nav_count: int = 0
var nav_index_target: int = 0

## only move if it is not talking to player
func is_at_target_layer():
	if body is CPQuest:
		return not body.is_talking_to_me
	else:
		return true

func _physics_process(_delta: float) -> void:
	if not is_at_target_layer():
		return
	# set target
	if target is CPMob:
		target_position = target.global_position
	elif target is Vector2:
		target_position = target
	
	if target_position:
		agent.target_position = target_position
	else:
		return
	
	if agent.is_navigation_finished():
		return
	if target_position:
		agent_next_path_position()
	movement.body.move_and_slide()

func agent_next_path_position():
	agent.target_position = target_position
	next_position = agent.get_next_path_position()
	direction = global_position.direction_to(next_position)
	
	avoidance()

func avoidance():
	if agent.avoidance_enabled:
		agent.set_velocity(direction)
	else:
		movement.direction = direction

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	movement.direction = safe_velocity
	pass

func _on_navigation_agent_2d_target_reached() -> void:
	if timer.is_stopped():
		if body.patrol_targets:
			nav_index_target += 1
			timer.start(6)
			if body.patrol_targets.size() <= nav_index_target:
				nav_index_target = 0
				timer.start(15)
			target = null
			await timer.timeout
			target = body.patrol_targets[nav_index_target]

class_name HelplessBotController extends Node2D

enum State{
	CHASE,
	RUN,
	BROKEN,
}

@export var movement: Movement
@export var agent: NavigationAgent2D
@export var state: State = State.CHASE
var target
var direction = Vector2.ZERO

var target_position
var next_position
func _physics_process(delta: float) -> void:
	if state == State.BROKEN:
		movement.state = Movement.State.BROKEN
	
	if target:
		target_position = target.global_position
		agent.target_position = target_position
	else:
		return
	if agent.is_navigation_finished():
		return
	
	
	
	
	next_position = agent.get_next_path_position()
	direction = global_position.direction_to(next_position)
	
	
	if agent.avoidance_enabled:
		agent.set_velocity(direction)
	else:
		movement.direction = direction
	
	
	if state == State.BROKEN:
		if target:
			direction = global_position.direction_to(target.global_position)
			if agent.avoidance_enabled:
				agent.set_velocity(direction)
			else:
				movement.direction = direction
	elif target:
		direction = global_position.direction_to(target.global_position)
		if agent.avoidance_enabled:
			agent.set_velocity(direction)
		else:
			movement.direction = direction
		
		if state == State.CHASE:
			if global_position.distance_to(target.global_position) < 64:
				state = State.RUN
		elif state == State.RUN:
			direction *= -1
	movement.body.move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	movement.direction = safe_velocity

class_name FriendlyController extends EnemyController

@export var factory_target: Vector2

func _physics_process(_delta: float) -> void:
	# always reset target
	if target:
		target_position = target.global_position
	else:
		return
	
	if target_position:
		agent.target_position = target_position
	else:
		return
	
	if agent.is_navigation_finished():
		return
	
	if target_position:
		agent_next_path_position()
	
	# override
	movement.body.move_and_slide()
	
	if global_position.distance_to(target.global_position) < 15:
		if not movement.state == Movement.State.MINE:
			movement.state = Movement.State.MINE
			await get_tree().create_timer(2).timeout
			if not state == State.BROKEN:
				movement.state = Movement.State.WALK
				g_man.factory.upgrade()

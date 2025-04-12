class_name FriendlyController extends EnemyController

@export var factory_target: Vector2

func _physics_process(_delta: float) -> void:
	# always reset target
	target_position = factory_target
	
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

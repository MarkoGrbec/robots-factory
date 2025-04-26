class_name FriendlyController extends EnemyController

enum InternalState{
	DEFEND,
	ATTACK,
	MINE,
	BUILD_FIGHT
}
@export var internal_state: InternalState
var close_to_target: float = 15
var return_target

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
	
	if agent.is_navigation_finished() and agent.avoidance_enabled:
		return
	
	if target_position:
		agent_next_path_position()
	
	# override
	movement.body.move_and_slide()
	
	if global_position.distance_to(target.global_position) < close_to_target:
		if not movement.state == Movement.State.MINE:
			agent.avoidance_enabled = true
			movement.state = Movement.State.MINE
			await get_tree().create_timer(2).timeout
			if not state == State.BROKEN:
				agent.avoidance_enabled = false
				movement.state = Movement.State.WALK
				if internal_state == InternalState.DEFEND:
					g_man.factory.upgrade()
				elif internal_state == InternalState.ATTACK:
					g_man.enemy_factory.downgrade()
				elif internal_state == InternalState.MINE:
					if target == return_target:
						# he got material back to home
						cp_mob.got_material_back_home()
					target = return_target
				elif internal_state == InternalState.BUILD_FIGHT:
					g_man.factory_fight.upgrade()

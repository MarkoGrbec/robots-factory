class_name AssistantController extends QuestController

## only move if it is at target layer
func is_at_target_layer():
	if target is CPPlayer:
		if target.layer == 0:
			return true

func _on_navigation_agent_2d_waypoint_reached(details: Dictionary) -> void:
	await get_tree().create_timer(0.6).timeout
	if global_position.distance_to(details["position"]) < 10:
		agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
		await get_tree().create_timer(0.6).timeout
		agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL

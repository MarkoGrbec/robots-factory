extends Node

var entered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var sophie_basis = QuestsManager.get_server_quest_basis(12)
		if sophie_basis == 4:
			if not entered:
				entered = true
				g_man.mold_window.set_instructions_only(["Let's build the factory here."])
				g_man.friendly_robots_spawn_reality.start_spawning()

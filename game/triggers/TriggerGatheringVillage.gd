extends Node

@export var quadrant: int

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if quadrant == 1:
			if g_man.holding_hand.holding_hand_quadrant1():
				# gathering bot
				QuestsManager.set_server_quest(4, false, 0)
				# weapon master
				var weapon_master_basis = QuestsManager.get_server_quest_basis(6)
				if weapon_master_basis == 0:
					QuestsManager.set_server_quest(6, true, 0)
				else:
					QuestsManager.set_server_quest(6, true, 1)
				# assistant bot
				QuestsManager.set_server_quest(7, true, 3)
				

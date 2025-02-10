class_name CPEnemy extends CPMob

var health: int = 3

@export var controller: EnemyController

func _on_mouse_entered() -> void:
	g_man.camera.input_active = -4

func _on_mouse_exited() -> void:
	g_man.camera.input_active = 0

func _input(event: InputEvent) -> void:
	if controller.state == EnemyController.State.BROKEN and not controller.enemy_tunnel:
		if g_man.camera.input_active is int and g_man.camera.input_active == -4:
			if event is InputEventMouseButton:
				if event.is_action_pressed("left mouse button"):
					if get_global_mouse_position().distance_to(global_position) < 128:
						g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.hard_metal, global_position)
						g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.hard_metal, global_position)
						g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.sand, global_position)
						g_man.camera.input_active = 0
						queue_free()
						g_man.camera.input_active = 0

func get_hit(damage):
	health -= damage
	if health == 0:
		controller.movement.state = Movement.State.BROKEN
		controller.state = EnemyController.State.BROKEN
		if GameControl._helpless_bot and  controller.target == GameControl._helpless_bot:
			GameControl._helpless_bot.controller.target = null
		controller.target = null
		GameControl.retreve_bot(controller.enemy_tunnel)

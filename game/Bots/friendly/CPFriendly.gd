class_name CPFriendly extends CPMob

@export var health: float = 20
@export var armor: float = 8
@export var controller: FriendlyController
@export var robot_sfx_audio_stream_player: AudioStreamPlayer2D
@export var dead_sound: AudioStream

var friendly_robots_spawn: FriendlyRobotsSpawnFight

func _on_mouse_entered() -> void:
	if not g_man.speech_activated():
		g_man.camera.input_active = -5
		show_label()

func _on_mouse_exited() -> void:
	g_man.camera.input_active = 0
	hide_label()

func _input(event: InputEvent) -> void:
	if controller.state == EnemyController.State.BROKEN:
		if g_man.camera.input_active is int and g_man.camera.input_active == -5:
			if event is InputEventMouseButton:
				if event.is_action_pressed("select"):
					if get_global_mouse_position().distance_to(global_position) < 128:
						create_material()

func create_material():
	if randf_range(0, 1) < 0.5:
		g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.hard_metal, global_position)
	#g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.hard_metal, global_position)
	else:
		g_man.entity_manager.create_entity_from_scratch(Enums.Esprite.sand, global_position)
	g_man.camera.input_active = 0
	queue_free()

func get_hit(damage):
	damage -= armor
	health -= clampf(damage, 0, INF)
	if health < 0 and not controller.state == FriendlyController.State.BROKEN:
		robot_sfx_audio_stream_player.stream = dead_sound
		robot_sfx_audio_stream_player.play()
		
		controller.movement.state = Movement.State.BROKEN
		controller.state = FriendlyController.State.BROKEN
		
		await robot_sfx_audio_stream_player.finished
		
		controller.target = null
		if friendly_robots_spawn:
			friendly_robots_spawn.report_friendly_dead()
	elif health < 0 and controller.state == FriendlyController.State.BROKEN:
		create_material()

func got_material_back_home():
	if friendly_robots_spawn:
		friendly_robots_spawn.report_material_home(self)

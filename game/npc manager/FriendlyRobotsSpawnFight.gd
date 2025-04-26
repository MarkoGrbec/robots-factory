class_name FriendlyRobotsSpawnFight extends Node2D

@export var friendly_robot: PackedScene
@export var gather_point_1: Node2D
@export var gather_point_2: Node2D
@export var build_factory_point: Node2D
@export var timer_spawn_friendly: Timer

var materials: int = 0

func _ready() -> void:
	g_man.friendly_robots_spawn_fight = self
	await get_tree().create_timer(1).timeout
	if QuestsManager.get_server_quest_basis(24) == 1:
		spawn_friendly_to_gather()
	if QuestsManager.get_server_quest_basis(24) == 3:
		spawn_friendly_to_build()

func spawn_friendly_to_gather() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	if randf_range(0, 1) < 0.5:
		friendly.controller.target = gather_point_1
	else:
		friendly.controller.target = gather_point_2
	friendly.controller.return_target = self
	friendly.controller.close_to_target = 15
	friendly.controller.internal_state = FriendlyController.InternalState.MINE
	friendly.armor = randf_range(8.0, 11.0)
	friendly.health = randf_range(20.0, 50.0)
	friendly.friendly_robots_spawn = self

func spawn_friendly_to_build() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.target = build_factory_point
	friendly.controller.close_to_target = 15
	friendly.controller.internal_state = FriendlyController.InternalState.BUILD_FIGHT
	friendly.armor = randf_range(15.0, 30.0)
	friendly.health = randf_range(50.0, 100.0)
	friendly.friendly_robots_spawn = self

func report_friendly_dead():
	spawn_friendly_to_gather()

func report_material_home(cp_mob: CPFriendly):
	materials += 1
	if materials < 10:
		spawn_friendly_to_gather()
		cp_mob.queue_free()
	else:
		QuestsManager.set_server_quest(24, true, 2)
		cp_mob.queue_free()

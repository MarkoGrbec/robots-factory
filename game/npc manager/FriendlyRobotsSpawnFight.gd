class_name FriendlyRobotsSpawnFight extends Node2D

@export var friendly_robot: PackedScene
@export var gather_point_1: Node2D
@export var gather_point_2: Node2D
@export var build_factory_point: Node2D
@export var timer_spawn_friendly: Timer

func _ready() -> void:
	g_man.friendly_robots_spawn_fight = self

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
	friendly.controller.internal_state = FriendlyController.InternalState.RETURN_MINED
	friendly.armor = randf_range(8.0, 11.0)
	friendly.health = randf_range(20.0, 50.0)

func spawn_friendly_to_build() -> void:
	var friendly: CPFriendly = friendly_robot.instantiate()
	g_man.map.add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.target = build_factory_point
	friendly.controller.close_to_target = 15
	friendly.controller.internal_state = FriendlyController.InternalState.DEFEND
	friendly.armor = randf_range(15.0, 30.0)
	friendly.health = randf_range(50.0, 100.0)

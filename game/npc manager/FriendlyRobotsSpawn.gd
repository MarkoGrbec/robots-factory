class_name FriendlyRobotsSpawn extends Node2D

@export var friendly_robot: PackedScene

func _ready() -> void:
	spawn_friendlies()

func spawn_friendlies():
	var friendly = friendly_robot.instantiate()
	add_child(friendly)
	friendly.global_position = global_position
	friendly.controller.factory_target = Vector2(-2500*0.5, -1600*0.5)

class_name Player extends Node2D

@export var movement: Movement

func _physics_process(delta: float) -> void:
	movement.state = Movement.State.RUN
	if Input.is_action_pressed("walk"):
		movement.state = Movement.State.WALK
	
	var y_direction := Input.get_axis("move up", "move down")
	var x_direction := Input.get_axis("move left", "move right")
	movement.direction = Vector2(x_direction, y_direction)
	movement.body.move_and_slide()

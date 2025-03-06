class_name Player extends Node2D

@export var movement: Movement
@export var animation_tree: AnimationTree
@export var holding_hand: bool = false

func _physics_process(delta: float) -> void:
	movement.state = Movement.State.WALK
	if true or Input.is_action_pressed("run"):
		movement.state = Movement.State.RUN
	
	movement.body.move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if ( not g_man.quests_manager.is_visible_in_tree() or g_man.misc.quest_move.button_pressed) and not g_man.in_game_menu.is_visible_in_tree() and not g_man.asking_toggled:
		var y_direction := Input.get_axis("move up", "move down")
		var x_direction := Input.get_axis("move left", "move right")
		movement.direction = Vector2(x_direction, y_direction)
		if movement.direction:
			g_man.sliders_manager.remove_work()
			g_man.holding_hand.holding_hand_movement_completed()

func blend_anim(anim, value: float, timescale: float):
	animation_tree["parameters/state/transition_request"] = anim
	animation_tree[str("parameters/", anim, "_blend/blend_amount")] = value
	animation_tree[str("parameters/", anim ,"_timescale/scale")] = timescale

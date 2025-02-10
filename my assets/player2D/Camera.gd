class_name Camera extends Camera2D

var input_active = 0

func _ready() -> void:
	g_man.camera = self

func _unhandled_input(event: InputEvent) -> void:
	if not input_active and g_man.inventory_system.hover_over_sprite <= 0:
		if event is InputEventMouseButton:
			var cp_player: CPPlayer = get_parent()
			var mouse_pos = get_global_mouse_position()
			if cp_player.global_position.distance_to(mouse_pos) < 128:
				if event.is_action_released("left mouse button"):
					TTCTool.new(null, mouse_pos, dig)

func dig(mouse_pos):
	var gl_mouse_position: Vector2 = get_global_mouse_position()
	if gl_mouse_position.distance_to(mouse_pos) < 32:
		GlobalSignals.select_tile_node.emit(0, mouse_pos, null)

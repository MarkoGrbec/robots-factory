extends AudioStreamPlayer2D

@export var audio_streams: Dictionary[int, AudioStream]

func activate_foot_sound():
	var cell_id = g_man.tile_map_layers.get_id_by_global_position(global_position)
	stream = audio_streams.get(cell_id)
	if cell_id == 2:
		volume_db = 10
	elif cell_id == 10:
		volume_db = -4
	else:
		volume_db = 1
	play()
	#g_man.changes_manager.add_key_change("cell id: ", cell_id)

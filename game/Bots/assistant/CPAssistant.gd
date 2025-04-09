class_name CPAssistant extends CPQuest

func get_target():
	if g_man.player:
		controller.target = g_man.player

func quest_believe(_old_basis):
	pass

func succeed_old_basis(success_old_basis__qq_index):
	if quest_index == 7:# assistant bot
		if success_old_basis__qq_index[0] == 0:
			if success_old_basis__qq_index[1] == 0:
				g_man.tile_map_layers.set_region(Rect2i(9, -29, 1, 30), [[TileMapLayers.Tile.ROCK, 1]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)
				g_man.tile_map_layers.set_region(Rect2i(10, -29, 1, 30), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(11, -29, 1, 30), [[TileMapLayers.Tile.CLAY, 3]], [Vector2i(3, 5)], TileMapLayers.RegionActionType.OVERWRITE, true, 0.6, [TileMapLayers.Tile.DIRT, 3], Vector2i(2, 4))
				g_man.tile_map_layers.set_region(Rect2i(12, -29, 1, 30), [[TileMapLayers.Tile.ROCK, 3]], [Vector2i(5, 8)], TileMapLayers.RegionActionType.DISCARD, false)

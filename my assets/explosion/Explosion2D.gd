extends Node

@export var sprites: Array[Sprite2D]

func start_explosion():
	sprites[0].show()
	var tween_puff = create_tween()
	tween_puff.tween_property(sprites[0], "scale", Vector2(0.5, 0.5), 0.2)
	await get_tree().create_timer(0.1).timeout
	sprites[0].hide()
	sprites[1].show()
	var tween_flash = create_tween()
	tween_flash.tween_property(sprites[1], "scale", Vector2(0.5, 0.5), 0.1)
	tween_flash.tween_property(sprites[1], "scale", Vector2(0, 0), 0.5)
	await get_tree().create_timer(0.025).timeout
	sprites[2].show()
	var tween_explosion = create_tween()
	tween_explosion.tween_property(sprites[2], "scale", Vector2(0.5, 0.5), 0.15)
	tween_explosion.tween_property(sprites[2], "scale", Vector2(0, 0), 0.5)
	sprites[3].show()
	var tween_smoke = create_tween()
	tween_smoke.tween_property(sprites[3], "scale", Vector2(0.5, 0.5), 0.2)
	tween_smoke.tween_property(sprites[3], "scale", Vector2(0, 0), 0.65)

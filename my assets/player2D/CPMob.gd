class_name CPMob extends EntityBase2D

var id_mob: int
var mob: Mob

func _on_mouse_entered() -> void:
	g_man.camera.input_active = -1


func _on_mouse_exited() -> void:
	g_man.camera.input_active = 0

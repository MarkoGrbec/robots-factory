class_name CPPlayer extends EntityBase2D

@export var weapon_controller: PlayerWeaponController

func _ready() -> void:
	g_man.player = self

func _on_mouse_entered() -> void:
	g_man.camera.input_active = false


func _on_mouse_exited() -> void:
	g_man.camera.input_active = true

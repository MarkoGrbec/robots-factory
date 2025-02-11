class_name CPPlayer extends CPMob

@export var weapon_controller: PlayerWeaponController

func config_name(text):
	name_label.text = text

func _ready() -> void:
	g_man.player = self

func _on_mouse_entered() -> void:
	g_man.camera.input_active = false
	show_label()
	


func _on_mouse_exited() -> void:
	g_man.camera.input_active = true
	hide_label()

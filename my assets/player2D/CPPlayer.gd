class_name CPPlayer extends CPMob

@export var weapon_controller: PlayerWeaponController
@export var controller: Player

var layer: int = 0

func config_name(text):
	name_label.text = text

func _ready() -> void:
	g_man.player = self

func _on_mouse_entered() -> void:
	if not g_man.speech_activated():
		g_man.camera.input_active = true
		show_label()

func _on_mouse_exited() -> void:
	g_man.camera.input_active = false
	hide_label()

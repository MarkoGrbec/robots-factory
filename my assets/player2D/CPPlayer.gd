class_name CPPlayer extends CPMob

@export var weapon_controller: PlayerWeaponController
@export var controller: Player
@export var rain_particles: RainParticles

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

func _process(_delta: float) -> void:
	g_man.changes_manager.add_key_change("id position: ", str(g_man.tile_map_layers.get_position_by_mouse_position()))

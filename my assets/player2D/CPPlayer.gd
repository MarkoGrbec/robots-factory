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
	g_man.changes_manager.add_key_change("CPPlayer: id position, global_position: ", str(g_man.tile_map_layers.get_position_by_mouse_position(), ", ", global_position))

func get_hit(damage):
	# lower damage
	damage -= g_man.user.armor_strength
	# lower health based on damage
	var health = g_man.sliders_manager.slider_add_value(Enums.slider.health, -clampf(damage, 0, INF))
	# if health is below 0 respawn
	if health <= 0:
		g_man.sliders_manager.slider_change_value(Enums.slider.health, 100)
		global_position = Vector2(500, 500)
		g_man.user.save_position(global_position)
		g_man.user.save_add_weapon_strength(15, false)
		g_man.user.save_add_armor_strength(15, false)

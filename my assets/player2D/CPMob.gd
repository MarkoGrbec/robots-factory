class_name CPMob extends EntityBase2D

var id_mob: int
var mob: Mob
var tween

@export var name_label: Label

func _on_mouse_entered() -> void:
	if not g_man.speech_activated():
		g_man.camera.input_active = -1
		show_label()


func _on_mouse_exited() -> void:
	g_man.camera.input_active = 0
	hide_label()

func show_label():
	if name_label:
		name_label.show()
		name_label.visible_characters = 0
		if tween:
			tween.stop()
		tween = create_tween()
		tween.tween_property(name_label, "visible_characters", name_label.text.length(), name_label.text.length() * g_man.misc.slow_writing)
		if g_man.quests_manager.voices and g_man.misc.speak_names.button_pressed:
			var voice_id = g_man.quests_manager.voices[0]
			if not g_man.speech_activated():
				#g_man.changes_manager.add_change("stop name show")
				DisplayServer.tts_stop()
				DisplayServer.tts_speak(name_label.text, voice_id)

func hide_label():
	if name_label:
		name_label.hide()
		if g_man.misc.speak_names.button_pressed:
			if not g_man.speech_activated():
				print(global_position)
				#g_man.changes_manager.add_change("stop name hide")
				DisplayServer.tts_stop()

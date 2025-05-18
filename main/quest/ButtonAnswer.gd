class_name ButtonAnswer extends Control

@export var label: Label
@export var button: Button
@export var show_text_slowly: bool = true

func set_text(text: String) -> void:
	label.text = text
	if show_text_slowly:
		_show_characters()

func get_text() -> String:
	return label.text

func _show_characters() -> void:
	var tween = create_tween()
	label.visible_characters = 0
	var dialog_speed = label.text.length() * g_man.misc.slow_writing
	tween.tween_property(label, "visible_characters", label.text.length(), dialog_speed)

func _on_ui_pressed() -> void:
	g_man.main_menu._on_ui_pressed()

func _on_button_mouse_entered() -> void:
	g_man.main_menu._on_mouse_entered()

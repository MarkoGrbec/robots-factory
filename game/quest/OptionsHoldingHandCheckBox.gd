class_name OptionsHoldingHandCheckBox extends CheckBox

var on_callable
var off_callable

func toggle_me(toggle_on: bool) -> void:
	button_pressed = toggle_on

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on and on_callable:
		on_callable.call()
	elif off_callable:
		off_callable.call()

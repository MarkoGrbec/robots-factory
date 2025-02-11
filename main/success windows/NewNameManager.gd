class_name ChangeNameManager extends TabContainer

func _ready() -> void:
	g_man.change_name_manager = self

func close_window():
	hide()

func open_window():
	show()

func _on_new_name_text_submitted(new_text: String) -> void:
	var user: User = g_man.user
	user.avatar_name = new_text
	g_man.player.config_name(new_text)
	user.save_username()
	g_man.changes_manager.add_change("you successfully changed your name")
	user.save_user_time_change_name(Time.get_unix_time_from_system())

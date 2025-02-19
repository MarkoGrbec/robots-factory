class_name OrganicRobot extends CPQuest

var convinced: bool = false

@export var believe: TextureRect
@onready var gradient_tex: GradientTexture1D = believe.texture

func quest_believe(array_believe):
	gradient_tex.gradient.offsets[0] = array_believe[0]
	gradient_tex.gradient.offsets[1] = array_believe[1]
	if g_man.user.believe_in_god:
		convince(array_believe[0] > 0.95)
	else:
		convince(array_believe[1] < 0.05)

func convince(value):
	if value:
		if not convinced:
			var server_quest: ServerQuest = QuestsManager.get_server_quest(11)
			server_quest.mission_completing({"convince" = Enums.Esprite.mob_organic_robot})
		convinced = true
	else:
		#if convinced:
		var server_quest: ServerQuest = QuestsManager.get_server_quest(11)
		server_quest.mission_failing_quest({"convince" = Enums.Esprite.mob_organic_robot})
		convinced = false

func succeed_old_basis(success_old_basis__qq_index):
	pass

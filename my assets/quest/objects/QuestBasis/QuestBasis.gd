class_name QuestBasis extends Resource
@export_multiline var description: String
@export_group("default mission")
## example: key [kill], value [zombie_naked_visual]
@export var dict_mission__entity_num: Dictionary[String, Enums.Esprite]
## how many times it has to be done
@export var mission_quantity: int
@export_group("general")
## fail quest goes through next basis
@export var fail_passes: bool = false
## display answers to choose from
@export var display_answers: bool = true
## more than 1 quest question
@export var list_quest_questions: Array[QuestQuestion]
@export_multiline var default_starting_dialog: String
@export_multiline var default_failed_dialog: String
## which dialogs are available at this basis
var dict_quest_questions: Dictionary = {}

# Update the basis with questions
func update_basis() -> void:
	for question in list_quest_questions:
		dict_quest_questions[question.list_avatar_dialog] = question

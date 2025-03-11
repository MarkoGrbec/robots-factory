class_name QuestQuestion extends Resource
@export_group("basis")
## use basis even if it's only flag
@export var use_basis: bool = false
## new basis on this qq
@export var new_basis: Array[int] = [0]
@export_group("add remove basis flags")
@export var add_basis_flags: Array[int]
@export var remove_basis_flags: Array[int]
@export var basis_is_root: int = 0
## which qq has it only if this has been activated
@export var add_qq_flags: Array[QuestQuestion]
@export_group("items needed for this quest")
## quest item needed for finishing this quest
@export var quest_item: Enums.Esprite
## minimum quantity of items needed
@export var quantity: int
## minimum ql needed for to hand over
@export var ql: int
@export_group("reward for this quest")
## reward for finishing this quest
@export var reward: Enums.Esprite
@export_group("other npc")
@export var other_npcs: Array[QQOtherNPC]
@export_group("dialogs")
## what dialogs are available to choose
@export_multiline var list_avatar_dialog: Array[String]
## what dialog is a response dialog
@export_multiline var response_dialog: Array[String]
## what will happen if he fails the quest
@export_multiline var response_failed_dialog: String

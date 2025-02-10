class_name ClientQuest extends Node

var quest_index
var id_inventory
var position
var visuals
var activate

var equipment_in_hand

func copy():
	return ClientQuest.new()

#region serialize
func deserialize(data:Array):
	equipment_in_hand = data.pop_back()
	activate = data.pop_back()
	visuals = data.pop_back()
	position = data.pop_back()
	id_inventory = data.pop_back()
	quest_index = data.pop_back()
	return data
#endregion serialize

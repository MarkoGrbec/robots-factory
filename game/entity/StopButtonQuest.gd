class_name StopButtonQuest extends Node
# for quest stacking all the materials

@export var slot_texture: TextureRect
@export var counter: Label

## array [Enums.Esprite, int]
func change_texture_counter(array):
	var e_obj = mp.get_item_object(array[0])
	if e_obj:
		slot_texture.texture = e_obj.texture
	counter.text = str(array[1])

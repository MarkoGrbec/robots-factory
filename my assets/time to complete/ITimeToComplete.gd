class_name ITimeComplete extends Node


var time_to_complete: float = 1
var time_start: float = 0
var change_to_parent_sound: AudioStream
var working_sound: AudioStream
var is_sound_on_end: bool
var delay_sound: float = 0
var start_delay_sound: float = 0.5
var one_shot: bool = false
var hard: float = 10

func calc_time_to_complete(level_exp, min_time, max_time):
	if level_exp < 1000:
		time_to_complete = max_time - (max_time * 0.001 * level_exp) + min_time
	else:
		time_to_complete = min_time

func complete():
	pass
func stop():
	queue_free()
## return true to have it operational correctly
func start_of_ttc():
	return false
func set_complete_time():
	pass
func to_string_name():
	pass
## if the operand can be done else it cancels it as soon as it starts the operand
## <returns>if it's ok to make stuff</returns>
func Check():
	pass

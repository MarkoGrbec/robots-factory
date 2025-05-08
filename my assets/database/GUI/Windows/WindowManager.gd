class_name WindowManager extends Control

var start : Vector2
var initial_position : Vector2
var is_moving : bool
var is_resizing : bool
var resize_x : bool
var resize_y : bool
var initial_size : Vector2
var focus = false
var id_window: int

static var MOUSE_BUTTON_NAME: String = "left mouse button"
static var id_windows = {}

@export var grab_threshold := 55
@export var resize_threshold := 20
@export var border := 20
@export var set_default_window_rect: bool = false
@export var default_window_rect: Rect2 = Rect2(256, 100, 784, 256)
@export var minimum_window_size: Vector2 = Vector2(225, 225)
## when ever resizing window it makes sibling last
@export var set_if_last_sibling: bool = false

func _ready() -> void:
	g_man.array_mouse_inside_windows.push_back(mouse_inside)

func _on_mouse_entered():
	focus = true

func _on_mouse_exited():
	if not is_moving && not is_resizing:
		focus = false

## give position like: g_man.camera.global_position - global_position
func camera_inside(pos: Vector2) -> bool:
	pos *= -1
	var _size = g_man.global_canvas.get_global_canvas_rect().size
	pos.x = pos.x + (_size.x / 2)
	pos.y = pos.y + (_size.y / 2)
	return mouse_inside(pos)

func mouse_inside(pos: Vector2):
	if is_visible_in_tree():
		var rect: Rect2 = get_global_rect()
		pos -= get_global_position()
		var left_right: bool = pos.x > 0 and pos.x < rect.size.x
		if pos.y < rect.size.y and pos.y > 0 and left_right:
			g_man.changes_manager.add_key_change("mouse_inside t: ", str(true, pos, rect))
			return true
	g_man.changes_manager.add_key_change("mouse_inside f: ", str(true, pos, get_global_rect()))
	return false

func open_window(_show: bool = false):
	# close window if it's shown
	if is_visible_in_tree():
		if not _show:
			hide()
		return
	# show window
	show()

func close_window():
	hide()

func last_sibling():
	get_parent().move_child.call_deferred(self, get_parent().get_child_count())

func is_last_sibling():
	var parent = get_parent()  # Get the parent node
	var index = get_index()     # Get this node's index
	var total_children = parent.get_child_count()  # Get total children count
	return index == total_children - 1  # Check if it's the last sibling

func set_id_window(id:int, text:String):
	id_window = id
	if id_windows.has(id):
		pass
		#g_man.mold_window.set_instructions_only([text, "window id:", id, "does not have unique id there for won't save it's position size correctly it conflicts with:", id_windows[id], get_stack()])
	else:
		id_windows[id] = text
		if not id == 14: # slider manager do not resize or move
			if set_default_window_rect:
				default_window_rect = DataBase.select(false, g_man.dbms, "windows", "rect", id_window, default_window_rect)
			else:
				default_window_rect = DataBase.select(false, g_man.dbms, "windows", "rect", id_window, Rect2())
			if default_window_rect:
				set_position(default_window_rect.position)
				set_size(default_window_rect.size)
	reset_window_position()

# if it's accidenally out of borders I throw them back and resize
func reset_window_position():
	await get_tree().process_frame
	var pos = get_global_position()
	# left border
	if pos.x < border:
		pos.x = border
	# right border
	elif pos.x > g_man.global_canvas.get_global_canvas_rect().size.x + border * 2 - get_size().x:
		pos.x = g_man.global_canvas.get_global_canvas_rect().size.x + border * 2 - get_size().x
	# top border
	if pos.y < border:
		pos.y = border
	# bottom border
	elif pos.y > g_man.global_canvas.get_global_canvas_rect().size.y + border * 2 - get_size().y:
		pos.y = g_man.global_canvas.get_global_canvas_rect().size.y + border * 2 - get_size().y
	set_position(pos)
	# if too big window resize it
	var new_width = clamp(get_size().x, minimum_window_size.x, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().position.x - border)
	var new_height = clamp(get_size().y, minimum_window_size.y, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().position.y - border)
	set_size(Vector2(new_width, new_height))

func _input(event):
	if not event is InputEventMouse or not id_window:
		return
	#if focus and event is InputEventMouse:
		#local_exit_mouse_pos = event.position - get_global_position()
	if focus:
		if Input.is_action_just_pressed(MOUSE_BUTTON_NAME):
			if set_if_last_sibling:
				last_sibling()
	# don't grab or resize if it's not last sibling like pressed on it
	elif not is_last_sibling():
		return
#region button down
	if Input.is_action_just_pressed(MOUSE_BUTTON_NAME):
		var rect = get_global_rect()
		var local_mouse_pos = event.position - get_global_position()
		var left_right = local_mouse_pos.x > 0 && local_mouse_pos.x < rect.size.x
		var up_down = local_mouse_pos.y > 0 && local_mouse_pos.y < rect.size.y
	#region drag
		if local_mouse_pos.y < grab_threshold && local_mouse_pos.y > -resize_threshold && left_right:
			reset_window_position()
			# set it as last sibling
			last_sibling()
			start = event.position
			initial_position = get_global_position()
			is_moving = true
	#endregion drag
	#region resize
		else:# get_parent().get_child_count() == get_index() + 1: # if last sibling
			if abs(local_mouse_pos.x - rect.size.x) < resize_threshold && up_down:
				reset_window_position()
				start.x = event.position.x
				initial_size.x = get_size().x
				resize_x = true
				is_resizing = true
			
			if abs(local_mouse_pos.y - rect.size.y) < resize_threshold && left_right:
				reset_window_position()
				start.y = event.position.y
				initial_size.y = get_size().y
				resize_y = true
				is_resizing = true
			
			if local_mouse_pos.x < resize_threshold &&  local_mouse_pos.x > -resize_threshold && up_down:
				reset_window_position()
				start.x = event.position.x
				initial_position.x = get_global_position().x
				initial_size.x = get_size().x
				is_resizing = true
				resize_x = true
			
			if local_mouse_pos.y < resize_threshold &&  local_mouse_pos.y > -resize_threshold && left_right:
				reset_window_position()
				start.y = event.position.y
				initial_position.y = get_global_position().y
				initial_size.y = get_size().y
				is_resizing = true
				resize_y = true
	#endregion resize
#endregion button down
#region button hold
	if Input.is_action_pressed(MOUSE_BUTTON_NAME):
		if is_moving:
			var position_x = clamp(initial_position.x + (event.position.x - start.x), border, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().size.x - border)
			var position_y = clamp(initial_position.y + (event.position.y - start.y), border, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().size.y - border)
			set_position(Vector2(position_x, position_y))
		if is_resizing:
			var new_width = get_size().x
			var new_height = get_size().y
			
			#right sizing
			if resize_x:
				new_width = clamp(initial_size.x - (start.x - event.position.x), minimum_window_size.x, g_man.global_canvas.get_global_canvas_rect().size.x - get_global_rect().position.x - border)
			if resize_y:
				new_height = clamp(initial_size.y - (start.y - event.position.y), minimum_window_size.y, g_man.global_canvas.get_global_canvas_rect().size.y - get_global_rect().position.y - border)
			
			#left sizing AGAIN
			if initial_position.x != 0:
				var right_offset = g_man.global_canvas.get_global_canvas_rect().size.x - initial_position.x - initial_size.x
				new_width = initial_size.x + (initial_position.x - (clamp(event.position.x, border, g_man.global_canvas.get_global_canvas_rect().size.x - right_offset - minimum_window_size.x)))
				
				set_position(Vector2(clamp(initial_position.x - (new_width - initial_size.x), border, g_man.global_canvas.get_global_canvas_rect().size.x - right_offset - minimum_window_size.x), get_position().y))
			
			## it gets here does by resizing on top ##TODO clamp
			#if initial_position.y != 0:
				#new_height = initial_size.y + (start.y - event.position.y)
				#set_position(Vector2(get_position().x, initial_position.y - (new_height - initial_size.y)))
			
			set_size(Vector2(new_width, new_height))
			
#endregion button hold
#region button released
	if Input.is_action_just_released(MOUSE_BUTTON_NAME):
		if is_moving or is_resizing or resize_x or resize_y:
			save_rect()
		is_moving = false
		initial_position = Vector2.ZERO
		start = Vector2.ZERO
		resize_x = false
		resize_y = false
		is_resizing = false
		
#endregion button released

func set_min_size(min_size:Vector2 = minimum_window_size):
	default_window_rect.size = min_size
	set_size(default_window_rect.size)

func save_rect():
	print("Save ", id_window, " : ", get_global_rect(), " :/: ", get_rect())
	DataBase.insert(false, g_man.dbms, "windows", "rect", id_window, get_rect())

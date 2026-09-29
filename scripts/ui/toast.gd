class_name Toast
extends PanelContainer
## Short messages at the top center of the screen (e.g. "Achievement unlocked"), one at a time, 3 s each.

const SHOW_SECONDS: float = 3.0

var title_label: Label
var text_label: Label
var queue: Array = []
var time_left: float = 0.0


func _ready() -> void:
	anchor_left = 0.5
	anchor_right = 0.5
	offset_top = 16.0
	offset_bottom = 16.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(380, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	box.add_child(title_label)
	text_label = Label.new()
	box.add_child(text_label)
	hide()


func _process(delta: float) -> void:
	advance(delta)


func enqueue(title: String, text: String) -> void:
	queue.append([title, text])
	if not visible:
		_show_next()


func advance(delta: float) -> void:
	if not visible:
		return
	time_left -= delta
	if time_left <= 0.0:
		hide()
		_show_next()


func _show_next() -> void:
	if queue.is_empty():
		return
	var item: Array = queue.pop_front()
	title_label.text = item[0]
	text_label.text = item[1]
	time_left = SHOW_SECONDS
	show()

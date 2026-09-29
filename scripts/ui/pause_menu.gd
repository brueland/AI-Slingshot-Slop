class_name PauseMenu
extends PanelContainer
## Buttons near the bottom of the screen while paused: Resume, or quit to the title.

signal resume_pressed
signal quit_pressed

var resume_button: Button
var quit_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	custom_minimum_size = Vector2(260, 0)
	offset_top -= 140.0
	offset_bottom -= 140.0
	var box := VBoxContainer.new()
	add_child(box)
	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(func(): resume_pressed.emit())
	box.add_child(resume_button)
	quit_button = Button.new()
	quit_button.text = "Quit to title"
	quit_button.pressed.connect(func(): quit_pressed.emit())
	box.add_child(quit_button)
	hide()

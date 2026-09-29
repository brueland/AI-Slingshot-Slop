class_name VictoryPanel
extends PanelContainer
## Shown once, the first time a run reaches GOAL_DISTANCE.

signal continue_pressed

var message_label: Label
var continue_button: Button

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(480, 0)
	
	var vbox := VBoxContainer.new()
	add_child(vbox)
	
	message_label = Label.new()
	message_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(message_label)
	
	continue_button = Button.new()
	continue_button.text = "Keep flying"
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	vbox.add_child(continue_button)
	
	hide()

func _on_continue_pressed():
	emit_signal("continue_pressed")

func show_victory(runs: int) -> void:
	message_label.text = "You reached %d m in %d runs!" % [int(Balance.GOAL_DISTANCE), runs]
	show()

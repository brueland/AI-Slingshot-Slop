class_name TitlePanel
extends PanelContainer
## The title screen: game name, best distance, Play and Reset progress.

signal play_pressed
signal reset_pressed

var title_label: Label
var best_label: Label
var play_button: Button
var reset_button: Button
var box: VBoxContainer

func _ready():
	set_anchors_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	
	box = VBoxContainer.new()
	add_child(box)
	
	title_label = Label.new()
	title_label.text = "Slingshot Skies"
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	
	best_label = Label.new()
	box.add_child(best_label)
	
	play_button = Button.new()
	play_button.text = "Play"
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	box.add_child(play_button)
	
	reset_button = Button.new()
	reset_button.text = "Reset progress"
	reset_button.connect("pressed", Callable(self, "_on_reset_pressed"))
	box.add_child(reset_button)
	
	show_progress(0.0, 0)

func _on_play_pressed():
	emit_signal("play_pressed")

func _on_reset_pressed():
	emit_signal("reset_pressed")

func show_progress(best: float, runs: int) -> void:
	best_label.text = "Best: %d m in %d runs" % [floori(best), runs]

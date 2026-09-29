class_name TitlePanel
extends PanelContainer
## The title screen: game name, best distance, Play and Reset progress.

signal play_pressed
signal reset_pressed
signal options_pressed
signal credits_pressed
signal stats_pressed
signal rogue_pressed
signal daily_pressed
signal wardrobe_pressed

var title_label: Label
var best_label: Label
var play_button: Button
var reset_button: Button
var options_button: Button
var credits_button: Button
var stats_button: Button
var rogue_button: Button
var daily_button: Button
var wardrobe_button: Button
var box: VBoxContainer
var mascot: TitleMascot

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	
	box = VBoxContainer.new()
	add_child(box)
	
	mascot = TitleMascot.new()
	box.add_child(mascot)
	
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
	
	rogue_button = Button.new()
	rogue_button.text = "Roguelike"
	rogue_button.pressed.connect(func(): rogue_pressed.emit())
	box.add_child(rogue_button)
	
	daily_button = Button.new()
	daily_button.text = "Daily Run"
	daily_button.pressed.connect(func(): daily_pressed.emit())
	box.add_child(daily_button)
	
	wardrobe_button = Button.new()
	wardrobe_button.text = "Wardrobe"
	wardrobe_button.pressed.connect(func(): wardrobe_pressed.emit())
	box.add_child(wardrobe_button)
	
	stats_button = Button.new()
	stats_button.text = "Stats"
	stats_button.connect("pressed", Callable(self, "_on_stats_pressed"))
	box.add_child(stats_button)
	
	options_button = Button.new()
	options_button.text = "Options"
	options_button.connect("pressed", Callable(self, "_on_options_pressed"))
	box.add_child(options_button)
	
	credits_button = Button.new()
	credits_button.text = "Credits"
	credits_button.connect("pressed", Callable(self, "_on_credits_pressed"))
	box.add_child(credits_button)
	
	reset_button = Button.new()
	reset_button.text = "Reset progress"
	reset_button.connect("pressed", Callable(self, "_on_reset_pressed"))
	box.add_child(reset_button)
	
	show_progress(0.0, 0)

func _on_play_pressed():
	emit_signal("play_pressed")

func _on_options_pressed():
	emit_signal("options_pressed")

func _on_credits_pressed():
	emit_signal("credits_pressed")

func _on_stats_pressed():
	emit_signal("stats_pressed")

func _on_reset_pressed():
	emit_signal("reset_pressed")

func set_mascot_hat(id: String) -> void:
	mascot.set_hat(id)

func show_progress(best: float, runs: int) -> void:
	best_label.text = "Best: %d m in %d runs" % [floori(best), runs]

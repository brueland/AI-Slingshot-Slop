class_name OptionsPanel
extends PanelContainer
## Music and sound-effect volume sliders.

signal volume_changed(kind: String, value: float)
signal closed

var music_slider: HSlider
var sfx_slider: HSlider
var close_button: Button

func _ready():
	set_anchors_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	
	var box := VBoxContainer.new()
	add_child(box)
	
	var title_label := Label.new()
	title_label.text = "Options"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	
	# Music slider
	var music_container := HBoxContainer.new()
	box.add_child(music_container)
	
	var music_label := Label.new()
	music_label.text = "Music"
	music_container.add_child(music_label)
	
	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.custom_minimum_size = Vector2(300, 24)
	music_slider.connect("value_changed", Callable(self, "_on_music_value_changed"))
	music_container.add_child(music_slider)
	
	# SFX slider
	var sfx_container := HBoxContainer.new()
	box.add_child(sfx_container)
	
	var sfx_label := Label.new()
	sfx_label.text = "Sound effects"
	sfx_container.add_child(sfx_label)
	
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.custom_minimum_size = Vector2(300, 24)
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_value_changed"))
	sfx_container.add_child(sfx_slider)
	
	# Close button
	close_button = Button.new()
	close_button.text = "Close"
	close_button.connect("pressed", Callable(self, "_on_close_pressed"))
	box.add_child(close_button)
	
	hide()

func _on_music_value_changed(value: float) -> void:
	emit_signal("volume_changed", "music", value)

func _on_sfx_value_changed(value: float) -> void:
	emit_signal("volume_changed", "sfx", value)

func _on_close_pressed() -> void:
	emit_signal("closed")

func set_values(music: float, sfx: float) -> void:
	music_slider.value = music
	sfx_slider.value = sfx

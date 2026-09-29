class_name WardrobePanel
extends PanelContainer
## Pick a hat for the alien. Locked hats show how to unlock them.

signal hat_chosen(id: String)
signal closed

var title_label: Label
var hat_buttons: Dictionary = {}
var close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title_label = Label.new()
	title_label.text = "Wardrobe"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	for entry in Hats.LIST:
		var id: String = entry["id"]
		var button := Button.new()
		button.text = entry["name"]
		button.pressed.connect(func(): hat_chosen.emit(id))
		box.add_child(button)
		hat_buttons[id] = button
	close_button = Button.new()
	close_button.text = "Done"
	close_button.pressed.connect(func(): closed.emit())
	box.add_child(close_button)
	hide()


func show_hats(progress: Progress) -> void:
	for entry in Hats.LIST:
		var id: String = entry["id"]
		var button: Button = hat_buttons[id]
		if button == null:
			continue
		var open := Hats.is_unlocked(id, progress)
		button.disabled = not open
		if not open:
			button.text = "Locked - %s" % entry["hint"]
		elif id == progress.hat:
			button.text = "%s (wearing)" % entry["name"]
		else:
			button.text = entry["name"]
	show()

class_name RoguePanel
extends PanelContainer
## Roguelike: after each shot, shows whether the goal was met, the next goal, and three perks to choose from.

signal perk_chosen(id: String)
signal reroll_pressed
signal size_chosen(id: String)

var title_label: Label
var goal_label: Label
var round_label: Label
var perk_buttons: Array[Button] = []
var perk_ids: Array[String] = []
var reroll_button: Button
var size_label: Label
var size_buttons: Dictionary = {}
var current_run: RogueRun
var weather_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(520, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	round_label = Label.new()
	box.add_child(round_label)
	goal_label = Label.new()
	goal_label.add_theme_font_size_override("font_size", 24)
	box.add_child(goal_label)
	weather_label = Label.new()
	weather_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	box.add_child(weather_label)
	size_label = Label.new()
	box.add_child(size_label)
	var sizes := HBoxContainer.new()
	box.add_child(sizes)
	for entry in RogueSizes.LIST:
		var id: String = entry["id"]
		var size_button := Button.new()
		size_button.text = entry["name"]
		size_button.toggle_mode = true
		size_button.pressed.connect(func(): _on_size(id))
		sizes.add_child(size_button)
		size_buttons[id] = size_button
	var pick := Label.new()
	pick.text = "Choose a perk:"
	box.add_child(pick)
	for i in 3:
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(func(): _on_pick(i))
		box.add_child(button)
		perk_buttons.append(button)
	
	reroll_button = Button.new()
	reroll_button.pressed.connect(func(): reroll_pressed.emit())
	box.add_child(reroll_button)
	hide()


func show_outcome(outcome: Dictionary, run: RogueRun) -> void:
	if outcome.get("met", false):
		title_label.text = "Goal met!"
	else:
		title_label.text = "Missed! Lives left: %d" % int(outcome.get("lives", run.lives))
	round_label.text = "Round %d - Lives %d" % [run.round_number, run.lives]
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
	var weather := RogueWeather.get_def(run.weather)
	weather_label.text = "Weather: %s - %s" % [weather["name"], weather["description"]]
	perk_ids.assign(run.offer)
	for i in perk_buttons.size():
		var button := perk_buttons[i]
		if i < perk_ids.size():
			var d := RoguePerks.get_def(perk_ids[i])
			button.text = "%s - %s" % [d.get("name", ""), d.get("description", "")]
			button.show()
		else:
			button.hide()
	show()
	
	reroll_button.text = "Reroll perks (%d left)" % run.rerolls
	reroll_button.disabled = run.rerolls <= 0
	current_run = run
	_show_size()


func _on_pick(index: int) -> void:
	if index < perk_ids.size():
		perk_chosen.emit(perk_ids[index])


## The size row: "Next shot size: Big - ..." and the chosen size's button pressed.
func _show_size() -> void:
	var d := RogueSizes.get_def(current_run.size_id)
	size_label.text = "Next shot size: %s - %s" % [d["name"], d["description"]]
	for id in size_buttons:
		var size_button: Button = size_buttons[id]
		size_button.set_pressed_no_signal(id == current_run.size_id)


func _on_size(id: String) -> void:
	if current_run == null:
		return
	if current_run.set_size(id):
		size_chosen.emit(id)
	_show_size()

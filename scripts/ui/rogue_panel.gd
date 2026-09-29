class_name RoguePanel
extends PanelContainer
## Roguelike: after each shot, shows whether the goal was met, the next goal, and three perks to choose from.

signal perk_chosen(id: String)

var title_label: Label
var goal_label: Label
var round_label: Label
var perk_buttons: Array[Button] = []
var perk_ids: Array[String] = []


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
	var pick := Label.new()
	pick.text = "Choose a perk:"
	box.add_child(pick)
	for i in 3:
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(func(): _on_pick(i))
		box.add_child(button)
		perk_buttons.append(button)
	hide()


func show_outcome(outcome: Dictionary, run: RogueRun) -> void:
	if outcome.get("met", false):
		title_label.text = "Goal met!"
	else:
		title_label.text = "Missed! Lives left: %d" % int(outcome.get("lives", run.lives))
	round_label.text = "Round %d - Lives %d" % [run.round_number, run.lives]
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
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


func _on_pick(index: int) -> void:
	if index < perk_ids.size():
		perk_chosen.emit(perk_ids[index])

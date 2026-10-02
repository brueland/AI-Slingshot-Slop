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
var close_label: Label
## What this shot's stars gave (hidden without stars).
var stars_label: Label


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
	close_label = Label.new()
	close_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	close_label.hide()
	box.add_child(close_label)
	stars_label = Label.new()
	stars_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	stars_label.hide()
	box.add_child(stars_label)
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
	close_label.text = "You got %d%% of the way there" % roundi(float(outcome.get("ratio", 0.0)) * 100.0)
	close_label.visible = not outcome.get("met", false)
	if outcome.get("lucky", false):
		title_label.text = "Lucky! Goal met, +1 reroll"
	if outcome.get("boss_beaten", false):
		title_label.text = "Boss beaten! +1 life"
	if outcome.get("fight", false) and not outcome.get("met", false):
		_show_fight_shot(outcome, run)
	goal_label.modulate = Color(1.0, 0.6, 0.6) if run.goal.get("type", "") in ["boss", "fight"] else Color.WHITE
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
	
	# Handle stars label
	var gained: Array = outcome.get("stars_gained", [])
	stars_label.text = "+%d star%s: %s (%d this run)" % [gained.size(), "" if gained.size() == 1 else "s", StarBoosts.summary(gained), run.stars_total]
	stars_label.visible = not gained.is_empty()


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


## The title after a boss fight shot that didn't beat it: the damage, the HP and shots left, or out of shots.
func _show_fight_shot(outcome: Dictionary, run: RogueRun) -> void:
	var shots := int(outcome.get("shots_left", 0))
	if shots <= 0:
		title_label.text = "Out of shots! The boss heals. Lives left: %d" % run.lives
		return
	var dealt := int(outcome.get("boss_damage", 0))
	var hit := "Boss hit for %d!" % dealt if dealt > 0 else "No hit!"
	title_label.text = "%s %d HP left, %d shot%s to go" % [hit, int(outcome.get("boss_hp", 0)), shots, "" if shots == 1 else "s"]


func _on_size(id: String) -> void:
	if current_run == null:
		return
	if current_run.set_size(id):
		size_chosen.emit(id)
	_show_size()

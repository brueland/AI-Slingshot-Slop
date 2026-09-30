class_name RogueOverPanel
extends PanelContainer
## Roguelike: shown when the last life is lost. Rounds cleared, best, the perks taken, and Back to title.

signal back_pressed
signal replay_pressed

var title_label: Label
var rounds_label: Label
var best_label: Label
var daily_label: Label
var perks_label: Label
var back_button: Button
var history_label: Label
var replay_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(480, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title_label = Label.new()
	title_label.text = "Run over"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	rounds_label = Label.new()
	box.add_child(rounds_label)
	best_label = Label.new()
	box.add_child(best_label)
	perks_label = Label.new()
	perks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	perks_label.custom_minimum_size = Vector2(440, 0)
	box.add_child(perks_label)
	history_label = Label.new()
	history_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	box.add_child(history_label)
	replay_button = Button.new()
	replay_button.text = "Play this seed again"
	replay_button.pressed.connect(func(): replay_pressed.emit())
	box.add_child(replay_button)
	daily_label = Label.new()
	daily_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	daily_label.hide()
	box.add_child(daily_label)
	back_button = Button.new()
	back_button.text = "Back to title"
	box.add_child(back_button)
	back_button.pressed.connect(func(): back_pressed.emit())
	hide()


## "Last runs: 7, 4, 3 rounds" from Progress.rogue_history (newest first); empty when there is none.
func show_history(history: Array) -> void:
	var parts := PackedStringArray()
	for item in history:
		parts.append(str(int(item.get("rounds", 0))))
	history_label.text = "Last runs: %s rounds" % ", ".join(parts) if not parts.is_empty() else ""


func show_over(run: RogueRun, best_rounds: int) -> void:
	rounds_label.text = "Rounds cleared: %d" % run.rounds_cleared
	best_label.text = "Best: %d rounds" % best_rounds
	var names := PackedStringArray()
	for id in run.perks:
		names.append(str(RoguePerks.get_def(id).get("name", id)))
	perks_label.text = "Perks: %s" % (", ".join(names) if not names.is_empty() else "none")
	show()

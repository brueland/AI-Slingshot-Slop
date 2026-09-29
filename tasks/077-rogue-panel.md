---
id: 077-rogue-panel
status: ready
tests: [tests/acceptance/test_077_rogue_panel.gd]
files: [scripts/ui/rogue_panel.gd, scripts/ui/hud.gd]
read: [scripts/core/rogue_run.gd, scripts/core/rogue_perks.gd]
---

# Roguelike perk panel and HUD

**1. Create `scripts/ui/rogue_panel.gd` with exactly this code** (shown after each roguelike shot: goal met or
missed, the next goal, and three perk buttons):
```gdscript
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
```

**2. `scripts/ui/hud.gd`** (keep everything): add this function right after `update_progress()`. It reuses the
three labels of the right column:
```gdscript
## Roguelike: the right column shows the round, lives and the current goal instead of best/coins/next.
func show_rogue(goal_text: String, round_number: int, lives: int) -> void:
	best_label.text = "Round %d" % round_number
	coins_label.text = "Lives: %d" % lives
	goal_label.text = "Goal: %s" % goal_text
```

## Acceptance criteria
- Hidden at start; `show_outcome` shows "Goal met!" or "Missed! Lives left: N", "Round R - Lives L",
  "Next goal: ..." and one button per offered perk ("Name - description").
- Pressing button i emits `perk_chosen` with the i-th offered id.
- The panel is centered on screen.
- `Hud.show_rogue("Bounce 4 times", 5, 2)` shows "Round 5", "Lives: 2", "Goal: Bounce 4 times".

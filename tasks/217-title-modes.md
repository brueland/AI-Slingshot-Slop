---
id: 217-title-modes
status: ready
tests: [tests/acceptance/test_217_mode_chooser.gd, tests/acceptance/test_038_title_screen.gd]
files: [scripts/ui/title_panel.gd]
---

# PLAY and the mode chooser

The title gets one big orange PLAY button. It opens a card over the title to choose Classic, Roguelike or Daily Run
(each with a short description); Back closes it. The Classic, Roguelike and Daily Run buttons are the same button
objects as before, moved into the card. (Task 217b then lays out the rest of the title.)

**`scripts/ui/title_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1-3 are small changes near the top and at the end of `_ready()`; Edit 4 keeps the last function of the file, `show_progress()`, exactly as it is and adds the new function `_build_mode_chooser()` after it, at the very end of the file. Nothing else changes: keep every other function (`show_greeting`, `_pair`, `set_mascot_hat`, `show_progress`).

Edit 1 - SEARCH:
```gdscript
var achievements_button: Button
```
REPLACE:
```gdscript
var achievements_button: Button
var start_button: Button
var mode_overlay: Control
```

Edit 2 - SEARCH:
```gdscript
	play_button.text = "Play"
```
REPLACE:
```gdscript
	play_button.text = "Classic"
```

Edit 3 - SEARCH:
```gdscript
	_pair(rogue_button, daily_button)
```
REPLACE:
```gdscript
	_build_mode_chooser()
```

Edit 4 - SEARCH:
```gdscript
func show_progress(best: float, runs: int) -> void:
	best_label.text = "Best: %d m in %d runs" % [floori(best), runs]
```
REPLACE:
```gdscript
func show_progress(best: float, runs: int) -> void:
	best_label.text = "Best: %d m in %d runs" % [floori(best), runs]

## PLAY opens a card over the title to choose Classic, Roguelike or Daily Run, each with a short description.
func _build_mode_chooser() -> void:
	start_button = Button.new()
	start_button.text = "PLAY"
	start_button.theme_type_variation = "PrimaryButton"
	start_button.custom_minimum_size = Vector2(340, 84)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.pressed.connect(func(): mode_overlay.show())
	box.add_child(start_button)
	box.move_child(start_button, play_button.get_index())
	mode_overlay = Control.new()
	mode_overlay.hide()
	add_child(mode_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mode_overlay.add_child(dim)
	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	card.grow_vertical = Control.GROW_DIRECTION_BOTH
	mode_overlay.add_child(card)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 14)
	card.add_child(list)
	var heading := Label.new()
	heading.text = "Choose a mode"
	heading.add_theme_font_size_override("font_size", 34)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(heading)
	var modes := [[play_button, "Fly as far as you can and buy upgrades."],
		[rogue_button, "A new goal every round, a perk after every shot. Three lives."],
		[daily_button, "Today's roguelike run: the same for everyone."]]
	for mode in modes:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 18)
		list.add_child(row)
		var button: Button = mode[0]
		button.reparent(row)
		button.custom_minimum_size = Vector2(210, 0)
		button.pressed.connect(mode_overlay.hide)
		var about := Label.new()
		about.text = mode[1]
		about.custom_minimum_size = Vector2(330, 0)
		about.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		about.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(about)
	var back := Button.new()
	back.text = "Back"
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(mode_overlay.hide)
	list.add_child(back)
```

## Acceptance criteria
- `start_button` (PLAY, PrimaryButton) shows `mode_overlay`; Classic (`play_button`), Roguelike and Daily Run start their modes and close it; Back closes it.

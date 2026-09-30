---
id: 217-title-redesign
status: ready
tests: [tests/acceptance/test_217_title_redesign.gd, tests/acceptance/test_038_title_screen.gd, tests/acceptance/test_180_title_row.gd, tests/acceptance/test_212_title_pairs.gd, tests/acceptance/test_099_title_mascot.gd, tests/acceptance/test_142_tips.gd, tests/acceptance/test_148_challenge_label.gd]
files: [scripts/ui/title_panel.gd]
---

# Title screen redesign

The title stops being one tall box of buttons. It becomes a screen-sized layout (1280 x 720) with the mascot and the logo up
top, one big orange PLAY button that opens a mode chooser (Classic, Roguelike, Daily Run, each with a short
description), the other buttons in a bar along the bottom, and Reset progress as a small link in the top-right
corner. The same button objects are reused (moved into their new places). Six older tests are updated.

**`scripts/ui/title_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 adds three variables; Edit 2 renames the classic mode button; Edit 3 replaces the three `_pair(...)` calls at the end of `_ready()`; Edit 4 replaces the whole `_pair` function with two new functions. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var achievements_button: Button
```
REPLACE:
```gdscript
var achievements_button: Button
var start_button: Button
var mode_overlay: Control
var bottom_bar: HBoxContainer
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
	_pair(wardrobe_button, stats_button)
	_pair(options_button, credits_button)
```
REPLACE:
```gdscript
	_build_mode_chooser()
	_build_layout()
```

Edit 4 - SEARCH:
```gdscript
## Puts two buttons side by side in one row, where the first one was (keeps the title short enough).
func _pair(left: Button, right: Button) -> HBoxContainer:
	var row := HBoxContainer.new()
	box.add_child(row)
	box.move_child(row, left.get_index())
	for button in [left, right]:
		button.reparent(row)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return row
```
REPLACE:
```gdscript
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

## The title's layout: no box, but the mascot and the logo up top, the big PLAY button in the middle, the other
## buttons in a bar along the bottom (above the tip lines), and Reset progress small in the top-right corner.
func _build_layout() -> void:
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	custom_minimum_size = Vector2(1280, 720)
	box.add_theme_constant_override("separation", 8)
	var top_space := Control.new()
	top_space.custom_minimum_size = Vector2(0, 24)
	box.add_child(top_space)
	box.move_child(top_space, 0)
	for label in [title_label, greeting_label, best_label, rogue_best_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	bottom_bar = HBoxContainer.new()
	bottom_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_bar.add_theme_constant_override("separation", 12)
	box.add_child(bottom_bar)
	var old_row := help_button.get_parent()
	for button in [wardrobe_button, stats_button, achievements_button, help_button, options_button, credits_button]:
		button.reparent(bottom_bar)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	old_row.queue_free()
	var bottom_space := Control.new()
	bottom_space.custom_minimum_size = Vector2(0, 92)
	box.add_child(bottom_space)
	var corner := Control.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(corner)
	move_child(corner, box.get_index() + 1)
	reset_button.reparent(corner)
	reset_button.add_theme_font_size_override("font_size", 16)
	reset_button.flat = true
	reset_button.modulate = Color(1, 1, 1, 0.8)
	reset_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	reset_button.offset_left = -190
	reset_button.offset_right = -16
	reset_button.offset_top = 16
	reset_button.offset_bottom = 56
```

## Acceptance criteria
- `start_button` (PLAY) shows `mode_overlay`; Classic (`play_button`), Roguelike and Daily Run start their modes and close it; Back closes it.
- `bottom_bar` holds Wardrobe, Stats, Achievements, How to play, Options and Credits; Reset progress is flat, top right.

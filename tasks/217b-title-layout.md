---
id: 217b-title-layout
status: ready
tests: [tests/acceptance/test_217_title_redesign.gd, tests/acceptance/test_212_title_pairs.gd, tests/acceptance/test_180_title_row.gd, tests/acceptance/test_099_title_mascot.gd, tests/acceptance/test_142_tips.gd, tests/acceptance/test_148_challenge_label.gd]
files: [scripts/ui/title_panel.gd]
---

# Title screen layout

The title stops being one tall box of buttons. It becomes a screen-sized layout (1280 x 720): the mascot and the
logo up top, the PLAY button in the middle, the other buttons in a bar along the bottom (above the tip lines), and
Reset progress as a small link in the top-right corner. The `_pair` helper is no longer needed. Five older tests are
updated for the new layout.

**`scripts/ui/title_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 adds a variable; Edit 2 replaces the two `_pair(...)` calls at the end of `_ready()`; Edit 3 deletes the `_pair` function and keeps the first line of `set_mascot_hat()` right after it (keep `set_mascot_hat` and `show_progress` as they are); Edit 4 keeps the last line of `_build_mode_chooser()` and adds the new function `_build_layout()` after it, at the very end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var mode_overlay: Control
```
REPLACE:
```gdscript
var mode_overlay: Control
var bottom_bar: HBoxContainer
```

Edit 2 - SEARCH:
```gdscript
	_pair(wardrobe_button, stats_button)
	_pair(options_button, credits_button)
```
REPLACE:
```gdscript
	_build_layout()
```

Edit 3 - SEARCH:
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

func set_mascot_hat(id: String) -> void:
```
REPLACE:
```gdscript
func set_mascot_hat(id: String) -> void:
```

Edit 4 - SEARCH:
```gdscript
	list.add_child(back)
```
REPLACE:
```gdscript
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
- `bottom_bar` holds Wardrobe, Stats, Achievements, How to play, Options and Credits; Reset progress is flat, top right.
- The title is 1280 x 720, PLAY is centered, and the bar stays clear of the tip lines.

---
id: 221-results-columns
status: ready
tests: [tests/acceptance/test_221_results_columns.gd]
files: [scripts/ui/results_panel.gd]
---

# Results in two columns

The results become two columns (the shot on the left, the numbers on the right) above a big orange Continue, so
the panel is short and wide instead of one long list under the achievement pop-up.

**`scripts/ui/results_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds one line after Continue is added in `_ready()`; Edit 2 adds a function above `_on_continue_pressed()`. Each REPLACE keeps its SEARCH lines; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	vbox.add_child(continue_button)
```
REPLACE:
```gdscript
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	vbox.add_child(continue_button)
	_build_columns(vbox)
```

Edit 2 - SEARCH:
```gdscript
func _on_continue_pressed():
```
REPLACE:
```gdscript
## Two columns above Continue: the shot on the left (title, stars, quip, map, gap to the best), the numbers on
## the right. Wider and shorter than one long list, so it sits comfortably on the screen.
func _build_columns(vbox: VBoxContainer) -> void:
	custom_minimum_size = Vector2(860, 0)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 28)
	vbox.add_child(columns)
	vbox.move_child(columns, 0)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(400, 0)
	columns.add_child(left)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	for node in [title_label, rating, quip_label, shot_map, gap_label]:
		node.reparent(left)
	for node in [distance_label, stars_label, bounces_label, air_label, multiplier_label, total_label, coins_label,
			milestones_label, hats_label, balloons_label]:
		node.reparent(right)
	title_label.add_theme_font_size_override("font_size", 34)
	quip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	continue_button.theme_type_variation = "PrimaryButton"
	continue_button.add_theme_font_size_override("font_size", 28)

func _on_continue_pressed():
```

## Acceptance criteria
- `_build_columns(vbox)` moves the labels into the two columns; Continue uses the PrimaryButton style.
- The results are on screen, under 520 px tall, and clear of the pop-up.

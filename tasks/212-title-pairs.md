---
id: 212-title-pairs
status: ready
tests: [tests/acceptance/test_212_title_pairs.gd, tests/acceptance/test_180_title_row.gd]
files: [scripts/ui/title_panel.gd]
---

# Title buttons in pairs

The title screen was too tall: the daily challenge and tip lines were printed over its bottom buttons. The title's
buttons now come in pairs (Roguelike | Daily Run, Wardrobe | Stats, Options | Credits). One older test is updated.

**`scripts/ui/title_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds three lines above `show_progress(0.0, 0)` at the end of `_ready()`; Edit 2 adds a function above `set_mascot_hat()`. Each REPLACE keeps its SEARCH line; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	show_progress(0.0, 0)
```
REPLACE:
```gdscript
	_pair(rogue_button, daily_button)
	_pair(wardrobe_button, stats_button)
	_pair(options_button, credits_button)
	show_progress(0.0, 0)
```

Edit 2 - SEARCH:
```gdscript
func set_mascot_hat(id: String) -> void:
```
REPLACE:
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

## Acceptance criteria
- `_pair(left, right)` moves two buttons into one HBoxContainer row where the first one was.
- The title stays clear of the challenge and tip lines, and every button still works.

---
id: 180-title-row
status: ready
tests: [tests/acceptance/test_180_title_row.gd]
files: [scripts/ui/title_panel.gd]
---

# How to play and Achievements buttons

The title screen gets one row with two buttons side by side, "How to play" and "Achievements", right under Stats.

**`scripts/ui/title_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal wardrobe_pressed
```
REPLACE:
```gdscript
signal wardrobe_pressed
signal help_pressed
signal achievements_pressed
```

Edit 2 - SEARCH:
```gdscript
var mascot: TitleMascot
```
REPLACE:
```gdscript
var mascot: TitleMascot
var help_button: Button
var achievements_button: Button
```

Edit 3 - SEARCH:
```gdscript
	stats_button.connect("pressed", Callable(self, "_on_stats_pressed"))
	box.add_child(stats_button)
```
REPLACE:
```gdscript
	stats_button.connect("pressed", Callable(self, "_on_stats_pressed"))
	box.add_child(stats_button)
	
	var more_row := HBoxContainer.new()
	box.add_child(more_row)
	help_button = Button.new()
	help_button.text = "How to play"
	help_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_button.pressed.connect(func(): help_pressed.emit())
	more_row.add_child(help_button)
	achievements_button = Button.new()
	achievements_button.text = "Achievements"
	achievements_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_button.pressed.connect(func(): achievements_pressed.emit())
	more_row.add_child(achievements_button)
```

## Acceptance criteria
- `help_button` emits `help_pressed`; `achievements_button` emits `achievements_pressed`; both sit in an HBoxContainer under Stats.
- The title still fits on screen.

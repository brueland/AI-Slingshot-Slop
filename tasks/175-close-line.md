---
id: 175-close-line
status: ready
tests: [tests/acceptance/test_175_close_line.gd]
files: [scripts/ui/rogue_panel.gd]
---

# How close, on the perk panel

After a missed roguelike goal the perk panel says how close the shot came, under the title.

**`scripts/ui/rogue_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var weather_label: Label
```
REPLACE:
```gdscript
var weather_label: Label
var close_label: Label
```

Edit 2 - SEARCH:
```gdscript
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
```
REPLACE:
```gdscript
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	close_label = Label.new()
	close_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	close_label.hide()
	box.add_child(close_label)
```

Edit 3 - SEARCH:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
```
REPLACE:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
	close_label.text = "You got %d%% of the way there" % roundi(float(outcome.get("ratio", 0.0)) * 100.0)
	close_label.visible = not outcome.get("met", false)
```

## Acceptance criteria
- `close_label` reads `You got 23% of the way there` after a miss and is hidden after a met goal.
- The panel still fits on screen.

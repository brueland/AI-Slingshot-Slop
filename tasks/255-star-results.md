---
id: 255-star-results
status: ready
tests: [tests/acceptance/test_255_star_results.gd]
files: [scripts/ui/rogue_panel.gd]
---

# What the stars gave

After a roguelike shot with stars, the perk panel says what they gave and the run's total, e.g. "+2 stars: Speed+
x1, Lift+ x1 (23 this run)", in gold under the title lines. Without stars the line is hidden.

**1. `scripts/ui/rogue_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var close_label: Label
```
REPLACE:
```gdscript
var close_label: Label
## What this shot's stars gave (hidden without stars).
var stars_label: Label
```

Edit 2 - SEARCH:
```gdscript
	close_label.hide()
	box.add_child(close_label)
```
REPLACE:
```gdscript
	close_label.hide()
	box.add_child(close_label)
	stars_label = Label.new()
	stars_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	stars_label.hide()
	box.add_child(stars_label)
```

Edit 3 - SEARCH:
```gdscript
	close_label.visible = not outcome.get("met", false)
```
REPLACE:
```gdscript
	close_label.visible = not outcome.get("met", false)
	var gained: Array = outcome.get("stars_gained", [])
	stars_label.text = "+%d star%s: %s (%d this run)" % [gained.size(), "" if gained.size() == 1 else "s", StarBoosts.summary(gained), run.stars_total]
	stars_label.visible = not gained.is_empty()
```

## Acceptance criteria
- `RoguePanel.stars_label` (right after `close_label`) shows "+N star(s): <StarBoosts.summary> (<run total> this run)" when the shot had stars.

---
id: 135-title-rogue-best
status: ready
tests: [tests/acceptance/test_135_title_rogue_best.gd]
files: [scripts/ui/title_panel.gd, scripts/ui/ui_root.gd]
---

# Roguelike best on the title

The title shows "Roguelike best: N rounds" once a roguelike run has cleared a round.

**1. `scripts/ui/title_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var box: VBoxContainer
```
REPLACE:
```gdscript
var box: VBoxContainer
var rogue_best_label: Label
```

Edit 2 - SEARCH:
```gdscript
	best_label = Label.new()
	box.add_child(best_label)
```
REPLACE:
```gdscript
	best_label = Label.new()
	box.add_child(best_label)
	
	rogue_best_label = Label.new()
	rogue_best_label.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0))
	rogue_best_label.hide()
	box.add_child(rogue_best_label)
```

**2. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		title_panel.set_mascot_hat(progress.hat)
```
REPLACE:
```gdscript
		title_panel.set_mascot_hat(progress.hat)
		title_panel.rogue_best_label.visible = progress.best_rogue_round > 0
		title_panel.rogue_best_label.text = "Roguelike best: %d rounds" % progress.best_rogue_round
```

## Acceptance criteria
- Hidden while the best is 0; afterwards "Roguelike best: N rounds"; the title still fits on screen.

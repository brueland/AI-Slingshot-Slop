---
id: 112-rogue-stats
status: ready
tests: [tests/acceptance/test_112_rogue_stats.gd]
files: [scripts/ui/stats_panel.gd]
read: [scripts/core/hats.gd]
---

# Roguelike stats on the Stats screen

The Stats screen also shows the best roguelike run, how many daily runs were played and how many hats are unlocked
(not counting "No hat").

**`scripts/ui/stats_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var bounces_label: Label
```
REPLACE:
```gdscript
var bounces_label: Label
var rogue_label: Label
var daily_label: Label
var hats_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(bounces_label)
```
REPLACE:
```gdscript
	vbox.add_child(bounces_label)
	
	rogue_label = Label.new()
	vbox.add_child(rogue_label)
	daily_label = Label.new()
	vbox.add_child(daily_label)
	hats_label = Label.new()
	vbox.add_child(hats_label)
```

Edit 3 - SEARCH:
```gdscript
	bounces_label.text = "Bounces: %d" % int(progress.lifetime["bounces"])
```
REPLACE:
```gdscript
	bounces_label.text = "Bounces: %d" % int(progress.lifetime["bounces"])
	rogue_label.text = "Best roguelike run: %d rounds" % progress.best_rogue_round
	daily_label.text = "Daily runs played: %d" % progress.daily_best.size()
	hats_label.text = "Hats: %d / %d" % [Hats.unlocked(progress).size() - 1, Hats.LIST.size() - 1]
```

## Acceptance criteria
- "Best roguelike run: N rounds", "Daily runs played: N" (days in `progress.daily_best`) and "Hats: N / 6".
- The Stats screen still fits on screen.

---
id: 166-collection-stats
status: ready
tests: [tests/acceptance/test_166_collection_stats.gd]
files: [scripts/ui/stats_panel.gd]
---

# Collection line on the Stats screen

The Stats screen shows one more line under the roguelike total: balloons popped, sheep woken and achievements earned.

**`scripts/ui/stats_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var rogue_total_label: Label
```
REPLACE:
```gdscript
var rogue_total_label: Label
var collection_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(rogue_total_label)
```
REPLACE:
```gdscript
	vbox.add_child(rogue_total_label)
	collection_label = Label.new()
	vbox.add_child(collection_label)
```

Edit 3 - SEARCH:
```gdscript
	rogue_total_label.text = "Roguelike rounds cleared: %d" % progress.rogue_rounds_total
```
REPLACE:
```gdscript
	rogue_total_label.text = "Roguelike rounds cleared: %d" % progress.rogue_rounds_total
	collection_label.text = "Balloons popped: %d   Sheep woken: %d   Achievements: %d/%d" % [progress.balloons_total, progress.sheep_woken, progress.achievements.size(), Achievements.LIST.size()]
```

## Acceptance criteria
- `collection_label` reads `Balloons popped: 12   Sheep woken: 5   Achievements: 1/6` (with the real numbers).
- The stats still fit on screen.

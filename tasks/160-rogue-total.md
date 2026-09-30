---
id: 160-rogue-total
status: ready
tests: [tests/acceptance/test_160_rogue_total.gd]
files: [scripts/core/progress.gd, scripts/game/main.gd, scripts/ui/stats_panel.gd]
---

# Total roguelike rounds

The total of roguelike rounds cleared over all runs is saved and shown on the Stats screen.

**1. `scripts/core/progress.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var best_combo: int = 0
```
REPLACE:
```gdscript
var best_combo: int = 0
var rogue_rounds_total: int = 0
```

Edit 2 - SEARCH:
```gdscript
		"best_combo": best_combo,
```
REPLACE:
```gdscript
		"best_combo": best_combo,
		"rogue_rounds_total": rogue_rounds_total,
```

Edit 3 - SEARCH:
```gdscript
	p.best_combo = maxi(0, int(data.get("best_combo", 0)))
```
REPLACE:
```gdscript
	p.best_combo = maxi(0, int(data.get("best_combo", 0)))
	p.rogue_rounds_total = maxi(0, int(data.get("rogue_rounds_total", 0)))
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
			progress.add_rogue_run(rogue.rounds_cleared, rogue.run_seed, rogue.perks.size())
```
REPLACE:
```gdscript
			progress.add_rogue_run(rogue.rounds_cleared, rogue.run_seed, rogue.perks.size())
			progress.rogue_rounds_total += rogue.rounds_cleared
```

**3. `scripts/ui/stats_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var combo_label: Label
```
REPLACE:
```gdscript
var combo_label: Label
var rogue_total_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(combo_label)
```
REPLACE:
```gdscript
	vbox.add_child(combo_label)
	rogue_total_label = Label.new()
	vbox.add_child(rogue_total_label)
```

Edit 3 - SEARCH:
```gdscript
	combo_label.text = "Best combo: x%d" % progress.best_combo
```
REPLACE:
```gdscript
	combo_label.text = "Best combo: x%d" % progress.best_combo
	rogue_total_label.text = "Roguelike rounds cleared: %d" % progress.rogue_rounds_total
```

## Acceptance criteria
- Every finished roguelike run adds its rounds to `Progress.rogue_rounds_total` (saved).
- The Stats screen shows "Roguelike rounds cleared: N" and still fits.

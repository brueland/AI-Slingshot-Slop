---
id: 176-longest-shot
status: ready
tests: [tests/acceptance/test_176_longest_shot.gd]
files: [scripts/core/rogue_run.gd, scripts/ui/rogue_over_panel.gd]
---

# Longest shot of the run

A roguelike run remembers its longest shot, and the run-over screen shows it under the best.

**1. `scripts/core/rogue_run.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var weather: String = "calm"
```
REPLACE:
```gdscript
var weather: String = "calm"
var best_shot: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	shots = 0
```
REPLACE:
```gdscript
	shots = 0
	best_shot = 0.0
```

Edit 3 - SEARCH:
```gdscript
	shots += 1
```
REPLACE:
```gdscript
	shots += 1
	best_shot = maxf(best_shot, float(result.get("distance", 0.0)))
```

**2. `scripts/ui/rogue_over_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var best_label: Label
```
REPLACE:
```gdscript
var best_label: Label
var longest_label: Label
```

Edit 2 - SEARCH:
```gdscript
	box.add_child(best_label)
```
REPLACE:
```gdscript
	box.add_child(best_label)
	longest_label = Label.new()
	box.add_child(longest_label)
```

Edit 3 - SEARCH:
```gdscript
	best_label.text = "Best: %d rounds" % best_rounds
```
REPLACE:
```gdscript
	best_label.text = "Best: %d rounds" % best_rounds
	longest_label.text = "Longest shot: %d m" % int(run.best_shot)
```

## Acceptance criteria
- `RogueRun.best_shot` is the longest distance of the run (0 at a new run).
- `longest_label` reads `Longest shot: 123 m`.

---
id: 165-collection-records
status: ready
tests: [tests/acceptance/test_165_collection_records.gd]
files: [scripts/game/feedback.gd, scripts/core/progress.gd, scripts/game/main.gd]
---

# Balloon and sheep records

Milestone 20 adds collecting. The game counts every balloon popped and every sheep woken, over all classic runs.

**1. `scripts/game/feedback.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var best_combo_run: int = 0
```
REPLACE:
```gdscript
var best_combo_run: int = 0
var sheep_woken_run: int = 0
```

Edit 2 - SEARCH:
```gdscript
	best_combo_run = 0
```
REPLACE:
```gdscript
	best_combo_run = 0
	sheep_woken_run = 0
```

Edit 3 - SEARCH:
```gdscript
		if sheep >= 0:
			var baa := FloatingText.new()
```
REPLACE:
```gdscript
		if sheep >= 0:
			sheep_woken_run += 1
			var baa := FloatingText.new()
```

**2. `scripts/core/progress.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var rogue_rounds_total: int = 0
```
REPLACE:
```gdscript
var rogue_rounds_total: int = 0
var balloons_total: int = 0
var sheep_woken: int = 0
```

Edit 2 - SEARCH:
```gdscript
		"rogue_rounds_total": rogue_rounds_total,
```
REPLACE:
```gdscript
		"rogue_rounds_total": rogue_rounds_total,
		"balloons_total": balloons_total,
		"sheep_woken": sheep_woken,
```

Edit 3 - SEARCH:
```gdscript
	p.rogue_rounds_total = maxi(0, int(data.get("rogue_rounds_total", 0)))
```
REPLACE:
```gdscript
	p.rogue_rounds_total = maxi(0, int(data.get("rogue_rounds_total", 0)))
	p.balloons_total = maxi(0, int(data.get("balloons_total", 0)))
	p.sheep_woken = maxi(0, int(data.get("sheep_woken", 0)))
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	progress.best_combo = maxi(progress.best_combo, feedback.best_combo_run)
```
REPLACE:
```gdscript
	progress.best_combo = maxi(progress.best_combo, feedback.best_combo_run)
	progress.balloons_total += int(last_result.get("balloons", 0))
	progress.sheep_woken += feedback.sheep_woken_run
```

## Acceptance criteria
- `Feedback.sheep_woken_run` counts the sheep woken this shot (0 at a new shot).
- `Progress.balloons_total` and `Progress.sheep_woken` add up every classic run, are saved, and load never negative.

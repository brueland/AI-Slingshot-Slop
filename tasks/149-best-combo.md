---
id: 149-best-combo
status: ready
tests: [tests/acceptance/test_149_best_combo.gd]
files: [scripts/game/feedback.gd, scripts/core/progress.gd, scripts/game/main.gd]
---

# Remember the best combo

The longest combo is remembered: `Feedback.best_combo_run` for the current shot, and `Progress.best_combo` (saved)
for all classic runs.

**1. `scripts/game/feedback.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var combo_left: float = 0.0
```
REPLACE:
```gdscript
var combo_left: float = 0.0
var best_combo_run: int = 0
```

Edit 2 - SEARCH:
```gdscript
	combo = 0
	combo_left = 0.0
```
REPLACE:
```gdscript
	combo = 0
	combo_left = 0.0
	best_combo_run = 0
```

Edit 3 - SEARCH:
```gdscript
	combo_left = COMBO_WINDOW
```
REPLACE:
```gdscript
	combo_left = COMBO_WINDOW
	best_combo_run = maxi(best_combo_run, combo)
```

**2. `scripts/core/progress.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var challenge_day: String = ""
```
REPLACE:
```gdscript
var challenge_day: String = ""
var best_combo: int = 0
```

Edit 2 - SEARCH:
```gdscript
		"challenge_day": challenge_day,
```
REPLACE:
```gdscript
		"challenge_day": challenge_day,
		"best_combo": best_combo,
```

Edit 3 - SEARCH:
```gdscript
	p.challenge_day = str(data.get("challenge_day", ""))
```
REPLACE:
```gdscript
	p.challenge_day = str(data.get("challenge_day", ""))
	p.best_combo = maxi(0, int(data.get("best_combo", 0)))
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	progress.record_lifetime(last_result)
```
REPLACE:
```gdscript
	progress.record_lifetime(last_result)
	progress.best_combo = maxi(progress.best_combo, feedback.best_combo_run)
```

## Acceptance criteria
- `best_combo_run` is the longest combo of the shot (reset every shot); a classic run keeps the best in `Progress.best_combo`, saved.

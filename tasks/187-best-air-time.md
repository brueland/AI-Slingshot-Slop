---
id: 187-best-air-time
status: ready
tests: [tests/acceptance/test_187_best_air_time.gd]
files: [scripts/core/progress.gd, scripts/game/main.gd]
---

# Best air time

The longest air time of any classic shot is remembered and saved.

**1. `scripts/core/progress.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var sheep_woken: int = 0
```
REPLACE:
```gdscript
var sheep_woken: int = 0
var best_air_time: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
		"sheep_woken": sheep_woken,
```
REPLACE:
```gdscript
		"sheep_woken": sheep_woken,
		"best_air_time": best_air_time,
```

Edit 3 - SEARCH:
```gdscript
	p.sheep_woken = maxi(0, int(data.get("sheep_woken", 0)))
```
REPLACE:
```gdscript
	p.sheep_woken = maxi(0, int(data.get("sheep_woken", 0)))
	p.best_air_time = maxf(0.0, float(data.get("best_air_time", 0.0)))
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	progress.sheep_woken += feedback.sheep_woken_run
```
REPLACE:
```gdscript
	progress.sheep_woken += feedback.sheep_woken_run
	progress.best_air_time = maxf(progress.best_air_time, float(last_result["air_time"]))
	last_result["best_air_time"] = progress.best_air_time
```

## Acceptance criteria
- `Progress.best_air_time` is saved and loads never negative.
- main's classic `_finish_run` updates it and puts it in `last_result["best_air_time"]`.

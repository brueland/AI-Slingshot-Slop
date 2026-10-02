---
id: 269-last-path
status: ready
tests: [tests/acceptance/test_269_last_path.gd]
files: [scripts/core/run_session.gd, scripts/core/rogue_run.gd]
---

# The run remembers the last path

Milestone 37 improves Steady Hand: it will show the previous shot's whole flight path. This task keeps that path:
RunSession's `result()` includes the shot's `path` (world meters), and RogueRun remembers the last one (`last_path`,
empty at the start of a run).

**1. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	r["air_time"] = sim.air_time
```
REPLACE:
```gdscript
	r["air_time"] = sim.air_time
	r["path"] = path
```

**2. `scripts/core/rogue_run.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 3 adds one line in `finish_shot()` before the stars; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var star_boosts: Dictionary = {}
```
REPLACE:
```gdscript
var star_boosts: Dictionary = {}
## The flight path of the last shot (world meters), for Steady Hand's ghost.
var last_path: PackedVector2Array = PackedVector2Array()
```

Edit 2 - SEARCH:
```gdscript
	star_boosts.clear()
```
REPLACE:
```gdscript
	star_boosts.clear()
	last_path = PackedVector2Array()
```

Edit 3 - SEARCH:
```gdscript
	var stars_gained: Array[String] = []
```
REPLACE:
```gdscript
	last_path = result.get("path", PackedVector2Array())
	var stars_gained: Array[String] = []
```

## Acceptance criteria
- `RunSession.result()["path"]` is the session's `path`.
- `RogueRun.last_path` is the last finished shot's path (empty without one, and after `start()`).

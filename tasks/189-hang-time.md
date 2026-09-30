---
id: 189-hang-time
status: ready
tests: [tests/acceptance/test_189_hang_time.gd]
files: [scripts/game/feedback.gd]
---

# Hang time!

A single hop that keeps the alien in the air for 3 seconds or more gets a "Hang time!" popup when it lands.

**`scripts/game/feedback.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const CLOSE_RATIO: float = 0.85
```
REPLACE:
```gdscript
const CLOSE_RATIO: float = 0.85
## A single hop at least this long (seconds in the air) gets a "Hang time!" popup when it lands.
const HANG_SECONDS: float = 3.0
```

Edit 2 - SEARCH:
```gdscript
var sheep_woken_run: int = 0
```
REPLACE:
```gdscript
var sheep_woken_run: int = 0
## sim.air_time when the current hop began (the launch or the last bounce).
var hop_start: float = 0.0
```

Edit 3 - SEARCH:
```gdscript
	sheep_woken_run = 0
```
REPLACE:
```gdscript
	sheep_woken_run = 0
	hop_start = 0.0
```

Edit 4 - SEARCH:
```gdscript
	bounces_seen += 1
```
REPLACE:
```gdscript
	bounces_seen += 1
	if sim != null:
		if sim.air_time - hop_start >= HANG_SECONDS:
			_say("Hang time! %.1f s" % (sim.air_time - hop_start), Color(0.6, 0.9, 1.0))
		hop_start = sim.air_time
```

## Acceptance criteria
- `Feedback.hop_start` is `sim.air_time` when the current hop began (0 at a new shot).
- Each bounce after a hop of `HANG_SECONDS` (3 s) or more pops up `Hang time! 5.0 s`.

---
id: 270-steady-ghost
status: ready
tests: [tests/acceptance/test_270_steady_ghost.gd]
files: [scripts/game/main.gd, scripts/game/slingshot.gd, scripts/core/rogue_perks.gd]
---

# Steady Hand's ghost

Steady Hand drew a straight dashed line from the last pull, and it stayed up during the flight, sliding across the
screen with the world. Now, with Steady Hand, the roguelike shows the previous shot's whole flight path as a faint
ghost (GhostPath, like classic's best shot; RogueRun.last_path, task 269), and the slingshot only draws the last-aim
line while it is enabled (aiming): setting `enabled` redraws it.

**1. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one line in `_begin_aim()`; nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
	ghost.set_points(GhostPath.unpack(progress.best_path) if mode == "classic" else PackedVector2Array())
```
REPLACE:
```gdscript
	ghost.set_points(GhostPath.unpack(progress.best_path) if mode == "classic" else (rogue.last_path if rogue.has_perk("steady") else PackedVector2Array()))
```

**2. `scripts/game/slingshot.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 gives `enabled` a setter that redraws; edit 2 changes one line in `_draw()`; edit 3 adds `shown_aim_line()` after `aim_line_points()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var enabled: bool = true
```
REPLACE:
```gdscript
## Only while enabled (aiming) is the slingshot grabbed and the last-aim line drawn.
var enabled: bool = true:
	set(value):
		enabled = value
		queue_redraw()
```

Edit 2 - SEARCH:
```gdscript
	var aim := aim_line_points()
```
REPLACE:
```gdscript
	var aim := shown_aim_line()
```

Edit 3 - SEARCH:
```gdscript
	return PackedVector2Array([last_pull, -last_pull * AIM_LINE_LENGTH])
```
REPLACE:
```gdscript
	return PackedVector2Array([last_pull, -last_pull * AIM_LINE_LENGTH])


## The last-aim line as drawn: only while aiming (in flight it would slide across the screen with the world).
func shown_aim_line() -> PackedVector2Array:
	return aim_line_points() if enabled else PackedVector2Array()
```

**3. `scripts/core/rogue_perks.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes only Steady Hand's description; nothing else changes.

Edit 1 - SEARCH:
```gdscript
{"id": "steady", "name": "Steady Hand", "description": "Shows the line of your last shot"},```
REPLACE:
```gdscript
{"id": "steady", "name": "Steady Hand", "description": "Shows the line and the path of your last shot"},```

## Acceptance criteria
- In the roguelike with Steady Hand the ghost shows `rogue.last_path`; without it, nothing; classic still shows the best path.
- `Slingshot.shown_aim_line()` is the aim line while `enabled`, empty otherwise, and `_draw` uses it.

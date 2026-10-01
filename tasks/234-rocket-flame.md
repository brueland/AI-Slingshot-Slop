---
id: 234-rocket-flame
status: ready
tests: [tests/acceptance/test_234_rocket_flame.gd]
files: [scripts/game/feedback.gd, scripts/core/upgrade_catalog.gd, scripts/core/rogue_perks.gd]
---

# Flame while the rocket burns

The rocket now burns while Space is held (tasks 231-233), but the flame still only puffs once when it starts.
Feedback gets a `tick_rocket(delta)` (called from `_process`) that puffs a flame behind the alien every 0.06 s while
the rocket fires. The shop and the Rocket perk describe the new rocket.

**1. `scripts/game/feedback.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 4 adds `tick_rocket()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
## sim.air_time when the current hop began (the launch or the last bounce).
var hop_start: float = 0.0
```
REPLACE:
```gdscript
## sim.air_time when the current hop began (the launch or the last bounce).
var hop_start: float = 0.0
## Seconds until the next flame puff while the rocket fires.
var flame_left: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
const CLOSE_RATIO: float = 0.85
```
REPLACE:
```gdscript
const CLOSE_RATIO: float = 0.85
## While the rocket fires, a puff of flame this often (seconds).
const FLAME_EVERY: float = 0.06
```

Edit 3 - SEARCH:
```gdscript
func _process(delta: float) -> void:
	tick_combo(delta)
```
REPLACE:
```gdscript
func _process(delta: float) -> void:
	tick_combo(delta)
	tick_rocket(delta)
```

Edit 4 - SEARCH:
```gdscript
	pop.setup("Pop!", Color(1.0, 0.6, 0.85))
	pop.position = projectile_view.position + Vector2(-16.0, -44.0)
	if popups != null:
		popups.add_child(pop)
```
REPLACE:
```gdscript
	pop.setup("Pop!", Color(1.0, 0.6, 0.85))
	pop.position = projectile_view.position + Vector2(-16.0, -44.0)
	if popups != null:
		popups.add_child(pop)


## While the rocket fires, a puff of flame behind the alien every FLAME_EVERY seconds.
func tick_rocket(delta: float) -> void:
	if sim == null or effects == null or projectile_view == null or not sim.is_boosting():
		flame_left = 0.0
		return
	flame_left -= delta
	if flame_left <= 0.0:
		effects.spawn_flame(projectile_view.position)
		flame_left = FLAME_EVERY
```

**2. `scripts/core/upgrade_catalog.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes only the `boosts` description; nothing else changes.

Edit 1 - SEARCH:
```gdscript
"per_level": 1, "description": "1 boost charge per level"},```
REPLACE:
```gdscript
"per_level": 1, "description": "+0.5 s of rocket per level (hold Space in the air)"},```

**3. `scripts/core/rogue_perks.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes only the Rocket perk's description; nothing else changes.

Edit 1 - SEARCH:
```gdscript
{"id": "boost", "name": "Rocket", "description": "+1 mid-air boost"},```
REPLACE:
```gdscript
{"id": "boost", "name": "Rocket", "description": "+0.5 s of rocket (hold Space)"},```

## Acceptance criteria
- `Feedback.tick_rocket(delta)` spawns a flame every `FLAME_EVERY` (0.06) seconds while `sim.is_boosting()`, and none otherwise.
- The `boosts` upgrade and the Rocket perk descriptions say "0.5 s of rocket".

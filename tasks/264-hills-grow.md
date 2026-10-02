---
id: 264-hills-grow
status: ready
tests: [tests/acceptance/test_264_hills_grow.gd, tests/acceptance/test_022_main_run_flow.gd, tests/acceptance/test_030c_checkpoint_scene.gd]
files: [scripts/core/rogue_run.gd, scripts/core/progress.gd]
---

# The hills grow

Shots now get hills that grow as the game goes on (Terrain, task 261): a roguelike shot gets its round's hills and
keeps its landing zones flat (the zone plus its dip's slopes); a classic shot gets the hills of the best distance.

**1. `scripts/core/rogue_run.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds three lines at the end of `stats()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	s.boss = fight
	return s
```
REPLACE:
```gdscript
	s.boss = fight
	s.hills = Terrain.for_round(round_number)
	for zone in ZoneMarker.zones_for(goal):
		s.flat_spans.append(Vector2(zone.x - Balance.DIP_SLOPE, zone.y + Balance.DIP_SLOPE))
	return s
```

**2. `scripts/core/progress.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE makes `stats()` set the hills; nothing else changes.

Edit 1 - SEARCH:
```gdscript
func stats() -> PlayerStats:
	return PlayerStats.from_levels(levels)
```
REPLACE:
```gdscript
func stats() -> PlayerStats:
	var s := PlayerStats.from_levels(levels)
	s.hills = Terrain.for_best_distance(best_distance)
	return s
```

## Acceptance criteria
- `RogueRun.stats().hills` is `Terrain.for_round(round_number)`; each landing zone of the goal is a flat span (zone +/- DIP_SLOPE).
- `Progress.stats().hills` is `Terrain.for_best_distance(best_distance)`.
- Older tests 022 and 030c now expect the second classic course on the hills of the best distance (the same course as `RunSession.new(progress.stats(), 2)`).

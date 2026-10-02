---
id: 250-meadow-goes-on
status: ready
tests: [tests/acceptance/test_250_meadow_goes_on.gd, tests/acceptance/test_058_scenery.gd]
files: [scripts/game/hills.gd, scripts/game/scenery.gd, scripts/game/world_builder.gd]
---

# The meadow goes on

Past the course the meadow looked empty, and the far hills had a visible step where their 1800 px tile repeats
(the wave didn't fit the tile). Now the hills' wave fits the tile exactly (two waves per 1800 px), so they repeat
seamlessly, and the rocks and plants go on to 8000 m. One older test is updated for the longer scenery.

**1. `scripts/game/hills.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes only the wave inside `sin(...)` in `outline()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		out.append(Vector2(x, -base - height * (0.5 + 0.5 * sin(x / 170.0 + phase))))
```
REPLACE:
```gdscript
		out.append(Vector2(x, -base - height * (0.5 + 0.5 * sin(x * TAU * 2.0 / WIDTH + phase))))
```

**2. `scripts/game/scenery.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
const SEED: int = 7
```
REPLACE:
```gdscript
const SEED: int = 7
## The meadow's rocks and plants go on this far (meters), well past the 2000 m course.
const LENGTH: float = 8000.0
```

**3. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the length the scenery is built for; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	main.scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)
```
REPLACE:
```gdscript
	main.scenery.build(Scenery.SEED, Scenery.LENGTH)
```

## Acceptance criteria
- `Hills.outline()` uses `sin(x * TAU * 2.0 / WIDTH + phase)`: its two ends meet.
- `Scenery.LENGTH` is 8000.0 and WorldBuilder builds the scenery that far.

---
id: 124-black-sheep
status: ready
tests: [tests/acceptance/test_124_black_sheep.gd]
files: [scripts/game/critters.gd, scripts/game/feedback.gd]
---

# Black sheep

Some sheep are black (index 2, 6, 10, ...). They are a little grumpy and say "Meh." instead of "Baa!".

**1. `scripts/game/critters.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edits 1-2 keep their SEARCH lines and add new ones; Edit 3 replaces the one `draw_circle` line. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const FACE := Color(0.2, 0.2, 0.22)
```
REPLACE:
```gdscript
const FACE := Color(0.2, 0.2, 0.22)
const BLACK_WOOL := Color(0.18, 0.17, 0.2)
```

Edit 2 - SEARCH:
```gdscript
func _process(delta: float) -> void:
```
REPLACE:
```gdscript
## Every sheep whose index is 2 more than a multiple of 4 is a black sheep (a little grumpier).
static func is_black(index: int) -> bool:
	return index % 4 == 2


func _process(delta: float) -> void:
```

Edit 3 - SEARCH:
```gdscript
			draw_circle(p + o, 6.0, WOOL)
```
REPLACE:
```gdscript
			draw_circle(p + o, 6.0, BLACK_WOOL if is_black(i) else WOOL)
```

**2. `scripts/game/feedback.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Edit 1 replaces the one `baa.setup` line. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
			baa.setup("Baa!", Color.WHITE)
```
REPLACE:
```gdscript
			baa.setup("Meh." if Critters.is_black(sheep) else "Baa!", Color.WHITE)
```

## Acceptance criteria
- `Critters.is_black(i)` is true when `i % 4 == 2`; black sheep are drawn with dark wool.
- Landing next to a black sheep pops up "Meh.", next to a white one "Baa!".

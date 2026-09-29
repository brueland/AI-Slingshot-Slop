---
id: 058-scenery
status: ready
tests: [tests/acceptance/test_058_scenery.gd]
files: [scripts/game/scenery.gd, scripts/game/main.gd]
read: [scripts/game/world_view.gd]
---

# Scenery: bushes, rocks and cacti along the ground

The sprites already exist: `assets/sprites/bush.png`, `rock.png`, `cactus.png` (Kenney, 70 px).

**1. Create `scripts/game/scenery.gd`:**
```gdscript
class_name Scenery
extends Node2D
## Bushes, rocks and cacti along the ground. Decoration only; the layout is the same every run.

const TEXTURES: Array[String] = [
	"res://assets/sprites/bush.png",
	"res://assets/sprites/rock.png",
	"res://assets/sprites/cactus.png",
]
const SEED: int = 7

var sprites: Array[Sprite2D] = []


static func layout(seed: int, length: float) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array = []
	var x := -60.0
	while true:
		x += rng.randf_range(8.0, 25.0)
		if x >= length:
			break
		out.append({"kind": rng.randi_range(0, TEXTURES.size() - 1), "x": x, "scale": rng.randf_range(0.5, 0.9)})
	return out
```
Add `func build(seed: int, length: float) -> void`: first `remove_child` and `free()` every old sprite and clear
`sprites`; then for each entry of `layout(seed, length)` create a Sprite2D with `load(TEXTURES[item["kind"]])`,
`position = WorldView.world_to_screen(Vector2(item["x"], 0.0))`, `offset = Vector2(0, -35)` (stands on the ground),
`scale = Vector2.ONE * float(item["scale"])`; add it and append it to `sprites`. (Read entries with typed
declarations or direct indexing; `var x := item["x"]` fails because `item` is untyped.)

**2. `scripts/game/main.gd`** (keep changes small): `var scenery: Scenery`; in `_ready()` right after
`world_view` is added: create it, `add_child(scenery)`, then `scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)`.
It must come after `world_view` and before `course_view` in the child order.

## Acceptance criteria
- `layout` is deterministic per seed, starts 60 m before the slingshot, 8-25 m apart, kinds 0-2, scales 0.5-0.9.
- `build` places one sprite per entry on the ground and replaces old sprites when rebuilt.
- main builds the whole course's scenery once, drawn in front of the ground and behind the course items.

---
id: 139-cows
status: ready
tests: [tests/acceptance/test_139_cows.gd]
files: [scripts/game/cows.gd, scripts/game/world_builder.gd, scripts/game/feedback.gd, scripts/game/main.gd]
---

# Cows that moo

Spotted cows stand in the meadow and say "Moo!" when the alien lands within 5 m of one.

**1. Create the file `scripts/game/cows.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Cows
extends Node2D
## Spotted cows standing in the meadow. They moo when the alien lands next to them.

const SEED: int = 31
const REACT_DISTANCE: float = 5.0
const HIDE := Color(0.98, 0.98, 0.96)
const SPOTS := Color(0.15, 0.15, 0.15)

var xs: Array[float] = []


## Cow positions (meters) for a seed: one every 120-260 m, starting after 60 m.
static func layout(seed: int, length: float) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[float] = []
	var x := 60.0
	while true:
		x += rng.randf_range(120.0, 260.0)
		if x >= length:
			break
		out.append(x)
	return out


func _ready() -> void:
	xs = layout(SEED, Balance.COURSE_LENGTH)
	queue_redraw()


## The nearest cow within REACT_DISTANCE meters of `world_x`, or -1.
func react(world_x: float) -> int:
	var best := -1
	var best_distance := REACT_DISTANCE
	for i in xs.size():
		var d := absf(xs[i] - world_x)
		if d <= best_distance:
			best = i
			best_distance = d
	return best


func cow_position(index: int) -> Vector2:
	return WorldView.world_to_screen(Vector2(xs[index], 0.0))


func _draw() -> void:
	for i in xs.size():
		var p := cow_position(i)
		for leg in [-12.0, -5.0, 6.0, 12.0]:
			draw_line(p + Vector2(leg, -8), p + Vector2(leg, 0), SPOTS, 2.5)
		draw_rect(Rect2(p + Vector2(-16, -24), Vector2(32, 16)), HIDE)
		draw_circle(p + Vector2(-8, -18), 4.0, SPOTS)
		draw_circle(p + Vector2(6, -14), 3.0, SPOTS)
		draw_circle(p + Vector2(20, -24), 6.0, HIDE)
		draw_circle(p + Vector2(23, -22), 3.0, Color(1.0, 0.75, 0.8))
		draw_line(p + Vector2(17, -30), p + Vector2(15, -34), SPOTS, 2.0)
		draw_line(p + Vector2(22, -30), p + Vector2(24, -34), SPOTS, 2.0)
```

**2. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.flowers)
```
REPLACE:
```gdscript
	main.add_child(main.flowers)
	main.cows = Cows.new()
	main.add_child(main.cows)
```

Edit 2 - SEARCH:
```gdscript
	main.feedback.flowers = main.flowers
```
REPLACE:
```gdscript
	main.feedback.flowers = main.flowers
	main.feedback.cows = main.cows
```

**3. `scripts/game/feedback.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var flowers: Flowers
```
REPLACE:
```gdscript
var flowers: Flowers
var cows: Cows
```

Edit 2 - SEARCH:
```gdscript
		flowers.grow_at(sim.position.x)
```
REPLACE:
```gdscript
		flowers.grow_at(sim.position.x)
	if cows != null and sim != null and cows.react(sim.position.x) >= 0:
		_say("Moo!", Color.WHITE)
```

**4. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var flowers: Flowers
```
REPLACE:
```gdscript
var flowers: Flowers
var cows: Cows
```

## Acceptance criteria
- The herd is the same for the same seed (one cow every 120-260 m after 60 m); `react(x)` finds a cow within 5 m.
- Landing next to a cow pops up "Moo!".

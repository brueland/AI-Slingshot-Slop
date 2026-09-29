---
id: 088-sheep
status: ready
tests: [tests/acceptance/test_088_sheep.gd]
files: [scripts/game/critters.gd, scripts/game/feedback.gd, scripts/game/main.gd]
read: [scripts/game/scenery.gd, scripts/game/floating_text.gd]
---

# Sheep in the meadow

Sheep graze along the course. When the alien bounces within 4 m of one, it hops and a "Baa!" pops up.

**1. Create the file `scripts/game/critters.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Critters
extends Node2D
## Sheep grazing in the meadow (drawn with circles). A sheep hops when the alien lands next to it.

const SEED: int = 11
const HOP_SECONDS: float = 0.5
const HOP_HEIGHT_PX: float = 14.0
const REACT_DISTANCE: float = 4.0
const WOOL := Color(0.97, 0.97, 0.94)
const FACE := Color(0.2, 0.2, 0.22)

var xs: Array[float] = []
var hop_left: Array[float] = []


## Sheep x positions (meters) for a seed: one every 35-90 m, starting after 25 m.
static func layout(seed: int, length: float) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[float] = []
	var x := 25.0
	while true:
		x += rng.randf_range(35.0, 90.0)
		if x >= length:
			break
		out.append(x)
	return out


func build(seed: int, length: float) -> void:
	xs = layout(seed, length)
	hop_left.clear()
	for i in xs.size():
		hop_left.append(0.0)
	queue_redraw()


## The nearest sheep within REACT_DISTANCE meters of `world_x` hops. Returns its index, or -1.
func react(world_x: float) -> int:
	var best := -1
	var best_distance := REACT_DISTANCE
	for i in xs.size():
		var d := absf(xs[i] - world_x)
		if d <= best_distance:
			best = i
			best_distance = d
	if best >= 0:
		hop_left[best] = HOP_SECONDS
		queue_redraw()
	return best


## How high (screen pixels) sheep `index` is in its hop right now.
func hop_offset(index: int) -> float:
	var left := hop_left[index]
	if left <= 0.0:
		return 0.0
	return sin(PI * (1.0 - left / HOP_SECONDS)) * HOP_HEIGHT_PX


## Screen position of sheep `index`'s feet.
func sheep_position(index: int) -> Vector2:
	return WorldView.world_to_screen(Vector2(xs[index], 0.0)) - Vector2(0.0, hop_offset(index))


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	var hopping := false
	for i in hop_left.size():
		if hop_left[i] > 0.0:
			hop_left[i] = maxf(hop_left[i] - delta, 0.0)
			hopping = true
	if hopping:
		queue_redraw()


func _draw() -> void:
	for i in xs.size():
		var p := sheep_position(i)
		draw_line(p + Vector2(-6, -5), p + Vector2(-6, 0), FACE, 2.0)
		draw_line(p + Vector2(6, -5), p + Vector2(6, 0), FACE, 2.0)
		for o in [Vector2(-7, -11), Vector2(0, -14), Vector2(7, -11), Vector2(-3, -8), Vector2(4, -8)]:
			draw_circle(p + o, 6.0, WOOL)
		draw_circle(p + Vector2(12, -13), 4.0, FACE)
		draw_circle(p + Vector2(13, -14), 1.0, Color.WHITE)
```

**2. `scripts/game/feedback.gd`** (keep everything else):
- **Declare the variables** after `var hud: Hud`:
  ```gdscript
  var critters: Critters
  var sim: FlightSim
  ```
- In `watch()`, after `star_value = session.stats.star_value`, add `sim = session.sim`.
- At the end of `_on_bounced()`, add:
  ```gdscript
  	if critters != null and sim != null:
  		var sheep := critters.react(sim.position.x)
  		if sheep >= 0:
  			var baa := FloatingText.new()
  			baa.setup("Baa!", Color.WHITE)
  			baa.position = critters.sheep_position(sheep) + Vector2(-16.0, -48.0)
  			popups.add_child(baa)
  ```

**3. `scripts/game/main.gd`** (only these edits):
- **Declare** `var critters: Critters` after `var scenery: Scenery`.
- In `_ready()`, right after `scenery.build(Scenery.SEED, Balance.COURSE_LENGTH)`:
  ```gdscript
  	critters = Critters.new()
  	add_child(critters)
  	critters.build(Critters.SEED, Balance.COURSE_LENGTH)
  ```
- In `_ready()`, right after `projectile_view.set_hat(progress.hat)`: `feedback.critters = critters`

## Acceptance criteria
- The flock layout is the same for the same seed (one sheep every 35-90 m after 25 m).
- `react(x)` makes the nearest sheep within 4 m hop (0.5 s, 14 px high at the middle) and returns its index.
- main builds the flock (seed 11) between the scenery and the course items; a bounce next to a sheep makes it hop
  and shows "Baa!".

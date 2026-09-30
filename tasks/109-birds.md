---
id: 109-birds
status: ready
tests: [tests/acceptance/test_109_birds.gd]
files: [scripts/game/birds.gd, scripts/game/main.gd]
---

# Birds that scatter

Little birds sit in the sky along the course. When the alien flies within 90 px of one it scatters up and away with a
"Tweet!". Every new shot puts them back on their perches.

**1. Create the file `scripts/game/birds.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Birds
extends Node2D
## Little birds perched in the sky along the course. When the alien flies close they scatter, flapping away with a
## "Tweet!". A new shot brings them back.

const SEED: int = 23
const SCARE_DISTANCE_PX: float = 90.0
const FLY_VELOCITY := Vector2(140.0, -200.0)
const COLOR := Color(0.25, 0.2, 0.3)

var perches: Array[Vector2] = []
var flying: Array[bool] = []
var offsets: Array[Vector2] = []
var target: Node2D
var flap: float = 0.0


## Bird perches (world meters) for a seed: one every 50-120 m after 30 m, 6-16 m high.
static func layout(seed: int, length: float) -> Array[Vector2]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[Vector2] = []
	var x := 30.0
	while true:
		x += rng.randf_range(50.0, 120.0)
		if x >= length:
			break
		out.append(Vector2(x, rng.randf_range(6.0, 16.0)))
	return out


func _ready() -> void:
	perches = layout(SEED, Balance.COURSE_LENGTH)
	reset()


## Every bird back on its perch.
func reset() -> void:
	flying.clear()
	offsets.clear()
	for i in perches.size():
		flying.append(false)
		offsets.append(Vector2.ZERO)
	queue_redraw()


## Screen position of bird `index` right now.
func bird_position(index: int) -> Vector2:
	return WorldView.world_to_screen(perches[index]) + offsets[index]


## Scares the perched birds within SCARE_DISTANCE_PX of a screen position; each flies off with a "Tweet!".
## Returns how many were scared.
func scare_near(screen_position: Vector2) -> int:
	var scared := 0
	for i in perches.size():
		if not flying[i] and bird_position(i).distance_to(screen_position) <= SCARE_DISTANCE_PX:
			flying[i] = true
			scared += 1
			var tweet := FloatingText.new()
			tweet.setup("Tweet!", Color(0.9, 0.95, 1.0))
			tweet.position = bird_position(i) + Vector2(-20.0, -30.0)
			add_child(tweet)
	return scared


func advance(delta: float) -> void:
	flap = fmod(flap + delta * 14.0, TAU)
	for i in perches.size():
		if flying[i]:
			offsets[i] += FLY_VELOCITY * delta
	if target != null:
		scare_near(target.position)
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	for i in perches.size():
		var p := bird_position(i)
		var wing := 5.0 * sin(flap + i) if flying[i] else 2.0
		draw_polyline(PackedVector2Array([p + Vector2(-7, -wing), p + Vector2(-3, 0), p, p + Vector2(3, 0), p + Vector2(7, -wing)]), COLOR, 2.0)
		draw_circle(p, 2.0, COLOR)
```

**2. `scripts/game/main.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var critters: Critters
```
REPLACE:
```gdscript
var critters: Critters
var birds: Birds
```

Edit 2 - SEARCH:
```gdscript
	critters.build(Critters.SEED, Balance.COURSE_LENGTH)
```
REPLACE:
```gdscript
	critters.build(Critters.SEED, Balance.COURSE_LENGTH)
	birds = Birds.new()
	add_child(birds)
```

Edit 3 - SEARCH:
```gdscript
	feedback.critters = critters
```
REPLACE:
```gdscript
	feedback.critters = critters
	birds.target = projectile_view
```

Edit 4 - SEARCH:
```gdscript
	balloon_view.build(session.balloons)
```
REPLACE:
```gdscript
	balloon_view.build(session.balloons)
	birds.reset()
```

## Acceptance criteria
- The perches are the same for the same seed (one every 50-120 m after 30 m, 6-16 m high).
- `scare_near(pos)` makes perched birds within 90 px fly off (one "Tweet!" each); flying birds move up and right.
- main has `birds` (behind the course items) watching the alien; a new shot calls `birds.reset()`.

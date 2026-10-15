---
id: 318-farm-animals
status: ready
tests: [tests/acceptance/test_318_farm_animals.gd, tests/acceptance/test_300c_checkpoint_endless.gd]
files: [scripts/core/farm_animals.gd, scripts/core/run_session.gd]
---

# Sheep bounce, cows kick

The sheep and cows were only drawn. Now the alien can run into them: `FarmAnimals` (a new core script) puts them
where Critters and Cows draw them (their layouts repeat every COURSE_LENGTH). A sheep is springy: the alien
bounces up off its back (at least 8 m/s up). A cow kicks: the alien flies back the way it came (40% of its speed,
kept between 7 and 15 m/s) and up (5 m/s). Each animal counts once per shot, never in the stretches kept clear (landing zones, the boss), and flying
over them is no hit. Every RunSession has them, and the result counts the animals hit. Checkpoint 300c now picks
its long shot by prediction (cows can kick a shot back).

**1. Create the file `scripts/core/farm_animals.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name FarmAnimals
extends RefCounted
## The meadow's sheep and cows as things the alien can run into, where Critters and Cows draw them (their layouts
## repeat every COURSE_LENGTH). A sheep is springy: the alien bounces up off it. A cow kicks: the alien flies back a
## bit. Each animal counts once per shot, and none count in the stretches kept clear (landing zones, the boss).

signal sheep_hit(x: float)
signal cow_hit(x: float)

const SHEEP_HALF_WIDTH: float = 1.0
const SHEEP_HEIGHT: float = 1.3
const COW_HALF_WIDTH: float = 1.9
const COW_HEIGHT: float = 2.1
## Bouncing off a sheep sends the alien up at least this fast (m/s).
const SHEEP_BOUNCE: float = 8.0
## A cow's kick sends the alien back the way it came with COW_KICK_SHARE of its sideways speed (kept between
## COW_KICK_MIN and COW_KICK_MAX m/s), and COW_KICK_UP m/s up.
const COW_KICK_SHARE: float = 0.4
const COW_KICK_MIN: float = 7.0
const COW_KICK_MAX: float = 15.0
const COW_KICK_UP: float = 5.0

var sheep_xs: Array[float] = []
var cow_xs: Array[float] = []
## The alien's body (as Balloons.body).
var body: float = 0.0
## Stretches (x to y, meters) where the animals do not count.
var keep_clear: Array[Vector2] = []
## The animals already hit this shot (by their world x).
var hit: Dictionary = {}


func _init() -> void:
	sheep_xs = Critters.layout(Critters.SEED, Balance.COURSE_LENGTH)
	cow_xs = Cows.layout(Cows.SEED, Balance.COURSE_LENGTH)


## The copy of an animal laid out at `base_m` nearest `near_m` (never before the layout itself).
static func nearest(base_m: float, near_m: float) -> float:
	return base_m + Balance.COURSE_LENGTH * maxf(0.0, roundf((near_m - base_m) / Balance.COURSE_LENGTH))


## Bounces the alien off every sheep and lets every cow kick it that it ran into between `previous_position` and now.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	for base in sheep_xs:
		var x := nearest(base, sim.position.x)
		if _touches(sim, previous_position, x, SHEEP_HALF_WIDTH, SHEEP_HEIGHT, "sheep"):
			sim.position.y = maxf(sim.position.y, sim.ground_height(x) + SHEEP_HEIGHT)
			sim.velocity.y = maxf(absf(sim.velocity.y) * 0.8, SHEEP_BOUNCE)
			sim.stopped = false
			sheep_hit.emit(x)
	for base in cow_xs:
		var x := nearest(base, sim.position.x)
		if _touches(sim, previous_position, x, COW_HALF_WIDTH, COW_HEIGHT, "cow"):
			var back := -1.0 if previous_position.x <= x else 1.0
			var speed := clampf(absf(sim.velocity.x) * COW_KICK_SHARE, COW_KICK_MIN, COW_KICK_MAX)
			sim.velocity = Vector2(back * speed, COW_KICK_UP)
			sim.position.y = maxf(sim.position.y, sim.ground_height(x) + 0.05)
			sim.stopped = false
			cow_hit.emit(x)


## Whether the alien ran into the `kind` animal at `x` this step: not hit before, not in a kept-clear stretch.
func _touches(sim: FlightSim, previous_position: Vector2, x: float, half_width: float, height: float, kind: String) -> bool:
	var key := "%s:%d" % [kind, roundi(x * 10.0)]
	if hit.has(key):
		return false
	var reach := half_width + body
	if x < minf(previous_position.x, sim.position.x) - reach or x > maxf(previous_position.x, sim.position.x) + reach:
		return false
	if sim.position.y - sim.ground_height(x) > height + body:
		return false
	for span in keep_clear:
		if x >= span.x - 10.0 and x <= span.y + 10.0:
			return false
	hit[key] = true
	return true
```

**2. `scripts/core/run_session.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var trees: Trees
```
REPLACE:
```gdscript
var trees: Trees
## The meadow's sheep and cows, to bounce off and be kicked by (see FarmAnimals).
var animals: FarmAnimals
```

Edit 2 - SEARCH:
```gdscript
	trees.add(Trees.layout(course_seed, Balance.COURSE_LENGTH), 0.0, sim.flat_spans)
```
REPLACE:
```gdscript
	trees.add(Trees.layout(course_seed, Balance.COURSE_LENGTH), 0.0, sim.flat_spans)
	animals = FarmAnimals.new()
	animals.body = stats.pickup_offset
	animals.keep_clear = sim.flat_spans
```

Edit 3 - SEARCH:
```gdscript
	trees.after_step(sim, previous)
```
REPLACE:
```gdscript
	trees.after_step(sim, previous)
	animals.after_step(sim, previous)
```

Edit 4 - SEARCH:
```gdscript
	r["trees"] = trees.broken.count(true)
```
REPLACE:
```gdscript
	r["trees"] = trees.broken.count(true)
	r["animals"] = animals.hit.size()
```

## Acceptance criteria
- `FarmAnimals.after_step` bounces off sheep and lets cows kick, once per animal, not in `keep_clear` or when flying over.
- RunSession has `animals`, steps them after the trees; `result()["animals"]` counts the hits.

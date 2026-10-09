class_name Trees
extends RefCounted
## Trees along the meadow (world meters, like the balloons). Hit fast enough (BREAK_SPEED) the alien smashes through a
## tree and keeps most of its speed; slower, it bounces back off it. A broken tree stays down for the rest of the shot.

signal tree_broken(index: int)
signal tree_bounced(index: int)

## Hitting a tree at least this fast (m/s) breaks it; the alien keeps KEEP_SPEED of its speed.
const BREAK_SPEED: float = 18.0
const KEEP_SPEED: float = 0.85
## A slower hit sends the alien back with this share of its speed.
const BOUNCE: float = 0.4
## A tree reaches this far to each side of its trunk (meters): its crown.
const HALF_WIDTH: float = 1.6
const SEED_OFFSET: int = 1300

var xs: Array[float] = []
var heights: Array[float] = []
var broken: Array[bool] = []
## The alien's body (as Balloons.body).
var body: float = 0.0


## Trees for a seed over `length` meters: one every 90-220 m from 200 m on, 5-9 m tall, as (x, height).
static func layout(seed: int, length: float) -> Array[Vector2]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed + SEED_OFFSET
	var out: Array[Vector2] = []
	var x := 200.0
	while true:
		x += rng.randf_range(90.0, 220.0)
		if x >= length:
			break
		out.append(Vector2(x, rng.randf_range(5.0, 9.0)))
	return out


## Adds trees `offset_m` further along, except within 10 m of the `keep_clear` stretches (landing zones, the boss).
func add(trees: Array[Vector2], offset_m: float, keep_clear: Array[Vector2] = []) -> void:
	for t in trees:
		var x := t.x + offset_m
		var clear := true
		for span in keep_clear:
			if x >= span.x - 10.0 and x <= span.y + 10.0:
				clear = false
		if clear:
			xs.append(x)
			heights.append(t.y)
			broken.append(false)


## Breaks, or bounces the alien off, every standing tree it ran into between `previous_position` and now.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	var reach := HALF_WIDTH + body
	for i in xs.size():
		if broken[i]:
			continue
		var x := xs[i]
		if x < minf(previous_position.x, sim.position.x) - reach or x > maxf(previous_position.x, sim.position.x) + reach:
			continue
		var ground := sim.ground_height(x)
		if sim.position.y - ground > heights[i] + body:
			continue
		if sim.velocity.length() >= BREAK_SPEED:
			broken[i] = true
			sim.velocity *= KEEP_SPEED
			tree_broken.emit(i)
			continue
		if previous_position.y - ground > heights[i] + body:
			# dropped onto the crown: it rolls off the side it is on
			var side := 1.0 if sim.position.x >= x else -1.0
			sim.position.y = ground + heights[i] + body
			sim.velocity = Vector2(side * 4.0, 3.0)
		else:
			sim.position.x = x - reach if previous_position.x < x else x + reach
			sim.velocity.x = -sim.velocity.x * BOUNCE
		sim.stopped = false
		tree_bounced.emit(i)

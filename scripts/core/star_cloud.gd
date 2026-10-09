class_name StarCloud
extends RefCounted
## Very high up the sky is thick with stars: from FROM_M meters up, most CELL_M x CELL_M cells hold a star at a spot
## of their own (the same in every shot). Flying through collects them like course stars, so a shot that gets that
## high can grab a ton of them.

signal star_collected(cell: Vector2i)

const FROM_M: float = 600.0
const CELL_M: float = 4.0
## The share of cells that hold a star.
const CHANCE: float = 0.6
const SEED: int = 77

var pickup_offset: float = 0.0
var pickup_radius: float = Balance.STAR_RADIUS
## Stars collected this shot, and the cells they were in.
var count: int = 0
var collected: Dictionary = {}


## The star in `cell` (world meters), or Vector2.INF when that cell has none (below FROM_M, or by chance).
static func star_in(cell: Vector2i) -> Vector2:
	if cell.y * CELL_M < FROM_M:
		return Vector2.INF
	var rng := RandomNumberGenerator.new()
	rng.seed = cell.x * 73856093 + cell.y * 19349663 + SEED
	if rng.randf() > CHANCE:
		return Vector2.INF
	return (Vector2(cell) + Vector2(rng.randf_range(0.2, 0.8), rng.randf_range(0.2, 0.8))) * CELL_M


## Collects every star of the cloud the alien touched between `previous_position` and its position now.
func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	var a := previous_position + Vector2(0.0, pickup_offset)
	var b := sim.position + Vector2(0.0, pickup_offset)
	if maxf(a.y, b.y) + pickup_radius < FROM_M:
		return
	var low_x := floori((minf(a.x, b.x) - pickup_radius) / CELL_M)
	var high_x := floori((maxf(a.x, b.x) + pickup_radius) / CELL_M)
	var low_y := floori((minf(a.y, b.y) - pickup_radius) / CELL_M)
	var high_y := floori((maxf(a.y, b.y) + pickup_radius) / CELL_M)
	for cx in range(low_x, high_x + 1):
		for cy in range(low_y, high_y + 1):
			var cell := Vector2i(cx, cy)
			if collected.has(cell):
				continue
			var star := star_in(cell)
			if star == Vector2.INF:
				continue
			if Geometry2D.get_closest_point_to_segment(star, a, b).distance_to(star) <= pickup_radius:
				collected[cell] = true
				count += 1
				star_collected.emit(cell)

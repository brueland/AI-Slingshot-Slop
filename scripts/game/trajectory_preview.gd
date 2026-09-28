class_name TrajectoryPreview
extends Node2D
## Dots along the predicted flight while aiming. Points are stored in screen pixels.

const STEP_TIME: float = 0.1
const SUBSTEPS: int = 6

var points: PackedVector2Array = PackedVector2Array()


## World-space positions every STEP_TIME seconds, until `count` points or the ground.
static func compute_points(start: Vector2, velocity: Vector2, drag: float, count: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	var sim := FlightSim.new()
	sim.drag = drag
	sim.launch(start, velocity)
	for i in count:
		for s in SUBSTEPS:
			sim.step(STEP_TIME / SUBSTEPS)
		if sim.position.y <= 0.0:
			break
		out.append(sim.position)
	return out


## Clear points and append screen-space positions from compute_points.
func update_preview(start: Vector2, velocity: Vector2, drag: float, count: int) -> void:
	points.clear()
	var world_points := TrajectoryPreview.compute_points(start, velocity, drag, count)
	for p in world_points:
		points.append(WorldView.world_to_screen(p))
	queue_redraw()


## Clear points and redraw.
func clear() -> void:
	points.clear()
	queue_redraw()


## Draw trajectory dots with shrinking radius.
func _draw() -> void:
	for i in range(points.size()):
		var radius := 4.0 - (3.5 * (i / maxf(1, points.size() - 1)))
		draw_circle(points[i], radius, Color(1, 1, 1, 0.7))

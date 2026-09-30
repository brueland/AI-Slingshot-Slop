---
id: 182-course-bar
status: ready
tests: [tests/acceptance/test_182_course_bar.gd]
files: [scripts/ui/course_bar.gd]
---

# Course bar

A thin bar that shows how far the alien is on the way to 1000 m, with ticks at the milestones and the best distance.

**Create the file `scripts/ui/course_bar.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name CourseBar
extends Control
## A thin bar at the bottom of the HUD: how far the alien is on the way to 1000 m, with white ticks at the milestones
## and a gold tick at the best distance.

const BAR_SIZE := Vector2(400, 8)

var fraction: float = 0.0
var best_fraction: float = 0.0


func _ready() -> void:
	custom_minimum_size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Where `distance_m` is on the bar: 0.0 at the slingshot, 1.0 at Balance.GOAL_DISTANCE (1000 m) and beyond.
static func fraction_for(distance_m: float) -> float:
	return clampf(distance_m / Balance.GOAL_DISTANCE, 0.0, 1.0)


func set_distance(distance_m: float) -> void:
	fraction = fraction_for(distance_m)
	queue_redraw()


func set_best(best_m: float) -> void:
	best_fraction = fraction_for(best_m)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, BAR_SIZE), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(Vector2.ZERO, Vector2(BAR_SIZE.x * fraction, BAR_SIZE.y)), Color(0.5, 0.85, 1.0, 0.9))
	for m in Milestones.LIST:
		var x := BAR_SIZE.x * fraction_for(float(m["distance"]))
		draw_line(Vector2(x, -3), Vector2(x, BAR_SIZE.y + 3), Color(1, 1, 1, 0.7), 1.0)
	if best_fraction > 0.0:
		var best_x := BAR_SIZE.x * best_fraction
		draw_line(Vector2(best_x, -5), Vector2(best_x, BAR_SIZE.y + 5), Color(1.0, 0.85, 0.3), 2.0)
	draw_circle(Vector2(BAR_SIZE.x * fraction, BAR_SIZE.y / 2.0), 6.0, Color.WHITE)
```

## Acceptance criteria
- `CourseBar.fraction_for(m)` is m / 1000 clamped to 0..1; `set_distance` sets `fraction`; `set_best` sets `best_fraction`.

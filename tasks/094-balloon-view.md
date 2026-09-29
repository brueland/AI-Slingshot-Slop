---
id: 094-balloon-view
status: ready
tests: [tests/acceptance/test_094_balloon_view.gd]
files: [scripts/game/balloon_view.gd, scripts/game/feedback.gd, scripts/game/main.gd]
read: [scripts/core/balloons.gd]
---

# Draw and pop the balloons

**1. Create the file `scripts/game/balloon_view.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name BalloonView
extends Node2D
## Draws the current shot's party balloons (bobbing ovals on strings). Popped balloons disappear.

const COLORS: Array[Color] = [Color(0.95, 0.3, 0.35), Color(0.3, 0.6, 0.95), Color(1.0, 0.8, 0.2),
	Color(0.5, 0.85, 0.4), Color(0.8, 0.45, 0.9)]

var points: Array[Vector2] = []
var shown: Array[bool] = []
var bob: float = 0.0


func build(balloons: Balloons) -> void:
	points = balloons.points.duplicate()
	shown.clear()
	for i in points.size():
		shown.append(true)
	queue_redraw()


func pop(index: int) -> void:
	if index >= 0 and index < shown.size():
		shown[index] = false
		queue_redraw()


func visible_count() -> int:
	return shown.count(true)


## Screen position of balloon `index` right now (it bobs up and down a little).
func screen_position(index: int) -> Vector2:
	return WorldView.world_to_screen(points[index]) + Vector2(0.0, sin(bob + index) * 3.0)


static func ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		out.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return out


func _process(delta: float) -> void:
	bob = fmod(bob + delta * 2.0, TAU)
	if not points.is_empty():
		queue_redraw()


func _draw() -> void:
	for i in points.size():
		if not shown[i]:
			continue
		var c := screen_position(i)
		var color := COLORS[i % COLORS.size()]
		draw_line(c + Vector2(0, 17), c + Vector2(3, 40), Color(0.95, 0.95, 0.95, 0.8), 1.0)
		draw_colored_polygon(ellipse(c, 14.0, 18.0), color)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 20), c + Vector2(3, 20), c + Vector2(0, 16)]), color.darkened(0.2))
		draw_circle(c + Vector2(-5, -7), 3.5, Color(1, 1, 1, 0.45))
```

**2. `scripts/game/feedback.gd`** (keep everything else):
- **Declare** `var balloon_view: BalloonView` after `var sim: FlightSim`.
- In `watch()`, after `session.sim.boosted.connect(_on_boosted)`:
  `session.balloons.popped.connect(_on_balloon_popped)`
- Add this function at the end of the file:
  ```gdscript
  func _on_balloon_popped(index: int) -> void:
  	audio.play_sfx("spring")
  	projectile_view.set_mood("wow", 0.8)
  	if balloon_view != null:
  		effects.spawn_confetti(balloon_view.screen_position(index))
  		balloon_view.pop(index)
  	var pop := FloatingText.new()
  	pop.setup("Pop!", Color(1.0, 0.6, 0.85))
  	pop.position = projectile_view.position + Vector2(-16.0, -44.0)
  	popups.add_child(pop)
  ```

**3. `scripts/game/main.gd`** (only these edits):
- **Declare** `var balloon_view: BalloonView` after `var course_view: CourseView`.
- In `_ready()`, right after `add_child(course_view)`:
  ```gdscript
  	balloon_view = BalloonView.new()
  	add_child(balloon_view)
  ```
- In `_ready()`, right after `feedback.critters = critters`: `feedback.balloon_view = balloon_view`
- In `_begin_aim()`, right after `course_view.build(session.course)`: `balloon_view.build(session.balloons)`

## Acceptance criteria
- The view shows one bobbing balloon per point of the shot's Balloons; `pop(i)` hides one.
- main has the view right after the course view (behind the alien) and rebuilds it every shot.
- A pop hides the balloon, plays "spring", shows "Pop!", throws confetti and makes the alien say "wow".

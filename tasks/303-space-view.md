---
id: 303-space-view
status: ready
tests: [tests/acceptance/test_303_space_view.gd]
files: [scripts/game/space_things_view.gd, scripts/game/world_builder.gd, scripts/game/feedback.gd]
---

# Drawing the space things

`SpaceThingsView` (a new game script) draws the current shot's meteors (a tumbling rock with a fiery tail),
space stations (a hub with solar panels and a blinking light, as big as their bounce radius) and the star cloud
(one mesh of small stars), only what is on screen and only high up, and pops up "Whoosh!" and "Boing!".
WorldBuilder adds it to the world and to Feedback's new `watchers` list: Feedback hands every new shot to each watcher
(later views join the list the same way).

**1. Create the file `scripts/game/space_things_view.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name SpaceThingsView
extends Node2D
## Draws the current shot's meteors, space stations and star cloud (only what is on screen, high up) and pops up
## "Whoosh!" when the alien smashes a meteor and "Boing!" when it bounces off a station.

const ROCK := Color(0.5, 0.42, 0.38)
const FIRE := Color(1.0, 0.55, 0.15, 0.8)
const HULL := Color(0.86, 0.88, 0.92)
const PANEL := Color(0.25, 0.4, 0.85)

var shot: RunSession
var time: float = 0.0


func watch(session: RunSession) -> void:
	shot = session
	session.space.meteor_hit.connect(_on_meteor_hit)
	session.space.station_hit.connect(_on_station_hit)
	queue_redraw()


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


## The world stretch on screen (meters): x = left, y = right, plus the bottom and top heights.
func _view() -> Rect2:
	var to_world := get_canvas_transform().affine_inverse()
	var size := get_viewport_rect().size
	var a := WorldView.screen_to_world(to_world * Vector2.ZERO)
	var b := WorldView.screen_to_world(to_world * size)
	return Rect2(a.x, b.y, b.x - a.x, a.y - b.y)


func _draw() -> void:
	if shot == null:
		return
	var view := _view().grow(10.0)
	if view.end.y < 100.0:
		return
	for i in shot.space.meteors.size():
		var m := shot.space.meteor_position(i)
		if not shot.space.meteor_used[i] and view.has_point(m):
			_draw_meteor(WorldView.world_to_screen(m), i)
	for i in shot.space.stations.size():
		if view.has_point(shot.space.stations[i]):
			_draw_station(WorldView.world_to_screen(shot.space.stations[i]))
	if view.end.y >= StarCloud.FROM_M:
		_draw_cloud(view)


func _draw_meteor(at: Vector2, index: int) -> void:
	draw_colored_polygon(PackedVector2Array([at + Vector2(-10, -12), at + Vector2(-46, -40), at + Vector2(-14, 8)]), FIRE)
	var rock := PackedVector2Array()
	for k in 7:
		var angle := TAU * k / 7.0 + time * 1.5 + index
		rock.append(at + Vector2(cos(angle), sin(angle)) * 26.0 * (0.8 + 0.2 * sin(k * 2.1 + index)))
	draw_colored_polygon(rock, ROCK)
	draw_circle(at + Vector2(-6, -6), 6.0, Color(0.42, 0.35, 0.32))


func _draw_station(at: Vector2) -> void:
	draw_rect(Rect2(at + Vector2(-120, -14), Vector2(64, 28)), PANEL)
	draw_rect(Rect2(at + Vector2(56, -14), Vector2(64, 28)), PANEL)
	draw_line(at + Vector2(-56, 0), at + Vector2(56, 0), HULL, 6.0)
	draw_circle(at, 72.0, HULL)
	draw_circle(at, 46.0, Color(0.7, 0.74, 0.82))
	draw_circle(at, 18.0, Color(0.35, 0.75, 1.0))
	var blink := 1.0 if fmod(time, 1.0) < 0.5 else 0.25
	draw_circle(at + Vector2(0, -80), 6.0, Color(1.0, 0.3, 0.3, blink))


## The cloud's stars on screen (not collected yet) as one mesh: a small 4-pointed star each.
func _draw_cloud(view: Rect2) -> void:
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for cx in range(floori(view.position.x / StarCloud.CELL_M), floori(view.end.x / StarCloud.CELL_M) + 1):
		for cy in range(maxi(floori(view.position.y / StarCloud.CELL_M), 0), floori(view.end.y / StarCloud.CELL_M) + 1):
			var cell := Vector2i(cx, cy)
			if shot.cloud.collected.has(cell):
				continue
			var star := StarCloud.star_in(cell)
			if star == Vector2.INF:
				continue
			var c := WorldView.world_to_screen(star)
			var r := 7.0 + 2.0 * sin(time * 3.0 + cx + cy)
			var first := points.size()
			points.append_array(PackedVector2Array([c, c + Vector2(0, -r), c + Vector2(r * 0.35, 0), c + Vector2(0, r), c + Vector2(-r * 0.35, 0),
				c + Vector2(-r, 0), c + Vector2(0, -r * 0.35), c + Vector2(r, 0), c + Vector2(0, r * 0.35)]))
			for k in 9:
				colors.append(Color(1.0, 0.9, 0.35))
			indices.append_array(PackedInt32Array([first, first + 1, first + 2, first, first + 2, first + 3, first, first + 3, first + 4,
				first, first + 4, first + 1, first, first + 5, first + 6, first, first + 6, first + 7, first, first + 7, first + 8,
				first, first + 8, first + 5]))
	if not indices.is_empty():
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), indices, points, colors)


func _pop(text: String, at_m: Vector2, color: Color) -> void:
	var popup := FloatingText.new()
	popup.setup(text, color)
	popup.position = WorldView.world_to_screen(at_m) + Vector2(-30.0, -60.0)
	add_child(popup)


func _on_meteor_hit(index: int) -> void:
	_pop("Whoosh!", shot.space.meteor_position(index), Color(1.0, 0.7, 0.3))


func _on_station_hit(index: int) -> void:
	_pop("Boing!", shot.space.stations[index], Color(0.6, 0.85, 1.0))
```

**2. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.balloon_view)
```
REPLACE:
```gdscript
	main.add_child(main.balloon_view)
	var space_view := SpaceThingsView.new()
	main.add_child(space_view)
```

Edit 2 - SEARCH:
```gdscript
	main.feedback.cows = main.cows
```
REPLACE:
```gdscript
	main.feedback.cows = main.cows
	main.feedback.watchers.append(space_view)
```

**3. `scripts/game/feedback.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a variable; edit 2 adds two lines at the end of `watch()`'s connections (not inside an `if` above). Nothing else changes (feedback.gd must stay under 300 lines).

Edit 1 - SEARCH:
```gdscript
var boss_view: BossView
```
REPLACE:
```gdscript
var boss_view: BossView
## World views that follow every new shot: each has watch(session) (WorldBuilder adds them).
var watchers: Array[Node] = []
```

Edit 2 - SEARCH:
```gdscript
	session.extended.connect(_on_course_extended)
```
REPLACE:
```gdscript
	session.extended.connect(_on_course_extended)
	for watcher in watchers:
		watcher.watch(session)
```

## Acceptance criteria
- The view is a child of main, in `feedback.watchers`, and watches every shot; popups for meteor and station hits.

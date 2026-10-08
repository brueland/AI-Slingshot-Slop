---
id: 293-meadow-goes-on
status: ready
tests: [tests/acceptance/test_293_meadow_goes_on.gd]
files: [scripts/game/critters.gd, scripts/game/cows.gd, scripts/game/birds.gd]
---

# Sheep, cows and birds go on

The sheep, cows and birds stopped at 2000 m, and they drew every one of them every frame. Now each layout repeats
every 2000 m (WorldView.repeat_x), so they go on forever, they react and scatter at any distance, and only the
ones on screen are drawn (WorldView.visible_span).

**1. `scripts/game/critters.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 adds a variable; edit 2 adds a line in `build()`; edit 3 changes one line in `react()`; edit 4 changes the start of `_draw()` (the rest of its loop stays). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var hop_left: Array[float] = []
var time: float = 0.0
```
REPLACE:
```gdscript
var hop_left: Array[float] = []
var time: float = 0.0
## The flock's layout repeats every `period` meters (the length it was built for), so the meadow never runs out.
var period: float = Balance.COURSE_LENGTH
```

Edit 2 - SEARCH:
```gdscript
	xs = layout(seed, length)
```
REPLACE:
```gdscript
	xs = layout(seed, length)
	period = length
```

Edit 3 - SEARCH:
```gdscript
		var d := absf(xs[i] - world_x)
```
REPLACE:
```gdscript
		var d := absf(WorldView.repeat_x(xs[i], period, world_x) - world_x)
```

Edit 4 - SEARCH:
```gdscript
func _draw() -> void:
	for i in xs.size():
		var p := sheep_position(i)
```
REPLACE:
```gdscript
func _draw() -> void:
	# only the sheep on screen are drawn: the copy of each sheep nearest the middle of the view
	var span := WorldView.visible_span(self, 3.0)
	var middle := (span.x + span.y) / 2.0
	for i in xs.size():
		var x := WorldView.repeat_x(xs[i], period, middle)
		if x < span.x or x > span.y:
			continue
		var p := WorldView.ground_point(x) - Vector2(0.0, hop_offset(i))
```

**2. `scripts/game/cows.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 changes one line in `react()`; edit 2 replaces `_process()`; edit 3 changes the start of `_draw()` (the rest of its loop stays). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
		var d := absf(xs[i] - world_x)
```
REPLACE:
```gdscript
		var d := absf(WorldView.repeat_x(xs[i], Balance.COURSE_LENGTH, world_x) - world_x)
```

Edit 2 - SEARCH:
```gdscript
func _process(_delta: float) -> void:
	if seen_terrain != WorldView.terrain_version:
		seen_terrain = WorldView.terrain_version
		queue_redraw()
```
REPLACE:
```gdscript
func _process(_delta: float) -> void:
	seen_terrain = WorldView.terrain_version
	# the view moves, so the cows on screen are redrawn every frame (only those: see _draw)
	queue_redraw()
```

Edit 3 - SEARCH:
```gdscript
func _draw() -> void:
	for i in xs.size():
		var p := cow_position(i)
```
REPLACE:
```gdscript
func _draw() -> void:
	# the herd repeats every COURSE_LENGTH meters; only the cows on screen are drawn
	var span := WorldView.visible_span(self, 4.0)
	var middle := (span.x + span.y) / 2.0
	for i in xs.size():
		var x := WorldView.repeat_x(xs[i], Balance.COURSE_LENGTH, middle)
		if x < span.x or x > span.y:
			continue
		var p := WorldView.ground_point(x)
```

**3. `scripts/game/birds.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 1 adds `bird_position_near()` after `bird_position()`; edits 2-4 make `scare_near()` use it; edit 5 changes the start of `_draw()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	return WorldView.world_to_screen(perches[index]) + offsets[index]


## Scares the perched birds within SCARE_DISTANCE_PX of a screen position;```
REPLACE:
```gdscript
	return WorldView.world_to_screen(perches[index]) + offsets[index]


## Screen position of bird `index`'s copy nearest `near_m` (the perches repeat every COURSE_LENGTH meters).
func bird_position_near(index: int, near_m: float) -> Vector2:
	var perch := Vector2(WorldView.repeat_x(perches[index].x, Balance.COURSE_LENGTH, near_m), perches[index].y)
	return WorldView.world_to_screen(perch) + offsets[index]


## Scares the perched birds within SCARE_DISTANCE_PX of a screen position;```

Edit 2 - SEARCH:
```gdscript
	var scared := 0
```
REPLACE:
```gdscript
	var scared := 0
	var near := screen_position.x / Balance.PIXELS_PER_METER
```

Edit 3 - SEARCH:
```gdscript
		if not flying[i] and bird_position(i).distance_to(screen_position) <= SCARE_DISTANCE_PX:
```
REPLACE:
```gdscript
		if not flying[i] and bird_position_near(i, near).distance_to(screen_position) <= SCARE_DISTANCE_PX:
```

Edit 4 - SEARCH:
```gdscript
			tweet.position = bird_position(i) + Vector2(-20.0, -30.0)
```
REPLACE:
```gdscript
			tweet.position = bird_position_near(i, near) + Vector2(-20.0, -30.0)
```

Edit 5 - SEARCH:
```gdscript
func _draw() -> void:
	for i in perches.size():
		var p := bird_position(i)
```
REPLACE:
```gdscript
func _draw() -> void:
	# only the birds on screen are drawn (the copy of each bird nearest the middle of the view)
	var span := WorldView.visible_span(self, 20.0) * Balance.PIXELS_PER_METER
	var middle := (span.x + span.y) / 2.0 / Balance.PIXELS_PER_METER
	for i in perches.size():
		var p := bird_position_near(i, middle)
		if p.x < span.x or p.x > span.y:
			continue
```

## Acceptance criteria
- Sheep, cows and birds repeat every 2000 m and react there; `Birds.bird_position_near(index, near_m)`.
- Each draws only what is on screen.

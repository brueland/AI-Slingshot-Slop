---
id: 292-views-follow
status: ready
tests: [tests/acceptance/test_292_views_follow.gd, tests/acceptance/test_029_course_view.gd, tests/acceptance/test_273_endless_milestones.gd]
files: [scripts/game/course_view.gd, scripts/game/balloon_view.gd, scripts/game/feedback.gd]
---

# The views follow the growing course

When a long shot's course grows (task 291), Feedback hears `RunSession.extended` and the new items and balloons
appear (`CourseView.add_items`, `BalloonView.grow`). Milestone flags now stand up to FLAGS_TO_M (30000 m) instead of
8000 m. Only the stars and balloons on screen are animated and drawn (WorldView.visible_span), which keeps long
shots smooth. Two older tests are updated for the 34 flags.

**1. `scripts/game/course_view.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 4 splits `build()`: it now calls the new `add_items()`, which holds the old loop (the loop body does not change); edit 5 changes the star loop in `advance()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const GOAL_FLAG_TEXTURE: String = "res://assets/sprites/goal_flag.png"
```
REPLACE:
```gdscript
const GOAL_FLAG_TEXTURE: String = "res://assets/sprites/goal_flag.png"
## Milestone flags stand up to here (meters): further than the longest shot can fly in MAX_RUN_SECONDS.
const FLAGS_TO_M: float = 30000.0
```

Edit 2 - SEARCH:
```gdscript
## The distance of each flag (the milestones up to Scenery.LENGTH).
```
REPLACE:
```gdscript
## The distance of each flag (the milestones up to FLAGS_TO_M).
```

Edit 3 - SEARCH:
```gdscript
	for milestone in Milestones.up_to(Scenery.LENGTH):
```
REPLACE:
```gdscript
	for milestone in Milestones.up_to(FLAGS_TO_M):
```

Edit 4 - SEARCH:
```gdscript
func build(items: Array) -> void:
	clear()
	
	for i in range(items.size()):
```
REPLACE:
```gdscript
func build(items: Array) -> void:
	clear()
	add_items(items, 0)


## Adds sprites for `items` from index `first` on (a long shot's course grew: RunSession.extended).
func add_items(items: Array, first: int) -> void:
	for i in range(first, items.size()):
```

Edit 5 - SEARCH:
```gdscript
	for i in star_indices:
		if i < sprites.size():
			sprites[i].scale = Vector2(0.5, 0.5) * (1.0 + 0.1 * sin(time * 4.0 + i))
```
REPLACE:
```gdscript
	# only the stars on screen twinkle (a long shot's course has thousands)
	var span := WorldView.visible_span(self, 5.0) * Balance.PIXELS_PER_METER
	for i in star_indices:
		if i < sprites.size() and sprites[i].position.x >= span.x and sprites[i].position.x <= span.y:
			sprites[i].scale = Vector2(0.5, 0.5) * (1.0 + 0.1 * sin(time * 4.0 + i))
```

**2. `scripts/game/balloon_view.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds `grow()` between `build()` and `pop()`; edit 2 changes the start of `_draw()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	for i in points.size():
		shown.append(true)
	queue_redraw()


func pop(index: int) -> void:
```
REPLACE:
```gdscript
	for i in points.size():
		shown.append(true)
	queue_redraw()


## The shot's balloons grew (a long shot): show the new ones too.
func grow(balloons: Balloons) -> void:
	for i in range(points.size(), balloons.points.size()):
		points.append(balloons.points[i])
		hats.append(balloons.hats[i] if i < balloons.hats.size() else "")
		shown.append(true)
	queue_redraw()


func pop(index: int) -> void:
```

Edit 2 - SEARCH:
```gdscript
func _draw() -> void:
	for i in points.size():
		if not shown[i]:
			continue
```
REPLACE:
```gdscript
func _draw() -> void:
	# only the balloons on screen are drawn
	var span := WorldView.visible_span(self, 4.0)
	for i in points.size():
		if not shown[i] or points[i].x < span.x or points[i].x > span.y:
			continue
```

**3. `scripts/game/feedback.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds one line at the end of `watch()`'s connections (not inside the `if`); edit 2 adds `_on_course_extended()` right before `_on_wall_hit()`. Nothing else changes (feedback.gd must stay under 300 lines).

Edit 1 - SEARCH:
```gdscript
		session.balloons.popped.connect(_on_balloon_popped)
```
REPLACE:
```gdscript
		session.balloons.popped.connect(_on_balloon_popped)
	session.extended.connect(_on_course_extended)
```

Edit 2 - SEARCH:
```gdscript
## The alien hit the brick wall behind the slingshot: "Bonk!", a thud and a shake.
func _on_wall_hit() -> void:
```
REPLACE:
```gdscript
## A long shot's course grew: show its new stars, springs, mud and balloons.
func _on_course_extended(first_item: int, _first_balloon: int) -> void:
	if course_view != null:
		course_view.add_items(shot.course, first_item)
	if balloon_view != null:
		balloon_view.grow(shot.balloons)


## The alien hit the brick wall behind the slingshot: "Bonk!", a thud and a shake.
func _on_wall_hit() -> void:
```

## Acceptance criteria
- New course items and balloons get sprites/drawing when the course grows; 34 flags up to 30000 m.
- Stars twinkle and balloons are drawn only on screen.

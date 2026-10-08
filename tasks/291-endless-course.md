---
id: 291-endless-course
status: ready
tests: [tests/acceptance/test_291_endless_course.gd]
files: [scripts/core/run_session.gd, scripts/core/run_tracker.gd]
---

# The course goes on

The course was 2000 m long: past it there were no stars, springs, mud or balloons, though a strong shot flies
much further. Now it grows during the shot: when the alien gets within EXTEND_AHEAD_M (300 m) of its end,
`RunSession.extend_course()` adds the next 2000 m of stars, springs and mud (from the next seed, on the hills).
The tracker sees the new items (`RunTracker.grow`) and the `extended` signal tells the views (task 292); balloons
follow in task 292b. Short shots are exactly as before.

**1. `scripts/core/run_session.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 1 adds the signal and a constant at the top; edit 3 adds one line at the start of `_init()`; edit 4 adds two lines at the start of `step()`'s work; edit 5 adds `extend_course()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.
```
REPLACE:
```gdscript
class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.

## The course grew during the shot: course items from `first_item` and balloons from `first_balloon` on are new.
signal extended(first_item: int, first_balloon: int)

## When the alien gets this close (meters) to the end of the course, the next COURSE_LENGTH meters are added.
const EXTEND_AHEAD_M: float = 300.0
```

Edit 2 - SEARCH:
```gdscript
var _steps: int = 0
```
REPLACE:
```gdscript
var _steps: int = 0
## The course goes on: it ends at `course_end` (meters) for now and grows in COURSE_LENGTH pieces (extend_course);
## `layout_seed` is the course seed and `chunks` how many pieces there are.
var course_end: float = Balance.COURSE_LENGTH
var layout_seed: int = 0
var chunks: int = 1
```

Edit 3 - SEARCH:
```gdscript
	stats = player_stats
```
REPLACE:
```gdscript
	stats = player_stats
	layout_seed = course_seed
```

Edit 4 - SEARCH:
```gdscript
	var previous := sim.position
```
REPLACE:
```gdscript
	if sim.position.x > course_end - EXTEND_AHEAD_M:
		extend_course()
	var previous := sim.position
```

Edit 5 - SEARCH:
```gdscript
## The boost key went up.
func release_boost() -> void:
	sim.release_boost()
```
REPLACE:
```gdscript
## The boost key went up.
func release_boost() -> void:
	sim.release_boost()


## Adds the next COURSE_LENGTH meters of course after `course_end`: stars, springs and mud from the next seed (on
## the hills). RunTracker sees the new items; `extended` tells the views.
func extend_course() -> void:
	var chunk_seed := layout_seed * 7 + chunks * 104729
	var first_item := course.size()
	for item in CourseGenerator.generate(chunk_seed, Balance.COURSE_LENGTH):
		var x: float = float(item["x"]) + course_end
		item["x"] = x
		item["y"] = float(item["y"]) + sim.terrain_height(x)
		course.append(item)
	tracker.grow()
	var first_balloon := balloons.points.size()
	course_end += Balance.COURSE_LENGTH
	chunks += 1
	extended.emit(first_item, first_balloon)
```

**2. `scripts/core/run_tracker.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `grow()` between `is_used()` and `after_step()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	return _used[index]


func after_step(sim: FlightSim, previous_position: Vector2) -> void:
```
REPLACE:
```gdscript
	return _used[index]


## The course grew (RunSession.extend_course): the new items are not used yet.
func grow() -> void:
	while _used.size() < items.size():
		_used.append(false)


func after_step(sim: FlightSim, previous_position: Vector2) -> void:
```

## Acceptance criteria
- `RunSession.extend_course()` appends the next COURSE_LENGTH meters of items, raises `course_end` and emits `extended`.
- `step()` extends the course when the alien is within EXTEND_AHEAD_M of `course_end`; the new items work.

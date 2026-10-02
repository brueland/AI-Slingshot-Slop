---
id: 276-hat-balloons
status: ready
tests: [tests/acceptance/test_276_hat_balloons.gd]
files: [scripts/core/balloons.gd, scripts/core/run_session.gd, scripts/game/balloon_view.gd]
---

# Hat balloons

Now the hats (task 275) are out there: about one balloon in six carries a hat hanging from its string (rolled
from the course seed). Popping it finds the hat (`Balloons.found_hats`), and the shot's result lists the finds under
"found", so the hat unlocks when the shot ends.

**1. `scripts/core/balloons.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 2 adds two lines after `popped_count += 1`; edit 3 adds `carry_hats()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var body: float = 0.0
```
REPLACE:
```gdscript
var body: float = 0.0
## The hats some balloons carry ("" for none; see carry_hats), and the hats found by popping them this shot.
var hats: Array[String] = []
var found_hats: Array[String] = []
```

Edit 2 - SEARCH:
```gdscript
			popped_count += 1
```
REPLACE:
```gdscript
			popped_count += 1
			if i < hats.size() and hats[i] != "":
				found_hats.append(hats[i])
```

Edit 3 - SEARCH:
```gdscript
			popped.emit(i)
```
REPLACE:
```gdscript
			popped.emit(i)


## About one balloon in six carries a hat (Cowboy Hat, Viking Helmet or Bobble Beanie), rolled from the course seed.
func carry_hats(course_seed: int) -> void:
	var choices: Array[String] = ["cowboy", "viking", "beanie"]
	var rng := RandomNumberGenerator.new()
	rng.seed = course_seed * 7919 + 17
	hats.clear()
	for i in points.size():
		var hat: String = choices[rng.randi_range(0, 2)]
		hats.append(hat if rng.randi_range(1, 6) == 1 else "")
```

**2. `scripts/core/run_session.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	balloons.body = stats.pickup_offset
```
REPLACE:
```gdscript
	balloons.body = stats.pickup_offset
	balloons.carry_hats(course_seed)
```

Edit 2 - SEARCH:
```gdscript
	r["path"] = path
```
REPLACE:
```gdscript
	r["path"] = path
	r["found"] = balloons.found_hats.duplicate()
```

**3. `scripts/game/balloon_view.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 3 adds the hat drawing at the end of `_draw()`'s loop and `_draw_hat_tag()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var shown: Array[bool] = []
```
REPLACE:
```gdscript
var shown: Array[bool] = []
## The hat each balloon carries ("" for none).
var hats: Array[String] = []
```

Edit 2 - SEARCH:
```gdscript
	points = balloons.points.duplicate()
```
REPLACE:
```gdscript
	points = balloons.points.duplicate()
	hats = balloons.hats.duplicate()
```

Edit 3 - SEARCH:
```gdscript
		draw_circle(c + Vector2(-5, -7), 3.5, Color(1, 1, 1, 0.45))
```
REPLACE:
```gdscript
		draw_circle(c + Vector2(-5, -7), 3.5, Color(1, 1, 1, 0.45))
		if i < hats.size() and hats[i] != "":
			_draw_hat_tag(c + Vector2(3, 47), hats[i])


## A small hat hanging from a balloon's string: popping the balloon finds it.
func _draw_hat_tag(at: Vector2, id: String) -> void:
	match id:
		"cowboy":
			draw_colored_polygon(ellipse(at, 11.0, 2.5), Color(0.55, 0.33, 0.15))
			draw_rect(Rect2(at + Vector2(-5, -8), Vector2(10, 8)), Color(0.62, 0.38, 0.18))
		"viking":
			draw_circle(at + Vector2(0, -3), 6.0, Color(0.62, 0.64, 0.7))
			draw_line(at + Vector2(-5, -5), at + Vector2(-10, -12), Color(0.98, 0.95, 0.85), 3.0)
			draw_line(at + Vector2(5, -5), at + Vector2(10, -12), Color(0.98, 0.95, 0.85), 3.0)
		_:
			draw_circle(at + Vector2(0, -3), 6.0, Color(0.2, 0.7, 0.55))
			draw_circle(at + Vector2(0, -10), 2.5, Color(0.95, 0.4, 0.4))
```

## Acceptance criteria
- `Balloons.carry_hats(seed)` fills `hats` (about one in six, the same for the same seed); popping a hat balloon adds its hat to `found_hats`.
- RunSession calls it and `result()["found"]` lists the found hats; BalloonView draws them.

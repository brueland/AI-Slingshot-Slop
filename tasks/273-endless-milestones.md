---
id: 273-endless-milestones
status: ready
tests: [tests/acceptance/test_273_endless_milestones.gd, tests/acceptance/test_012_milestones.gd, tests/acceptance/test_031_hud.gd, tests/acceptance/test_029_course_view.gd, tests/acceptance/test_219_goal_bar.gd]
files: [scripts/core/milestones.gd, scripts/game/course_view.gd]
---

# Endless milestones

Classic milestones ran out at 1000 m ("All milestones reached!"). Now after the five a new one comes every 1000 m
for ever (its reward is its distance; the names come round in turn), and the course has a flag for each up to
8000 m (only the 1000 m one is the goal flag). Four older tests are updated for the endless milestones.

**1. `scripts/core/milestones.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 adds two constants after LIST; edit 2 changes the loop in `newly_reached()`; edit 3 replaces the last line of `next_milestone()` and adds `more()` and `up_to()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
]

## Returns an array of milestone entries that were newly reached.
```
REPLACE:
```gdscript
]
## After the last of LIST a new milestone every MORE_EVERY meters for ever: its reward is its distance, and the
## names come round in turn.
const MORE_EVERY: float = 1000.0
const MORE_NAMES: Array[String] = ["Cloud Surfer", "Jet Setter", "Orbit Chaser", "Star Hopper", "Comet Rider", "Galaxy Glider"]

## Returns an array of milestone entries that were newly reached.
```

Edit 2 - SEARCH:
```gdscript
	for m in LIST:
		if previous_best < m["distance"] and m["distance"] <= distance:
```
REPLACE:
```gdscript
	for m in up_to(distance):
		if previous_best < m["distance"] and m["distance"] <= distance:
```

Edit 3 - SEARCH:
```gdscript
	for m in LIST:
		if m["distance"] > best:
			return m
	return {}
```
REPLACE:
```gdscript
	for m in LIST:
		if m["distance"] > best:
			return m
	return more(maxi(0, floori((best - float(LIST[LIST.size() - 1]["distance"])) / MORE_EVERY)))


## The k-th milestone after LIST (k = 0 is the first, 1000 m after the last of LIST).
static func more(k: int) -> Dictionary:
	var distance := float(LIST[LIST.size() - 1]["distance"]) + MORE_EVERY * (k + 1)
	return {"distance": distance, "reward": int(distance), "name": MORE_NAMES[k % MORE_NAMES.size()]}


## Every milestone up to `distance`: those of LIST, then the endless ones.
static func up_to(distance: float) -> Array:
	var out := []
	for m in LIST:
		if m["distance"] <= distance:
			out.append(m)
	var k := 0
	while more(k)["distance"] <= distance:
		out.append(more(k))
		k += 1
	return out
```

**2. `scripts/game/course_view.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 2 and 3 change the flag loop in `_ready()`; edit 4 makes `set_best_marker()` use `flag_distances`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var flags: Array[Sprite2D] = []
```
REPLACE:
```gdscript
var flags: Array[Sprite2D] = []
## The distance of each flag (the milestones up to Scenery.LENGTH).
var flag_distances: Array[float] = []
```

Edit 2 - SEARCH:
```gdscript
	for milestone in Milestones.LIST:
		var flag := Sprite2D.new()
```
REPLACE:
```gdscript
	for milestone in Milestones.up_to(Scenery.LENGTH):
		var flag := Sprite2D.new()
		flag_distances.append(float(milestone["distance"]))
```

Edit 3 - SEARCH:
```gdscript
		if milestone["distance"] >= Balance.GOAL_DISTANCE:
```
REPLACE:
```gdscript
		if milestone["distance"] == Balance.GOAL_DISTANCE:
```

Edit 4 - SEARCH:
```gdscript
		flags[k].position = WorldView.ground_point(float(Milestones.LIST[k]["distance"]))
		flags[k].modulate = Color(1.0, 0.9, 0.4) if float(Milestones.LIST[k]["distance"]) <= distance else Color.WHITE
```
REPLACE:
```gdscript
		flags[k].position = WorldView.ground_point(flag_distances[k])
		flags[k].modulate = Color(1.0, 0.9, 0.4) if flag_distances[k] <= distance else Color.WHITE
```

## Acceptance criteria
- `Milestones.more(k)`, `up_to(distance)`; `newly_reached` and `next_milestone` include the endless milestones.
- CourseView has a flag (and `flag_distances`) for every milestone up to `Scenery.LENGTH`.

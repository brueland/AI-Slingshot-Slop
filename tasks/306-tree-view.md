---
id: 306-tree-view
status: ready
tests: [tests/acceptance/test_306_tree_view.gd]
files: [scripts/game/tree_view.gd, scripts/game/world_builder.gd]
---

# Drawing the trees

`TreeView` (a new game script) draws the current shot's trees (only those on screen): a trunk under a round leafy
crown, as tall as the tree; a broken one is a stump whose top tips over and falls. "Crash!" pops up when the alien
smashes through and "Bonk!" when it bounces off. WorldBuilder adds it after the cows and to Feedback's watchers.

**1. Create the file `scripts/game/tree_view.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name TreeView
extends Node2D
## Draws the current shot's trees (only those on screen): a trunk under a round leafy crown, as tall as the tree. A
## broken one is a stump whose top tips over and falls. "Crash!" when the alien smashes through, "Bonk!" when it
## bounces off.

const TRUNK := Color(0.45, 0.3, 0.18)
const LEAVES := Color(0.22, 0.55, 0.25)
const LEAVES_LIGHT := Color(0.32, 0.68, 0.32)
const STUMP_PX: float = 14.0

var shot: RunSession
## How far each broken tree has fallen (0 to 1), by tree index.
var fallen: Dictionary = {}


func watch(session: RunSession) -> void:
	shot = session
	fallen.clear()
	session.trees.tree_broken.connect(_on_tree_broken)
	session.trees.tree_bounced.connect(_on_tree_bounced)
	queue_redraw()


func _process(delta: float) -> void:
	for i in fallen:
		fallen[i] = minf(float(fallen[i]) + delta * 2.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if shot == null:
		return
	var span := WorldView.visible_span(self, 6.0)
	for i in shot.trees.xs.size():
		var x: float = shot.trees.xs[i]
		if x < span.x or x > span.y:
			continue
		var base := WorldView.ground_point(x)
		var h: float = shot.trees.heights[i] * Balance.PIXELS_PER_METER
		if shot.trees.broken[i]:
			draw_rect(Rect2(base + Vector2(-5, -STUMP_PX), Vector2(10, STUMP_PX)), TRUNK)
			draw_set_transform(base + Vector2(0, -STUMP_PX), float(fallen.get(i, 1.0)) * PI / 2.0, Vector2.ONE)
			_draw_tree(Vector2.ZERO, h - STUMP_PX)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			_draw_tree(base, h)


## A tree standing on `base`, `h` px tall: the crown's top is at the tree's height.
func _draw_tree(base: Vector2, h: float) -> void:
	var crown := base + Vector2(0, -h + 24.0)
	draw_rect(Rect2(base + Vector2(-5, -h + 24.0), Vector2(10, h - 24.0)), TRUNK)
	draw_circle(crown + Vector2(-14, 10), 17.0, LEAVES)
	draw_circle(crown + Vector2(14, 8), 17.0, LEAVES)
	draw_circle(crown, 24.0, LEAVES)
	draw_circle(crown + Vector2(-7, -8), 10.0, LEAVES_LIGHT)


func _pop(text: String, index: int, color: Color) -> void:
	var popup := FloatingText.new()
	popup.setup(text, color)
	var x: float = shot.trees.xs[index]
	popup.position = WorldView.ground_point(x) + Vector2(-30.0, -shot.trees.heights[index] * Balance.PIXELS_PER_METER - 30.0)
	add_child(popup)


func _on_tree_broken(index: int) -> void:
	fallen[index] = 0.0
	_pop("Crash!", index, Color(1.0, 0.75, 0.4))


func _on_tree_bounced(index: int) -> void:
	_pop("Bonk!", index, Color(0.8, 1.0, 0.7))
```

**2. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.cows)
```
REPLACE:
```gdscript
	main.add_child(main.cows)
	var tree_view := TreeView.new()
	main.add_child(tree_view)
```

Edit 2 - SEARCH:
```gdscript
	main.feedback.watchers.append(space_view)
```
REPLACE:
```gdscript
	main.feedback.watchers.append(space_view)
	main.feedback.watchers.append(tree_view)
```

## Acceptance criteria
- A TreeView (child of main, in `feedback.watchers`) draws the trees and pops up "Crash!"/"Bonk!".

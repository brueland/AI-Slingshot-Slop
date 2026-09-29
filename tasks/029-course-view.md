---
id: 029-course-view
status: ready
tests: [tests/acceptance/test_029_course_view.gd]
files: [scripts/game/course_view.gd]
read: [scripts/game/world_view.gd, scripts/core/milestones.gd, scripts/core/balance.gd]
---

# CourseView: course sprites and milestone flags

Create `scripts/game/course_view.gd`, which shows the course items as sprites and a flag at every milestone.

```gdscript
class_name CourseView
extends Node2D
## Course items as sprites (stars, springs, mud) plus a flag at every milestone.

const TEXTURES: Dictionary = {
	"star": "res://assets/sprites/star.png",
	"spring": "res://assets/sprites/spring.png",
	"mud": "res://assets/sprites/mud.png",
}
const FLAG_TEXTURE: String = "res://assets/sprites/flag.png"
const GOAL_FLAG_TEXTURE: String = "res://assets/sprites/goal_flag.png"

var sprites: Array[Sprite2D] = []
var flags: Array[Sprite2D] = []
```

- `_ready()`: for each entry of `Milestones.LIST`, add a `Sprite2D` flag at
  `WorldView.world_to_screen(Vector2(distance, 0))` with `offset = Vector2(0, -35)` (stands on the ground).
  The 1000 m goal (`distance >= Balance.GOAL_DISTANCE`) uses `GOAL_FLAG_TEXTURE`, the others `FLAG_TEXTURE`.
  Append each to `flags`.
- `func build(items: Array) -> void`: call `clear()`, then for each item (index `i`, read it with a typed
  declaration: `var item: Dictionary = items[i]`, **not** `var item := items[i]`, which Godot refuses because
  `items` is an untyped Array) create a `Sprite2D` named
  `"Item%d" % i` with `load(TEXTURES[type])`, add it as a child and append it to `sprites`. Positions (world -> screen
  with `WorldView.world_to_screen`):
  - star: at `(x, y)`, scale 0.5
  - spring: at `(x, 0)`, `offset = Vector2(0, -35)`, scale 0.6
  - mud: centered at `(x + Balance.MUD_WIDTH / 2.0, 0)`, scale `Vector2(Balance.MUD_WIDTH * 16 / 70, 0.3)`
- `func mark_collected(index: int) -> void`: hide `sprites[index]`; ignore indexes out of range.
- `func item_count() -> int`: `sprites.size()`
- `func clear() -> void`: for each sprite `remove_child(sprite)` then `sprite.free()`; empty `sprites`.
  Flags are never cleared.

## Acceptance criteria
- 5 flags (the last one uses goal_flag.png at 1000 m = 16000 px).
- `build` makes one sprite per item at the positions above; rebuilding removes the old sprites from the tree.
- `mark_collected` hides one sprite.

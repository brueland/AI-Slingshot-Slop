---
id: 099-title-mascot
status: ready
tests: [tests/acceptance/test_099_title_mascot.gd]
files: [scripts/ui/title_mascot.gd, scripts/ui/title_panel.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
read: [scripts/game/projectile_decor.gd]
---

# Title mascot

The title screen shows the alien at the top, bobbing happily and wearing the player's hat.

**1. Create the file `scripts/ui/title_mascot.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name TitleMascot
extends Control
## The alien bobbing happily at the top of the title screen, wearing the player's hat.

const TEXTURE: String = "res://assets/sprites/projectile_1.png"
const BOB_PX: float = 6.0
const SIZE_PX: float = 40.0

var texture: Texture2D
var decor: ProjectileDecor
var time: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(0, 100)
	texture = load(TEXTURE)
	decor = ProjectileDecor.new()
	add_child(decor)
	decor.top_level = false
	decor.scale = Vector2.ONE * (SIZE_PX / 24.0)
	decor.position = center()


func _process(delta: float) -> void:
	time += delta
	decor.position = center()
	queue_redraw()


func bob_offset() -> float:
	return sin(time * 3.0) * BOB_PX


## Where the alien's center is inside this control right now.
func center() -> Vector2:
	return Vector2(size.x / 2.0, 66.0 + bob_offset())


func set_hat(id: String) -> void:
	decor.set_hat(id)


func _draw() -> void:
	var half := Vector2(SIZE_PX, SIZE_PX) / 2.0
	draw_texture_rect(texture, Rect2(center() - half, half * 2.0), false)
```

**2. `scripts/ui/title_panel.gd`** (keep everything else):
- **Declare the variable** at the top of the class, on the line right after `var box: VBoxContainer`:
  ```gdscript
  var mascot: TitleMascot
  ```
- In `_ready()`, right after `add_child(box)` (so the mascot is the first child of the box, above the game name):
  ```gdscript
  	mascot = TitleMascot.new()
  	box.add_child(mascot)
  ```
- Add this function right before `show_progress()`:
  ```gdscript
  func set_mascot_hat(id: String) -> void:
  	mascot.set_hat(id)
  ```

**3. `scripts/ui/ui_root.gd`:** in `refresh()`, inside `if title_panel.visible:`, right after the
`title_panel.show_progress(...)` line: `title_panel.set_mascot_hat(progress.hat)`

**4. `scripts/game/main.gd`**: exactly these SEARCH/REPLACE edits. Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in
main.gd changes.

Edit 1 - SEARCH:
```gdscript
	projectile_view.set_hat(id)
	save_progress()
```
REPLACE:
```gdscript
	projectile_view.set_hat(id)
	title_panel.set_mascot_hat(id)
	save_progress()
```

## Acceptance criteria
- The title panel's box starts with a TitleMascot that bobs (at most 6 px) with its hat following it.
- It wears the player's hat: right after choosing one, after a restart, and none after a reset.
- The title panel still fits on screen.

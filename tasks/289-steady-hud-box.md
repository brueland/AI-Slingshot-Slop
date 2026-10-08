---
id: 289-steady-hud-box
status: ready
tests: [tests/acceptance/test_289_steady_hud_box.gd]
files: [scripts/ui/hud.gd]
---

# The HUD box keeps its width

Milestone 42 makes long shots endless and smooth. First the top-left HUD box: it was as wide as its widest line,
so it grew and shrank every frame while the numbers changed in flight (the font's digits have different widths)
and the height bar beside it jittered. Its text column now has a fixed minimum width, LEFT_TEXT_WIDTH (200 px,
room for a 5-digit distance).

**1. `scripts/ui/hud.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a constant after HINT_REPEAT; edit 2 adds one line in `_ready()`. Nothing else changes (hud.gd must stay under 300 lines).

Edit 1 - SEARCH:
```gdscript
const HINT_REPEAT: String = "Press R to repeat your last shot"
```
REPLACE:
```gdscript
const HINT_REPEAT: String = "Press R to repeat your last shot"
## The flight readouts' column is always this wide (pixels), so the top-left box keeps its size while the
## numbers change (the font's digits have different widths).
const LEFT_TEXT_WIDTH: float = 200.0
```

Edit 2 - SEARCH:
```gdscript
	var left_container := VBoxContainer.new()
	left_row.add_child(left_container)
```
REPLACE:
```gdscript
	var left_container := VBoxContainer.new()
	left_container.custom_minimum_size = Vector2(LEFT_TEXT_WIDTH, 0.0)
	left_row.add_child(left_container)
```

## Acceptance criteria
- `Hud.LEFT_TEXT_WIDTH` is 200.0 and the left column's `custom_minimum_size.x` is LEFT_TEXT_WIDTH.
- The box and the height bar keep their size and place while `update_flight` changes the numbers.

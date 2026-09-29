---
id: 072-aim-memory
status: ready
tests: [tests/acceptance/test_072_aim_memory.gd]
files: [scripts/game/slingshot.gd]
---

# Slingshot remembers the last aim

The slingshot remembers the pull of the last real launch and, when `show_last_aim` is on, draws a faint dashed
line from that pull point forward through the anchor (plus a ghost pouch), so a good shot can be repeated.
Nothing turns it on yet (task 073 does).

**`scripts/game/slingshot.gd`** (keep everything else exactly as it is):

1. Add these two constants after `const POWER_HIGH`:
   ```gdscript
   const AIM_LINE_LENGTH: float = 2.5
   const AIM_LINE_COLOR := Color(1, 1, 1, 0.55)
   ```
2. Add these variables after `var post_texture: Texture2D` (the setter redraws when it changes):
   ```gdscript
   var last_pull: Vector2 = Vector2.ZERO
   var show_last_aim: bool = false:
   	set(value):
   		show_last_aim = value
   		queue_redraw()
   ```
3. In `release()`, remember the pull only for a real launch - add `last_pull = p` right before
   `launched.emit(p)` (after the `MIN_PULL_PX` early return). `cancel_drag()` does not change `last_pull`.
4. Add this function above `_draw()`:
   ```gdscript
   ## The remembered aim: from the last pull point forward through the anchor, or nothing when hidden.
   func aim_line_points() -> PackedVector2Array:
   	if not show_last_aim or last_pull == Vector2.ZERO:
   		return PackedVector2Array()
   	return PackedVector2Array([last_pull, -last_pull * AIM_LINE_LENGTH])
   ```
5. At the very start of `_draw()` (so the line is under the bands and posts):
   ```gdscript
   	var aim := aim_line_points()
   	if aim.size() == 2:
   		draw_dashed_line(aim[0], aim[1], AIM_LINE_COLOR, 2.0, 8.0)
   		draw_circle(aim[0], 7.0, Color(1, 1, 1, 0.35))
   ```

## Acceptance criteria
- `last_pull` is the pull of the last launch; too-short pulls and cancelled drags do not change it.
- `aim_line_points()` is empty while `show_last_aim` is off or nothing was launched, else `[last_pull, -last_pull * 2.5]`.
- Drawing the line raises no errors, also while aiming again.

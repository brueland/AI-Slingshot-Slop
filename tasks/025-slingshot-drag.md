---
id: 025-slingshot-drag
status: ready
tests: [tests/acceptance/test_025_slingshot_drag.gd]
files: [scripts/game/slingshot.gd]
read: [scripts/core/launch_math.gd, scripts/core/balance.gd]
---

# Slingshot: drag, release and drawing

Create `scripts/game/slingshot.gd`. The node's `position` is the pouch's rest point (the anchor), in screen
pixels. The pull is the drag point minus the anchor. This task adds the drag API and drawing; task 026 connects
the mouse.

```gdscript
class_name Slingshot
extends Node2D
## The slingshot. The node's position is the pouch rest point (anchor), in screen pixels.
## pull = drag point - anchor. Posts are drawn from the anchor down to the ground.

signal launched(pull: Vector2)

const GRAB_RADIUS: float = 48.0

var max_pull: float = Balance.MAX_PULL_PX
var pull: Vector2 = Vector2.ZERO
var dragging: bool = false
var enabled: bool = true
var frame_height_px: float = Balance.BASE_LAUNCH_HEIGHT * Balance.PIXELS_PER_METER
var band_color: Color = Color(0.35, 0.2, 0.1)
var post_texture: Texture2D
```

Functions (points are in the same canvas space as `global_position`):
- `_ready()`: `post_texture = load("res://assets/sprites/post.png")`, `queue_redraw()`.
- `func begin_drag(point: Vector2) -> bool`: if not `enabled` or `point.distance_to(global_position) > GRAB_RADIUS`,
  return false. Else `dragging = true`, `pull = Vector2.ZERO`, `queue_redraw()`, return true.
- `func update_drag(point: Vector2) -> void`: only while dragging:
  `pull = LaunchMath.clamp_pull(point - global_position, max_pull)`, `queue_redraw()`.
- `func release() -> Vector2`: if not dragging return `Vector2.ZERO`. Else stop dragging, remember `p := pull`,
  reset `pull` to zero, `queue_redraw()`. If `p.length() < Balance.MIN_PULL_PX` return `Vector2.ZERO` (no launch);
  otherwise `launched.emit(p)` and return `p`.
- `func cancel_drag() -> void`: `dragging = false`, `pull = Vector2.ZERO`, `queue_redraw()`.
- `func pouch_position() -> Vector2`: `global_position + pull`.
- `_draw()`: two posts (the post texture with `draw_texture_rect`) at x = -18 and x = +18 from the anchor,
  from y = -6 down to `frame_height_px` (the ground); two band lines (`draw_line`, width 4, `band_color`) from
  the post tips (±18, 0) to `pull`; and a small `draw_circle(pull, 6.0, band_color)` for the pouch.

## Acceptance criteria
- Grabbing only works within 48 px of the anchor and when enabled.
- Dragging to (-60, 30) with the anchor at (0, -32) gives pull (-60, 62); long pulls clamp to 120 px.
- Releasing emits `launched(pull)` and returns it; pulls under 10 px emit nothing.

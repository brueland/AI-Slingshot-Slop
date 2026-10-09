---
id: 308-secret
status: ready
tests: [tests/acceptance/test_308_secret.gd, tests/acceptance/test_249_endless_ground.gd, tests/acceptance/test_286_wrong_way_signs.gd]
files: [scripts/game/wrong_way.gd, scripts/game/world_view.gd, scripts/game/world_builder.gd]
---

# The secret behind the wall

Behind the brick wall, for whoever breaks through (task 307), WrongWay draws a big thank-you sign ("THANK YOU FOR
PLAYING!", at -190 m) and the end of the world (a stone wall at -260 m). It now follows every shot (`watch`, in
Feedback's watchers): when the wall breaks it pops up "You found the secret!" and draws rubble where the wall
stood; the next shot rebuilds it. The ground is drawn back to -280 m. Older tests 249 and 286 are updated for it.

**1. `scripts/game/wrong_way.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 3 adds `watch()`, `_on_wall_broken()`, `_draw_secret()`, `_draw_heart()` and `_draw_rubble()` before `_draw()`; edit 4 adds four lines in `_draw()` before the wall is drawn. The others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
## Behind the slingshot: red "WRONG WAY" signs pointing back to the course and, at Balance.WALL_X, a giant brick wall
## the alien bounces off (FlightSim does the bouncing).
```
REPLACE:
```gdscript
## Behind the slingshot: red "WRONG WAY" signs pointing back to the course and, at Balance.WALL_X, a giant brick wall
## the alien bounces off (FlightSim does the bouncing). Behind the wall, for whoever breaks through it, a big sign
## thanks the players.
```

Edit 2 - SEARCH:
```gdscript
const MORTAR := Color(0.86, 0.8, 0.72)
```
REPLACE:
```gdscript
const MORTAR := Color(0.86, 0.8, 0.72)
## Where the thank-you sign stands (meters), between the wall and the end of the world.
const SECRET_SIGN_M: float = -190.0

var shot: RunSession
## The wall is down in this shot (the alien broke through).
var wall_down: bool = false
```

Edit 3 - SEARCH:
```gdscript
func _draw() -> void:
	var font := UiTheme.game_font(800)
```
REPLACE:
```gdscript
func watch(session: RunSession) -> void:
	shot = session
	wall_down = false
	session.sim.wall_broken.connect(_on_wall_broken)
	queue_redraw()


func _on_wall_broken() -> void:
	wall_down = true
	queue_redraw()
	var popup := FloatingText.new()
	popup.setup("You found the secret!", Color(1.0, 0.85, 0.3))
	popup.position = WorldView.world_to_screen(Vector2(Balance.WALL_X - 5.0, 8.0))
	add_child(popup)


## Behind the wall: the thank-you sign and the end of the world.
func _draw_secret() -> void:
	var base := WorldView.ground_point(SECRET_SIGN_M)
	var font := UiTheme.game_font(800)
	for post in [-150.0, 140.0]:
		draw_rect(Rect2(base + Vector2(post, -120), Vector2(10, 120)), Color(0.45, 0.3, 0.18))
	draw_rect(Rect2(base + Vector2(-190, -330), Vector2(380, 220)), Color(1.0, 0.85, 0.3))
	draw_rect(Rect2(base + Vector2(-182, -322), Vector2(364, 204)), Color(0.18, 0.12, 0.35))
	draw_string(font, base + Vector2(-182, -262), "THANK YOU", HORIZONTAL_ALIGNMENT_CENTER, 364, 44, Color(1.0, 0.85, 0.3))
	draw_string(font, base + Vector2(-182, -214), "FOR PLAYING!", HORIZONTAL_ALIGNMENT_CENTER, 364, 36, Color.WHITE)
	draw_string(font, base + Vector2(-182, -176), "You broke through to the secret.", HORIZONTAL_ALIGNMENT_CENTER, 364, 18, Color(0.85, 0.85, 1.0))
	draw_string(font, base + Vector2(-182, -150), "Have a wonderful flight!", HORIZONTAL_ALIGNMENT_CENTER, 364, 18, Color(0.85, 0.85, 1.0))
	for side in [-1.0, 1.0]:
		_draw_heart(base + Vector2(side * 150.0, -284.0), Color(1.0, 0.4, 0.55))
	var end := WorldView.world_to_screen(Vector2(Balance.SECRET_END_X, 0.0))
	draw_rect(Rect2(end.x - 64.0, end.y - 960.0, 64.0, 968.0), Color(0.45, 0.45, 0.5))


func _draw_heart(at: Vector2, color: Color) -> void:
	draw_circle(at + Vector2(-7, 0), 8.0, color)
	draw_circle(at + Vector2(7, 0), 8.0, color)
	draw_colored_polygon(PackedVector2Array([at + Vector2(-14.5, 3), at + Vector2(14.5, 3), at + Vector2(0, 18)]), color)


## Where the wall stood after the alien broke through: a pile of bricks.
func _draw_rubble() -> void:
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	for k in 14:
		var x := right.x - 70.0 + float((k * 37) % 120)
		var y := right.y - 6.0 - float((k * 13) % 30)
		draw_rect(Rect2(x, y, 30, 13), BRICK if k % 3 != 0 else MORTAR)


func _draw() -> void:
	var font := UiTheme.game_font(800)
```

Edit 4 - SEARCH:
```gdscript
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	var w := WALL_THICK_M * Balance.PIXELS_PER_METER
```
REPLACE:
```gdscript
	_draw_secret()
	if wall_down:
		_draw_rubble()
		return
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	var w := WALL_THICK_M * Balance.PIXELS_PER_METER
```

**2. `scripts/game/world_view.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE changes the -175 limit to -280 (and the start values); nothing else changes.

Edit 1 - SEARCH:
```gdscript
var drawn_from_m: float = -175.0
var drawn_to_m: float = 660.0
```
REPLACE:
```gdscript
var drawn_from_m: float = -280.0
var drawn_to_m: float = 555.0
```

Edit 2 - SEARCH:
```gdscript
## on a multiple of SNAP_M, and never more than 175 m behind the slingshot (the brick wall is at 120 m).
```
REPLACE:
```gdscript
## on a multiple of SNAP_M, and never more than 280 m behind the slingshot (the brick wall is at 120 m, the secret
## behind it ends at 260 m).
```

Edit 3 - SEARCH:
```gdscript
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -175.0)
```
REPLACE:
```gdscript
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -280.0)
```

**3. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(WrongWay.new())
```
REPLACE:
```gdscript
	var wrong_way := WrongWay.new()
	main.add_child(wrong_way)
```

Edit 2 - SEARCH:
```gdscript
	main.feedback.watchers.append(tree_view)
```
REPLACE:
```gdscript
	main.feedback.watchers.append(tree_view)
	main.feedback.watchers.append(wrong_way)
```

## Acceptance criteria
- WrongWay watches every shot: rubble and "You found the secret!" when the wall breaks, the thank-you sign behind it.
- `WorldView.span_around(0)` is (-280, 555).

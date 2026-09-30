---
id: 229-sharp-face
status: ready
tests: [tests/acceptance/test_229_sharp_face.gd]
files: [scripts/game/alien_face.gd, scripts/game/projectile_decor.gd]
---

# A sharp face on the big alien

The face's smooth (antialiased) edges are about a pixel wide, but on the big roguelike alien the whole face is
scaled up almost 4 times, so those edges became a blur. The face now has a switch, `AlienFace.smooth`, and the
decor turns it off when the alien is drawn at 2x or more.

**1. `scripts/game/alien_face.gd`**: exactly these 19 SEARCH/REPLACE edit(s). Edit 1 adds the switch after `EYE_R`; every other edit changes the last argument of one draw call from `true` to `smooth` (and nothing else on that line). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const EYE_R := Vector2(4.4, -2.4)
```
REPLACE:
```gdscript
const EYE_R := Vector2(4.4, -2.4)
## Smooth (antialiased) edges for a small face; ProjectileDecor turns them off for a big one, whose soft edges
## would be scaled up into a blur.
static var smooth: bool = true
```

Edit 2 - SEARCH:
```gdscript
			canvas.draw_line(Vector2(-2.6, 6.2), Vector2(2.6, 5.6), INK, 1.4, true)
```
REPLACE:
```gdscript
			canvas.draw_line(Vector2(-2.6, 6.2), Vector2(2.6, 5.6), INK, 1.4, smooth)
```

Edit 3 - SEARCH:
```gdscript
			canvas.draw_circle(Vector2(0, 6.3), 1.6, MOUTH_RED, true, -1.0, true)
```
REPLACE:
```gdscript
			canvas.draw_circle(Vector2(0, 6.3), 1.6, MOUTH_RED, true, -1.0, smooth)
```

Edit 4 - SEARCH:
```gdscript
			canvas.draw_circle(Vector2(0, 6.0), 1.9, INK, true, -1.0, true)
```
REPLACE:
```gdscript
			canvas.draw_circle(Vector2(0, 6.0), 1.9, INK, true, -1.0, smooth)
```

Edit 5 - SEARCH:
```gdscript
			canvas.draw_circle(Vector2(0, 5.6), 2.3, INK, true, -1.0, true)
```
REPLACE:
```gdscript
			canvas.draw_circle(Vector2(0, 5.6), 2.3, INK, true, -1.0, smooth)
```

Edit 6 - SEARCH:
```gdscript
			canvas.draw_circle(Vector2(0, 6.2), 1.1, MOUTH_RED, true, -1.0, true)
```
REPLACE:
```gdscript
			canvas.draw_circle(Vector2(0, 6.2), 1.1, MOUTH_RED, true, -1.0, smooth)
```

Edit 7 - SEARCH:
```gdscript
					c + Vector2(2.4 * side, 2.2)]), INK, 1.4, true)
```
REPLACE:
```gdscript
					c + Vector2(2.4 * side, 2.2)]), INK, 1.4, smooth)
```

Edit 8 - SEARCH:
```gdscript
				canvas.draw_line(c + Vector2(-2.2, -2.2), c + Vector2(2.2, 2.2), INK, 1.4, true)
```
REPLACE:
```gdscript
				canvas.draw_line(c + Vector2(-2.2, -2.2), c + Vector2(2.2, 2.2), INK, 1.4, smooth)
```

Edit 9 - SEARCH:
```gdscript
				canvas.draw_line(c + Vector2(-2.2, 2.2), c + Vector2(2.2, -2.2), INK, 1.4, true)
```
REPLACE:
```gdscript
				canvas.draw_line(c + Vector2(-2.2, 2.2), c + Vector2(2.2, -2.2), INK, 1.4, smooth)
```

Edit 10 - SEARCH:
```gdscript
			canvas.draw_polyline(wave, INK, 1.3, true)
```
REPLACE:
```gdscript
			canvas.draw_polyline(wave, INK, 1.3, smooth)
```

Edit 11 - SEARCH:
```gdscript
				canvas.draw_arc(eye + Vector2(0, -1.0), 2.8, 0.35, PI - 0.35, 8, INK, 1.4, true)
```
REPLACE:
```gdscript
				canvas.draw_arc(eye + Vector2(0, -1.0), 2.8, 0.35, PI - 0.35, 8, INK, 1.4, smooth)
```

Edit 12 - SEARCH:
```gdscript
			canvas.draw_arc(Vector2(0, 4.2), 2.2, 0.4, PI - 0.4, 8, INK, 1.3, true)
```
REPLACE:
```gdscript
			canvas.draw_arc(Vector2(0, 4.2), 2.2, 0.4, PI - 0.4, 8, INK, 1.3, smooth)
```

Edit 13 - SEARCH:
```gdscript
			canvas.draw_arc(Vector2(0, 3.4), 3.6, 0.35, PI - 0.35, 10, INK, 1.4, true)
```
REPLACE:
```gdscript
			canvas.draw_arc(Vector2(0, 3.4), 3.6, 0.35, PI - 0.35, 10, INK, 1.4, smooth)
```

Edit 14 - SEARCH:
```gdscript
		canvas.draw_circle(eye, r + 0.9, INK, true, -1.0, true)
```
REPLACE:
```gdscript
		canvas.draw_circle(eye, r + 0.9, INK, true, -1.0, smooth)
```

Edit 15 - SEARCH:
```gdscript
		canvas.draw_circle(eye, r, WHITE, true, -1.0, true)
```
REPLACE:
```gdscript
		canvas.draw_circle(eye, r, WHITE, true, -1.0, smooth)
```

Edit 16 - SEARCH:
```gdscript
		canvas.draw_circle(p, pupil, INK, true, -1.0, true)
```
REPLACE:
```gdscript
		canvas.draw_circle(p, pupil, INK, true, -1.0, smooth)
```

Edit 17 - SEARCH:
```gdscript
		canvas.draw_circle(p + Vector2(-0.5, -0.6), pupil * 0.3, WHITE, true, -1.0, true)
```
REPLACE:
```gdscript
		canvas.draw_circle(p + Vector2(-0.5, -0.6), pupil * 0.3, WHITE, true, -1.0, smooth)
```

Edit 18 - SEARCH:
```gdscript
	canvas.draw_line(Vector2(-7.6, outer_y), Vector2(-2.0, inner_y), INK, 1.4, true)
```
REPLACE:
```gdscript
	canvas.draw_line(Vector2(-7.6, outer_y), Vector2(-2.0, inner_y), INK, 1.4, smooth)
```

Edit 19 - SEARCH:
```gdscript
	canvas.draw_line(Vector2(7.6, outer_y), Vector2(2.0, inner_y), INK, 1.4, true)
```
REPLACE:
```gdscript
	canvas.draw_line(Vector2(7.6, outer_y), Vector2(2.0, inner_y), INK, 1.4, smooth)
```

**2. `scripts/game/projectile_decor.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds one line in `_draw()` before the face is drawn; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	AlienFace.draw(self, shown_face(), look)
```
REPLACE:
```gdscript
	AlienFace.smooth = scale.x < 2.0
	AlienFace.draw(self, shown_face(), look)
```

## Acceptance criteria
- `AlienFace.smooth` (a static var, true by default) is the antialias argument of every face draw call.
- ProjectileDecor sets it to `scale.x < 2.0` before drawing the face.

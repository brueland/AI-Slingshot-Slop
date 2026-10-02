---
id: 277-new-hats
status: ready
tests: [tests/acceptance/test_277_new_hats.gd]
files: [scripts/game/projectile_decor.gd]
---

# The new hats

The alien can wear the three balloon hats (task 275): ProjectileDecor draws a brown cowboy hat, a grey viking helmet
with white horns and a green bobble beanie with a red bobble, like the other hats.

**1. `scripts/game/projectile_decor.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds three cases at the end of the `match hat:` in `_draw_hat()`, after the crown; nothing else changes.

Edit 1 - SEARCH:
```gdscript
			draw_circle(Vector2(5, y - 2), 1.3, Color(0.2, 0.4, 0.95))
```
REPLACE:
```gdscript
			draw_circle(Vector2(5, y - 2), 1.3, Color(0.2, 0.4, 0.95))
		"cowboy":
			draw_colored_polygon(BalloonView.ellipse(Vector2(0, y), 13.0, 3.0), Color(0.55, 0.33, 0.15))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, y), Vector2(-6, y - 11), Vector2(0, y - 8), Vector2(6, y - 11), Vector2(7, y)]), Color(0.62, 0.38, 0.18))
			draw_line(Vector2(-6.5, y - 3), Vector2(6.5, y - 3), Color(0.3, 0.18, 0.08), 2.0)
		"viking":
			draw_colored_polygon(dome(Vector2(0, y + 1), 9.0), Color(0.62, 0.64, 0.7))
			draw_colored_polygon(PackedVector2Array([Vector2(-8, y - 3), Vector2(-15, y - 14), Vector2(-11, y - 4)]), Color(0.98, 0.95, 0.85))
			draw_colored_polygon(PackedVector2Array([Vector2(8, y - 3), Vector2(15, y - 14), Vector2(11, y - 4)]), Color(0.98, 0.95, 0.85))
			draw_line(Vector2(-9, y), Vector2(9, y), Color(0.85, 0.65, 0.2), 2.0)
		"beanie":
			draw_colored_polygon(dome(Vector2(0, y + 1), 8.5), Color(0.2, 0.7, 0.55))
			draw_rect(Rect2(-9, y - 2, 18, 4), Color(0.95, 0.95, 0.95))
			draw_circle(Vector2(0, y - 9), 3.5, Color(0.95, 0.4, 0.4))
```

## Acceptance criteria
- `_draw_hat()` draws `cowboy`, `viking` and `beanie`.

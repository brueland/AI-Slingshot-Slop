---
id: 205-alien-look-size
status: ready
tests: [tests/acceptance/test_205_alien_look_size.gd, tests/acceptance/test_024_projectile_view.gd, tests/acceptance/test_030_main_views.gd, tests/acceptance/test_103_alien_size.gd]
files: [scripts/game/projectile_view.gd]
---

# A bigger-looking alien

Milestone 27 gives the alien cartoon faces and the sky a way up to space. First, the alien is drawn 1.5 times its
physical size (the physics do not change) so its face reads. Three older tests are updated for the new size.

**`scripts/game/projectile_view.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edits 1-2 keep their SEARCH lines and add new ones; Edits 3-5 change the lines shown (they add `LOOK_SCALE`). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const WOBBLE_SECONDS: float = 0.4
```
REPLACE:
```gdscript
const WOBBLE_SECONDS: float = 0.4
## The alien is drawn this much bigger than its physical size (PROJECTILE_RADIUS), so its face reads.
const LOOK_SCALE: float = 1.5
```

Edit 2 - SEARCH:
```gdscript
	decor = ProjectileDecor.new()
	add_child(decor)
```
REPLACE:
```gdscript
	decor = ProjectileDecor.new()
	add_child(decor)
	decor.scale = Vector2.ONE * LOOK_SCALE
```

Edit 3 - SEARCH:
```gdscript
	# Scale the sprite so it is 2 * Balance.PROJECTILE_RADIUS meters wide on screen
	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER) / texture.get_width() * size_scale
```
REPLACE:
```gdscript
	# Scale the sprite so it is 2 * Balance.PROJECTILE_RADIUS * LOOK_SCALE meters wide on screen
	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER * LOOK_SCALE) / texture.get_width() * size_scale
```

Edit 4 - SEARCH:
```gdscript
	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS * size_scale))
```
REPLACE:
```gdscript
	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS * size_scale * LOOK_SCALE))
```

Edit 5 - SEARCH:
```gdscript
	decor.scale = Vector2.ONE * size_scale
```
REPLACE:
```gdscript
	decor.scale = Vector2.ONE * size_scale * LOOK_SCALE
```

## Acceptance criteria
- `ProjectileView.LOOK_SCALE` is 1.5: the alien is 36 px wide, sits on the ground, and its decor (hat, face) is 1.5x.

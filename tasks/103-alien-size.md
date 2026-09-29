---
id: 103-alien-size
status: ready
tests: [tests/acceptance/test_103_alien_size.gd]
files: [scripts/game/projectile_view.gd, scripts/game/main.gd]
---

# Draw the alien at its size

The roguelike alien can be small, normal or big (task 102). ProjectileView draws it (and its hat) at that size;
classic shots are always size 1. Use small SEARCH/REPLACE edits.

**1. `scripts/game/projectile_view.gd`** (keep everything else):
- **Declare** `var size_scale: float = 1.0` after `var decor: ProjectileDecor`.
- In `set_tier()`, multiply the scale by the size: the `scale = ...` line becomes
  ```gdscript
  	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER) / texture.get_width() * size_scale
  ```
- In `show_at()`, the alien's center is one (sized) radius above the ground:
  ```gdscript
  	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS * size_scale))
  ```
- Add this function right before `set_hat()`:
  ```gdscript
  ## Draws the alien (and its hat) `s` times its normal size; 1.0 is normal. Used by the roguelike sizes.
  func set_size(s: float) -> void:
  	size_scale = maxf(s, 0.1)
  	set_tier(tier)
  	decor.scale = Vector2.ONE * size_scale
  ```

**2. `scripts/game/main.gd`:** in `_begin_aim()`, right after the `projectile_view.set_tier(...)` line:
```gdscript
	projectile_view.set_size(stats.size_scale)
```

## Acceptance criteria
- `set_size(2.5)` makes the alien and its hat 2.5 times bigger (also after `set_tier`), resting on the ground;
  the size never goes below 0.1.
- Every shot uses the session's `stats.size_scale`: 1 in classic, the chosen size in the roguelike.

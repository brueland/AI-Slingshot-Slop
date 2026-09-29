---
id: 082-jelly-wobble
status: ready
tests: [tests/acceptance/test_082_jelly_wobble.gd]
files: [scripts/game/projectile_view.gd, scripts/game/feedback.gd]
---

# The alien wobbles like jelly after a bounce

**1. `scripts/game/projectile_view.gd`** (keep everything else):
- Add the constant `const WOBBLE_SECONDS: float = 0.4` after `TEXTURES`.
- **Declare the variables** after `var tier: int = 0`:
  ```gdscript
  var base_scale: Vector2 = Vector2.ONE
  var wobble_strength: float = 0.0
  var wobble_left: float = 0.0
  ```
- In `set_tier()`, add `base_scale = scale` as the last line (after `scale` is computed).
- Add these functions (the first one right after `_ready()`, the others at the end of the file):
  ```gdscript
  func _process(delta: float) -> void:
  	advance_wobble(delta)
  ```
  ```gdscript
  ## Jelly wobble after a bounce: the alien squashes and stretches for WOBBLE_SECONDS, then is round again.
  func wobble(strength: float) -> void:
  	wobble_strength = clampf(strength, 0.0, 0.5)
  	wobble_left = WOBBLE_SECONDS


  func advance_wobble(delta: float) -> void:
  	if wobble_left <= 0.0:
  		return
  	wobble_left = maxf(wobble_left - delta, 0.0)
  	var t := 1.0 - wobble_left / WOBBLE_SECONDS
  	var w := wobble_strength * (1.0 - t) * cos(t * TAU * 2.0)
  	scale = base_scale * Vector2(1.0 + w, 1.0 - w)
  	if wobble_left <= 0.0:
  		scale = base_scale
  ```

**2. `scripts/game/feedback.gd`:** at the end of `_on_bounced()` add:
```gdscript
	projectile_view.wobble(clampf(impact_speed / 25.0, 0.08, 0.35))
```

## Acceptance criteria
- `base_scale` is the normal size (updated by `set_tier`); `wobble(s)` starts a 0.4 s wobble (strength capped at 0.5).
- Right after a bounce the alien is wider and flatter; after 0.4 s its scale is exactly `base_scale` again.
- Every bounce in a flight wobbles the alien with strength `impact_speed / 25` clamped to 0.08..0.35.

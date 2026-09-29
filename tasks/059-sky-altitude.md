---
id: 059-sky-altitude
status: ready
tests: [tests/acceptance/test_059_sky_altitude.gd]
files: [scripts/game/background.gd, scripts/game/main.gd]
---

# The sky deepens with height; clouds drift

**1. `scripts/game/background.gd`** (keep everything):
- Constants: `const HIGH_SKY_COLOR := Color(0.45, 0.5, 0.85)` and `const HIGH_ALTITUDE_M: float = 150.0`.
- On the cloud layer only: `cloud_layer.autoscroll = Vector2(-12, 0)` (clouds drift left by themselves; the sky
  layer does not move).
- Add:
  ```gdscript
  ## Tints the whole sky toward deep blue as the projectile climbs (full tint at HIGH_ALTITUDE_M).
  func set_altitude(height_m: float) -> void:
  	var t := clampf(height_m / HIGH_ALTITUDE_M, 0.0, 1.0)
  	modulate = Color.WHITE.lerp(HIGH_SKY_COLOR, t)
  ```

**2. `scripts/game/main.gd`** (keep changes small): during FLIGHT in `advance()`,
`background.set_altitude(session.sim.position.y)`; at the end of `_begin_aim()`, `background.set_altitude(0.0)`.

## Acceptance criteria
- White at 0 m and below, halfway tinted at 75 m, fully `HIGH_SKY_COLOR` from 150 m.
- The cloud layer drifts at (-12, 0); the sky layer has no autoscroll.
- In flight the tint follows the projectile's height; the next shot starts untinted.

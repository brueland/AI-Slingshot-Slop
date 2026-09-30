---
id: 211-sky-wire
status: ready
tests: [tests/acceptance/test_211_sky_wire.gd, tests/acceptance/test_040_background.gd, tests/acceptance/test_059_sky_altitude.gd]
files: [scripts/game/background.gd]
---

# The gradient replaces the painted sky

The painted sky picture (whose green hills showed across the top of the screen) is replaced by the SkyGradient,
which follows the flight height; the clouds fade out as the alien climbs instead of turning purple. Two older tests
are updated for this.

**`scripts/game/background.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 2 keeps its SEARCH line and adds one; Edits 1, 3 and 4 replace the lines shown (the painted sky picture and the purple tint go away). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const SKY_TEXTURE: String = "res://assets/backgrounds/sky.png"
const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"
const HIGH_SKY_COLOR := Color(0.45, 0.5, 0.85)
const HIGH_ALTITUDE_M: float = 150.0
```
REPLACE:
```gdscript
const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"
## The clouds fade out while the alien climbs from CLOUDS_FADE_START_M to CLOUDS_GONE_M.
const CLOUDS_FADE_START_M: float = 60.0
const CLOUDS_GONE_M: float = 120.0
```

Edit 2 - SEARCH:
```gdscript
var hills: Hills
```
REPLACE:
```gdscript
var hills: Hills
var sky_gradient: SkyGradient
```

Edit 3 - SEARCH:
```gdscript
	var sky_sprite = Sprite2D.new()
	sky_sprite.texture = preload(SKY_TEXTURE)
	sky_sprite.centered = false
	sky_sprite.scale = Vector2(1.5, 1.5)
	sky_sprite.position = Vector2(-768, -1400)
	
	sky_layer.add_child(sky_sprite)
```
REPLACE:
```gdscript
	# The sky itself: a gradient drawn behind everything in screen space (a CanvasLayer ignores the parallax)
	sky_gradient = SkyGradient.new()
	sky_layer.add_child(sky_gradient)
```

Edit 4 - SEARCH:
```gdscript
## Tints the whole sky toward deep blue as the projectile climbs (full tint at HIGH_ALTITUDE_M).
func set_altitude(height_m: float) -> void:
	var t := clampf(height_m / HIGH_ALTITUDE_M, 0.0, 1.0)
	modulate = Color.WHITE.lerp(HIGH_SKY_COLOR, t)
```
REPLACE:
```gdscript
## As the projectile climbs, the sky darkens toward space (SkyGradient) and the clouds fade out.
func set_altitude(height_m: float) -> void:
	sky_gradient.set_height(height_m)
	layers[1].modulate.a = 1.0 - clampf((height_m - CLOUDS_FADE_START_M) / (CLOUDS_GONE_M - CLOUDS_FADE_START_M), 0.0, 1.0)
```

## Acceptance criteria
- `SkyBackground.sky_gradient` sits in the sky layer; `set_altitude(h)` sets its height and fades the clouds (60-120 m).
- Nothing in the background is tinted any more.

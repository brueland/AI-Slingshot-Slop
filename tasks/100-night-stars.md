---
id: 100-night-stars
status: ready
tests: [tests/acceptance/test_100_night_stars.gd]
files: [scripts/game/star_field.gd, scripts/game/background.gd]
---

# Stars in the high sky

When the alien climbs high, twinkling stars fade in over the deep-blue sky.

**1. Create the file `scripts/game/star_field.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name StarField
extends Node2D
## Twinkling stars in the high sky. Invisible near the ground; they fade in as the alien climbs.

const COUNT: int = 90
const SEED: int = 3
const FADE_START_M: float = 40.0
const FADE_FULL_M: float = 150.0

var stars: Array[Vector3] = []
var time: float = 0.0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	for i in COUNT:
		stars.append(Vector3(rng.randf_range(-900.0, 900.0), rng.randf_range(-800.0, 300.0), rng.randf_range(0.0, TAU)))
	modulate.a = 0.0


## How visible the stars are at a height: 0 below 40 m, 1 from 150 m up.
static func alpha_for_height(height_m: float) -> float:
	return clampf((height_m - FADE_START_M) / (FADE_FULL_M - FADE_START_M), 0.0, 1.0)


func set_height(height_m: float) -> void:
	modulate.a = alpha_for_height(height_m)


func _process(delta: float) -> void:
	if modulate.a > 0.0:
		time += delta
		queue_redraw()


func _draw() -> void:
	for s in stars:
		var twinkle := 0.6 + 0.4 * sin(time * 2.0 + s.z)
		draw_circle(Vector2(s.x, s.y), 1.5 + 0.8 * twinkle, Color(1.0, 1.0, 0.9, twinkle))
```

**2. `scripts/game/background.gd`** (keep everything else; `layers` must still hold only the sky and cloud layers):
- **Declare the variables** after `var layers: Array[Parallax2D] = []`:
  ```gdscript
  var stars_layer: Parallax2D
  var star_field: StarField
  ```
- At the end of `_ready()` (after `layers.append(cloud_layer)`):
  ```gdscript
  	# Night stars: a separate layer (not in `layers`), almost fixed to the screen
  	stars_layer = Parallax2D.new()
  	stars_layer.scroll_scale = Vector2(0.05, 0.02)
  	stars_layer.repeat_size = Vector2(1800, 0)
  	stars_layer.repeat_times = 3
  	star_field = StarField.new()
  	stars_layer.add_child(star_field)
  	add_child(stars_layer)
  ```
- At the end of `set_altitude()`:
  ```gdscript
  	if star_field != null:
  		star_field.set_height(height_m)
  ```

## Acceptance criteria
- 90 stars at the same places every time; hidden below 40 m, half visible at 95 m, fully visible from 150 m.
- The sky has a separate `stars_layer`; `layers` still has 2 entries; `set_altitude` fades the stars.
- A steep, strong shot makes the stars shine.

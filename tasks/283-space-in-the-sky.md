---
id: 283-space-in-the-sky
status: ready
tests: [tests/acceptance/test_283_space_in_the_sky.gd]
files: [scripts/game/background.gd]
---

# Space in the sky

The sky gets a space layer: SkyBackground adds a slow Parallax2D (scroll 0.06, 0.03) in front of the stars with a
`SpaceDecor` (task 282), and `set_altitude` passes the height on, so the satellite, planets, comets, asteroids
and the astronaut appear as the alien climbs.

**1. `scripts/game/background.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 2 adds the space layer in `_ready()` after the stars layer; edit 3 adds two lines at the end of `set_altitude()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var sky_gradient: SkyGradient
```
REPLACE:
```gdscript
var sky_gradient: SkyGradient
## Things in space (a satellite, planets, comets...), in their own slow layer.
var space_layer: Parallax2D
var space: SpaceDecor
```

Edit 2 - SEARCH:
```gdscript
	stars_layer.add_child(star_field)
	add_child(stars_layer)
```
REPLACE:
```gdscript
	stars_layer.add_child(star_field)
	add_child(stars_layer)
	
	# Things in space: their own slow layer (not in `layers`), in front of the stars
	space_layer = Parallax2D.new()
	space_layer.scroll_scale = Vector2(0.06, 0.03)
	space_layer.repeat_size = Vector2(1800, 0)
	space_layer.repeat_times = 3
	space = SpaceDecor.new()
	space_layer.add_child(space)
	add_child(space_layer)
```

Edit 3 - SEARCH:
```gdscript
	if star_field != null:
		star_field.set_height(height_m)
```
REPLACE:
```gdscript
	if star_field != null:
		star_field.set_height(height_m)
	if space != null:
		space.set_height(height_m)
```

## Acceptance criteria
- `SkyBackground.space_layer` (a Parallax2D after `stars_layer`) holds `space` (a SpaceDecor); `set_altitude(h)` calls `space.set_height(h)`.
- `layers` still has the sky and cloud layers only.

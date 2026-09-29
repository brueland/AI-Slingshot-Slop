---
id: 060-slingshot-polish
status: ready
tests: [tests/acceptance/test_060_slingshot_polish.gd]
files: [scripts/game/slingshot.gd]
---

# A slingshot that looks like one, with a power meter

Edit `scripts/game/slingshot.gd` (keep the drag API, `apply_stats` and input). Today the posts are 6 px slivers
tinted with the band color and the bands only appear while dragging.

1. Constants:
   ```gdscript
   const POST_WIDTH: float = 12.0
   const POWER_LOW := Color(0.3, 0.9, 0.3)
   const POWER_MID := Color(1.0, 0.9, 0.2)
   const POWER_HIGH := Color(1.0, 0.3, 0.2)
   ```
2. Power:
   ```gdscript
   ## How hard the band is pulled, 0..1.
   func power_ratio() -> float:
   	if max_pull <= 0.0:
   		return 0.0
   	return clampf(pull.length() / max_pull, 0.0, 1.0)


   ## Green at no pull, yellow at half, red at full.
   static func power_color(ratio: float) -> Color:
   	if ratio <= 0.5:
   		return POWER_LOW.lerp(POWER_MID, ratio * 2.0)
   	return POWER_MID.lerp(POWER_HIGH, (ratio - 0.5) * 2.0)
   ```
3. Replace `_draw()` with:
   ```gdscript
   func _draw() -> void:
   	var left_tip := Vector2(-18.0, 0.0)
   	var right_tip := Vector2(18.0, 0.0)
   	var pouch: Vector2 = pull if dragging else Vector2.ZERO
   	# Back band, then the two wooden posts, then the front band on top.
   	draw_line(right_tip, pouch, band_color, 4.0)
   	for tip in [left_tip, right_tip]:
   		draw_texture_rect(post_texture, Rect2(tip.x - POST_WIDTH / 2.0, -6.0, POST_WIDTH, frame_height_px + 6.0), false)
   	draw_line(left_tip, pouch, band_color, 4.0)
   	draw_circle(pouch, 6.0, band_color)
   	if dragging:
   		var ratio := power_ratio()
   		var bar := Rect2(-30.0, -48.0, 60.0, 8.0)
   		draw_rect(bar, Color(0, 0, 0, 0.5))
   		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), power_color(ratio))
   ```
   (The posts are no longer tinted; the band color still shows the Band Power tier.)

## Acceptance criteria
- `POST_WIDTH` is 12 and the three power colors are as above.
- `power_ratio()` is 0 at rest, 0.5 at a 60 px pull, 1 at full pull; `power_color` goes green -> yellow -> red.
- Drawing at rest and while pulling raises no errors.

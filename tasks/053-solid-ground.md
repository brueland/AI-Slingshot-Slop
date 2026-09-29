---
id: 053-solid-ground
status: ready
tests: [tests/acceptance/test_053_solid_ground.gd]
files: [scripts/game/world_view.gd]
read: [scripts/core/balance.gd]
---

# Solid ground instead of a floating strip

Edit `scripts/game/world_view.gd`. Right now the ground is a 32 px strip with sky below it. Fill everything
below the grass with tiled dirt, 600 px deep, and give the distance labels a dark outline.

1. Constants and a helper (keep the existing ones):
   ```gdscript
   const GROUND_DEPTH_PX: float = 600.0

   var dirt_texture: Texture2D


   ## The dirt below the grass, in screen pixels: 100 m before the slingshot to 100 m past the course.
   static func ground_rect() -> Rect2:
   	var ppm := Balance.PIXELS_PER_METER
   	return Rect2(-100.0 * ppm, 0.0, (Balance.COURSE_LENGTH + 200.0) * ppm, GROUND_DEPTH_PX)
   ```
2. In `_ready()`, also `dirt_texture = load("res://assets/sprites/mud.png")` (texture_repeat is already enabled).
3. In `_draw()`, replace the brown `draw_rect` with the tiled dirt, drawn first so the grass strip stays on top:
   `draw_texture_rect(dirt_texture, ground_rect(), true, Color(0.85, 0.75, 0.65))`
4. For each distance label, first draw an outline, then the white text at the same place:
   `draw_string_outline(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color(0, 0, 0, 0.8))`

## Acceptance criteria
- `WorldView.GROUND_DEPTH_PX` is 600 and `ground_rect()` is Rect2(-1600, 0, 35200, 600).
- The node loads `dirt_texture` (mud.png) and still the grass texture, and draws without errors.

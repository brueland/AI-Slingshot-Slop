---
id: 064-best-marker
status: ready
tests: [tests/acceptance/test_064_best_marker.gd]
files: [scripts/game/course_view.gd, scripts/game/main.gd]
read: [scripts/game/world_view.gd]
---

# A "Best" flag at your best distance

**1. `scripts/game/course_view.gd`** (keep everything): add `var best_marker: Sprite2D` and
`var best_label: Label`. At the end of `_ready()` (after the milestone flags):
```gdscript
	best_marker = Sprite2D.new()
	best_marker.texture = load(FLAG_TEXTURE)
	best_marker.modulate = Color(1.0, 0.85, 0.3)
	best_marker.offset = Vector2(0, -35)
	best_marker.hide()
	add_child(best_marker)
	best_label = Label.new()
	best_label.position = Vector2(-40, -110)
	best_label.add_theme_font_size_override("font_size", 18)
	best_label.add_theme_constant_override("outline_size", 4)
	best_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	best_marker.add_child(best_label)
```
and:
```gdscript
func set_best_marker(distance: float) -> void:
	if distance <= 0.0:
		best_marker.hide()
		return
	best_marker.position = WorldView.world_to_screen(Vector2(distance, 0.0))
	best_label.text = "Best: %d m" % floori(distance)
	best_marker.show()
```
`clear()` must not remove it (it only frees the course item sprites).

**2. `scripts/game/main.gd`:** in `_begin_aim()`, right after `course_view.build(session.course)`:
`course_view.set_best_marker(progress.best_distance)`.

## Acceptance criteria
- Hidden with no best distance; at 123.4 m it stands at x = 1974.4 px on the ground with "Best: 123 m".
- It survives rebuilding the course; main shows it at the saved best distance when aiming.

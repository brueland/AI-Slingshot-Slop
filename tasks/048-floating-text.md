---
id: 048-floating-text
status: ready
tests: [tests/acceptance/test_048_floating_text.gd]
files: [scripts/game/floating_text.gd, scripts/game/main.gd]
---

# "+15" popups for stars

**1. Create `scripts/game/floating_text.gd`:**
```gdscript
class_name FloatingText
extends Label
## A short text ("+15") that rises, fades out and frees itself.

const LIFETIME: float = 0.8
const RISE_SPEED: float = 60.0

var age: float = 0.0


func setup(text_value: String, color: Color) -> void:
	text = text_value
	modulate = color
	add_theme_font_size_override("font_size", 24)


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	age += delta
	position.y -= RISE_SPEED * delta
	modulate.a = clampf(1.0 - age / LIFETIME, 0.0, 1.0)
	if age >= LIFETIME:
		queue_free()
```

**2. `scripts/game/main.gd`:** add `var popups: Node2D`, created in `_ready()` right after the camera and added
as a child of main. In `_on_star_collected`, after the sound:
```gdscript
var popup := FloatingText.new()
popup.setup("+%d" % session.stats.star_value, Color(1.0, 0.85, 0.2))
popup.position = projectile_view.position + Vector2(-12.0, -40.0)
popups.add_child(popup)
```

## Acceptance criteria
- A popup rises 60 px/s, is half faded at 0.4 s, and frees itself after 0.8 s.
- Collecting a star with Star Polish 1 adds one "+15" popup to `main.popups`.

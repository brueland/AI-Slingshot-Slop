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

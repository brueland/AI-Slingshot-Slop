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

class_name StarRating
extends Control
## One to three stars for a shot: 3 for a new best, 2 for at least 75% of the best, 1 otherwise.

const STAR_SIZE: float = 14.0
const GOLD := Color(1.0, 0.85, 0.25)
const EMPTY := Color(1, 1, 1, 0.25)

var rating: int = 0


func _ready() -> void:
	custom_minimum_size = Vector2(100, 32)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func rating_for(distance: float, previous_best: float) -> int:
	if distance > previous_best:
		return 3
	if distance >= previous_best * 0.75:
		return 2
	return 1


func set_rating(value: int) -> void:
	rating = clampi(value, 0, 3)
	queue_redraw()


## The 10 corners of a five-pointed star around `center`.
static func star_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 10:
		var r := radius if i % 2 == 0 else radius * 0.45
		var a := -PI / 2.0 + i * PI / 5.0
		points.append(center + Vector2(cos(a), sin(a)) * r)
	return points


func _draw() -> void:
	for i in 3:
		draw_colored_polygon(star_points(Vector2(18.0 + i * 32.0, 16.0), STAR_SIZE), GOLD if i < rating else EMPTY)

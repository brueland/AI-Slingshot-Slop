class_name AlienFace
extends RefCounted
## The alien's cartoon faces, drawn upright around (0, 0) for a 24 px alien (radius 12) by ProjectileDecor:
## big white eyes whose pupils look where the alien flies, eyebrows, and a mouth for each expression.

const FACES: Array[String] = ["happy", "focus", "wee", "scared", "wow", "ouch", "dizzy", "sleepy"]
const INK := Color(0.12, 0.14, 0.19)
const WHITE := Color(1, 1, 1)
const MOUTH_RED := Color(0.75, 0.25, 0.3)
const EYE_L := Vector2(-4.4, -2.4)
const EYE_R := Vector2(4.4, -2.4)


## Draws `face` on `canvas` (call it from the canvas's _draw); `look` is where the pupils look (length 0 to 1).
static func draw(canvas: CanvasItem, face: String, look: Vector2) -> void:
	match face:
		"focus":
			_eyes(canvas, look, 3.1, 1.7)
			_brows(canvas, -5.2, -7.6)
			canvas.draw_line(Vector2(-2.6, 6.2), Vector2(2.6, 5.6), INK, 1.4, true)
		"wee":
			_eyes(canvas, look, 3.4, 1.5)
			var grin := PackedVector2Array()
			for i in 11:
				var a := PI * i / 10.0
				grin.append(Vector2(cos(a) * 4.4, 3.4 + sin(a) * 4.4))
			canvas.draw_colored_polygon(grin, INK)
			canvas.draw_circle(Vector2(0, 6.3), 1.6, MOUTH_RED, true, -1.0, true)
		"scared":
			_eyes(canvas, look, 3.9, 1.1)
			_brows(canvas, -8.2, -6.4)
			canvas.draw_circle(Vector2(0, 6.0), 1.9, INK, true, -1.0, true)
		"wow":
			_eyes(canvas, look, 3.8, 1.4)
			canvas.draw_circle(Vector2(0, 5.6), 2.3, INK, true, -1.0, true)
			canvas.draw_circle(Vector2(0, 6.2), 1.1, MOUTH_RED, true, -1.0, true)
		"ouch":
			for side in [-1.0, 1.0]:
				var c := Vector2(4.4 * side, -2.4)
				canvas.draw_polyline(PackedVector2Array([c + Vector2(2.4 * side, -2.2), c + Vector2(-1.6 * side, 0.0),
					c + Vector2(2.4 * side, 2.2)]), INK, 1.4, true)
			canvas.draw_rect(Rect2(-4.2, 3.6, 8.4, 3.6), WHITE)
			canvas.draw_rect(Rect2(-4.2, 3.6, 8.4, 3.6), INK, false, 1.1)
			canvas.draw_line(Vector2(-1.4, 3.6), Vector2(-1.4, 7.2), INK, 0.9)
			canvas.draw_line(Vector2(1.4, 3.6), Vector2(1.4, 7.2), INK, 0.9)
		"dizzy":
			for side in [-1.0, 1.0]:
				var c := Vector2(4.4 * side, -2.4)
				canvas.draw_line(c + Vector2(-2.2, -2.2), c + Vector2(2.2, 2.2), INK, 1.4, true)
				canvas.draw_line(c + Vector2(-2.2, 2.2), c + Vector2(2.2, -2.2), INK, 1.4, true)
			var wave := PackedVector2Array()
			for i in 9:
				wave.append(Vector2(-4.0 + i, 5.6 + sin(i * 1.6) * 0.9))
			canvas.draw_polyline(wave, INK, 1.3, true)
		"sleepy":
			for eye in [EYE_L, EYE_R]:
				canvas.draw_arc(eye + Vector2(0, -1.0), 2.8, 0.35, PI - 0.35, 8, INK, 1.4, true)
			canvas.draw_arc(Vector2(0, 4.2), 2.2, 0.4, PI - 0.4, 8, INK, 1.3, true)
		_:
			_eyes(canvas, look, 3.3, 1.6)
			canvas.draw_arc(Vector2(0, 3.4), 3.6, 0.35, PI - 0.35, 10, INK, 1.4, true)


## Two eyes: an ink ring, the white, and a pupil with a small shine, moved toward `look`.
static func _eyes(canvas: CanvasItem, look: Vector2, r: float, pupil: float) -> void:
	for eye in [EYE_L, EYE_R]:
		canvas.draw_circle(eye, r + 0.9, INK, true, -1.0, true)
		canvas.draw_circle(eye, r, WHITE, true, -1.0, true)
		var p: Vector2 = eye + look * (r - pupil - 0.2)
		canvas.draw_circle(p, pupil, INK, true, -1.0, true)
		canvas.draw_circle(p + Vector2(-0.5, -0.6), pupil * 0.3, WHITE, true, -1.0, true)


## Eyebrows from the outer end (x = +-7.6, y = outer_y) to the inner end (x = +-2, y = inner_y).
static func _brows(canvas: CanvasItem, inner_y: float, outer_y: float) -> void:
	canvas.draw_line(Vector2(-7.6, outer_y), Vector2(-2.0, inner_y), INK, 1.4, true)
	canvas.draw_line(Vector2(7.6, outer_y), Vector2(2.0, inner_y), INK, 1.4, true)

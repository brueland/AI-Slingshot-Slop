class_name SpaceDecor
extends Node2D
## Things in space high above the meadow, in their own slow layer: a satellite drifting by, a ringed planet and a
## cratered moon, comets with glowing tails, tumbling asteroids and a waving astronaut. Each fades in at its own
## height as the alien climbs toward space; near the ground none of it shows.

## The height (meters) at which each thing starts to show; it is fully there FADE_M higher.
const SHOW_FROM_M := {"satellite": 90.0, "planet": 120.0, "moon": 120.0, "comet": 150.0, "asteroids": 180.0, "astronaut": 250.0}
const FADE_M: float = 60.0
## Comets: one every COMET_EVERY seconds, crossing the sky in COMET_SECONDS.
const COMET_EVERY: float = 8.0
const COMET_SECONDS: float = 3.0

var height_m: float = 0.0
var time: float = 0.0


## How visible `thing` is at `height` meters (0 to 1).
static func alpha_for(thing: String, height: float) -> float:
	return clampf((height - float(SHOW_FROM_M.get(thing, 99999.0))) / FADE_M, 0.0, 1.0)


## The things that show at all at `height` meters.
static func showing(height: float) -> Array[String]:
	var out: Array[String] = []
	for thing in SHOW_FROM_M:
		if alpha_for(thing, height) > 0.0:
			out.append(thing)
	return out


func set_height(h: float) -> void:
	height_m = h
	visible = not showing(h).is_empty()
	queue_redraw()


func _process(delta: float) -> void:
	if visible:
		time += delta
		queue_redraw()


## Where the satellite is now: it drifts slowly across the sky, over and over.
func satellite_position() -> Vector2:
	return Vector2(fposmod(time * 25.0, 1800.0) - 900.0, 230.0 + sin(time * 0.5) * 12.0)


## Where the current comet's head is (0 to 1 across the sky), or -1 between comets.
func comet_progress() -> float:
	var t := fmod(time, COMET_EVERY)
	return t / COMET_SECONDS if t < COMET_SECONDS else -1.0


func _draw() -> void:
	_draw_planet(Vector2(470.0, 110.0), alpha_for("planet", height_m))
	_draw_moon(Vector2(-430.0, 150.0), alpha_for("moon", height_m))
	_draw_satellite(satellite_position(), alpha_for("satellite", height_m))
	_draw_comet(alpha_for("comet", height_m))
	_draw_asteroids(alpha_for("asteroids", height_m))
	_draw_astronaut(Vector2(140.0 + sin(time * 0.3) * 40.0, 60.0 + sin(time * 0.7) * 15.0), alpha_for("astronaut", height_m))


func _draw_planet(at: Vector2, a: float) -> void:
	if a <= 0.0:
		return
	draw_circle(at, 70.0, Color(0.85, 0.55, 0.35, a))
	draw_colored_polygon(BalloonView.ellipse(at + Vector2(0, -22), 64.0, 9.0), Color(0.95, 0.72, 0.48, a))
	draw_colored_polygon(BalloonView.ellipse(at + Vector2(0, 20), 66.0, 8.0), Color(0.72, 0.42, 0.28, a))
	var ring := BalloonView.ellipse(at, 125.0, 26.0)
	ring.append(ring[0])
	draw_polyline(ring, Color(0.95, 0.88, 0.62, a), 6.0)


func _draw_moon(at: Vector2, a: float) -> void:
	if a <= 0.0:
		return
	draw_circle(at, 42.0, Color(0.82, 0.82, 0.86, a))
	for crater in [Vector3(-14, -10, 9), Vector3(12, 6, 12), Vector3(-6, 18, 6), Vector3(18, -16, 5)]:
		draw_circle(at + Vector2(crater.x, crater.y), crater.z, Color(0.64, 0.64, 0.7, a))


func _draw_satellite(at: Vector2, a: float) -> void:
	if a <= 0.0:
		return
	draw_rect(Rect2(at + Vector2(-34, -5), Vector2(24, 10)), Color(0.25, 0.4, 0.85, a))
	draw_rect(Rect2(at + Vector2(10, -5), Vector2(24, 10)), Color(0.25, 0.4, 0.85, a))
	draw_rect(Rect2(at + Vector2(-9, -8), Vector2(18, 16)), Color(0.9, 0.75, 0.3, a))
	draw_line(at + Vector2(0, -8), at + Vector2(6, -20), Color(0.8, 0.8, 0.8, a), 2.0)
	var blink := 1.0 if fmod(time, 1.0) < 0.5 else 0.2
	draw_circle(at + Vector2(6, -21), 3.0, Color(1.0, 0.3, 0.3, a * blink))


func _draw_comet(a: float) -> void:
	var p := comet_progress()
	if a <= 0.0 or p < 0.0:
		return
	var head := Vector2(-800.0, -20.0).lerp(Vector2(760.0, 250.0), p)
	var back := Vector2(-1560.0, 270.0).normalized()
	var side := Vector2(-back.y, back.x)
	draw_colored_polygon(PackedVector2Array([head + side * 9.0, head + back * 170.0, head - side * 9.0]), Color(0.6, 0.85, 1.0, 0.45 * a))
	draw_circle(head, 9.0, Color(0.85, 0.95, 1.0, a))


func _draw_asteroids(a: float) -> void:
	if a <= 0.0:
		return
	var spots := [Vector3(-700, 80, 14), Vector3(-260, 30, 10), Vector3(330, 320, 18), Vector3(760, 40, 12), Vector3(-80, 190, 8)]
	for i in spots.size():
		var s: Vector3 = spots[i]
		var rock := PackedVector2Array()
		for k in 7:
			var angle := TAU * k / 7.0 + time * (0.3 + 0.1 * i)
			var r := s.z * (0.75 + 0.25 * sin(k * 2.3 + i))
			rock.append(Vector2(s.x, s.y) + Vector2(cos(angle), sin(angle)) * r)
		draw_colored_polygon(rock, Color(0.55, 0.5, 0.46, a))


func _draw_astronaut(at: Vector2, a: float) -> void:
	if a <= 0.0:
		return
	draw_rect(Rect2(at + Vector2(-14, -2), Vector2(8, 22)), Color(0.75, 0.75, 0.8, a))
	draw_circle(at + Vector2(0, 8), 12.0, Color(0.95, 0.95, 0.97, a))
	draw_circle(at + Vector2(0, -10), 10.0, Color(0.95, 0.95, 0.97, a))
	draw_colored_polygon(BalloonView.ellipse(at + Vector2(2, -10), 7.0, 5.0), Color(0.2, 0.35, 0.7, a))
	var wave := Vector2(cos(-1.2 + sin(time * 4.0) * 0.5), sin(-1.2 + sin(time * 4.0) * 0.5)) * 16.0
	draw_line(at + Vector2(10, 4), at + Vector2(10, 4) + wave, Color(0.95, 0.95, 0.97, a), 5.0)
	draw_line(at + Vector2(-6, 18), at + Vector2(-8, 30), Color(0.95, 0.95, 0.97, a), 5.0)
	draw_line(at + Vector2(6, 18), at + Vector2(9, 30), Color(0.95, 0.95, 0.97, a), 5.0)

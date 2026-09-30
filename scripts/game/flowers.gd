class_name Flowers
extends Node2D
## Flowers sprout wherever the alien bounces, so the meadow slowly blooms as you play (up to MAX_FLOWERS).

const MAX_FLOWERS: int = 80
const GROW_SECONDS: float = 0.6
const COLORS: Array[Color] = [Color(1.0, 0.5, 0.7), Color(1.0, 0.85, 0.3), Color(0.7, 0.6, 1.0), Color(1.0, 1.0, 1.0)]

var xs: Array[float] = []
var ages: Array[float] = []


func grow_at(world_x: float) -> void:
	xs.append(world_x)
	ages.append(0.0)
	while xs.size() > MAX_FLOWERS:
		xs.pop_front()
		ages.pop_front()
	queue_redraw()


## How grown flower `index` is, from 0 (just sprouted) to 1.
func growth(index: int) -> float:
	return clampf(ages[index] / GROW_SECONDS, 0.0, 1.0)


func advance(delta: float) -> void:
	var growing := false
	for i in ages.size():
		if ages[i] < GROW_SECONDS:
			ages[i] += delta
			growing = true
	if growing:
		queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	for i in xs.size():
		var g := growth(i)
		var base := WorldView.world_to_screen(Vector2(xs[i], 0.0))
		var top := base + Vector2(0.0, -14.0 * g)
		draw_line(base, top, Color(0.3, 0.6, 0.3), 2.0)
		var color := COLORS[i % COLORS.size()]
		for k in 5:
			var a := TAU * k / 5.0
			draw_circle(top + Vector2(cos(a), sin(a)) * 3.5 * g, 2.5 * g, color)
		draw_circle(top, 2.0 * g, Color(1.0, 0.9, 0.3))

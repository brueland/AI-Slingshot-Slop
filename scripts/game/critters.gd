class_name Critters
extends Node2D
## Sheep grazing in the meadow (drawn with circles). A sheep hops when the alien lands next to it.

const SEED: int = 11
const HOP_SECONDS: float = 0.5
const HOP_HEIGHT_PX: float = 14.0
const REACT_DISTANCE: float = 4.0
const WOOL := Color(0.97, 0.97, 0.94)
const FACE := Color(0.2, 0.2, 0.22)

var xs: Array[float] = []
var hop_left: Array[float] = []


## Sheep x positions (meters) for a seed: one every 35-90 m, starting after 25 m.
static func layout(seed: int, length: float) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[float] = []
	var x := 25.0
	while true:
		x += rng.randf_range(35.0, 90.0)
		if x >= length:
			break
		out.append(x)
	return out


func build(seed: int, length: float) -> void:
	xs = layout(seed, length)
	hop_left.clear()
	for i in xs.size():
		hop_left.append(0.0)
	queue_redraw()


## The nearest sheep within REACT_DISTANCE meters of `world_x` hops. Returns its index, or -1.
func react(world_x: float) -> int:
	var best := -1
	var best_distance := REACT_DISTANCE
	for i in xs.size():
		var d := absf(xs[i] - world_x)
		if d <= best_distance:
			best = i
			best_distance = d
	if best >= 0:
		hop_left[best] = HOP_SECONDS
		queue_redraw()
	return best


## How high (screen pixels) sheep `index` is in its hop right now.
func hop_offset(index: int) -> float:
	var left := hop_left[index]
	if left <= 0.0:
		return 0.0
	return sin(PI * (1.0 - left / HOP_SECONDS)) * HOP_HEIGHT_PX


## Screen position of sheep `index`'s feet.
func sheep_position(index: int) -> Vector2:
	return WorldView.world_to_screen(Vector2(xs[index], 0.0)) - Vector2(0.0, hop_offset(index))


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	var hopping := false
	for i in hop_left.size():
		if hop_left[i] > 0.0:
			hop_left[i] = maxf(hop_left[i] - delta, 0.0)
			hopping = true
	if hopping:
		queue_redraw()


func _draw() -> void:
	for i in xs.size():
		var p := sheep_position(i)
		draw_line(p + Vector2(-6, -5), p + Vector2(-6, 0), FACE, 2.0)
		draw_line(p + Vector2(6, -5), p + Vector2(6, 0), FACE, 2.0)
		for o in [Vector2(-7, -11), Vector2(0, -14), Vector2(7, -11), Vector2(-3, -8), Vector2(4, -8)]:
			draw_circle(p + o, 6.0, WOOL)
		draw_circle(p + Vector2(12, -13), 4.0, FACE)
		draw_circle(p + Vector2(13, -14), 1.0, Color.WHITE)

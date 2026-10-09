class_name Critters
extends Node2D
## Sheep grazing in the meadow (drawn with sprites). A sheep hops when the alien lands next to it.

const SEED: int = 11
const HOP_SECONDS: float = 0.5
const HOP_HEIGHT_PX: float = 14.0
const REACT_DISTANCE: float = 4.0
const WOOL := Color(0.97, 0.97, 0.94)
const FACE := Color(0.2, 0.2, 0.22)
const BLACK_WOOL := Color(0.18, 0.17, 0.2)

var xs: Array[float] = []
var hop_left: Array[float] = []
var time: float = 0.0
## The flock's sprites (white and black, head up and grazing), drawn at SPRITE_SCALE with the feet at
## SPRITE_FEET_X of their width.
var textures: Dictionary = {"up": load("res://assets/sprites/sheep.png"), "graze": load("res://assets/sprites/sheep_graze.png"),
	"black_up": load("res://assets/sprites/sheep_black.png"), "black_graze": load("res://assets/sprites/sheep_black_graze.png")}
const SPRITE_SCALE: float = 0.4
const SPRITE_FEET_X: float = 0.4
## The flock's layout repeats every `period` meters (the length it was built for), so the meadow never runs out.
var period: float = Balance.COURSE_LENGTH


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
	period = length
	hop_left.clear()
	for i in xs.size():
		hop_left.append(0.0)
	queue_redraw()


## The nearest sheep within REACT_DISTANCE meters of `world_x` hops. Returns its index, or -1.
func react(world_x: float) -> int:
	var best := -1
	var best_distance := REACT_DISTANCE
	for i in xs.size():
		var d := absf(WorldView.repeat_x(xs[i], period, world_x) - world_x)
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
	return WorldView.ground_point(xs[index]) - Vector2(0.0, hop_offset(index))


## How far sheep `index` has lowered its head to graze right now (0-3 px).
func head_bob(index: int) -> float:
	return maxf(0.0, sin(time * 1.5 + index * 1.3)) * 3.0


## The sprite for sheep `index` right now: black or white, grazing while its head is down.
func sheep_texture(index: int) -> Texture2D:
	var key := ("black_" if is_black(index) else "") + ("graze" if head_bob(index) > 1.5 else "up")
	return textures[key]


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	time += delta
	queue_redraw()
	var hopping := false
	for i in hop_left.size():
		if hop_left[i] > 0.0:
			hop_left[i] = maxf(hop_left[i] - delta, 0.0)
			hopping = true
	if hopping:
		queue_redraw()


func _draw() -> void:
	# only the sheep on screen are drawn: the copy of each sheep nearest the middle of the view
	var span := WorldView.visible_span(self, 3.0)
	var middle := (span.x + span.y) / 2.0
	for i in xs.size():
		var x := WorldView.repeat_x(xs[i], period, middle)
		if x < span.x or x > span.y:
			continue
		var p := WorldView.ground_point(x) - Vector2(0.0, hop_offset(i))
		var texture := sheep_texture(i)
		var size := texture.get_size() * SPRITE_SCALE
		draw_texture_rect(texture, Rect2(p - Vector2(size.x * SPRITE_FEET_X, size.y - 6.0 * SPRITE_SCALE), size), false)


## Every sheep whose index is 2 more than a multiple of 4 is a black sheep (a little grumpier).
static func is_black(index: int) -> bool:
	return index % 4 == 2

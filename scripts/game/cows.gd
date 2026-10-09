class_name Cows
extends Node2D
## Spotted cows standing in the meadow. They moo when the alien lands next to them.

const SEED: int = 31
const REACT_DISTANCE: float = 5.0
const HIDE := Color(0.98, 0.98, 0.96)
const SPOTS := Color(0.15, 0.15, 0.15)

var xs: Array[float] = []
## The terrain the cows were drawn on (WorldView.terrain_version).
var seen_terrain: int = -1
## Seconds since the start, for the cows' grazing.
var time: float = 0.0
## The cow's sprites (head up and grazing), drawn at SPRITE_SCALE with the feet at SPRITE_FEET_X of their width.
var textures: Dictionary = {"up": load("res://assets/sprites/cow.png"), "graze": load("res://assets/sprites/cow_graze.png")}
const SPRITE_SCALE: float = 0.4
const SPRITE_FEET_X: float = 0.4


## Cow positions (meters) for a seed: one every 120-260 m, starting after 60 m.
static func layout(seed: int, length: float) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[float] = []
	var x := 60.0
	while true:
		x += rng.randf_range(120.0, 260.0)
		if x >= length:
			break
		out.append(x)
	return out


func _ready() -> void:
	xs = layout(SEED, Balance.COURSE_LENGTH)
	queue_redraw()


## The nearest cow within REACT_DISTANCE meters of `world_x`, or -1.
func react(world_x: float) -> int:
	var best := -1
	var best_distance := REACT_DISTANCE
	for i in xs.size():
		var d := absf(WorldView.repeat_x(xs[i], Balance.COURSE_LENGTH, world_x) - world_x)
		if d <= best_distance:
			best = i
			best_distance = d
	return best


func cow_position(index: int) -> Vector2:
	return WorldView.ground_point(xs[index])


func _process(delta: float) -> void:
	time += delta
	seen_terrain = WorldView.terrain_version
	# the view moves, so the cows on screen are redrawn every frame (only those: see _draw)
	queue_redraw()


## The sprite for cow `index` right now: now and then it lowers its head to graze.
func cow_texture(index: int) -> Texture2D:
	return textures["graze"] if sin(time * 0.4 + index * 2.1) > 0.3 else textures["up"]


func _draw() -> void:
	# the herd repeats every COURSE_LENGTH meters; only the cows on screen are drawn
	var span := WorldView.visible_span(self, 4.0)
	var middle := (span.x + span.y) / 2.0
	for i in xs.size():
		var x := WorldView.repeat_x(xs[i], Balance.COURSE_LENGTH, middle)
		if x < span.x or x > span.y:
			continue
		var p := WorldView.ground_point(x)
		var texture := cow_texture(i)
		var size := texture.get_size() * SPRITE_SCALE
		draw_texture_rect(texture, Rect2(p - Vector2(size.x * SPRITE_FEET_X, size.y - 6.0 * SPRITE_SCALE), size), false)

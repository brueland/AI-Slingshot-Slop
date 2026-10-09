class_name Birds
extends Node2D
## Little birds perched in the sky along the course. When the alien flies close they scatter, flapping away with a
## "Tweet!". A new shot brings them back.

const SEED: int = 23
const SCARE_DISTANCE_PX: float = 90.0
const FLY_VELOCITY := Vector2(140.0, -200.0)
const COLOR := Color(0.25, 0.2, 0.3)

var perches: Array[Vector2] = []
var flying: Array[bool] = []
var offsets: Array[Vector2] = []
var target: Node2D
var flap: float = 0.0


## Bird perches (world meters) for a seed: one every 50-120 m after 30 m, 6-16 m high.
static func layout(seed: int, length: float) -> Array[Vector2]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array[Vector2] = []
	var x := 30.0
	while true:
		x += rng.randf_range(50.0, 120.0)
		if x >= length:
			break
		out.append(Vector2(x, rng.randf_range(6.0, 16.0)))
	return out


func _ready() -> void:
	perches = layout(SEED, Balance.COURSE_LENGTH)
	reset()


## Every bird back on its perch.
func reset() -> void:
	flying.clear()
	offsets.clear()
	for i in perches.size():
		flying.append(false)
		offsets.append(Vector2.ZERO)
	queue_redraw()


## Screen position of bird `index` right now.
func bird_position(index: int) -> Vector2:
	return WorldView.world_to_screen(perches[index]) + offsets[index]


## Screen position of bird `index`'s copy nearest `near_m` (the perches repeat every COURSE_LENGTH meters).
func bird_position_near(index: int, near_m: float) -> Vector2:
	var perch := Vector2(WorldView.repeat_x(perches[index].x, Balance.COURSE_LENGTH, near_m), perches[index].y)
	return WorldView.world_to_screen(perch) + offsets[index]


## Scares the perched birds within SCARE_DISTANCE_PX of a screen position; each flies off with a "Tweet!".
## Returns how many were scared.
func scare_near(screen_position: Vector2) -> int:
	var scared := 0
	var near := screen_position.x / Balance.PIXELS_PER_METER
	for i in perches.size():
		if not flying[i] and bird_position_near(i, near).distance_to(screen_position) <= SCARE_DISTANCE_PX:
			flying[i] = true
			scared += 1
			var tweet := FloatingText.new()
			tweet.setup("Tweet!", Color(0.9, 0.95, 1.0))
			tweet.position = bird_position_near(i, near) + Vector2(-20.0, -30.0)
			add_child(tweet)
	return scared


func advance(delta: float) -> void:
	flap = fmod(flap + delta * 14.0, TAU)
	for i in perches.size():
		if flying[i]:
			offsets[i] += FLY_VELOCITY * delta
	if target != null:
		scare_near(target.position)
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	# only the birds on screen are drawn (the copy of each bird nearest the middle of the view)
	var span := WorldView.visible_span(self, 20.0) * Balance.PIXELS_PER_METER
	var middle := (span.x + span.y) / 2.0 / Balance.PIXELS_PER_METER
	for i in perches.size():
		var p := bird_position_near(i, middle)
		if p.x < span.x or p.x > span.y:
			continue
		var wing := 5.0 * sin(flap + i) if flying[i] else 2.0
		draw_polyline(PackedVector2Array([p + Vector2(-7, -wing), p + Vector2(-3, 0), p, p + Vector2(3, 0), p + Vector2(7, -wing)]), COLOR, 2.0)
		draw_circle(p, 2.0, COLOR)

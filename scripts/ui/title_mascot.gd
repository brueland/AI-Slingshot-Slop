class_name TitleMascot
extends Control
## The alien bobbing happily at the top of the title screen, wearing the player's hat.

const TEXTURE: String = "res://assets/sprites/projectile_1.png"
const BOB_PX: float = 6.0
const SIZE_PX: float = 40.0

var texture: Texture2D
var decor: ProjectileDecor
var time: float = 0.0
var poke_left: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(0, 100)
	texture = load(TEXTURE)
	decor = ProjectileDecor.new()
	add_child(decor)
	decor.top_level = false
	decor.scale = Vector2.ONE * (SIZE_PX / 24.0)
	decor.position = center()


## Clicking the mascot makes it jump (16 px, 0.4 s) and say "Hi!".
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		poke()


func poke() -> void:
	poke_left = 0.4
	decor.set_mood("wow", 0.6)
	var hi := FloatingText.new()
	hi.setup("Hi!", Color(0.7, 1.0, 0.7))
	hi.position = center() + Vector2(24.0, -40.0)
	add_child(hi)


## How high the poke jump lifts the alien right now (negative is up, 0 when not poked).
func poke_offset() -> float:
	if poke_left <= 0.0:
		return 0.0
	return -sin((0.4 - poke_left) / 0.4 * PI) * 16.0


func _process(delta: float) -> void:
	time += delta
	poke_left = maxf(0.0, poke_left - delta)
	decor.set_face(decor.face, (get_local_mouse_position() - center()).limit_length(60.0) / 60.0)
	decor.position = center()
	queue_redraw()


func bob_offset() -> float:
	return sin(time * 3.0) * BOB_PX


## Every 4 seconds the alien does a little 12 px hop that lasts 0.4 s (0 the rest of the time; negative is up).
func hop_offset() -> float:
	var t := fmod(time, 4.0)
	if t >= 0.4:
		return 0.0
	return -sin(t / 0.4 * PI) * 12.0


## Where the alien's center is inside this control right now.
func center() -> Vector2:
	return Vector2(size.x / 2.0, 66.0 + bob_offset() + hop_offset() + poke_offset())


func set_hat(id: String) -> void:
	decor.set_hat(id)


func _draw() -> void:
	var half := Vector2(SIZE_PX, SIZE_PX) / 2.0
	draw_texture_rect(texture, Rect2(center() - half, half * 2.0), false)

class_name TitleMascot
extends Control
## The alien bobbing happily at the top of the title screen, wearing the player's hat.

const TEXTURE: String = "res://assets/sprites/projectile_1.png"
const BOB_PX: float = 6.0
const SIZE_PX: float = 40.0

var texture: Texture2D
var decor: ProjectileDecor
var time: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(0, 100)
	texture = load(TEXTURE)
	decor = ProjectileDecor.new()
	add_child(decor)
	decor.top_level = false
	decor.scale = Vector2.ONE * (SIZE_PX / 24.0)
	decor.position = center()


func _process(delta: float) -> void:
	time += delta
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
	return Vector2(size.x / 2.0, 66.0 + bob_offset() + hop_offset())


func set_hat(id: String) -> void:
	decor.set_hat(id)


func _draw() -> void:
	var half := Vector2(SIZE_PX, SIZE_PX) / 2.0
	draw_texture_rect(texture, Rect2(center() - half, half * 2.0), false)

class_name Scenery
extends Node2D
## Bushes, rocks and cacti along the ground. Decoration only; the layout is the same every run.

const TEXTURES: Array[String] = [
	"res://assets/sprites/bush.png",
	"res://assets/sprites/rock.png",
	"res://assets/sprites/cactus.png",
]
const SEED: int = 7
## The meadow's rocks and plants go on this far (meters), well past the 2000 m course.
const LENGTH: float = 8000.0

var sprites: Array[Sprite2D] = []


static func layout(seed: int, length: float) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var out: Array = []
	var x := -60.0
	while true:
		x += rng.randf_range(8.0, 25.0)
		if x >= length:
			break
		out.append({"kind": rng.randi_range(0, TEXTURES.size() - 1), "x": x, "scale": rng.randf_range(0.5, 0.9)})
	return out


func build(seed: int, length: float) -> void:
	# Remove and free all existing sprites
	for sprite in sprites:
		if is_instance_valid(sprite):
			remove_child(sprite)
			sprite.queue_free()
	sprites.clear()
	
	# Build new sprites from layout
	var items := layout(seed, length)
	for item in items:
		var sprite := Sprite2D.new()
		var item_kind: int = item["kind"]
		var item_x: float = item["x"]
		var item_scale: float = item["scale"]
		
		sprite.texture = load(TEXTURES[item_kind])
		sprite.position = WorldView.world_to_screen(Vector2(item_x, 0.0))
		sprite.offset = Vector2(0, -35)
		sprite.scale = Vector2.ONE * item_scale
		
		add_child(sprite)
		sprites.append(sprite)

class_name ProjectileView
extends Sprite2D
## The alien projectile, drawn where the FlightSim says it is.

const TEXTURES: Array[String] = [
	"res://assets/sprites/projectile_1.png",
	"res://assets/sprites/projectile_2.png",
	"res://assets/sprites/projectile_3.png",
]

const WOBBLE_SECONDS: float = 0.4

var tier: int = 0
var base_scale: Vector2 = Vector2.ONE
var wobble_strength: float = 0.0
var wobble_left: float = 0.0


func _ready() -> void:
	set_tier(tier)


func _process(delta: float) -> void:
	advance_wobble(delta)


func set_tier(new_tier: int) -> void:
	tier = clampi(new_tier, 0, 2)
	texture = load(TEXTURES[tier])
	# Scale the sprite so it is 2 * Balance.PROJECTILE_RADIUS meters wide on screen
	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER) / texture.get_width()
	base_scale = scale


func show_at(world_pos: Vector2) -> void:
	# The sprite's center is one radius above the given point
	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS))


func sync_from(sim: FlightSim) -> void:
	show_at(sim.position)
	# Roll the projectile based on its x position
	rotation = sim.position.x / Balance.PROJECTILE_RADIUS


## Jelly wobble after a bounce: the alien squashes and stretches for WOBBLE_SECONDS, then is round again.
func wobble(strength: float) -> void:
	wobble_strength = clampf(strength, 0.0, 0.5)
	wobble_left = WOBBLE_SECONDS


func advance_wobble(delta: float) -> void:
	if wobble_left <= 0.0:
		return
	wobble_left = maxf(wobble_left - delta, 0.0)
	var t := 1.0 - wobble_left / WOBBLE_SECONDS
	var w := wobble_strength * (1.0 - t) * cos(t * TAU * 2.0)
	scale = base_scale * Vector2(1.0 + w, 1.0 - w)
	if wobble_left <= 0.0:
		scale = base_scale

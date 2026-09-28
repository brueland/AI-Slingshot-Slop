class_name ProjectileView
extends Sprite2D
## The alien projectile, drawn where the FlightSim says it is.

const TEXTURES: Array[String] = [
	"res://assets/sprites/projectile_1.png",
	"res://assets/sprites/projectile_2.png",
	"res://assets/sprites/projectile_3.png",
]

var tier: int = 0


func _ready() -> void:
	set_tier(tier)


func set_tier(new_tier: int) -> void:
	tier = clampi(new_tier, 0, 2)
	texture = load(TEXTURES[tier])
	# Scale the sprite so it is 2 * Balance.PROJECTILE_RADIUS meters wide on screen
	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER) / texture.get_width()


func show_at(world_pos: Vector2) -> void:
	# The sprite's center is one radius above the given point
	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS))


func sync_from(sim: FlightSim) -> void:
	show_at(sim.position)
	# Roll the projectile based on its x position
	rotation = sim.position.x / Balance.PROJECTILE_RADIUS

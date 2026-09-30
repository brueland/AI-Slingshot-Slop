class_name ProjectileView
extends Sprite2D
## The alien projectile, drawn where the FlightSim says it is.

const TEXTURES: Array[String] = [
	"res://assets/sprites/projectile_1.png",
	"res://assets/sprites/projectile_2.png",
	"res://assets/sprites/projectile_3.png",
]

const WOBBLE_SECONDS: float = 0.4
## The alien is drawn this much bigger than its physical size (PROJECTILE_RADIUS), so its face reads.
const LOOK_SCALE: float = Balance.LOOK_SCALE

var tier: int = 0
var base_scale: Vector2 = Vector2.ONE
var wobble_strength: float = 0.0
var wobble_left: float = 0.0
var decor: ProjectileDecor
var size_scale: float = 1.0
## Seconds left of the "ouch" face after a hard bounce.
var ouch_left: float = 0.0


func _init() -> void:
	decor = ProjectileDecor.new()
	add_child(decor)
	decor.scale = Vector2.ONE * LOOK_SCALE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_tier(tier)


func _process(delta: float) -> void:
	advance_wobble(delta)
	_sync_decor()
	ouch_left = maxf(0.0, ouch_left - delta)


func set_tier(new_tier: int) -> void:
	tier = clampi(new_tier, 0, 2)
	texture = load(TEXTURES[tier])
	# Scale the sprite so it is 2 * Balance.PROJECTILE_RADIUS * LOOK_SCALE meters wide on screen
	scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER * LOOK_SCALE) / texture.get_width() * size_scale
	base_scale = scale


func show_at(world_pos: Vector2) -> void:
	# The sprite's center is one (sized) radius above the given point
	position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS * size_scale * LOOK_SCALE))
	_sync_decor()


func sync_from(sim: FlightSim) -> void:
	show_at(sim.position)
	# Roll the projectile based on its x position
	rotation = sim.position.x / Balance.PROJECTILE_RADIUS
	var airborne := sim.is_airborne() and not sim.stopped
	decor.set_face(AlienFace.pick(sim.velocity, airborne, ouch_left), AlienFace.look_for(sim.velocity))
	if sim.stopped:
		set_mood("sleepy")


## A hard bounce: the alien winces (the "ouch" face) for 0.35 s.
func ouch() -> void:
	ouch_left = 0.35
	decor.set_face("ouch", decor.look)


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


## Draws the alien (and its hat) `s` times its normal size; 1.0 is normal. Used by the roguelike sizes.
func set_size(s: float) -> void:
	size_scale = maxf(s, 0.1)
	set_tier(tier)
	decor.scale = Vector2.ONE * size_scale * LOOK_SCALE


func set_hat(id: String) -> void:
	decor.set_hat(id)


func set_mood(id: String, seconds: float = 0.0) -> void:
	decor.set_mood(id, seconds)


## The decor is top_level (it does not roll), so it is moved to the alien by hand.
func _sync_decor() -> void:
	if is_inside_tree():
		decor.position = global_position
		decor.visible = is_visible_in_tree()

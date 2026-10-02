class_name PlayerStats
extends RefCounted
## Gameplay numbers computed from upgrade levels. See docs/DESIGN.md section 4.

var max_speed: float = Balance.BASE_MAX_SPEED
var launch_height: float = Balance.BASE_LAUNCH_HEIGHT
var guide_points: int = Balance.BASE_GUIDE_POINTS
var drag: float = Balance.BASE_DRAG
var restitution: float = Balance.BASE_RESTITUTION
var boost_charges: int = 0
var score_multiplier: float = 1.0
var star_value: int = Balance.BASE_STAR_VALUE
var bounce_bonus: int = 0
## The roguelike boss this shot is fired at (null when there is none); RunSession fights a copy.
var boss: BossFight = null
## The rolling hills' height for this shot (meters; 0 = flat ground; see Terrain), and stretches kept flat
## (landing zones).
var hills: float = 0.0
var flat_spans: Array[Vector2] = []

## Star pickups: a star is collected within pickup_radius of a point pickup_offset meters above the alien's
## contact point: the center of the alien as it is drawn, and its drawn radius plus RogueSizes.STAR_REACH.
var size_scale: float = 1.0
var pickup_offset: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE
var pickup_radius: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE + RogueSizes.STAR_REACH


static func _level(levels: Dictionary, id: String) -> int:
	return clampi(int(levels.get(id, 0)), 0, UpgradeCatalog.max_level(id))


static func from_levels(levels: Dictionary) -> PlayerStats:
	var ps := PlayerStats.new()
	
	ps.max_speed = Balance.BASE_MAX_SPEED * (1.0 + 0.25 * _level(levels, "power"))
	ps.launch_height = Balance.BASE_LAUNCH_HEIGHT + 1.5 * _level(levels, "height")
	ps.guide_points = Balance.BASE_GUIDE_POINTS + 6 * _level(levels, "guide")
	ps.drag = Balance.BASE_DRAG * (1.0 - 0.18 * _level(levels, "aero"))
	ps.restitution = Balance.BASE_RESTITUTION + 0.08 * _level(levels, "bounce")
	ps.boost_charges = _level(levels, "boosts")
	ps.score_multiplier = 1.0 + 0.25 * _level(levels, "multiplier")
	ps.star_value = Balance.BASE_STAR_VALUE + 5 * _level(levels, "star_value")
	ps.bounce_bonus = 3 * _level(levels, "bounce_bonus")
	
	return ps


func apply_to(sim: FlightSim) -> void:
	sim.drag = drag
	sim.restitution = restitution
	sim.boost_charges = boost_charges

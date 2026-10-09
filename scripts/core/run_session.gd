class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.

## The course grew during the shot: course items from `first_item` and balloons from `first_balloon` on are new.
signal extended(first_item: int, first_balloon: int)

## When the alien gets this close (meters) to the end of the course, the next COURSE_LENGTH meters are added.
const EXTEND_AHEAD_M: float = 300.0

var stats: PlayerStats
var sim: FlightSim
var tracker: RunTracker
var balloons: Balloons
## A copy of stats.boss for this shot (null without a boss fight).
var boss: BossFight = null
var course: Array = []
var launched: bool = false
var elapsed: float = 0.0
var path: PackedVector2Array = PackedVector2Array()
var _steps: int = 0
## The course goes on: it ends at `course_end` (meters) for now and grows in COURSE_LENGTH pieces (extend_course);
## `layout_seed` is the course seed and `chunks` how many pieces there are.
var course_end: float = Balance.COURSE_LENGTH
var layout_seed: int = 0
var chunks: int = 1


func _init(player_stats: PlayerStats, course_seed: int) -> void:
	stats = player_stats
	sim = FlightSim.new()
	layout_seed = course_seed
	stats.apply_to(sim)
	sim.position = Vector2(0.0, stats.launch_height)
	course = CourseGenerator.generate(course_seed, Balance.COURSE_LENGTH)
	SpecialStars.mark(course, course_seed)
	tracker = RunTracker.new(course, stats.pickup_offset, stats.pickup_radius)
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
	balloons.body = stats.pickup_offset
	balloons.carry_hats(course_seed)
	if stats.boss != null:
		boss = stats.boss.copy()
	sim.hills = stats.hills
	sim.hill_phase = float(course_seed % 997) * 0.731
	sim.flat_spans = stats.flat_spans.duplicate()
	if boss != null:
		sim.flat_spans.append(Vector2(boss.x - 10.0, boss.x + 10.0))
	# course items sit on the hills (springs, mud) or float over them (stars)
	for item in course:
		item["y"] = float(item["y"]) + sim.terrain_height(float(item["x"]))


func launch_from_pull(pull: Vector2) -> Vector2:
	var v := LaunchMath.velocity_from_pull(pull, Balance.MAX_PULL_PX, stats.max_speed)
	sim.launch(Vector2(0.0, stats.launch_height), v)
	launched = true
	elapsed = 0.0
	path = PackedVector2Array([sim.position])
	_steps = 0
	return v


func step(dt: float) -> void:
	if not launched or sim.stopped:
		return
	
	if sim.position.x > course_end - EXTEND_AHEAD_M:
		extend_course()
	var previous := sim.position
	if sim.is_airborne() and TractorBeams.inside(sim.position + Vector2(0.0, stats.pickup_offset)):
		sim.velocity.y += TractorBeams.PULL * dt
	sim.step(dt)
	tracker.after_step(sim, previous)
	balloons.after_step(sim, previous)
	if boss != null:
		boss.after_step(sim, previous, stats.pickup_offset)
	elapsed += dt
	
	if elapsed >= Balance.MAX_RUN_SECONDS:
		sim.velocity = Vector2.ZERO
		sim.stopped = true
	else:
		_steps += 1
		if _steps % 6 == 0 or sim.stopped:
			path.append(sim.position)


func boost() -> bool:
	return launched and sim.boost()


func is_finished() -> bool:
	return launched and sim.stopped


func result() -> Dictionary:
	var r := Scoring.compute(sim.distance(), tracker.stars_collected, sim.bounce_count, stats)
	r["distance"] = sim.distance()
	r["stars"] = tracker.stars_collected
	r["bounces"] = sim.bounce_count
	r["max_height"] = sim.max_height
	r["balloons"] = balloons.popped_count
	r["air_time"] = sim.air_time
	r["path"] = path
	r["found"] = balloons.found_hats.duplicate()
	r["found"].append_array(tracker.found_specials)
	if boss != null:
		r["boss_hp"] = boss.hp
		r["boss_damage"] = boss.damage
	return r


## The boost key went up.
func release_boost() -> void:
	sim.release_boost()


## Adds the next COURSE_LENGTH meters of course after `course_end`: stars, springs and mud from the next seed (on
## the hills). RunTracker sees the new items; `extended` tells the views.
func extend_course() -> void:
	var chunk_seed := layout_seed * 7 + chunks * 104729
	var first_item := course.size()
	for item in CourseGenerator.generate(chunk_seed, Balance.COURSE_LENGTH):
		var x: float = float(item["x"]) + course_end
		item["x"] = x
		item["y"] = float(item["y"]) + sim.terrain_height(x)
		course.append(item)
	tracker.grow()
	var first_balloon := balloons.points.size()
	var more: Array[Vector2] = []
	for p in Balloons.layout(chunk_seed, Balance.COURSE_LENGTH):
		more.append(p + Vector2(course_end, 0.0))
	balloons.add_points(more, chunk_seed)
	course_end += Balance.COURSE_LENGTH
	chunks += 1
	extended.emit(first_item, first_balloon)

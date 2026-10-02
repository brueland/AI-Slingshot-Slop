class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.

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


func _init(player_stats: PlayerStats, course_seed: int) -> void:
	stats = player_stats
	sim = FlightSim.new()
	stats.apply_to(sim)
	sim.position = Vector2(0.0, stats.launch_height)
	course = CourseGenerator.generate(course_seed, Balance.COURSE_LENGTH)
	tracker = RunTracker.new(course, stats.pickup_offset, stats.pickup_radius)
	balloons = Balloons.new(Balloons.layout(course_seed, Balance.COURSE_LENGTH))
	balloons.body = stats.pickup_offset
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
	if boss != null:
		r["boss_hp"] = boss.hp
		r["boss_damage"] = boss.damage
	return r


## The boost key went up.
func release_boost() -> void:
	sim.release_boost()

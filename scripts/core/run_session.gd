class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.

var stats: PlayerStats
var sim: FlightSim
var tracker: RunTracker
var balloons: Balloons
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
	sim.step(dt)
	tracker.after_step(sim, previous)
	balloons.after_step(sim, previous)
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
	return r

---
id: 020-run-session
status: ready
tests: [tests/acceptance/test_020_run_session.gd]
files: [scripts/core/run_session.gd]
read: [scripts/core/player_stats.gd, scripts/core/flight_sim.gd, scripts/core/run_tracker.gd, scripts/core/course_generator.gd, scripts/core/launch_math.gd, scripts/core/scoring.gd]
---

# RunSession: one whole shot, headless

Create `scripts/core/run_session.gd`, which ties the core classes together for one run.

```gdscript
class_name RunSession
extends RefCounted
## One shot from launch to stop, with course items and scoring. See docs/DESIGN.md section 9.

var stats: PlayerStats
var sim: FlightSim
var tracker: RunTracker
var course: Array = []
var launched: bool = false
var elapsed: float = 0.0
```

- `func _init(player_stats: PlayerStats, course_seed: int) -> void`: store `stats`; `sim = FlightSim.new()`;
  `stats.apply_to(sim)`; put the waiting projectile at `sim.position = Vector2(0.0, stats.launch_height)`;
  `course = CourseGenerator.generate(course_seed, Balance.COURSE_LENGTH)`; `tracker = RunTracker.new(course)`.
- `func launch_from_pull(pull: Vector2) -> Vector2`:
  `var v := LaunchMath.velocity_from_pull(pull, Balance.MAX_PULL_PX, stats.max_speed)`;
  `sim.launch(Vector2(0.0, stats.launch_height), v)`; `launched = true`; `elapsed = 0.0`; return `v`.
- `func step(dt: float) -> void`: do nothing if not launched or `sim.stopped`. Otherwise remember
  `var previous := sim.position`, call `sim.step(dt)`, then `tracker.after_step(sim, previous)`, add `dt` to
  `elapsed`, and if `elapsed >= Balance.MAX_RUN_SECONDS` force a stop (`sim.velocity = Vector2.ZERO`,
  `sim.stopped = true`).
- `func boost() -> bool`: `return launched and sim.boost()`
- `func is_finished() -> bool`: `return launched and sim.stopped`
- `func result() -> Dictionary`: `Scoring.compute(sim.distance(), tracker.stars_collected, sim.bounce_count, stats)`
  plus the keys `distance` (sim.distance()), `stars` (tracker.stars_collected), `bounces` (sim.bounce_count) and
  `max_height` (sim.max_height).

## Acceptance criteria
- A new session is not launched, waits at launch height and generates its course from the seed.
- A full-strength 45 degree shot with no upgrades finishes at 40-75 m with a complete result dictionary.
- Runs that never land are stopped after 120 s.

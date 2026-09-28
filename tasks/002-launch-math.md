---
id: 002-launch-math
status: ready
tests: [tests/acceptance/test_002_launch_math.gd]
files: [scripts/core/launch_math.gd]
read: [scripts/core/balance.gd]
---

# Launch math: slingshot pull to launch velocity

Create `scripts/core/launch_math.gd` with two static functions. The player drags the slingshot pouch on the
screen (pixels, **y points down**); the projectile flies the opposite way in the world (meters/second,
**y points up**).

```gdscript
class_name LaunchMath
extends RefCounted
## Converts a slingshot pull (screen pixels, y down) into a launch velocity (world m/s, y up).


static func clamp_pull(pull: Vector2, max_pull: float) -> Vector2:
	return pull.limit_length(max_pull)


static func velocity_from_pull(pull: Vector2, max_pull: float, max_speed: float) -> Vector2:
	...
```

`velocity_from_pull`:
1. If `max_pull <= 0.0` or `pull == Vector2.ZERO`, return `Vector2.ZERO`.
2. `var p := clamp_pull(pull, max_pull)`
3. `var strength := p.length() / max_pull` (0..1)
4. `var direction := Vector2(-p.x, p.y).normalized()` (opposite of the pull on screen, with y flipped to world up)
5. return `direction * strength * max_speed`

Examples: pull (-120, 0) with max_pull 120 and max_speed 22 gives (22, 0). Pull (-60, 60) gives (11, 11):
dragged left and down, so the projectile flies right and up.

## Acceptance criteria
- Both functions are `static` and behave as described; over-long pulls are clamped to `max_pull`.

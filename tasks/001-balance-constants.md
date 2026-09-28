---
id: 001-balance-constants
status: ready
tests: [tests/acceptance/test_001_balance_constants.gd]
files: [scripts/core/balance.gd]
read: [docs/DESIGN.md]
---

# Balance constants

Create `scripts/core/balance.gd`: a script that only holds the game's tuning numbers as typed constants.

```gdscript
class_name Balance
extends RefCounted
## Every tuning number in the game. See docs/DESIGN.md section 3.

const GRAVITY: float = 15.0
...
```

Add exactly these constants (floats unless marked int), with these values:

| name | value | | name | value |
|---|---|---|---|---|
| GRAVITY | 15.0 | | BASE_GUIDE_POINTS | 6 (int) |
| BASE_MAX_SPEED | 22.0 | | BASE_STAR_VALUE | 10 (int) |
| MAX_PULL_PX | 120.0 | | STAR_RADIUS | 1.5 |
| MIN_PULL_PX | 10.0 | | SPRING_SPEED | 14.0 |
| BASE_LAUNCH_HEIGHT | 2.0 | | SPRING_PUSH | 4.0 |
| BASE_DRAG | 0.002 | | SPRING_HALF_WIDTH | 1.5 |
| BASE_RESTITUTION | 0.35 | | MUD_FACTOR | 0.5 |
| BOUNCE_FRICTION | 0.85 | | MUD_WIDTH | 6.0 |
| MIN_BOUNCE_SPEED | 2.0 | | COURSE_LENGTH | 2000.0 |
| SLIDE_FRICTION | 6.0 | | GOAL_DISTANCE | 1000.0 |
| STOP_SPEED | 0.1 | | MAX_RUN_SECONDS | 120.0 |
| BOOST_SPEED | 12.0 | | PIXELS_PER_METER | 16.0 |
| | | | PROJECTILE_RADIUS | 0.75 |

Write float values with a decimal point (`15.0`, not `15`) and declare the type (`const GRAVITY: float = 15.0`,
`const BASE_GUIDE_POINTS: int = 6`). No functions, no other code.

## Acceptance criteria
- `scripts/core/balance.gd` declares `class_name Balance` and `extends RefCounted`.
- All 25 constants exist with the values and types above.

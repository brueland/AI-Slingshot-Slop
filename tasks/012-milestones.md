---
id: 012-milestones
status: ready
tests: [tests/acceptance/test_012_milestones.gd]
files: [scripts/core/milestones.gd]
---

# Milestones: one-time distance rewards

Create `scripts/core/milestones.gd`.

```gdscript
class_name Milestones
extends RefCounted
## One-time distance rewards. See docs/DESIGN.md section 5.

const LIST: Array = [
	{"distance": 50.0, "reward": 25, "name": "First Flight"},
	{"distance": 100.0, "reward": 50, "name": "Century"},
	{"distance": 250.0, "reward": 150, "name": "Sky Sprinter"},
	{"distance": 500.0, "reward": 300, "name": "Half-K Hero"},
	{"distance": 1000.0, "reward": 1000, "name": "Moon Shot"},
]
```

Static functions:
- `static func newly_reached(previous_best: float, distance: float) -> Array`: every entry of `LIST` (in order)
  with `previous_best < entry.distance` and `entry.distance <= distance`. Reaching exactly 100 counts.
- `static func next_milestone(best: float) -> Dictionary`: the first entry with `distance > best`, or `{}` if
  all are reached.

## Acceptance criteria
- `newly_reached(0, 120)` gives First Flight and Century; `newly_reached(100, 240)` gives nothing.
- `next_milestone(100)` is Sky Sprinter; `next_milestone(1000)` is `{}`.

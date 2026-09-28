---
id: 010-scoring
status: ready
tests: [tests/acceptance/test_010_scoring.gd]
files: [scripts/core/scoring.gd]
read: [scripts/core/player_stats.gd]
---

# Scoring: points and coins for a run

Create `scripts/core/scoring.gd`.

```gdscript
class_name Scoring
extends RefCounted
## Score and coins for one run. See docs/DESIGN.md section 5.


static func compute(distance: float, stars: int, bounces: int, stats: PlayerStats) -> Dictionary:
	...
```

Rules:
- `distance_points = maxi(0, floori(distance))`
- `star_points = stars * stats.star_value`
- `bounce_points = bounces * stats.bounce_bonus`
- `total = floori((distance_points + star_points + bounce_points) * stats.score_multiplier)`
- coins earned = total

Return a dictionary with exactly these keys: `distance_points`, `star_points`, `bounce_points`, `total`,
`coins` (all int) and `multiplier` (float, = `stats.score_multiplier`).

Example: distance 100.9, 4 stars, 5 bounces with star_value 15, bounce_bonus 6, multiplier 1.25:
100 + 60 + 30 = 190, × 1.25 = 237.5, total 237.

## Acceptance criteria
- Values and types as above; negative distances give 0 distance points.

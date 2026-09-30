---
id: 123-fading-dots
status: ready
tests: [tests/acceptance/test_123_fading_dots.gd]
files: [scripts/game/trajectory_preview.gd]
---

# Fading aim dots

The aim preview's dots fade out along the arc: 0.9 opaque next to the slingshot, 0.2 at the far end.

**`scripts/game/trajectory_preview.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 keeps its SEARCH line and adds the new function above it; Edit 2 replaces the one `draw_circle` line. Nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
## Draw trajectory dots with shrinking radius.
```
REPLACE:
```gdscript
## How opaque dot `i` of `n` is: 0.9 next to the slingshot, fading to 0.2 at the far end.
static func dot_alpha(i: int, n: int) -> float:
	if n <= 1:
		return 0.9
	return lerpf(0.9, 0.2, float(i) / float(n - 1))


## Draw trajectory dots with shrinking radius.
```

Edit 2 - SEARCH:
```gdscript
		draw_circle(points[i], radius, Color(1, 1, 1, 0.7))
```
REPLACE:
```gdscript
		draw_circle(points[i], radius, Color(1, 1, 1, dot_alpha(i, points.size())))
```

## Acceptance criteria
- `dot_alpha(i, n)` goes linearly from 0.9 (first dot) to 0.2 (last dot); a single dot is 0.9.
- The dots are drawn with that alpha.

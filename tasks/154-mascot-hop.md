---
id: 154-mascot-hop
status: ready
tests: [tests/acceptance/test_154_mascot_hop.gd]
files: [scripts/ui/title_mascot.gd]
---

# Mascot hop

The title mascot does a little 12 px hop every 4 seconds.

**`scripts/ui/title_mascot.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds a function above `center()`; Edit 2 replaces the `return` line of `center()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
## Where the alien's center is inside this control right now.
```
REPLACE:
```gdscript
## Every 4 seconds the alien does a little 12 px hop that lasts 0.4 s (0 the rest of the time; negative is up).
func hop_offset() -> float:
	var t := fmod(time, 4.0)
	if t >= 0.4:
		return 0.0
	return -sin(t / 0.4 * PI) * 12.0


## Where the alien's center is inside this control right now.
```

Edit 2 - SEARCH:
```gdscript
	return Vector2(size.x / 2.0, 66.0 + bob_offset())
```
REPLACE:
```gdscript
	return Vector2(size.x / 2.0, 66.0 + bob_offset() + hop_offset())
```

## Acceptance criteria
- `hop_offset()` is -12 at the top of a hop (0.2 s in), 0 between hops; the center includes it.

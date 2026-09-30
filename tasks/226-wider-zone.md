---
id: 226-wider-zone
status: ready
tests: [tests/acceptance/test_226_wider_zone.gd, tests/acceptance/test_074_rogue_goals.gd, tests/acceptance/test_172_goal_progress.gd]
files: [scripts/core/rogue_goals.gd]
---

# A wider landing zone

The roguelike's "Stop between" goals were a bit punishing: the zone was 12 m wide. It is now 20 m. Two older tests
are updated.

**`scripts/core/rogue_goals.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the width (and adds a comment above it); nothing else changes.

Edit 1 - SEARCH:
```gdscript
const ZONE_WIDTH: float = 12.0
```
REPLACE:
```gdscript
## How wide a "Stop between" landing zone is.
const ZONE_WIDTH: float = 20.0
```

## Acceptance criteria
- `RogueGoals.ZONE_WIDTH` is 20: "Stop between 30 and 50 m".

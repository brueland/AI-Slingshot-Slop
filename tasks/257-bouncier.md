---
id: 257-bouncier
status: ready
tests: [tests/acceptance/test_257_bouncier.gd, tests/acceptance/test_001_balance_constants.gd, tests/acceptance/test_003_flight_sim_flight.gd, tests/acceptance/test_004_flight_sim_bounce.gd, tests/acceptance/test_009_player_stats.gd, tests/acceptance/test_075_rogue_perks.gd, tests/acceptance/test_110_rogue_weather.gd]
files: [scripts/core/balance.gd]
---

# Bouncier

Milestone 35 makes flights livelier. Bounces felt flat: the alien kept only 35% of its landing speed. Now a bounce
keeps 45% of it and 90% of the forward speed (was 85%). Upgrades and perks still add to the bounciness. Six older
tests are updated for the new numbers.

**1. `scripts/core/balance.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the two numbers; nothing else changes.

Edit 1 - SEARCH:
```gdscript
const BASE_RESTITUTION: float = 0.35
const BOUNCE_FRICTION: float = 0.85
```
REPLACE:
```gdscript
const BASE_RESTITUTION: float = 0.45
const BOUNCE_FRICTION: float = 0.9
```

## Acceptance criteria
- `Balance.BASE_RESTITUTION` is 0.45 and `Balance.BOUNCE_FRICTION` is 0.9.

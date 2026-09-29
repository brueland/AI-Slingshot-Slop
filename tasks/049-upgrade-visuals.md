---
id: 049-upgrade-visuals
status: ready
tests: [tests/acceptance/test_049_upgrade_visuals.gd]
files: [scripts/game/slingshot.gd, scripts/game/main.gd]
read: [scripts/core/player_stats.gd, scripts/game/projectile_view.gd]
---

# Upgrades you can see

**1. `scripts/game/slingshot.gd`** (keep everything): the band color shows the Band Power tier and the frame
grows with Tall Frame.
```gdscript
const BAND_COLORS: Array[Color] = [Color(0.35, 0.2, 0.1), Color(0.8, 0.2, 0.2), Color(1.0, 0.8, 0.2)]


func apply_stats(stats: PlayerStats, power_level: int) -> void:
	frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
	band_color = BAND_COLORS[clampi(floori(power_level / 4.0), 0, BAND_COLORS.size() - 1)]
	queue_redraw()
```
(power 0-3 -> tier 0, 4-7 -> tier 1, 8-10 -> tier 2.)

**2. `scripts/game/main.gd`:** in `_begin_aim()`, replace the line that sets `slingshot.frame_height_px` with:
```gdscript
slingshot.apply_stats(stats, progress.level_of("power"))
projectile_view.set_tier(floori(progress.level_of("aero") / 2.0))
```
(aero 0-1 -> green alien, 2-3 -> blue, 4-5 -> pink.)

## Acceptance criteria
- `apply_stats` sets the frame height from launch height and the band color by power tier.
- With aero 4, power 8, height 1, the next aim shows projectile tier 2, the gold band and a 56 px frame.

---
id: 073-aim-guide-unlock
status: ready
tests: [tests/acceptance/test_073_aim_guide_unlock.gd]
files: [scripts/game/main.gd, scripts/core/upgrade_catalog.gd]
read: [scripts/game/slingshot.gd]
---

# The last-aim line is an Aim Guide upgrade

In the classic game the last-aim line from task 072 is a reward: buying Aim Guide (level 1 or more) turns it on.

**1. `scripts/game/main.gd`:** in `_begin_aim()`, add this line right after `slingshot.enabled = true`:
```gdscript
	slingshot.show_last_aim = progress.level_of("guide") >= 1
```
Nothing else in main.gd changes (the slingshot node lives for the whole game, so it keeps `last_pull` between
runs by itself).

**2. `scripts/core/upgrade_catalog.gd`:** change only the `"description"` of the `"guide"` entry to:
```
"+6 trajectory preview dots per level; also shows your last aim"
```

## Acceptance criteria
- Without Aim Guide the line is off; with Aim Guide level 1+ it is on at the start of each shot.
- After a run, the next shot shows where the previous one was aimed.
- Aim Guide's description mentions "last aim".

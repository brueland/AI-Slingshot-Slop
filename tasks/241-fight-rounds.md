---
id: 241-fight-rounds
status: ready
tests: [tests/acceptance/test_241_fight_rounds.gd, tests/acceptance/test_105c_checkpoint_sizes.gd]
files: [scripts/core/rogue_run.gd]
---

# Boss fight rounds

The roguelike run now fights on fight rounds (task 240). `RogueRun.fight` is the round's boss (`BossFight.make`),
and `stats()` sets `boss` so every shot is fired at it (task 239). A shot that doesn't knock it out costs no life:
the boss keeps the damage and there is one shot less. Running out of shots costs a life and the boss heals. Beating
it counts as beating a boss (+1 life). The outcome tells the panel what happened. The checkpoint 105c bot plays
past round 10, so its perk and size tables get a `"fight"` entry (that older test is updated).

**1. `scripts/core/rogue_run.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Edit 3 changes the end of `stats()`; edit 4 replaces the `boss_beaten` line in `finish_shot()` (and adds two variables before it); edit 6 replaces the `else` branch of `if met:` with an `elif` and a longer `else`; edit 7 adds four keys to the returned dictionary. The others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var best_shot: float = 0.0
```
REPLACE:
```gdscript
var best_shot: float = 0.0
## The boss fight of this round (null when the round is not a fight).
var fight: BossFight = null
```

Edit 2 - SEARCH:
```gdscript
	best_shot = 0.0
```
REPLACE:
```gdscript
	best_shot = 0.0
	fight = null
```

Edit 3 - SEARCH:
```gdscript
	return RogueWeather.apply(s, weather)
```
REPLACE:
```gdscript
	s = RogueWeather.apply(s, weather)
	s.boss = fight
	return s
```

Edit 4 - SEARCH:
```gdscript
	var boss_beaten := met and str(goal.get("type", "")) == "boss"
```
REPLACE:
```gdscript
	var fighting := fight != null and str(goal.get("type", "")) == "fight"
	var shots_left := 0
	var boss_beaten := met and str(goal.get("type", "")) in ["boss", "fight"]
```

Edit 5 - SEARCH:
```gdscript
		if RogueGoals.is_boss_round(round_number):
			goal = RogueGoals.make_boss_goal(round_number, run_seed)
```
REPLACE:
```gdscript
		if RogueGoals.is_boss_round(round_number):
			goal = RogueGoals.make_boss_goal(round_number, run_seed)
		fight = null
		if RogueGoals.is_fight_round(round_number):
			fight = BossFight.make(round_number)
			goal = fight.goal()
```

Edit 6 - SEARCH:
```gdscript
	else:
		lives -= 1
```
REPLACE:
```gdscript
	elif fighting and fight.shots_left > 1:
		fight.hp = int(result.get("boss_hp", fight.hp))
		fight.shots_left -= 1
		shots_left = fight.shots_left
		goal = fight.goal()
	else:
		lives -= 1
		if fighting:
			fight.restart()
			goal = fight.goal()
```

Edit 7 - SEARCH:
```gdscript
"boss_beaten": boss_beaten, "lucky": lucky, "ratio": ratio}```
REPLACE:
```gdscript
"boss_beaten": boss_beaten, "lucky": lucky, "ratio": ratio,
		"fight": fighting, "boss_damage": int(result.get("boss_damage", 0)), "boss_hp": int(result.get("boss_hp", 0)), "shots_left": shots_left}```

## Acceptance criteria
- `RogueRun.fight` is set on fight rounds (null otherwise and after `start()`); `stats().boss` is it.
- A fight shot that doesn't beat the boss: no life lost, `fight.hp` from the result, one shot less, the goal text updated.
- The last shot without beating it: a life lost and `fight.restart()`. Beating it: `boss_beaten` (+1 life), next round.
- The outcome has `fight`, `boss_damage`, `boss_hp` and `shots_left`.

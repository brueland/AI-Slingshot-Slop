---
id: 076-rogue-run
status: ready
tests: [tests/acceptance/test_076_rogue_run.gd]
files: [scripts/core/rogue_run.gd]
read: [scripts/core/rogue_goals.gd, scripts/core/rogue_perks.gd, scripts/core/player_stats.gd]
---

# One roguelike run

A run has a goal per round, three lives, and a perk offer after every shot. Meeting the goal moves to the next,
harder round; missing costs a life and keeps the same goal on the same course (so the player can pick a perk that
helps with it and adjust the aim). Every round gets a new course (`shot_seed()`), the same one for the same run seed.

**Create `scripts/core/rogue_run.gd` with exactly this code:**
```gdscript
class_name RogueRun
extends RefCounted
## One roguelike run: a goal per round, three lives, and a perk choice after every shot.
## Meeting the goal moves to the next (harder) round; missing costs a life and keeps the same goal.

const START_LIVES: int = 3

var run_seed: int = 1
var round_number: int = 1
var lives: int = START_LIVES
var rounds_cleared: int = 0
var shots: int = 0
var perks: Array[String] = []
var goal: Dictionary = {}
var offer: Array[String] = []


func start(new_seed: int) -> void:
	run_seed = new_seed
	round_number = 1
	lives = START_LIVES
	rounds_cleared = 0
	shots = 0
	perks.clear()
	offer.clear()
	goal = RogueGoals.make_goal(1, run_seed)


func stats() -> PlayerStats:
	return RoguePerks.apply(PlayerStats.from_levels({}), perks)


## The course seed for this round: a new course every round, and the same course again when retrying after a
## miss (so the last-aim line helps to adjust the shot).
func shot_seed() -> int:
	return run_seed * 1000 + round_number


func has_perk(id: String) -> bool:
	return perks.has(id)


func is_over() -> bool:
	return lives <= 0


## Scores a finished shot against the goal. Returns {"met", "lives", "round", "over", "goal", "offer"}.
func finish_shot(result: Dictionary) -> Dictionary:
	shots += 1
	var met := RogueGoals.check(goal, result)
	if met:
		rounds_cleared += 1
		round_number += 1
		goal = RogueGoals.make_goal(round_number, run_seed)
	else:
		lives -= 1
	offer.clear()
	if not is_over():
		offer = RoguePerks.offer(run_seed * 100 + shots, perks)
	return {"met": met, "lives": lives, "round": round_number, "over": is_over(), "goal": goal, "offer": offer.duplicate()}


func choose_perk(id: String) -> bool:
	if is_over() or not offer.has(id):
		return false
	perks.append(id)
	offer.clear()
	return true
```

## Acceptance criteria
- `start(7)`: round 1, 3 lives, no perks, no offer, goal `RogueGoals.make_goal(1, 7)`, `shot_seed()` 7001.
- Meeting a goal: round + 1, a new goal, an offer seeded with `run_seed * 100 + shots`.
- Missing: one life less, same goal and course, still an offer; at 0 lives the run is over and there is no offer.
- `choose_perk` only accepts an offered id, once per shot; `stats()` includes the perks.

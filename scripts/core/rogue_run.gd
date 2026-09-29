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

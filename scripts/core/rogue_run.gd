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
var rerolls: int = 1
var size_id: String = "normal"
var weather: String = "calm"
var best_shot: float = 0.0
## The boss fight of this round (null when the round is not a fight).
var fight: BossFight = null


func start(new_seed: int) -> void:
	run_seed = new_seed
	round_number = 1
	lives = START_LIVES
	rounds_cleared = 0
	shots = 0
	best_shot = 0.0
	rerolls = 1
	size_id = "normal"
	weather = RogueWeather.for_round(1, new_seed)
	perks.clear()
	offer.clear()
	goal = RogueGoals.make_goal(1, run_seed)
	fight = null


func stats() -> PlayerStats:
	var s := RogueSizes.apply(RoguePerks.apply(PlayerStats.from_levels({}), perks), size_id)
	s = RogueWeather.apply(s, weather)
	s.boss = fight
	return s


## The course seed for this round: a new course every round, and the same course again when retrying after a
## miss (so the last-aim line helps to adjust the shot).
func shot_seed() -> int:
	return run_seed * 1000 + round_number


func has_perk(id: String) -> bool:
	return perks.has(id)


## The alien's size for the next shots ("small", "normal" or "big"); it stays until changed.
func set_size(id: String) -> bool:
	if RogueSizes.get_def(id).is_empty():
		return false
	size_id = id
	return true


func is_over() -> bool:
	return lives <= 0


## Scores a finished shot against the goal. Returns {"met", "lives", "round", "over", "goal", "offer"}.
func finish_shot(result: Dictionary) -> Dictionary:
	shots += 1
	best_shot = maxf(best_shot, float(result.get("distance", 0.0)))
	var met := RogueGoals.check(goal, result)
	var ratio := RogueGoals.progress_ratio(goal, result)
	var fighting := fight != null and str(goal.get("type", "")) == "fight"
	var shots_left := 0
	var boss_beaten := met and str(goal.get("type", "")) in ["boss", "fight"]
	var lucky := met and RogueGoals.is_lucky_round(round_number, run_seed)
	if lucky:
		rerolls += 1
	if boss_beaten:
		lives += 1
	if met:
		rounds_cleared += 1
		round_number += 1
		if rounds_cleared % 5 == 0:
			rerolls += 1
		goal = RogueGoals.make_goal(round_number, run_seed)
		if RogueGoals.is_boss_round(round_number):
			goal = RogueGoals.make_boss_goal(round_number, run_seed)
		fight = null
		if RogueGoals.is_fight_round(round_number):
			fight = BossFight.make(round_number)
			goal = fight.goal()
		weather = RogueWeather.for_round(round_number, run_seed)
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
	offer.clear()
	if not is_over():
		offer = RoguePerks.offer(run_seed * 100 + shots, perks)
	return {"met": met, "lives": lives, "round": round_number, "over": is_over(), "goal": goal, "offer": offer.duplicate(), "boss_beaten": boss_beaten, "lucky": lucky, "ratio": ratio,
		"fight": fighting, "boss_damage": int(result.get("boss_damage", 0)), "boss_hp": int(result.get("boss_hp", 0)), "shots_left": shots_left}


## Swaps the offer for a different one. One reroll per run, plus one for every 5 rounds cleared.
func reroll() -> bool:
	if is_over() or rerolls <= 0 or offer.is_empty():
		return false
	rerolls -= 1
	var old := offer.duplicate()
	for k in 10:
		offer = RoguePerks.offer(run_seed * 100 + shots + 7777 * (k + 1), perks)
		if offer != old:
			break
	return true


func choose_perk(id: String) -> bool:
	if is_over() or not offer.has(id):
		return false
	perks.append(id)
	offer.clear()
	return true

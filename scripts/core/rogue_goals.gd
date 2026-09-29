class_name RogueGoals
extends RefCounted
## Goals for the roguelike mode. Round 1 is always a distance goal; later rounds pick a random type, and every
## target grows with the round number (there is no last round).

const TYPES: Array[String] = ["distance", "height", "zone", "bounces", "stars"]
const ZONE_WIDTH: float = 12.0
## Star goals need speed perks and a precise aim, so they only show up from this round on.
const STARS_FROM_ROUND: int = 4


static func target_for(type: String, round_number: int) -> float:
	var r := maxi(round_number, 1)
	match type:
		"distance":
			return float(roundi(40.0 * pow(1.12, r - 1)))
		"height":
			return float(roundi(8.0 * pow(1.12, r - 1)))
		"zone":
			return float(roundi(30.0 * pow(1.1, r - 1)))
		"bounces":
			return float(1 + floori(r / 4.0))
		"stars":
			return float(1 + floori(r / 10.0))
	return 0.0


static func make_goal(round_number: int, run_seed: int) -> Dictionary:
	var type := "distance"
	if round_number > 1:
		var rng := RandomNumberGenerator.new()
		rng.seed = run_seed * 7919 + round_number
		var count := TYPES.size() if round_number >= STARS_FROM_ROUND else TYPES.size() - 1
		type = TYPES[rng.randi_range(0, count - 1)]
	var target := target_for(type, round_number)
	return {"type": type, "target": target, "round": round_number, "text": describe(type, target)}


static func describe(type: String, target: float) -> String:
	var n := int(target)
	match type:
		"distance":
			return "Fly at least %d m" % n
		"height":
			return "Reach %d m high" % n
		"bounces":
			return "Bounce %d times" % n
		"stars":
			return "Collect %d star%s" % [n, "" if n == 1 else "s"]
		"zone":
			return "Stop between %d and %d m" % [n, n + int(ZONE_WIDTH)]
	return ""


static func check(goal: Dictionary, result: Dictionary) -> bool:
	var target := float(goal.get("target", 0.0))
	match str(goal.get("type", "")):
		"distance":
			return float(result.get("distance", 0.0)) >= target
		"height":
			return float(result.get("max_height", 0.0)) >= target
		"bounces":
			return int(result.get("bounces", 0)) >= int(target)
		"stars":
			return int(result.get("stars", 0)) >= int(target)
		"zone":
			var d := float(result.get("distance", 0.0))
			return d >= target and d <= target + ZONE_WIDTH
	return false

class_name RogueGoals
extends RefCounted
## Goals for the roguelike mode. Round 1 is always a distance goal; later rounds pick a random type, and every
## target grows with the round number (there is no last round).

const TYPES: Array[String] = ["distance", "height", "zone", "bounces", "stars"]
const ZONE_WIDTH: float = 12.0
## Star goals need speed perks and a precise aim, so they only show up from this round on.
const STARS_FROM_ROUND: int = 4
## Boss rounds: from BOSS_FROM_ROUND on, every BOSS_EVERY rounds, two goals at once.
const BOSS_FROM_ROUND: int = 12
const BOSS_EVERY: int = 6


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


## Lucky rounds: from round 4, about one round in eight (never a boss round); meeting one gives a reroll.
static func is_lucky_round(round_number: int, run_seed: int) -> bool:
	if round_number < 4 or is_boss_round(round_number):
		return false
	return posmod(run_seed * 13 + round_number * 29, 8) == 0


static func is_boss_round(round_number: int) -> bool:
	return round_number >= BOSS_FROM_ROUND and round_number % BOSS_EVERY == 0


## A boss goal: two goals of different types at once (never distance together with zone, which could clash).
static func make_boss_goal(round_number: int, run_seed: int) -> Dictionary:
	var first := make_goal(round_number, run_seed)
	var second := make_goal(round_number, run_seed + 1)
	var k := 1
	while k < 50 and (second["type"] == first["type"] or (first["type"] in ["distance", "zone"] and second["type"] in ["distance", "zone"])):
		k += 1
		second = make_goal(round_number, run_seed + k)
	return {"type": "boss", "target": 0.0, "round": round_number, "parts": [first, second],
		"text": "BOSS: %s + %s" % [first["text"], second["text"]]}


## How close `result` came to `goal`: 0.0 (nowhere) to 1.0 (met). A boss goal counts its weakest part.
static func progress_ratio(goal: Dictionary, result: Dictionary) -> float:
	var target := float(goal.get("target", 0.0))
	match str(goal.get("type", "")):
		"distance":
			return _ratio(float(result.get("distance", 0.0)), target)
		"height":
			return _ratio(float(result.get("max_height", 0.0)), target)
		"bounces":
			return _ratio(float(result.get("bounces", 0)), target)
		"stars":
			return _ratio(float(result.get("stars", 0)), target)
		"zone":
			if check(goal, result):
				return 1.0
			var d := float(result.get("distance", 0.0))
			if d > target:
				return clampf((target + ZONE_WIDTH) / d, 0.0, 0.99)
			return _ratio(d, target)
		"boss":
			var parts: Array = goal.get("parts", [])
			var lowest := 0.0 if parts.is_empty() else 1.0
			for part in parts:
				lowest = minf(lowest, progress_ratio(part, result))
			return lowest
	return 0.0


static func _ratio(value: float, target: float) -> float:
	if target <= 0.0:
		return 1.0
	return clampf(value / target, 0.0, 1.0)


## The live goal readout for the HUD, like "34/50 m" or "2/3 bounces". A boss goal joins its parts with "  +  ".
static func progress_text(goal: Dictionary, result: Dictionary) -> String:
	var n := int(float(goal.get("target", 0.0)))
	match str(goal.get("type", "")):
		"distance":
			return "%d/%d m" % [int(float(result.get("distance", 0.0))), n]
		"height":
			return "%d/%d m high" % [int(float(result.get("max_height", 0.0))), n]
		"bounces":
			return "%d/%d bounces" % [int(result.get("bounces", 0)), n]
		"stars":
			return "%d/%d stars" % [int(result.get("stars", 0)), n]
		"zone":
			return "%d m (stop at %d-%d m)" % [int(float(result.get("distance", 0.0))), n, n + int(ZONE_WIDTH)]
		"boss":
			var texts := PackedStringArray()
			for part in goal.get("parts", []):
				texts.append(progress_text(part, result))
			return "  +  ".join(texts)
	return ""


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
		"boss":
			# Boss goals are handled separately in the make_boss_goal function
			return ""
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
		"boss":
			var parts: Array = goal.get("parts", [])
			for part in parts:
				if not check(part, result):
					return false
			return not parts.is_empty()
	return false

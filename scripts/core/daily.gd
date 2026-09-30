class_name Daily
extends RefCounted
## The daily roguelike run: the same seed (so the same goals, courses and perk offers) for everyone on a day.

const KEEP_DAYS: int = 30


## "2026-09-29" for a date Dictionary with year, month and day (like Time.get_date_dict_from_system()).
static func key_for(date: Dictionary) -> String:
	return "%04d-%02d-%02d" % [int(date.get("year", 2000)), int(date.get("month", 1)), int(date.get("day", 1))]


## 20260929 for 2026-09-29.
static func seed_for(date: Dictionary) -> int:
	return int(date.get("year", 2000)) * 10000 + int(date.get("month", 1)) * 100 + int(date.get("day", 1))


## How many days in a row, up to and including `today_date`, have a daily result in `bests`.
static func streak(bests: Dictionary, today_date: Dictionary) -> int:
	var noon := {"year": int(today_date.get("year", 2000)), "month": int(today_date.get("month", 1)), "day": int(today_date.get("day", 1)), "hour": 12}
	var day_seconds := Time.get_unix_time_from_datetime_dict(noon)
	var count := 0
	while bests.has(key_for(Time.get_date_dict_from_unix_time(day_seconds - count * 86400))):
		count += 1
	return count


## Today's classic challenge: fly this far (150-450 m, the same for everyone on that day).
static func challenge_distance(date: Dictionary) -> float:
	return 150.0 + posmod(seed_for(date), 7) * 50.0


static func today() -> Dictionary:
	return Time.get_date_dict_from_system()


## Records a daily result (keeps the best per day and only the newest KEEP_DAYS days).
static func record(bests: Dictionary, key: String, rounds: int) -> void:
	bests[key] = maxi(int(bests.get(key, 0)), rounds)
	var keys := bests.keys()
	keys.sort()
	while keys.size() > KEEP_DAYS:
		bests.erase(keys.pop_front())

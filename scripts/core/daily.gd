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


static func today() -> Dictionary:
	return Time.get_date_dict_from_system()


## Records a daily result (keeps the best per day and only the newest KEEP_DAYS days).
static func record(bests: Dictionary, key: String, rounds: int) -> void:
	bests[key] = maxi(int(bests.get(key, 0)), rounds)
	var keys := bests.keys()
	keys.sort()
	while keys.size() > KEEP_DAYS:
		bests.erase(keys.pop_front())

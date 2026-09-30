---
id: 196-greetings
status: ready
tests: [tests/acceptance/test_196_greetings.gd]
files: [scripts/core/greetings.gd]
---

# Holiday greetings

Milestone 25 adds a few last touches. First, little holiday greetings for the title screen.

**Create the file `scripts/core/greetings.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Greetings
extends RefCounted
## Little holiday greetings for the title screen.

const DATES: Dictionary = {
	"01-01": "Happy New Year!",
	"02-14": "Happy Valentine's Day!",
	"03-14": "Happy Pi Day! Can you fly 314 m?",
	"04-01": "Watch out for flying aliens today!",
	"10-31": "Happy Halloween!",
	"12-25": "Merry Christmas!",
	"12-31": "Happy New Year's Eve!",
}


## The greeting for a date ("" on ordinary days).
static func for_date(month: int, day: int) -> String:
	return str(DATES.get("%02d-%02d" % [month, day], ""))


## Today's greeting, from the system clock.
static func today() -> String:
	var date := Time.get_date_dict_from_system()
	return for_date(int(date["month"]), int(date["day"]))
```

## Acceptance criteria
- `Greetings.for_date(month, day)` gives the greeting for 7 dates ("" otherwise); `today()` uses the system date.

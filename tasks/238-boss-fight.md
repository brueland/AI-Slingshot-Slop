---
id: 238-boss-fight
status: ready
tests: [tests/acceptance/test_238_boss_fight.gd]
files: [scripts/core/boss_fight.gd]
---

# The boss fight

Milestone 31 adds boss fights to the roguelike. This task creates the fight itself: the Grumblor, a giant standing
on the field with six targets on and around its body (a crown floating over its head, its eye, its belly, both
hands and a toe). Every target the alien's body flies through deals its damage, each target once per shot. The
player has 4 shots to knock its HP down to 0; running out of shots heals it. Later tasks put it in the shots and
the rounds; this file has no other dependencies.

**1. Create the file `scripts/core/boss_fight.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name BossFight
extends RefCounted
## A roguelike boss fight against the Grumblor, a giant standing on the field. Targets sit on and around its body;
## every target the alien flies through deals its damage (each target once per shot). The fight lasts SHOTS shots:
## knock its HP down to 0 to win; run out of shots and it heals. RogueRun starts one every FIGHT_EVERY rounds.

signal target_hit(index: int, damage: int)

const SHOTS: int = 4
## The Grumblor's body is a ball this big (meters) standing on the ground.
const BODY_RADIUS: float = 4.5
## Its targets: offset from its feet (meters), radius (meters) and damage.
const TARGETS: Array = [
	{"name": "crown", "offset": Vector2(0.0, 11.5), "radius": 1.0, "damage": 3},
	{"name": "eye", "offset": Vector2(-0.8, 6.0), "radius": 1.0, "damage": 3},
	{"name": "belly", "offset": Vector2(0.0, 2.6), "radius": 1.3, "damage": 2},
	{"name": "left hand", "offset": Vector2(-6.5, 5.0), "radius": 1.1, "damage": 1},
	{"name": "right hand", "offset": Vector2(6.5, 5.0), "radius": 1.1, "damage": 1},
	{"name": "toe", "offset": Vector2(-3.2, 0.5), "radius": 0.8, "damage": 1},
]

var round_number: int = 10
## Where the Grumblor stands (meters from the slingshot).
var x: float = 70.0
var max_hp: int = 12
var hp: int = 12
var shots_left: int = SHOTS
## The targets already hit this shot.
var hit: Array[bool] = []
## Damage dealt this shot.
var damage: int = 0


## The fight of `round_number`: every fight the Grumblor stands 10 m farther away and has 4 more HP.
static func make(for_round: int) -> BossFight:
	var f := BossFight.new()
	f.round_number = for_round
	f.x = 60.0 + for_round
	f.max_hp = 12 + 4 * (maxi(floori(for_round / 10.0), 1) - 1)
	f.hp = f.max_hp
	f.begin_shot()
	return f


## A copy for one shot: RunSession fights a copy, so predicting a shot never hurts the real boss.
func copy() -> BossFight:
	var f := BossFight.new()
	f.round_number = round_number
	f.x = x
	f.max_hp = max_hp
	f.hp = hp
	f.shots_left = shots_left
	f.begin_shot()
	return f


## A new shot: every target can be hit again.
func begin_shot() -> void:
	hit.resize(TARGETS.size())
	hit.fill(false)
	damage = 0


## Out of shots: the Grumblor heals and the fight starts over.
func restart() -> void:
	hp = max_hp
	shots_left = SHOTS
	begin_shot()


func target_position(index: int) -> Vector2:
	return Vector2(x, 0.0) + TARGETS[index]["offset"]


## Hits every target the alien's body touched between `previous_position` and its current position. The body is a
## ball of radius `body` whose center is `body` above the alien's contact point.
func after_step(sim: FlightSim, previous_position: Vector2, body: float) -> void:
	var a := previous_position + Vector2(0.0, body)
	var b := sim.position + Vector2(0.0, body)
	if hp <= 0 or maxf(a.x, b.x) < x - 9.0 or minf(a.x, b.x) > x + 9.0:
		return
	for i in TARGETS.size():
		if hit[i] or hp <= 0:
			continue
		var c := target_position(i)
		if Geometry2D.get_closest_point_to_segment(c, a, b).distance_to(c) <= float(TARGETS[i]["radius"]) + body:
			hit[i] = true
			var dealt := mini(int(TARGETS[i]["damage"]), hp)
			hp -= dealt
			damage += dealt
			target_hit.emit(i, dealt)


## The roguelike goal for this fight; its text shows the HP and shots left.
func goal() -> Dictionary:
	return {"type": "fight", "target": float(max_hp), "round": round_number,
		"text": "Boss: %d HP, %d shot%s left" % [hp, shots_left, "" if shots_left == 1 else "s"]}
```

## Acceptance criteria
- `BossFight.make(round)`: x = 60 + round, 12 HP at round 10 (+4 every 10 rounds), 4 shots.
- `after_step(sim, previous, body)` hits each target the alien's body touches once per shot (`begin_shot()` re-arms them), never below 0 HP, and emits `target_hit(index, damage)`.
- `copy()`, `restart()` and `goal()` ("Boss: 12 HP, 4 shots left").

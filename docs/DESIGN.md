# Slingshot Skies: game design and code contracts

A small 2D "launch for distance" game in Godot 4.7. Pull back a slingshot, fling a round alien across a
meadow, collect stars, bounce off springs, avoid mud, and spend the score on upgrades so the next shot flies
farther. Reach **1000 m** to win; after that the game continues endlessly for best distances.

This file is the contract every task follows. Names, file paths, signatures and numbers here are exact.

## 1. Game loop

```
TITLE --Play--> AIM --release slingshot--> FLIGHT --projectile stops--> RESULTS --Continue--> SHOP --Launch!--> AIM
                                                   \--first time >= 1000 m--> VICTORY --Continue--> SHOP
```

| State | What the player sees and does |
|---|---|
| TITLE | Game name, best distance, **Play**, **Options**, **Credits**, **Reset progress** |
| AIM | Slingshot with the projectile. Drag the pouch back with the mouse; a dotted trajectory preview shows the arc. Release to launch. |
| FLIGHT | Camera follows the projectile. **Space** spends a boost charge (if any). HUD shows distance, height, stars, boosts. |
| RESULTS | Distance, stars, bounces, multiplier, total score, coins earned, milestones reached. **Continue**. |
| SHOP | Coins and 9 upgrades in 3 groups (Slingshot, Projectile, Score). Buy any affordable upgrade. **Launch!** |
| VICTORY | "You reached 1000 m in N runs!" **Continue** goes to the shop. |

Esc pauses during AIM and FLIGHT.

**Roguelike mode** (title button **Roguelike**, milestone 8): a separate run with no shop and no level cap. Every
round has a goal (fly N m, reach N m high, stop inside a 12 m zone, bounce N times, collect N stars) whose target
grows each round. The player has 3 lives: meeting the goal moves to the next round on a new course, missing costs
a life and retries the same goal on the same course. After every shot the player picks 1 of 3 random perks
(stats that stack with no cap, some with trade-offs), so the choice should fit the next goal. The run ends at 0
lives; the best number of rounds cleared is saved. It reuses the AIM, FLIGHT and RESULTS states (`main.mode` is
"classic" or "rogue"); in RESULTS the perk panel or the run-over panel is shown instead of the results panel.

**Whimsy** (milestone 9): the alien wears a hat chosen in the **Wardrobe** (hats unlock by playing; they never
change physics), wobbles like jelly on bounces, shows moods (dizzy stars, a surprised "!", sleepy "z"s), sheep
hop and say "Baa!" when it lands next to them, great moments throw confetti, and the results screen quotes it.

**Features** (milestone 10): party balloons float above the course (flying into one lifts the alien), the best
classic run is drawn as a faint ghost line, R repeats the last shot once the last-aim line is unlocked, a **Daily
Run** gives everyone the same roguelike seed each day, perk offers can be rerolled, Esc opens a pause menu, the
title shows the alien in its hat, and stars come out high in the sky.

**Roguelike sizes** (milestone 11): on the perk panel the player also picks the alien's size for the next shots.
Small (0.6x) is faster with less drag, so it flies farther, but has less reach; Big (2.5x) is a little slower with
more drag but reaches stars easily. In the roguelike stars are picked up by the alien's body (its radius + 0.9 m
around its center), so rolling into a low star counts; classic keeps its 1.5 m rule.

**Weather and polish** (milestone 12): from round 3 each roguelike round has a weather (Tailwind, Headwind, Thick
Air, Springy or Soggy Ground, or Calm) shown on the perk panel; it changes the shot a little. Birds perch along the
course and scatter with a "Tweet!", quick lively moments pop up "Combo xN!", bounces and stars vary their pitch,
and the Stats screen shows the roguelike records.

**Last-aim line:** a dashed line through the slingshot showing the previous launch's pull, so a good shot can be
repeated. Classic: unlocked by Aim Guide level 1+. Roguelike: unlocked by the Steady Hand perk.

## 2. Units and coordinates

- Game logic uses **meters and seconds in world space**: x = distance forward, **y = height above the ground
  (y points up)**. The ground is y = 0. The slingshot is at x = 0.
- The screen uses Godot's canvas space: **y points down**, 16 pixels per meter.
  `screen = Vector2(world.x, -world.y) * Balance.PIXELS_PER_METER` (see WorldView).
- Mouse drags on the slingshot are measured in **screen pixels**.

## 3. Numbers (scripts/core/balance.gd)

| Constant | Value | Meaning |
|---|---|---|
| GRAVITY | 15.0 | m/s², pulls down |
| BASE_MAX_SPEED | 22.0 | launch speed (m/s) at full pull, no upgrades |
| MAX_PULL_PX | 120.0 | longest slingshot pull, screen pixels |
| MIN_PULL_PX | 10.0 | shorter pulls are ignored (no launch) |
| BASE_LAUNCH_HEIGHT | 2.0 | m, launch point height |
| BASE_DRAG | 0.002 | quadratic air drag coefficient |
| BASE_RESTITUTION | 0.35 | vertical bounce factor |
| BOUNCE_FRICTION | 0.85 | horizontal speed kept on each bounce |
| MIN_BOUNCE_SPEED | 2.0 | m/s; slower rebounds turn into sliding |
| SLIDE_FRICTION | 6.0 | m/s² deceleration while sliding |
| STOP_SPEED | 0.1 | m/s; slower than this = stopped |
| BOOST_SPEED | 12.0 | m/s added by one boost, direction (1, 1) normalized |
| BASE_GUIDE_POINTS | 6 | trajectory preview dots, no upgrades (int) |
| BASE_STAR_VALUE | 10 | points per star, no upgrades (int) |
| STAR_RADIUS | 1.5 | m, star pickup radius |
| SPRING_SPEED | 14.0 | m/s upward speed a spring gives |
| SPRING_PUSH | 4.0 | m/s forward speed a spring adds |
| SPRING_HALF_WIDTH | 1.5 | m, spring triggers within ±this of its x |
| MUD_FACTOR | 0.5 | horizontal speed kept after touching mud |
| MUD_WIDTH | 6.0 | m, a mud patch spans [x, x + MUD_WIDTH] |
| COURSE_LENGTH | 2000.0 | m of generated course |
| GOAL_DISTANCE | 1000.0 | m, winning distance |
| MAX_RUN_SECONDS | 120.0 | a run is force-stopped after this long |
| PIXELS_PER_METER | 16.0 | screen scale |
| PROJECTILE_RADIUS | 0.75 | m, for drawing only |

Balance was tuned with a simulation: a shot with no upgrades flies about 50 m; a bot that always buys the
cheapest upgrade reaches 1000 m in about 35 runs; fully upgraded shots reach about 1400 m.

## 4. Upgrades (scripts/core/upgrade_catalog.gd)

Cost to buy the next level when the current level is `L`: `roundi(base_cost * pow(growth, L))`.

| id | name | category | max_level | base_cost | growth | per_level | effect at level L |
|---|---|---|---|---|---|---|---|
| power | Band Power | launcher | 10 | 80 | 1.7 | 0.25 | max_speed = BASE_MAX_SPEED × (1 + 0.25·L) |
| height | Tall Frame | launcher | 5 | 60 | 1.7 | 1.5 | launch_height = BASE_LAUNCH_HEIGHT + 1.5·L |
| guide | Aim Guide | launcher | 5 | 25 | 1.5 | 6 | guide_points = BASE_GUIDE_POINTS + 6·L |
| aero | Aerodynamics | projectile | 5 | 120 | 1.8 | 0.18 | drag = BASE_DRAG × (1 − 0.18·L) |
| bounce | Bouncy Shell | projectile | 5 | 100 | 1.8 | 0.08 | restitution = BASE_RESTITUTION + 0.08·L |
| boosts | Rocket Boosts | projectile | 3 | 300 | 2.2 | 1 | boost_charges = L |
| multiplier | Score Multiplier | score | 5 | 200 | 1.9 | 0.25 | score_multiplier = 1 + 0.25·L |
| star_value | Star Polish | score | 5 | 80 | 1.7 | 5 | star_value = BASE_STAR_VALUE + 5·L |
| bounce_bonus | Style Points | score | 5 | 60 | 1.7 | 3 | bounce_bonus = 3·L points per bounce |

Category display names: launcher = "Slingshot", projectile = "Projectile", score = "Score".

## 5. Scoring, coins and milestones

- `distance_points = max(0, floori(distance))`, `star_points = stars × star_value`,
  `bounce_points = bounces × bounce_bonus`.
- `total = floori((distance_points + star_points + bounce_points) × score_multiplier)`. Coins earned = total.
- Milestones pay a one-time bonus the first time the best distance reaches them:

| distance | reward | name |
|---|---|---|
| 50 | 25 | First Flight |
| 100 | 50 | Century |
| 250 | 150 | Sky Sprinter |
| 500 | 300 | Half-K Hero |
| 1000 | 1000 | Moon Shot |

## 6. Course (deterministic from a seed)

Generated by `CourseGenerator.generate(seed, length)` with one `RandomNumberGenerator` (`rng.seed = seed`),
in this order: all stars, then all springs, then all mud. The result is sorted by x.

- **Stars**: x starts at 20; repeat `x += rng.randf_range(12.0, 30.0)`; stop when x >= length; y = `rng.randf_range(1.5, 10.0)`.
- **Springs**: x starts at 40; repeat `x += rng.randf_range(60.0, 120.0)`; stop when x >= length; y = 0.
- **Mud**: x starts at 50; repeat `x += rng.randf_range(80.0, 150.0)`; stop when x >= length; y = 0.
- Item = `{"type": "star" | "spring" | "mud", "x": float, "y": float}`.
- The run seed is `progress.total_runs + 1`, so every run has a new but reproducible layout.

## 7. Flight simulation rules (FlightSim.step(dt))

Semi-implicit Euler, in this exact order:

1. If `stopped`: do nothing.
2. If airborne (`position.y > 0.0 or velocity.y > 0.0`):
   `accel = Vector2(0, -gravity) - velocity * velocity.length() * drag`; `velocity += accel * dt`;
   `position += velocity * dt`; `max_height = maxf(max_height, position.y)`.
   If now `position.y <= 0.0`: ground contact: `position.y = 0`; `rebound = -velocity.y * restitution`;
   if `rebound >= MIN_BOUNCE_SPEED`: `velocity.y = rebound`, `velocity.x *= BOUNCE_FRICTION`, `bounce_count += 1`,
   emit `bounced(rebound)`; else `velocity.y = 0` (the projectile slides from the next step on).
3. Otherwise (sliding on the ground): `position.y = 0`, `velocity.y = 0`,
   `velocity.x = move_toward(velocity.x, 0, SLIDE_FRICTION * dt)`, `position.x += velocity.x * dt`;
   if `absf(velocity.x) <= STOP_SPEED`: `velocity = Vector2.ZERO`, `stopped = true`.

After each step the RunTracker checks the course items (stars by segment distance, springs and mud on ground
contact); see section 9.

## 8. Architecture

- **Pure logic** in `scripts/core/` (extends RefCounted, `class_name`, static typing, no nodes). Fully unit tested.
- **Game nodes** in `scripts/game/`, **UI** in `scripts/ui/`. Nodes build their children **in code in `_ready()`**.
- **One scene**: `scenes/main.tscn` = a single `Node2D` named `Main` with `scripts/game/main.gd`. No other `.tscn` files.
- No autoloads. `Main` owns the `Progress` object and passes data down; children talk back with signals.
- Tests call public methods directly (no real input, no waiting for frames). Main's per-frame logic lives in
  `advance(dt)`, which `_physics_process` calls.

## 9. Class contracts

### scripts/core/balance.gd: `class_name Balance extends RefCounted`
Only the typed constants of section 3 (`const GRAVITY: float = 15.0`, ints for BASE_GUIDE_POINTS and BASE_STAR_VALUE).

### scripts/core/launch_math.gd: `class_name LaunchMath extends RefCounted`
- `static func clamp_pull(pull: Vector2, max_pull: float) -> Vector2`: `pull.limit_length(max_pull)`.
- `static func velocity_from_pull(pull: Vector2, max_pull: float, max_speed: float) -> Vector2`: zero if
  `max_pull <= 0` or pull is zero. Otherwise `p = clamp_pull(pull, max_pull)`, strength `p.length() / max_pull`,
  world direction `Vector2(-p.x, p.y).normalized()` (the opposite of the screen pull, with y flipped),
  result `direction * strength * max_speed`. Example: pull (-100, 50) on screen = dragged left and down,
  so the projectile flies right and up.

### scripts/core/flight_sim.gd: `class_name FlightSim extends RefCounted`
- Signals: `bounced(impact_speed: float)`, `boosted`.
- Vars: `position: Vector2`, `velocity: Vector2`, `gravity: float = Balance.GRAVITY`, `drag: float = Balance.BASE_DRAG`,
  `restitution: float = Balance.BASE_RESTITUTION`, `boost_charges: int = 0`, `bounce_count: int = 0`,
  `max_height: float = 0.0`, `stopped: bool = false`, `start_x: float = 0.0`.
- `launch(start: Vector2, launch_velocity: Vector2) -> void`: set position/velocity, `start_x = start.x`,
  `max_height = start.y`, `bounce_count = 0`, `stopped = false`.
- `is_airborne() -> bool`, `distance() -> float` (= position.x − start_x), `step(dt: float) -> void` (section 7),
  `simulate(dt: float, max_steps: int) -> int` (step until stopped or max_steps; returns steps taken),
  `boost() -> bool` (only if not stopped, airborne and boost_charges > 0: `velocity += Vector2(1, 1).normalized() * BOOST_SPEED`,
  `boost_charges -= 1`, emit `boosted`, return true).

### scripts/core/upgrade_catalog.gd: `class_name UpgradeCatalog extends RefCounted`
- `const UPGRADES: Dictionary` (section 4; keys in the table's order; each value has `name, category, max_level, base_cost, growth, per_level, description`).
- `const CATEGORIES: Array[String] = ["launcher", "projectile", "score"]`, `const CATEGORY_NAMES: Dictionary`.
- `static func ids() -> Array[String]`, `static func is_valid(id: String) -> bool`, `static func get_def(id: String) -> Dictionary`
  (empty if unknown), `static func max_level(id: String) -> int` (0 if unknown), `static func ids_in_category(category: String) -> Array[String]`,
  `static func cost(id: String, level: int) -> int` (−1 if unknown, level < 0 or level >= max_level), `static func is_maxed(id: String, level: int) -> bool`.

### scripts/core/player_stats.gd: `class_name PlayerStats extends RefCounted`
- Vars: `max_speed: float`, `launch_height: float`, `guide_points: int`, `drag: float`, `restitution: float`,
  `boost_charges: int`, `score_multiplier: float`, `star_value: int`, `bounce_bonus: int`.
- `static func from_levels(levels: Dictionary) -> PlayerStats` (section 4 formulas; missing ids = level 0; levels clamped to 0..max_level).
- `apply_to(sim: FlightSim) -> void`: copies drag, restitution and boost_charges into the sim.

### scripts/core/scoring.gd: `class_name Scoring extends RefCounted`
- `static func compute(distance: float, stars: int, bounces: int, stats: PlayerStats) -> Dictionary` with keys
  `distance_points, star_points, bounce_points, total, coins` (int) and `multiplier` (float).

### scripts/core/progress.gd: `class_name Progress extends RefCounted`
- Vars: `coins: int = 0`, `levels: Dictionary = {}`, `best_distance: float = 0.0`, `total_runs: int = 0`,
  `goal_reached: bool = false`, `settings: Dictionary = {"music_volume": 0.8, "sfx_volume": 0.8}` (added in task 045).
- `level_of(id) -> int`, `add_coins(amount: int) -> void` (ignores amount <= 0), `next_cost(id) -> int`,
  `can_buy(id) -> bool`, `buy(id) -> bool`, `stats() -> PlayerStats`,
  `record_run(distance: float, coins_earned: int) -> Array` (returns newly reached milestones),
  `to_dict() -> Dictionary`, `static func from_dict(data: Dictionary) -> Progress`.

### scripts/core/milestones.gd: `class_name Milestones extends RefCounted`
- `const LIST: Array` of `{"distance": float, "reward": int, "name": String}` (section 5, ascending).
- `static func newly_reached(previous_best: float, distance: float) -> Array` (entries with previous_best < d <= distance).
- `static func next_milestone(best: float) -> Dictionary` (first with distance > best, `{}` if none).

### scripts/core/save_system.gd: `class_name SaveSystem extends RefCounted`
- `const DEFAULT_PATH: String = "user://save.json"`.
- `static func save_progress(progress: Progress, path: String = DEFAULT_PATH) -> bool`,
  `static func load_progress(path: String = DEFAULT_PATH) -> Progress` (missing or corrupt file = new Progress, no errors printed),
  `static func delete_save(path: String = DEFAULT_PATH) -> void`.

### scripts/core/course_generator.gd: `class_name CourseGenerator extends RefCounted`
- `static func generate(seed: int, length: float) -> Array` (section 6).

### scripts/core/run_tracker.gd: `class_name RunTracker extends RefCounted`
- Signals: `star_collected(index: int)`, `spring_hit(index: int)`, `mud_hit(index: int)` (index into `items`).
- Vars: `items: Array`, `stars_collected: int`, `springs_hit: int`, `mud_hits: int`.
- `_init(course_items: Array = [])`, `is_used(index: int) -> bool`,
  `after_step(sim: FlightSim, previous_position: Vector2) -> void`: for each unused item:
  star: collected if `Geometry2D.get_closest_point_to_segment(star, previous_position, sim.position)` is within STAR_RADIUS;
  spring: if `sim.position.y <= 0` and `absf(sim.position.x - x) <= SPRING_HALF_WIDTH`: `velocity.y = maxf(velocity.y, SPRING_SPEED)`,
  `velocity.x += SPRING_PUSH`, `sim.stopped = false`;
  mud: if `sim.position.y <= 0` and `x <= sim.position.x <= x + MUD_WIDTH`: `velocity.x *= MUD_FACTOR`. Each item triggers once.

### scripts/core/run_session.gd: `class_name RunSession extends RefCounted`
- Vars: `stats: PlayerStats`, `sim: FlightSim`, `tracker: RunTracker`, `course: Array`, `launched: bool`, `elapsed: float`.
- `_init(player_stats: PlayerStats, course_seed: int)`, `launch_from_pull(pull: Vector2) -> Vector2`,
  `step(dt: float) -> void`, `boost() -> bool`, `is_finished() -> bool`, `result() -> Dictionary`
  (Scoring keys plus `distance, stars, bounces, max_height`).

### scripts/game/main.gd (attached to scenes/main.tscn)
- `enum State { TITLE, AIM, FLIGHT, RESULTS, SHOP, VICTORY }`, `signal state_changed(new_state: int)`.
- `@export var save_path: String = "user://save.json"`; vars `state`, `progress`, `session`, `last_result`, `is_paused`.
- Public API used by tests and UI: `change_state(s)`, `state_name()`, `start_game()`, `launch_with_pull(pull) -> bool`,
  `advance(dt)`, `request_boost() -> bool`, `continue_to_shop()`, `buy_upgrade(id) -> bool`, `leave_shop()`,
  `toggle_pause()`, `go_to_title()`, `reset_progress()`.
- Child nodes (created in `_ready()`, exposed as vars): `world_view`, `course_view`, `slingshot`, `projectile_view`,
  `trajectory`, `camera`, `background`, `ui_layer`, `hud`, `results_panel`, `shop_panel`, `title_panel`,
  `victory_panel`, `pause_label`, `options_panel`, `credits_panel`, `audio`.

The per-task files (tasks/*.md) give each node's exact API.

## 10. Assets (already in the repo; never edit or rename)

| Path | Use |
|---|---|
| assets/sprites/projectile_1.png, _2, _3 | alien projectile (tier by Aerodynamics level) |
| assets/sprites/star.png, spring.png, mud.png | course items |
| assets/sprites/ground.png | ground tile |
| assets/sprites/post.png | slingshot posts |
| assets/sprites/flag.png, goal_flag.png | milestone flags, 1000 m goal flag |
| assets/sprites/cloud.png, assets/backgrounds/sky.png | background |
| assets/sprites/bush.png, rock.png, cactus.png | ground scenery (decoration) |
| assets/audio/music/menu.ogg, flight.ogg, victory.ogg | music |
| assets/audio/sfx/launch.mp3, bounce.mp3, star.mp3, spring.mp3, boost.mp3, buy.mp3, milestone.mp3, click.wav | sound effects |

## 11. Build plan

129 tasks in 14 milestones. After every 10 tasks a checkpoint task (`010c`, `020c`, ...) runs integration tests
across the milestone and records it in docs/PROGRESS.md. Tasks run in order; each builds on the previous one.

| Milestone | Tasks | Result |
|---|---|---|
| 1 Core simulation | 001–010, 010c | Constants, launch math, flight physics, upgrades, stats, scoring |
| 2 Progression | 011–020, 020c | Coins and purchases, milestones, saving, course, star/spring/mud logic, a full headless run |
| 3 Playable scene | 021–030, 030c | Main scene state machine, world, slingshot, projectile, preview, camera, course sprites |
| 4 Game loop UI | 031–040, 040c | HUD, results, shop, save/load, title, victory, pause, background |
| 5 Audio and polish | 041–050, 050c | Music, sound effects, volume options, camera shake, popups, upgrade visuals, credits |
| 6 Graphics polish | 051–060, 060c | UI theme, solid ground, scenery, projectile trail and shadow, particles, sky tint, slingshot with power meter |
| 7 Player experience | 061–070, 070c | UiRoot refactor, screen fades, first-time hints, best-distance flag, boost flame, lifetime stats and stats screen, achievements with pop-ups |
| 8 Roguelike | 071–080, 080c | Feedback refactor, last-aim line (Aim Guide upgrade), roguelike goals, perks, runs with lives, perk and run-over screens, title button |
| 9 Whimsy | 081–090, 090c | UiRoot.refresh refactor, jelly wobble, hats with a Wardrobe, alien moods, sheep that hop, confetti, alien quips |
| 10 Features | 091–100 (096 in two parts: 096, 096b), 100c | Compact main._ready, R repeats the last shot, party balloons, best-run ghost, daily run, perk rerolls, pause menu, title mascot, night stars |
| 11 Roguelike sizes | 101–104, 105c | Star pickup settings, Small/Normal/Big alien sizes, size drawn on screen, size choice on the perk panel |
| 12 Weather and polish | 106–112, 113c | UiRoot.wire refactor, varied sound pitch, combo popups, birds that scatter, roguelike weather, weather on the perk panel, roguelike stats |
| 13 Bosses and extras | 114–119, 120c | Shot map on the results, wardrobe preview, friendly UFOs, roguelike boss rounds (every 6th round from 12, +1 life) |
| 14 Juice | 121–128, 129c | Boing/Splat popups, twinkling stars and waving flags, fading aim dots, black sheep, hat celebration, keyboard aiming, WorldBuilder refactor, weather on screen |
| 15 Roguelike depth | 130–135, 136c | Run history, replay a seed, perks and boss banner on the HUD, daily streak, best roguelike run on the title |
| 16 Meadow | 137–143, 144c | Rolling hills, flowers where you bounce, cows, kites, shooting stars, tip of the day, distance to best |
| 17 Options and extras | 145–150, 151c | Screen shake setting and option, classic daily challenge and its label, best combo and its stat |
| 18 Final polish | 152–155, 156c | Hat trails, grazing sheep, mascot hop, height bar on the HUD |
| 19 Variety | 157–163, 164c | Lucky rounds and their banner, weather on the HUD, roguelike total, best buy in the shop, glowing reached flags, victory confetti |

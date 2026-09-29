---
id: 044-sfx-wiring
status: ready
tests: [tests/acceptance/test_044_sfx_wiring.gd]
files: [scripts/game/main.gd]
read: [scripts/game/audio_manager.gd, scripts/core/run_tracker.gd, scripts/core/flight_sim.gd]
---

# Main: sound effects for game events

Edit `scripts/game/main.gd` (keep everything that works).

1. In `launch_with_pull`, after `session.launch_from_pull(pull)`: `audio.play_sfx("launch")`.
2. In `_begin_aim()`, next to the existing `star_collected -> course_view.mark_collected` connection, connect
   the new session's signals (each run has a new session, so this connects once per run):
   ```gdscript
   session.tracker.star_collected.connect(_on_star_collected)
   session.tracker.spring_hit.connect(_on_spring_hit)
   session.sim.bounced.connect(_on_bounced)
   session.sim.boosted.connect(_on_boosted)
   ```
3. Handlers:
   ```gdscript
   func _on_star_collected(_index: int) -> void:
   	audio.play_sfx("star")


   func _on_spring_hit(_index: int) -> void:
   	audio.play_sfx("spring")


   func _on_bounced(_impact_speed: float) -> void:
   	audio.play_sfx("bounce")


   func _on_boosted() -> void:
   	audio.play_sfx("boost")
   ```
4. `buy_upgrade`: after a successful purchase, `audio.play_sfx("buy")`.
5. `_finish_run`: right after `record_run(...)`, if `last_result["milestones"]` is not empty,
   `audio.play_sfx("milestone")`.

## Acceptance criteria
- Launch, bounce, star, spring, boost, buy and milestone each play their sound; the star sprite still hides.
- After the next run starts, one event plays exactly one sound (no leftover connections).

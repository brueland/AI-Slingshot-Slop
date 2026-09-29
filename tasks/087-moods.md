---
id: 087-moods
status: ready
tests: [tests/acceptance/test_087_moods.gd]
files: [scripts/game/projectile_decor.gd, scripts/game/projectile_view.gd, scripts/game/feedback.gd]
---

# Alien moods

Little effects above the alien: a surprised red "!" on a star, three dizzy stars circling after the third bounce
of a run, and sleepy "z"s once it stops.

Edit the three files with several **small** SEARCH/REPLACE blocks (one per bullet below), each SEARCH holding
only the few existing lines around that change. Do not rewrite whole files. main.gd does not change.

**1. `scripts/game/projectile_decor.gd`** (keep the hat drawing exactly as it is):
- Add `const MOODS: Array[String] = ["", "dizzy", "wow", "sleepy"]` after `const HAT_Y`.
- **Declare the variables** after `var spin: float = 0.0`:
  ```gdscript
  var mood: String = ""
  var mood_left: float = 0.0
  ```
- Replace `_process()` with these two functions:
  ```gdscript
  func _process(delta: float) -> void:
  	advance(delta)


  func advance(delta: float) -> void:
  	spin = fmod(spin + delta * 18.0, TAU)
  	if mood_left > 0.0:
  		mood_left = maxf(mood_left - delta, 0.0)
  		if mood_left <= 0.0:
  			mood = ""
  	if hat == "propeller" or mood != "":
  		queue_redraw()
  ```
- Add this function after `set_hat()`:
  ```gdscript
  ## Shows a mood for `seconds` (0 = until changed). Unknown moods are ignored.
  func set_mood(id: String, seconds: float = 0.0) -> void:
  	if not MOODS.has(id):
  		return
  	mood = id
  	mood_left = seconds
  	queue_redraw()
  ```
- Rename the current `_draw()` to `_draw_hat()` (same body), and add a new `_draw()` above it:
  ```gdscript
  func _draw() -> void:
  	_draw_hat()
  	_draw_mood()
  ```
- Add this function at the end of the file:
  ```gdscript
  func _draw_mood() -> void:
  	match mood:
  		"dizzy":
  			for k in 3:
  				var a := spin * 0.4 + k * TAU / 3.0
  				draw_circle(Vector2(cos(a) * 12.0, -24.0 + sin(a) * 3.0), 2.2, Color(1.0, 0.9, 0.2))
  		"wow":
  			draw_rect(Rect2(13, -32, 3, 9), Color(0.95, 0.2, 0.2))
  			draw_circle(Vector2(14.5, -19), 1.8, Color(0.95, 0.2, 0.2))
  		"sleepy":
  			var bob := sin(spin * 0.2) * 2.0
  			draw_string(ThemeDB.fallback_font, Vector2(12, -14 + bob), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.9))
  			draw_string(ThemeDB.fallback_font, Vector2(18, -24 - bob), "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.9))
  ```

**2. `scripts/game/projectile_view.gd`:**
- Add after `set_hat()`:
  ```gdscript
  func set_mood(id: String, seconds: float = 0.0) -> void:
  	decor.set_mood(id, seconds)
  ```
- At the end of `sync_from(sim)`, add:
  ```gdscript
  	if sim.stopped:
  		set_mood("sleepy")
  ```

**3. `scripts/game/feedback.gd`:**
- **Declare** `var bounces_seen: int = 0` after `var star_value ...`.
- In `watch()`, after `star_value = session.stats.star_value`, add:
  ```gdscript
  	bounces_seen = 0
  	projectile_view.set_mood("")
  ```
- In `_on_star_collected()`, after `audio.play_sfx("star")`, add `projectile_view.set_mood("wow", 0.8)`.
- At the end of `_on_bounced()`, add:
  ```gdscript
  	bounces_seen += 1
  	if bounces_seen >= 3:
  		projectile_view.set_mood("dizzy", 2.0)
  ```

## Acceptance criteria
- Moods "", "dizzy", "wow", "sleepy"; timed moods end by themselves, 0 seconds lasts until changed; unknown
  moods are ignored; every mood draws without errors.
- A star gives "wow" for 0.8 s; the third bounce of a run gives "dizzy" for 2 s; a stopped alien is "sleepy";
  a new shot starts with no mood.

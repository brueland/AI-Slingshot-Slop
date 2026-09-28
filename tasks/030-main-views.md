---
id: 030-main-views
status: ready
tests: [tests/acceptance/test_030_main_views.gd]
files: [scripts/game/main.gd]
read: [scripts/game/world_view.gd, scripts/game/course_view.gd, scripts/game/slingshot.gd, scripts/game/trajectory_preview.gd, scripts/game/projectile_view.gd, scripts/game/camera_rig.gd, scripts/core/run_session.gd]
---

# Main: build the world nodes and keep them in sync

Edit `scripts/game/main.gd` (keep the existing state machine). Build the world in code and drive it from the
run.

1. Add typed vars: `world_view: WorldView`, `course_view: CourseView`, `slingshot: Slingshot`,
   `trajectory: TrajectoryPreview`, `projectile_view: ProjectileView`, `camera: CameraRig`.
2. In `_ready()` (after creating `progress`), create each with `.new()` and `add_child()` in this order:
   world_view, course_view, slingshot, trajectory, projectile_view, camera. Then
   `slingshot.launched.connect(launch_with_pull)` and `camera.make_current()`.
3. At the end of `_begin_aim()`, before `change_state(State.AIM)`, set up the views for the new session:
   ```gdscript
   course_view.build(session.course)
   session.tracker.star_collected.connect(course_view.mark_collected)
   var stats := session.stats
   slingshot.position = WorldView.world_to_screen(Vector2(0.0, stats.launch_height))
   slingshot.frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
   slingshot.enabled = true
   projectile_view.show_at(session.sim.position)
   projectile_view.rotation = 0.0
   camera.snap_to(projectile_view.position)
   trajectory.clear()
   ```
4. In `launch_with_pull`, after `session.launch_from_pull(pull)`: `slingshot.enabled = false`,
   `slingshot.cancel_drag()`, `trajectory.clear()`.
5. Change `advance(dt)` to handle both states (still nothing while `is_paused`):
   - AIM: call `_update_aim()`.
   - FLIGHT: `session.step(dt)`, `projectile_view.sync_from(session.sim)`,
     `camera.follow(projectile_view.position, dt)`, then finish the run if `session.is_finished()`.
6. Add `_update_aim()`: if the slingshot is not dragging, `trajectory.clear()` and return. Otherwise
   `var v := LaunchMath.velocity_from_pull(slingshot.pull, Balance.MAX_PULL_PX, stats.max_speed)`, then
   `trajectory.update_preview(Vector2(0.0, stats.launch_height), v, stats.drag, stats.guide_points)` and move the
   projectile into the pouch: `projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)`.

## Acceptance criteria
- The six nodes exist after `_ready()` with the right scripts.
- Aiming places the slingshot at world (0, launch_height) and builds one sprite per course item.
- Dragging shows up to `guide_points` dots; releasing the slingshot starts the flight (via its signal).
- During flight the projectile and camera follow the sim, and collected stars are hidden.

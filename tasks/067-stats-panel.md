---
id: 067-stats-panel
status: ready
tests: [tests/acceptance/test_067_stats_panel.gd]
files: [scripts/ui/distance_chart.gd, scripts/ui/stats_panel.gd]
read: [scripts/core/progress.gd]
---

# Stats panel with a chart of recent runs

Two new UI scripts (task 068 opens the panel from the title screen).

**1. `scripts/ui/distance_chart.gd`:**
```gdscript
class_name DistanceChart
extends Control
## A small line chart of the most recent run distances (oldest on the left, newest on the right).

var values: Array[float] = []


## Chart points for `data` inside a box of `box_size`: x spread evenly across the width, y from the bottom (0)
## up to the top (the largest value).
static func chart_points(data: Array, box_size: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	if data.is_empty():
		return out
	var top := 0.0
	for v in data:
		top = maxf(top, float(v))
	if top <= 0.0:
		top = 1.0
	var step := box_size.x / maxf(1.0, data.size() - 1.0)
	for i in data.size():
		out.append(Vector2(i * step, box_size.y - float(data[i]) / top * box_size.y))
	return out


func _ready() -> void:
	custom_minimum_size = Vector2(360, 120)


func set_values(new_values: Array) -> void:
	values.clear()
	for v in new_values:
		values.append(float(v))
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.3))
	var points := chart_points(values, size)
	if points.size() >= 2:
		draw_polyline(points, Color(1.0, 0.85, 0.3), 3.0, true)
	for p in points:
		draw_circle(p, 4.0, Color.WHITE)
```

**2. `scripts/ui/stats_panel.gd`:** `class_name StatsPanel extends PanelContainer`, `signal closed`, and vars
`runs_label, distance_label, best_label, height_label, stars_label, bounces_label: Label`, `chart: DistanceChart`,
`close_button: Button`. `_ready()`: center it like the other panels
(`set_anchors_and_offsets_preset(Control.PRESET_CENTER)`, grow both ways, `custom_minimum_size = Vector2(420, 0)`),
then a VBoxContainer with a "Stats" title (font size 32 via `add_theme_font_size_override`), the six labels, a
"Last 10 runs" label, the chart, and a "Close" button (pressed -> emit `closed`). End with `hide()`.

`func show_stats(progress: Progress) -> void` sets, then `chart.set_values(progress.recent_distances)` and `show()`:
`"Runs: %d" % progress.total_runs`, `"Total distance: %d m" % floori(float(progress.lifetime["distance"]))`,
`"Best distance: %d m" % floori(progress.best_distance)`, `"Best height: %d m" % floori(float(progress.lifetime["best_height"]))`,
`"Stars collected: %d" % int(progress.lifetime["stars"])`, `"Bounces: %d" % int(progress.lifetime["bounces"])`.

## Acceptance criteria
- `chart_points([10, 20, 5], (100, 50))` is (0, 25), (50, 0), (100, 37.5); all zeros lie on the bottom.
- The panel shows the six texts above and the chart's values, and Close emits `closed`.

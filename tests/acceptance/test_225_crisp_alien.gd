extends GutTest
# Task 225: the alien's textures are 256 px (with mipmaps), so even the big roguelike alien is sharp; the views use
# mipmapped filtering so the small alien is smooth too.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_225_save.json"
const PULL := Vector2(-84.852814, 84.852814)


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func test_crisp_alien() -> void:
	for i in 3:
		var tex: Texture2D = load(ProjectileView.TEXTURES[i])
		assert_eq(tex.get_width(), 256, "a big texture")
		assert_true(tex.get_image().has_mipmaps(), "with mipmaps")
	var main = _main()
	assert_eq(main.projectile_view.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	assert_eq(main.title_panel.mascot.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	main.projectile_view.set_size(2.5)
	var drawn: float = main.projectile_view.texture.get_width() * main.projectile_view.scale.x
	assert_almost_eq(drawn, 36.0 * 2.5, 0.01, "the big alien is 90 px")
	assert_lt(drawn, 256.0, "never stretched past its texture")

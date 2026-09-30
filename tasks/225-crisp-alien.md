---
id: 225-crisp-alien
status: ready
tests: [tests/acceptance/test_225_crisp_alien.gd, tests/acceptance/test_024_projectile_view.gd, tests/acceptance/test_205_alien_look_size.gd]
files: [scripts/game/projectile_view.gd, scripts/ui/title_mascot.gd]
---

# A sharp alien

The alien's pictures are now 256 px (they were 70 px, so the big roguelike alien was stretched and blurry), with
mipmaps. The picture files are already replaced; the alien's views only need to use mipmapped filtering so it also
looks smooth when small. Two older tests are updated.

**1. `scripts/game/projectile_view.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
func _ready() -> void:
	set_tier(tier)
```
REPLACE:
```gdscript
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_tier(tier)
```

**2. `scripts/ui/title_mascot.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	custom_minimum_size = Vector2(0, 100)
	texture = load(TEXTURE)
```
REPLACE:
```gdscript
	custom_minimum_size = Vector2(0, 100)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture = load(TEXTURE)
```

## Acceptance criteria
- ProjectileView and TitleMascot use `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`.
- The big alien (90 px) is drawn from a 256 px texture.

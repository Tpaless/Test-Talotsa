extends Node2D

const SCREEN_SIZE := Vector2(540.0, 960.0)

# HOW TO ADD A LAYER
# 1. Copy one complete { ... } block below.
# 2. Change `layer` to control draw order (1 = farthest back).
# 3. Change `texture` to your asset path.
# 4. Lower `speed` feels farther away; higher `speed` feels closer.
# Transparent PNG/WebP images work best for every layer above layer 1.
const LAYER_CONFIGS: Array[Dictionary] = [
	{
		"layer": 1,
		"texture": "res://assets/backgrounds/layer_1_space.png",
		"speed": 5.0,
		"opacity": 1.0,
		"enabled": true
	},
	{
		"layer": 2,
		"texture": "res://assets/backgrounds/layer_2_nebula.svg",
		"speed": 14.0,
		"opacity": 0.72,
		"enabled": true
	},
	{
		"layer": 3,
		"texture": "res://assets/backgrounds/layer_3_stars.svg",
		"speed": 42.0,
		"opacity": 1.0,
		"enabled": true
	}
]

var active_layers: Array[Dictionary] = []


func _ready() -> void:
	reload_layers()


func reload_layers() -> void:
	active_layers.clear()
	for config in LAYER_CONFIGS:
		if not config.get("enabled", true):
			continue
		var texture_path: String = config.get("texture", "")
		if not ResourceLoader.exists(texture_path):
			push_warning("Parallax layer asset not found: " + texture_path)
			continue
		var texture := load(texture_path) as Texture2D
		if texture == null:
			push_warning("Parallax layer is not a Texture2D: " + texture_path)
			continue
		active_layers.append({
			"layer": int(config.get("layer", 1)),
			"texture": texture,
			"speed": float(config.get("speed", 0.0)),
			"opacity": clampf(float(config.get("opacity", 1.0)), 0.0, 1.0),
			"offset": 0.0
		})
	active_layers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.layer < b.layer)
	queue_redraw()


func _process(delta: float) -> void:
	for layer_data in active_layers:
		var tile_height: float = SCREEN_SIZE.x * layer_data.texture.get_height() / layer_data.texture.get_width()
		layer_data.offset = fmod(layer_data.offset + layer_data.speed * delta, tile_height)
	queue_redraw()


func _draw() -> void:
	# Fallback color remains visible if layer 1 is disabled or missing.
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("050819"))
	for layer_data in active_layers:
		var y_offset: float = layer_data.offset
		var tint := Color(1.0, 1.0, 1.0, layer_data.opacity)
		if layer_data.layer == 1:
			draw_texture_rect(layer_data.texture, Rect2(Vector2.ZERO, SCREEN_SIZE), false, tint)
			continue
		var tile_height: float = SCREEN_SIZE.x * layer_data.texture.get_height() / layer_data.texture.get_width()
		for tile_index in range(-1, ceili(SCREEN_SIZE.y / tile_height) + 1):
			draw_texture_rect(layer_data.texture, Rect2(0.0, y_offset + tile_index * tile_height, SCREEN_SIZE.x, tile_height), false, tint)

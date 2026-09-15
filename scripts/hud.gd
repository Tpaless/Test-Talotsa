extends Node2D

const SHIP_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/player_ship.svg"),
	preload("res://assets/sprites/player_swift.svg"),
	preload("res://assets/sprites/player_titan.svg")
]
const SHIP_NAMES := ["FALCON", "SWIFT", "TITAN"]
const SHIP_ROLES := ["BALANCED", "SPEED", "HEAVY"]
const SHIP_STAT_LINES := [
	["HULL  4", "SPEED  3", "TWIN SHOT"],
	["HULL  3", "SPEED  5", "RAPID SHOT"],
	["HULL  6", "SPEED  2", "TRIPLE SHOT"]
]

@export var game_path: NodePath

var game: Node
var title_font: Font
var body_font: Font


func _ready() -> void:
	game = get_node(game_path)
	title_font = ThemeDB.fallback_font
	body_font = ThemeDB.fallback_font


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(game):
		return
	if game.selecting_character:
		draw_character_select()
		return
	draw_hud()
	if game.flash_timer > 0.0:
		draw_rect(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)), Color(1.0, 0.2, 0.28, game.flash_timer * 2.2))
	if game.paused:
		draw_overlay("PAUSED", "Press P to continue")
	elif game.game_over:
		draw_overlay("MISSION FAILED", "Score  %06d     Best  %06d\nPress R to choose a ship" % [game.score, game.best_score])


func draw_character_select() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)), Color(0.01, 0.015, 0.06, 0.72))
	draw_string(title_font, Vector2(0.0, 74.0), "SELECT YOUR SHIP", HORIZONTAL_ALIGNMENT_CENTER, 960.0, 34, Color("eafcff"))
	draw_string(body_font, Vector2(0.0, 104.0), "A / D or ARROWS to select     •     ENTER / SPACE to launch", HORIZONTAL_ALIGNMENT_CENTER, 960.0, 15, Color("76dfff"))
	for i in range(SHIP_TEXTURES.size()):
		var x := 130.0 + i * 240.0
		var selected: bool = i == game.selected_character
		var fill := Color(0.055, 0.09, 0.19, 0.98) if selected else Color(0.025, 0.04, 0.10, 0.92)
		var border := Color("65efff") if selected else Color(0.25, 0.42, 0.58, 0.55)
		draw_rect(Rect2(x, 130.0, 220.0, 260.0), fill)
		draw_rect(Rect2(x, 130.0, 220.0, 260.0), border, false, 3.0 if selected else 1.0)
		if selected:
			draw_circle(Vector2(x + 110.0, 190.0), 55.0, Color(0.20, 0.84, 1.0, 0.10))
		draw_texture_rect(SHIP_TEXTURES[i], Rect2(x + 74.0, 145.0, 72.0, 88.0), false)
		draw_string(title_font, Vector2(x, 269.0), SHIP_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, 220.0, 23, Color.WHITE)
		draw_string(body_font, Vector2(x, 292.0), SHIP_ROLES[i], HORIZONTAL_ALIGNMENT_CENTER, 220.0, 12, border)
		for stat_index in range(3):
			draw_string(body_font, Vector2(x, 322.0 + stat_index * 22.0), SHIP_STAT_LINES[i][stat_index], HORIZONTAL_ALIGNMENT_CENTER, 220.0, 14, Color(0.72, 0.82, 0.93, 0.92))
		if selected:
			draw_string(body_font, Vector2(x, 382.0), "SELECTED", HORIZONTAL_ALIGNMENT_CENTER, 220.0, 12, Color("65efff"))
	draw_rect(Rect2(360.0, 425.0, 240.0, 50.0), Color("1aafc2"))
	draw_rect(Rect2(360.0, 425.0, 240.0, 50.0), Color("a8f8ff"), false, 2.0)
	draw_string(title_font, Vector2(360.0, 458.0), "LAUNCH", HORIZONTAL_ALIGNMENT_CENTER, 240.0, 21, Color.WHITE)
	draw_string(body_font, Vector2(0.0, 505.0), "Click a card to select • Click LAUNCH to begin • Keys 1 / 2 / 3 also select", HORIZONTAL_ALIGNMENT_CENTER, 960.0, 13, Color(0.58, 0.70, 0.82, 0.85))


func draw_hud() -> void:
	draw_rect(Rect2(18.0, 16.0, 238.0, 56.0), Color(0.02, 0.04, 0.12, 0.82), true)
	draw_rect(Rect2(18.0, 16.0, 238.0, 56.0), Color(0.24, 0.79, 1.0, 0.35), false, 1.5)
	draw_string(body_font, Vector2(32.0, 39.0), "SCORE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("76dfff"))
	draw_string(title_font, Vector2(31.0, 62.0), "%06d" % game.score, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 25, Color.WHITE)
	draw_string(body_font, Vector2(274.0, 38.0), "HULL", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color("76dfff"))
	for i in range(game.max_player_health):
		var x := 274.0 + i * 27.0
		var heart_color := Color("62f5ff") if i < game.player_health else Color(0.17, 0.22, 0.31, 0.9)
		draw_polygon(PackedVector2Array([Vector2(x, 48.0), Vector2(x + 9.0, 42.0), Vector2(x + 18.0, 48.0), Vector2(x + 9.0, 63.0)]), PackedColorArray([heart_color]))
	draw_string(body_font, Vector2(778.0, 35.0), "P  PAUSE", HORIZONTAL_ALIGNMENT_RIGHT, 150.0, 13, Color(0.62, 0.72, 0.85, 0.8))
	draw_string(body_font, Vector2(578.0, 57.0), "WASD / ARROWS   -   SPACE / CLICK", HORIZONTAL_ALIGNMENT_RIGHT, 350.0, 13, Color(0.62, 0.72, 0.85, 0.8))


func draw_overlay(heading: String, subheading: String) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960.0, 540.0)), Color(0.01, 0.015, 0.06, 0.78))
	draw_rect(Rect2(220.0, 174.0, 520.0, 190.0), Color(0.03, 0.06, 0.16, 0.96))
	draw_rect(Rect2(220.0, 174.0, 520.0, 190.0), Color(0.29, 0.88, 1.0, 0.68), false, 2.0)
	draw_string(title_font, Vector2(220.0, 245.0), heading, HORIZONTAL_ALIGNMENT_CENTER, 520.0, 36, Color("eafcff"))
	var lines := subheading.split("\n")
	for i in range(lines.size()):
		draw_string(body_font, Vector2(220.0, 292.0 + i * 32.0), lines[i], HORIZONTAL_ALIGNMENT_CENTER, 520.0, 18, Color("8eeaff"))

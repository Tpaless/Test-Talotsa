extends Node2D

const SCREEN_SIZE := Vector2(540.0, 960.0)
const MENU_BACKGROUND_TEXTURE: Texture2D = preload("res://assets/backgrounds/Menu.png")
# Typography อ้างอิง PROJECT _ DESIGN/User Design Home Page And Theme.png
# ขาวอมฟ้าด้านบน + ฟ้าอ่อนด้านล่าง, ขอบกรมท่าซ้อนขอบดำ และฐานเงาแข็งแบบพิกเซล
const MENU_TEXT_TOP := Color("ffffff")
const MENU_TEXT_BOTTOM := Color("69e8ff")
const MENU_TEXT_INNER_STROKE := Color("0a315f")
const MENU_TEXT_OUTER_STROKE := Color("020817")
const MENU_TEXT_SHADOW := Color("087aa5")
const MENU_TEXT_SHADOW_OFFSET := Vector2(5.0, 7.0)
const MENU_TEXT_STROKE_SIZE := 4
const MENU_TEXT_INNER_STROKE_SIZE := 2

@export var game_path: NodePath

var game: Node
var title_font: Font
var body_font: Font
var story_font: Font
var ship_stat_lines: Array = []
var ship_textures: Array[Texture2D] = []
var shopkeeper_texture: Texture2D
var coin_texture: Texture2D
var chest_texture: Texture2D
var settings_texture: Texture2D
var version_label := ""


func _ready() -> void:
	game = get_node(game_path)
	version_label = "Ver %s" % str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	title_font = ThemeDB.fallback_font
	body_font = ThemeDB.fallback_font
	story_font = ThemeDB.fallback_font
	var design_title := load("res://PROJECT _ DESIGN/PixeloidSans-Bold.ttf") as Font
	var design_body := load("res://PROJECT _ DESIGN/PixeloidSans.ttf") as Font
	if design_title != null:
		title_font = design_title
	if design_body != null:
		body_font = design_body
	var thai_story_font := load("res://assets/fonts/NotoSansThai.ttf") as Font
	if thai_story_font != null:
		story_font = thai_story_font
	coin_texture = load("res://assets/assest_For_Menu/coin.svg") as Texture2D
	chest_texture = load("res://assets/assest_For_Menu/chest.svg") as Texture2D
	settings_texture = load("res://assets/assest_For_Menu/settings.svg") as Texture2D
	# อ่านค่ายาน/ภาพจาก Scene จริง การเปลี่ยน Texture ใน Scene จึงสะท้อนในเมนูทันที
	for i in range(game.PLAYER_SCENES.size()):
		var ship: Dictionary = game.PLAYER_CONFIG.get_ship(i)
		var visual: CombatantVisual = game.PLAYER_SCENES[i].instantiate() as CombatantVisual
		ship_textures.append(game.visual_textures.get(game.PLAYER_VISUAL_KEYS[i], visual.texture))
		var modifiers: Dictionary = visual.get_skill_modifiers()
		var names: PackedStringArray = visual.get_skill_names()
		var skill_text := " + " + " + ".join(names) if not names.is_empty() else ""
		ship_stat_lines.append([
			"HULL %d  SPEED %d" % [ceili(float(ship.base_health) * float(ship.health_multiplier) * float(modifiers.max_health_multiplier)), roundi(float(ship.speed))],
			"FIRE: %s  /  %.2fs" % [ship.weapon_label, float(ship.fire_delay) * float(modifiers.fire_interval_multiplier)],
			"SPECIAL: %s%s" % [ship.special_label, skill_text]
		])
		visual.free()
	var shopkeeper: CombatantVisual = game.BOSS_SCENE.instantiate() as CombatantVisual
	shopkeeper_texture = game.visual_textures.get("boss", shopkeeper.texture)
	shopkeeper.free()



func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(game):
		return
	if game.selecting_character:
		match game.menu_page:
			"stage": draw_stage_select()
			"scoreboard": draw_scoreboard()
			"collection": draw_collection_select()
			"settings": draw_settings()
			_: draw_home_menu()
		return
	draw_hud()
	if game.flash_timer > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(1.0, 0.2, 0.28, game.flash_timer * 2.2))
	if game.paused:
		draw_pause_menu()
	elif game.game_over:
		draw_summary()

func draw_home_menu() -> void:
	draw_underwater_home_background()
	var selected: int = game.selected_character
	var unlocked: bool = game.is_ship_unlocked(selected)
	var previous: int = game.get_adjacent_visible_ship(selected, -1)
	var following: int = game.get_adjacent_visible_ship(selected, 1)
	var slide_ratio: float = clampf(absf(game.carousel_slide_offset) / 210.0, 0.0, 1.0)
	var bob: float = sin(game.menu_animation_time * 2.2) * 6.0

	draw_menu_gradient_text(title_font, Vector2(24.0, 58.0), game.get_ship_display_name(selected), HORIZONTAL_ALIGNMENT_CENTER, 492.0, 34)
	draw_coin(Vector2(214.0, 101.0), 20.0)
	draw_menu_gradient_text(title_font, Vector2(242.0, 110.0), ": %d" % game.sea_tokens, HORIZONTAL_ALIGNMENT_LEFT, 180.0, 23)
	var nightmare_unlocked: bool = game.is_nightmare_unlocked()
	var difficulty_labels := ["NORMAL", "NIGHTMARE X2", "NIGHTMARE X3"]
	for difficulty_index in range(game.DIFFICULTY_BUTTONS.size()):
		var difficulty_rect: Rect2 = game.DIFFICULTY_BUTTONS[difficulty_index]
		var available := difficulty_index == 0 or nightmare_unlocked
		var selected_difficulty: bool = game.difficulty_multiplier == difficulty_index + 1
		draw_rounded_panel(difficulty_rect, Color("087b91") if selected_difficulty else Color("07304f"), Color("fff09a") if selected_difficulty else Color("4a8295"), 10, 3 if selected_difficulty else 2)
		draw_string(title_font, difficulty_rect.position + Vector2(0.0, 25.0), difficulty_labels[difficulty_index] if available else "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, difficulty_rect.size.x, 11, Color.WHITE if available else Color("718995"))
	draw_rounded_panel(game.SETTINGS_BUTTON, Color("07304f"), Color("7fffff"), 15, 2)
	if settings_texture != null:
		draw_texture_rect(settings_texture, game.SETTINGS_BUTTON.grow(-10.0), false, Color.WHITE)
	if game.admin_test_armed or game.admin_test_active:
		draw_rounded_panel(Rect2(105.0, 180.0, 330.0, 34.0), Color("4f174f"), Color("ff8df0"), 10, 2)
		var admin_label := "[AdminTest] PRESS START" if game.admin_test_armed else "[AdminTest] ALL UNLOCKED"
		draw_string(title_font, Vector2(105.0, 203.0), admin_label, HORIZONTAL_ALIGNMENT_CENTER, 330.0, 13, Color("fff4ff"))

	if ship_textures[previous] != null:
		draw_texture_rect(ship_textures[previous], Rect2(-18.0, 270.0, 104.0, 104.0), false, Color(1.0, 1.0, 1.0, 0.34) if game.is_ship_unlocked(previous) else Color(0.18, 0.28, 0.34, 0.48))
	if ship_textures[following] != null:
		draw_texture_rect(ship_textures[following], Rect2(454.0, 270.0, 104.0, 104.0), false, Color(1.0, 1.0, 1.0, 0.34) if game.is_ship_unlocked(following) else Color(0.18, 0.28, 0.34, 0.48))
	var hero_center := Vector2(270.0, 310.0 + bob)
	draw_circle(hero_center, 120.0, Color(0.08, 0.92, 0.96, 0.18))
	draw_circle(hero_center, 110.0, Color(0.20, 0.92, 0.95, 0.16))
	draw_arc(hero_center, 120.0, 0.0, TAU, 80, Color("79fbff"), 5.0)
	draw_arc(hero_center, 111.0, 0.0, TAU, 80, Color(0.18, 0.52, 0.82, 0.95), 3.0)
	if ship_textures[selected] != null:
		var selected_size := Vector2.ONE * (168.0 - slide_ratio * 18.0)
		var selected_center := hero_center + Vector2(game.carousel_slide_offset, 0.0)
		var ship_color := Color(1.0, 1.0, 1.0, 1.0 - slide_ratio * 0.25) if unlocked else Color(0.16, 0.24, 0.28, 0.68)
		draw_texture_rect(ship_textures[selected], Rect2(selected_center - selected_size * 0.5, selected_size), false, ship_color)
	draw_home_circle_button(game.SHIP_PREV_BUTTON, "<", "", "")
	draw_home_circle_button(game.SHIP_NEXT_BUTTON, ">", "", "")
	if not unlocked:
		draw_lock_badge(game.SHIP_LOCK_BUTTON)

	var ship: Dictionary = game.PLAYER_CONFIG.get_ship(selected)
	draw_rounded_panel(Rect2(34.0, 500.0, 472.0, 164.0), Color(0.02, 0.67, 0.72, 0.94), Color("7fffff"), 24, 4)
	draw_menu_gradient_text(title_font, Vector2(34.0, 538.0), "ABILITIES", HORIZONTAL_ALIGNMENT_CENTER, 472.0, 27)
	var ability_x := [58.0, 204.0, 350.0]
	var ability_icons := ["H", "F", "S"]
	for ability_index in range(3):
		var ability_rect := Rect2(ability_x[ability_index], 550.0, 132.0, 92.0)
		draw_rounded_panel(ability_rect, Color(0.015, 0.18, 0.38, 0.96), Color("35e8ff"), 14, 3)
		draw_circle(ability_rect.position + Vector2(28.0, 31.0), 19.0, Color("075086"))
		draw_string(title_font, ability_rect.position + Vector2(9.0, 39.0), ability_icons[ability_index], HORIZONTAL_ALIGNMENT_CENTER, 38.0, 20, Color("fff07a"))
		draw_string(body_font, ability_rect.position + Vector2(8.0, 74.0), str(ship_stat_lines[selected][ability_index]), HORIZONTAL_ALIGNMENT_CENTER, 116.0, 9, Color("e8ffff"))
	var visible_ships: Array[int] = game.get_visible_ship_indices()
	for visible_index in range(visible_ships.size()):
		var dot_ship: int = visible_ships[visible_index]
		var dot_color := Color("fff07a") if dot_ship == selected else (Color("7fffff") if game.is_ship_unlocked(dot_ship) else Color(0.16, 0.26, 0.34, 0.9))
		draw_circle(Vector2(240.0 + visible_index * 20.0, 682.0), 5.0 if dot_ship == selected else 3.2, dot_color)
	var unlock_detail: String = str(ship.role) if unlocked else str(game.get_selected_ship_purchase_status())
	draw_string(body_font, Vector2(78.0, 696.0), unlock_detail, HORIZONTAL_ALIGNMENT_CENTER, 384.0, 11, Color("d9ffff") if unlocked else Color("fff07a"))

	draw_design_button(game.HOME_SCOREBOARD_BUTTON, "SCORE BOARD", "ENDLESS NIGHTMARE X%d" % game.difficulty_multiplier if game.difficulty_multiplier > 1 else "ENDLESS MODE", false, true)
	draw_design_button(game.HOME_COLLECTION_BUTTON, "QUEST", "%d / %d ITEMS" % [game.item_collection.size(), game.FINAL_LEVEL], false, true, chest_texture)
	var razor_trial: bool = game.is_razor_special_stage_available()
	var launch_detail := "UNLOCK RAZOR" if razor_trial else ("6 STAGES • ONE RUN" if game.difficulty_multiplier > 1 else "CHOOSE STAGE")
	draw_design_button(game.LAUNCH_BUTTON, "TRIAL" if razor_trial else "START", launch_detail, true, unlocked or razor_trial)
	draw_string(body_font, Vector2(18.0, 936.0), "SWIPE OR USE ARROWS   •   BEST %06d" % game.best_score, HORIZONTAL_ALIGNMENT_CENTER, 504.0, 12, Color("c8fbff"))
	draw_string(body_font, Vector2(18.0, 952.0), version_label, HORIZONTAL_ALIGNMENT_LEFT, 120.0, 10, Color("8fc9d8"))
	if game.purchase_overlay_visible:
		draw_purchase_confirmation()


func draw_underwater_home_background() -> void:
	draw_texture_rect(MENU_BACKGROUND_TEXTURE, Rect2(Vector2.ZERO, SCREEN_SIZE), false)
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.05, 0.11, 0.13))


func draw_rounded_panel(rect: Rect2, fill: Color, border: Color, radius: int, border_width: int = 2) -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = fill
	panel.border_color = border
	panel.set_border_width_all(border_width)
	panel.set_corner_radius_all(radius)
	panel.shadow_color = Color(0.0, 0.04, 0.12, 0.65)
	panel.shadow_size = 7
	panel.shadow_offset = Vector2(0.0, 6.0)
	draw_style_box(panel, rect)


func draw_menu_gradient_text(font: Font, position: Vector2, text: String, alignment: HorizontalAlignment, width: float, font_size: int, enabled: bool = true) -> void:
	var top_color := MENU_TEXT_TOP if enabled else Color("a9b9c2")
	var bottom_color := MENU_TEXT_BOTTOM if enabled else Color("657b87")
	var inner_stroke := MENU_TEXT_INNER_STROKE if enabled else Color("243b4a")
	var shadow_color := MENU_TEXT_SHADOW if enabled else Color("304d5b")
	var outer_size := clampi(roundi(float(font_size) * 0.13), 2, MENU_TEXT_STROKE_SIZE)
	var inner_size := clampi(outer_size - 2, 1, MENU_TEXT_INNER_STROKE_SIZE)
	var shadow_offset := MENU_TEXT_SHADOW_OFFSET * clampf(float(font_size) / 29.0, 0.62, 1.0)

	# วาดขอบดำของฐานล่างก่อน แล้วเติมความลึกทีละพิกเซลให้เป็น Drop Shadow แข็งแบบภาพต้นแบบ
	draw_string_outline(font, position + shadow_offset, text, alignment, width, font_size, outer_size + 1, MENU_TEXT_OUTER_STROKE)
	for depth in range(roundi(shadow_offset.y), 1, -1):
		var ratio := float(depth) / maxf(1.0, shadow_offset.y)
		var depth_offset := Vector2(roundf(shadow_offset.x * ratio), float(depth))
		draw_string(font, position + depth_offset, text, alignment, width, font_size, shadow_color)

	# ขอบสองชั้น: ดำนอกสุดและกรมท่าด้านใน ทำให้ทรงตัวอักษรคมเหมือนโลโก้พิกเซล
	draw_string_outline(font, position, text, alignment, width, font_size, outer_size, MENU_TEXT_OUTER_STROKE)
	draw_string_outline(font, position, text, alignment, width, font_size, inner_size, inner_stroke)

	# Gradient เฟดสั้น: ฟ้าอ่อนเป็นฐาน และขาวอมฟ้าเหลื่อมขึ้นด้านบนให้เห็นสองระดับชัดเจน
	# Keep both gradient layers nearly aligned so the glyph silhouette stays crisp.
	draw_string(font, position, text, alignment, width, font_size, bottom_color)
	draw_string(font, position + Vector2(0.0, -1.0), text, alignment, width, font_size, Color(top_color, 0.86))


func draw_readable_text(font: Font, position: Vector2, text: String, alignment: HorizontalAlignment, width: float, font_size: int, color: Color, outline_size: int = 2) -> void:
	draw_string_outline(font, position + Vector2(2.0, 3.0), text, alignment, width, font_size, outline_size + 1, Color(0.0, 0.02, 0.07, 0.72))
	draw_string_outline(font, position, text, alignment, width, font_size, outline_size, Color("031426"))
	draw_string(font, position, text, alignment, width, font_size, color)


func draw_coin(center: Vector2, radius: float) -> void:
	if coin_texture != null:
		draw_texture_rect(coin_texture, Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false, Color.WHITE)
		return
	draw_circle(center, radius, Color("ffbd18"))
	draw_arc(center, radius - 3.0, 0.0, TAU, 32, Color("fff075"), 3.0)


func draw_lock_badge(rect: Rect2) -> void:
	var center := rect.get_center()
	draw_circle(center, 58.0, Color(0.015, 0.07, 0.14, 0.88))
	draw_arc(center + Vector2(0.0, -12.0), 28.0, PI, TAU, 24, Color("fff07a"), 10.0)
	draw_rounded_panel(Rect2(center - Vector2(37.0, 8.0), Vector2(74.0, 58.0)), Color("f6b817"), Color("fff49a"), 12, 4)
	draw_circle(center + Vector2(0.0, 14.0), 7.0, Color("7b4500"))
	draw_rect(Rect2(center + Vector2(-3.0, 18.0), Vector2(6.0, 15.0)), Color("7b4500"))
	draw_string(title_font, Vector2(center.x - 70.0, center.y + 78.0), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, 140.0, 16, Color("fff07a"))


func draw_lock_icon(center: Vector2, icon_scale: float = 1.0) -> void:
	draw_arc(center + Vector2(0.0, -8.0) * icon_scale, 13.0 * icon_scale, PI, TAU, 20, Color("8298a4"), 5.0 * icon_scale)
	var body := Rect2(center - Vector2(17.0, 5.0) * icon_scale, Vector2(34.0, 28.0) * icon_scale)
	draw_rounded_panel(body, Color("334956"), Color("8298a4"), roundi(6.0 * icon_scale), maxi(1, roundi(2.0 * icon_scale)))
	draw_circle(center + Vector2(0.0, 6.0) * icon_scale, 3.5 * icon_scale, Color("101d25"))


func draw_design_button(rect: Rect2, label: String, detail: String, vertical: bool, enabled: bool, icon: Texture2D = null) -> void:
	var fill := Color("f2a918") if vertical and enabled else (Color("08aeb8") if enabled else Color("17475c"))
	var border := Color("fff09a") if vertical and enabled else (Color("7fffff") if enabled else Color("496979"))
	draw_rounded_panel(rect, fill, border, 22, 5)
	if vertical:
		var letters: Array[String] = []
		for character in label:
			letters.append(character)
		for letter_index in range(letters.size()):
			draw_menu_gradient_text(title_font, Vector2(rect.position.x, rect.position.y + 44.0 + letter_index * 29.0), letters[letter_index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 27, enabled)
		draw_string(body_font, Vector2(rect.position.x, rect.end.y - 16.0), detail, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 9, Color("fff4bf") if enabled else Color("78909c"))
	else:
		var text_inset := 24.0
		if icon != null:
			draw_texture_rect(icon, Rect2(rect.position + Vector2(16.0, 15.0), Vector2(56.0, 56.0)), false, Color.WHITE if enabled else Color(1.0, 1.0, 1.0, 0.42))
			text_inset = 82.0
		draw_menu_gradient_text(title_font, rect.position + Vector2(text_inset, 48.0), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - text_inset - 14.0, 27 if icon != null else 29, enabled)
		draw_string(body_font, rect.position + Vector2(text_inset + 2.0, 70.0), detail, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - text_inset - 16.0, 9 if icon != null else 10, Color("d8ffff") if enabled else Color("78909c"))


func draw_settings() -> void:
	draw_underwater_home_background()
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.42))
	draw_rounded_panel(Rect2(24.0, 74.0, 492.0, 812.0), Color(0.015, 0.22, 0.40, 0.97), Color("7fffff"), 26, 5)
	draw_menu_back()
	if settings_texture != null:
		draw_texture_rect(settings_texture, Rect2(54.0, 102.0, 62.0, 62.0), false, Color.WHITE)
	draw_menu_gradient_text(title_font, Vector2(126.0, 148.0), "SETTINGS", HORIZONTAL_ALIGNMENT_LEFT, 300.0, 32)
	draw_readable_text(story_font, Vector2(54.0, 210.0), "แตะหรือลากแถบเพื่อปรับระดับเสียง", HORIZONTAL_ALIGNMENT_CENTER, 432.0, 17, Color("d9fbff"))
	var labels := ["MASTER", "MUSIC", "EFFECT"]
	var descriptions := ["ระดับเสียงรวม", "เพลง Menu / Stage / Boss", "เสียงปุ่มและ Game Over"]
	for setting_index in range(game.SETTINGS_SLIDERS.size()):
		var slider: Rect2 = game.SETTINGS_SLIDERS[setting_index]
		var value: float = game.get_audio_setting(setting_index)
		draw_menu_gradient_text(title_font, Vector2(slider.position.x, slider.position.y - 34.0), labels[setting_index], HORIZONTAL_ALIGNMENT_LEFT, 250.0, 22)
		draw_readable_text(story_font, Vector2(slider.position.x, slider.position.y + 72.0), descriptions[setting_index], HORIZONTAL_ALIGNMENT_LEFT, slider.size.x, 14, Color("b8efff"))
		draw_rounded_panel(slider, Color("06253f"), Color("4a8295"), 18, 2)
		if value > 0.0:
			draw_rounded_panel(Rect2(slider.position, Vector2(slider.size.x * value, slider.size.y)), Color("10b8c6"), Color("7fffff"), 18, 2)
		var knob := Vector2(slider.position.x + slider.size.x * value, slider.get_center().y)
		draw_circle(knob, 16.0, Color("fff09a"))
		draw_arc(knob, 16.0, 0.0, TAU, 30, Color("ffffff"), 3.0)
		draw_string(title_font, Vector2(slider.end.x - 76.0, slider.position.y - 30.0), "%d%%" % roundi(value * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 76.0, 18, Color("fff09a"))
	draw_rounded_panel(game.CLEAR_USER_DATA_BUTTON, Color("6b2031"), Color("ff9aa8"), 18, 3)
	draw_menu_gradient_text(title_font, game.CLEAR_USER_DATA_BUTTON.position + Vector2(0.0, 38.0), "CLEAR USER DATA", HORIZONTAL_ALIGNMENT_CENTER, game.CLEAR_USER_DATA_BUTTON.size.x, 20)
	draw_readable_text(story_font, Vector2(54.0, 824.0), "ลบ Coin / ตัวละคร / Stage / Quest / Score และคืนค่าเสียงเริ่มต้น", HORIZONTAL_ALIGNMENT_CENTER, 432.0, 13, Color("ffd7dc"))
	if game.clear_data_confirmation_visible:
		draw_clear_data_confirmation()


func draw_clear_data_confirmation() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.80))
	draw_rounded_panel(Rect2(48.0, 300.0, 444.0, 370.0), Color("3d1730"), Color("ff9aa8"), 26, 5)
	draw_menu_gradient_text(title_font, Vector2(68.0, 362.0), "CLEAR ALL DATA?", HORIZONTAL_ALIGNMENT_CENTER, 404.0, 29)
	draw_readable_text(story_font, Vector2(78.0, 430.0), "ข้อมูลความคืบหน้า Coin ตัวละคร Quest และ Score ทั้งหมดจะถูกลบถาวร", HORIZONTAL_ALIGNMENT_CENTER, 384.0, 17, Color("ffe7ea"))
	draw_readable_text(story_font, Vector2(78.0, 490.0), "กู้คืนไม่ได้ กรุณายืนยันอีกครั้ง", HORIZONTAL_ALIGNMENT_CENTER, 384.0, 15, Color("ffb8c2"))
	draw_rounded_panel(game.CLEAR_DATA_CANCEL_BUTTON, Color("15516c"), Color("7fffff"), 15, 3)
	draw_menu_gradient_text(title_font, game.CLEAR_DATA_CANCEL_BUTTON.position + Vector2(0.0, 43.0), "CANCEL", HORIZONTAL_ALIGNMENT_CENTER, game.CLEAR_DATA_CANCEL_BUTTON.size.x, 18)
	draw_rounded_panel(game.CLEAR_DATA_CONFIRM_BUTTON, Color("9b263f"), Color("ff9aa8"), 15, 3)
	draw_menu_gradient_text(title_font, game.CLEAR_DATA_CONFIRM_BUTTON.position + Vector2(0.0, 43.0), "DELETE", HORIZONTAL_ALIGNMENT_CENTER, game.CLEAR_DATA_CONFIRM_BUTTON.size.x, 18)


func draw_purchase_confirmation() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.78))
	draw_rounded_panel(Rect2(48.0, 298.0, 444.0, 382.0), Color("043c67"), Color("7fffff"), 26, 5)
	var offer_index: int = game.get_selected_ship_offer_index()
	if offer_index < 0:
		return
	var offer: Dictionary = game.TURTLE_SHIPS[offer_index]
	draw_menu_gradient_text(title_font, Vector2(68.0, 354.0), "UNLOCK TURTLE?", HORIZONTAL_ALIGNMENT_CENTER, 404.0, 29)
	draw_menu_gradient_text(title_font, Vector2(68.0, 402.0), game.get_ship_display_name(game.selected_character), HORIZONTAL_ALIGNMENT_CENTER, 404.0, 22)
	if str(offer.unlock_type) == "coin":
		draw_coin(Vector2(205.0, 452.0), 20.0)
		draw_string(title_font, Vector2(236.0, 461.0), "%d" % int(offer.cost), HORIZONTAL_ALIGNMENT_LEFT, 100.0, 23, Color.WHITE)
	else:
		draw_string(body_font, Vector2(88.0, 461.0), "SPECIAL UNLOCK CONDITION", HORIZONTAL_ALIGNMENT_CENTER, 364.0, 15, Color("fff07a"))
	draw_string(body_font, Vector2(72.0, 510.0), game.get_selected_ship_purchase_status(), HORIZONTAL_ALIGNMENT_CENTER, 396.0, 13, Color("d8ffff"))
	draw_rounded_panel(game.PURCHASE_CANCEL_BUTTON, Color("15516c"), Color("7fffff"), 15, 3)
	draw_menu_gradient_text(title_font, game.PURCHASE_CANCEL_BUTTON.position + Vector2(0.0, 43.0), "CANCEL", HORIZONTAL_ALIGNMENT_CENTER, game.PURCHASE_CANCEL_BUTTON.size.x, 18)
	var can_buy: bool = game.can_buy_turtle_ship(offer_index)
	draw_rounded_panel(game.PURCHASE_CONFIRM_BUTTON, Color("f2a918") if can_buy else Color("384d5a"), Color("fff09a") if can_buy else Color("60727b"), 15, 3)
	draw_menu_gradient_text(title_font, game.PURCHASE_CONFIRM_BUTTON.position + Vector2(0.0, 43.0), "CONFIRM", HORIZONTAL_ALIGNMENT_CENTER, game.PURCHASE_CONFIRM_BUTTON.size.x, 18, can_buy)

func draw_home_circle_button(rect: Rect2, symbol: String, label: String, detail: String, enabled: bool = true) -> void:
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.5
	var border := Color("65efff") if enabled else Color(0.30, 0.36, 0.44, 0.72)
	var pulse: float = 1.0 + sin(game.menu_animation_time * 2.4 + center.x * 0.01) * 0.02
	draw_circle(center, radius * pulse, Color(0.045, 0.085, 0.18, 0.98) if enabled else Color(0.03, 0.04, 0.07, 0.94))
	draw_circle(center, radius * 0.76, Color(0.08, 0.35, 0.48, 0.20) if enabled else Color(0.08, 0.08, 0.10, 0.3))
	draw_arc(center, radius - 2.0, 0.0, TAU, 48, border, 3.0)
	draw_menu_gradient_text(title_font, Vector2(center.x - radius, center.y + 9.0), symbol, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 25 if radius < 55.0 else 34, enabled)
	if not label.is_empty():
		draw_string(title_font, Vector2(center.x - 54.0, center.y + radius + 21.0), label, HORIZONTAL_ALIGNMENT_CENTER, 108.0, 14, Color.WHITE if enabled else Color("718090"))
	if not detail.is_empty():
		draw_string(body_font, Vector2(center.x - 62.0, center.y + radius + 38.0), detail, HORIZONTAL_ALIGNMENT_CENTER, 124.0, 11, border)

func draw_menu_back() -> void:
	var center: Vector2 = game.MENU_BACK_BUTTON.get_center()
	draw_circle(center, game.MENU_BACK_BUTTON.size.x * 0.5, Color(0.05, 0.12, 0.24, 0.92))
	draw_arc(center, game.MENU_BACK_BUTTON.size.x * 0.5 - 2.0, 0.0, TAU, 32, Color("65efff"), 2.0)
	draw_menu_gradient_text(title_font, Vector2(center.x - 32.0, center.y + 8.0), "<", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 22)


func draw_stage_select() -> void:
	var progress: float = clampf(game.stage_popup_progress, 0.0, 1.0)
	draw_underwater_home_background()
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.42 + progress * 0.25))
	var popup_offset := Vector2(0.0, (1.0 - progress) * 96.0)
	draw_set_transform(popup_offset)
	draw_rounded_panel(Rect2(22.0, 78.0, 496.0, 824.0), Color(0.015, 0.22, 0.40, 0.97), Color("7fffff"), 26, 5)
	draw_menu_back()
	draw_menu_gradient_text(title_font, Vector2(40.0, 128.0), "SELECT STAGE", HORIZONTAL_ALIGNMENT_LEFT, 330.0, 29)
	draw_string(body_font, Vector2(40.0, 156.0), "Choose a mission, then press START", HORIZONTAL_ALIGNMENT_LEFT, 400.0, 13, Color("b8fbff"))
	for i in range(game.STAGE_SELECT_COUNT):
		var card: Rect2 = game.STAGE_CARDS[i]
		var unlocked: bool = game.is_stage_unlocked(i + 1)
		var selected: bool = unlocked and i + 1 == game.selected_stage
		var border := Color("65efff") if selected else (Color(0.26, 0.52, 0.65, 0.65) if unlocked else Color(0.20, 0.23, 0.30, 0.75))
		draw_rect(card, Color(0.055, 0.11, 0.21, 0.98) if selected else (Color(0.025, 0.055, 0.12, 0.95) if unlocked else Color(0.018, 0.025, 0.045, 0.96)))
		draw_rect(card, border, false, 3.0 if selected else 1.0)
		draw_circle(card.position + Vector2(42.0, 50.0), 24.0, Color(0.12, 0.52, 0.68, 0.30) if unlocked else Color(0.12, 0.13, 0.16, 0.7))
		draw_menu_gradient_text(title_font, card.position + Vector2(18.0, 59.0), "%d" % (i + 1) if unlocked else "X", HORIZONTAL_ALIGNMENT_CENTER, 48.0, 22, unlocked)
		var stage_heading := "STAGE %d  •  %s" % [i + 1, game.get_story_boss_name(i + 1)] if unlocked else "STAGE %d" % (i + 1)
		draw_string(story_font, card.position + Vector2(82.0, 38.0), stage_heading, HORIZONTAL_ALIGNMENT_LEFT, 260.0, 19, Color.WHITE if unlocked else Color("647080"))
		var detail := ("%s  •  BOSS TRIAL" if i + 1 == game.SPECIAL_BOSS_LEVEL else "%s  •  3 PHASES") % game.get_story_stage_area(i + 1) if unlocked else "LOCKED  •  CLEAR STAGE %d" % i
		draw_string(story_font, card.position + Vector2(82.0, 70.0), detail, HORIZONTAL_ALIGNMENT_LEFT, 350.0, 13, Color("8eeaff") if unlocked else Color("536070"))
		if selected:
			draw_menu_gradient_text(title_font, card.position + Vector2(340.0, 61.0), "READY", HORIZONTAL_ALIGNMENT_CENTER, 96.0, 15)
	draw_rounded_panel(game.STAGE_START_BUTTON, Color("f2a918"), Color("fff09a"), 18, 4)
	draw_menu_gradient_text(title_font, game.STAGE_START_BUTTON.position + Vector2(0.0, 45.0), "START STAGE %d" % game.selected_stage, HORIZONTAL_ALIGNMENT_CENTER, game.STAGE_START_BUTTON.size.x, 19)
	draw_set_transform(Vector2.ZERO)

func draw_collection_select() -> void:
	draw_underwater_home_background()
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.48))
	draw_menu_back()
	draw_menu_gradient_text(title_font, Vector2(0.0, 83.0), "QUEST ARCHIVE", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_SIZE.x, 30)
	draw_readable_text(story_font, Vector2(24.0, 124.0), "แตะ Folder ที่ปลดล็อกเพื่ออ่านข้อมูลและเปิดงานวิจัยต้นทาง", HORIZONTAL_ALIGNMENT_CENTER, 492.0, 14, Color("d9fbff"))
	for stage in range(1, game.FINAL_LEVEL + 1):
		var card: Rect2 = game.STAGE_CARDS[stage - 1]
		var found: bool = game.item_collection.has(stage)
		draw_quest_folder(card, stage, found)
	if game.quest_open_stage > 0:
		draw_quest_folder_detail()


func draw_quest_folder(card: Rect2, stage: int, found: bool) -> void:
	var entry: Dictionary = game.RESEARCH_CONFIG.get_entry(stage)
	var fill := Color("0b9db8") if found else Color("17394d")
	var dark_fill := Color("076579") if found else Color("102a38")
	var border := Color("7fffff") if found else Color("385769")
	# แฟ้มมีแถบ Tab ด้านบนและตัว Folder หลักที่กดเปิดได้
	draw_rounded_panel(Rect2(card.position + Vector2(12.0, 4.0), Vector2(154.0, 30.0)), dark_fill, border, 9, 2)
	draw_rounded_panel(Rect2(card.position + Vector2(0.0, 22.0), Vector2(card.size.x, 78.0)), fill, border, 13, 3 if found else 2)
	draw_readable_text(title_font, card.position + Vector2(18.0, 20.0), "FILE %02d" % stage, HORIZONTAL_ALIGNMENT_LEFT, 130.0, 13, Color("efffff") if found else Color("91a5ae"), 2)
	draw_readable_text(story_font, card.position + Vector2(24.0, 60.0), str(entry.get("folder", "UNKNOWN")) if found else "แฟ้มข้อมูลยังถูกล็อก", HORIZONTAL_ALIGNMENT_LEFT, 310.0, 18, Color.WHITE if found else Color("a4b5bd"), 2)
	draw_readable_text(story_font, card.position + Vector2(24.0, 88.0), "แตะเพื่อเปิดอ่าน" if found else "เคลียร์บทที่ %d เพื่อปลดล็อก" % stage, HORIZONTAL_ALIGNMENT_LEFT, 300.0, 13, Color("e8ffff") if found else Color("91a5ae"), 2)
	if found:
		draw_menu_gradient_text(title_font, card.position + Vector2(346.0, 75.0), "OPEN", HORIZONTAL_ALIGNMENT_CENTER, 96.0, 16)
	else:
		draw_lock_icon(card.position + Vector2(400.0, 62.0), 0.72)


func draw_quest_folder_detail() -> void:
	var entry: Dictionary = game.get_open_research_entry()
	if entry.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.015, 0.05, 0.86))
	draw_rounded_panel(Rect2(28.0, 118.0, 484.0, 748.0), Color("063d63"), Color("7fffff"), 24, 5)
	draw_menu_back()
	draw_rounded_panel(Rect2(54.0, 142.0, 186.0, 42.0), Color("087b91"), Color("7fffff"), 10, 2)
	draw_readable_text(title_font, Vector2(68.0, 171.0), "RESEARCH %s" % str(entry.get("research_number", game.quest_open_stage)), HORIZONTAL_ALIGNMENT_LEFT, 220.0, 16, Color.WHITE)
	var title_lines := wrap_text_by_chars(str(entry.title), 38)
	draw_text_lines(story_font, Vector2(58.0, 226.0), title_lines, 420.0, 20, 29.0, Color.WHITE)
	var citation_y := 238.0 + title_lines.size() * 29.0
	draw_readable_text(story_font, Vector2(58.0, citation_y), str(entry.citation), HORIZONTAL_ALIGNMENT_LEFT, 420.0, 13, Color("b8f4ff"), 2)
	draw_readable_text(story_font, Vector2(58.0, citation_y + 44.0), "สรุปเนื้อหา", HORIZONTAL_ALIGNMENT_LEFT, 420.0, 18, Color("fff29a"), 2)
	var summary_lines := wrap_text_by_chars(str(entry.summary), 43)
	draw_text_lines(story_font, Vector2(58.0, citation_y + 78.0), summary_lines, 420.0, 16, 25.0, Color("e8fbff"))
	var fragment_locked := entry.has("fragment_group") and not bool(entry.get("fragment_complete", false))
	draw_readable_text(story_font, Vector2(58.0, 724.0), "เก็บชิ้นส่วน 3-A และ 3-B เพื่อเปิดฉบับเต็ม" if fragment_locked else "ปุ่มด้านล่างจะเปิด DOI หรือคลังงานวิจัยของสถาบันต้นทาง", HORIZONTAL_ALIGNMENT_CENTER, 420.0, 12, Color("fff09a") if fragment_locked else Color("c8efff"), 2)
	draw_rounded_panel(game.QUEST_READ_BUTTON, Color("263b4d") if fragment_locked else Color("f2a918"), Color("6f8793") if fragment_locked else Color("fff09a"), 17, 4)
	draw_menu_gradient_text(title_font, game.QUEST_READ_BUTTON.position + Vector2(0.0, 45.0), "NEED BOTH PARTS" if fragment_locked else "READ SOURCE", HORIZONTAL_ALIGNMENT_CENTER, game.QUEST_READ_BUTTON.size.x, 17 if fragment_locked else 20, not fragment_locked)


func wrap_text_by_chars(text: String, max_characters: int) -> Array[String]:
	var result: Array[String] = []
	var current := ""
	for word in text.split(" ", false):
		var candidate := word if current.is_empty() else current + " " + word
		if candidate.length() > max_characters and not current.is_empty():
			result.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		result.append(current)
	return result


func draw_text_lines(font: Font, start: Vector2, lines: Array[String], width: float, font_size: int, line_height: float, color: Color) -> void:
	for line_index in range(lines.size()):
		draw_readable_text(font, start + Vector2(0.0, line_index * line_height), lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, width, font_size, color, 2)


func draw_scoreboard() -> void:
	draw_underwater_home_background()
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.0, 0.02, 0.08, 0.38))
	draw_rounded_panel(Rect2(24.0, 74.0, 492.0, 836.0), Color(0.015, 0.22, 0.40, 0.97), Color("7fffff"), 26, 5)
	draw_menu_back()
	draw_menu_gradient_text(title_font, Vector2(38.0, 128.0), "SCORE BOARD", HORIZONTAL_ALIGNMENT_LEFT, 350.0, 31)
	var nightmare_endless: bool = game.difficulty_multiplier > 1
	var active_scores: Array[int] = game.get_active_endless_scores()
	draw_string(body_font, Vector2(38.0, 158.0), ("ENDLESS NIGHTMARE X%d" % game.difficulty_multiplier if nightmare_endless else "ENDLESS MODE") + "  •  LOCAL TOP SCORES", HORIZONTAL_ALIGNMENT_LEFT, 420.0, 13, Color("ffb2e8") if nightmare_endless else Color("b8fbff"))
	draw_string(body_font, Vector2(38.0, 180.0), "VIPER: %d / %d" % [mini(game.get_endless_best_score(), game.VIPER_ENDLESS_UNLOCK_SCORE), game.VIPER_ENDLESS_UNLOCK_SCORE], HORIZONTAL_ALIGNMENT_LEFT, 420.0, 12, Color("fff07a") if not game.is_ship_unlocked(4) else Color("65ff9a"))
	draw_rounded_panel(Rect2(56.0, 190.0, 428.0, 118.0), Color("07386d"), Color("fff09a"), 18, 4)
	draw_string(body_font, Vector2(72.0, 224.0), "PERSONAL BEST", HORIZONTAL_ALIGNMENT_CENTER, 396.0, 15, Color("b8fbff"))
	draw_string(title_font, Vector2(72.0, 280.0), "%08d" % game.get_active_endless_best_score(), HORIZONTAL_ALIGNMENT_CENTER, 396.0, 37, Color("fff07a"))
	for rank_index in range(game.MAX_SCOREBOARD_ENTRIES):
		var row := Rect2(62.0, 334.0 + rank_index * 75.0, 416.0, 58.0)
		draw_rounded_panel(row, Color("06315b") if rank_index % 2 == 0 else Color("052b50"), Color(0.25, 0.82, 0.90, 0.48), 12, 2)
		var rank_score: int = active_scores[rank_index] if rank_index < active_scores.size() else 0
		draw_string(title_font, row.position + Vector2(18.0, 38.0), "#%d" % (rank_index + 1), HORIZONTAL_ALIGNMENT_LEFT, 70.0, 19, Color("fff07a") if rank_index == 0 else Color.WHITE)
		draw_string(title_font, row.position + Vector2(104.0, 38.0), "%08d" % rank_score if rank_score > 0 else "--------", HORIZONTAL_ALIGNMENT_RIGHT, 282.0, 20, Color.WHITE if rank_score > 0 else Color("66889a"))
	draw_rounded_panel(game.SCOREBOARD_START_BUTTON, Color("f2a918"), Color("fff09a"), 18, 4)
	draw_menu_gradient_text(title_font, game.SCOREBOARD_START_BUTTON.position + Vector2(0.0, 38.0), "START ENDLESS NM" if nightmare_endless else "START ENDLESS", HORIZONTAL_ALIGNMENT_CENTER, game.SCOREBOARD_START_BUTTON.size.x, 19 if nightmare_endless else 21)
	draw_string(body_font, game.SCOREBOARD_START_BUTTON.position + Vector2(0.0, 64.0), "SURVIVE • DEFEAT BOSSES • SET A HIGH SCORE", HORIZONTAL_ALIGNMENT_CENTER, game.SCOREBOARD_START_BUTTON.size.x, 9, Color("fff4bf"))


func draw_hud() -> void:
	var panel_fill := Color(0.018, 0.04, 0.10, 0.84)
	var panel_border := Color(0.30, 0.78, 0.94, 0.38)
	draw_rect(Rect2(12.0, 14.0, 122.0, 66.0), panel_fill)
	draw_rect(Rect2(12.0, 14.0, 122.0, 66.0), panel_border, false, 1.0)
	draw_string(body_font, Vector2(22.0, 35.0), "SCORE", HORIZONTAL_ALIGNMENT_LEFT, 104.0, 11, Color("76dfff"))
	draw_string(title_font, Vector2(21.0, 65.0), "%06d" % game.score, HORIZONTAL_ALIGNMENT_LEFT, 106.0, 20, Color.WHITE)

	draw_rect(Rect2(144.0, 14.0, 126.0, 66.0), panel_fill)
	draw_rect(Rect2(144.0, 14.0, 126.0, 66.0), panel_border, false, 1.0)
	var mode_label := "ENDLESS" if game.endless_mode else ("SPECIAL" if game.special_stage_mode else "STAGE %d" % game.level)
	if game.difficulty_multiplier > 1 and not game.special_stage_mode:
		mode_label += " NM×%d" % game.difficulty_multiplier
	draw_string(body_font, Vector2(144.0, 36.0), mode_label, HORIZONTAL_ALIGNMENT_CENTER, 126.0, 11, Color("ff9de1") if game.difficulty_multiplier > 1 else Color("76dfff"))
	draw_string(title_font, Vector2(144.0, 65.0), "BOSS #%d" % (game.endless_bosses_defeated + 1) if game.endless_mode else ("BOSS %d" % game.SPECIAL_BOSS_LEVEL if game.special_stage_mode else "PHASE %d / %d" % [game.stage_level, game.LEVELS_PER_STAGE]), HORIZONTAL_ALIGNMENT_CENTER, 126.0, 15, Color.WHITE)

	draw_rect(Rect2(280.0, 14.0, 154.0, 66.0), panel_fill)
	draw_rect(Rect2(280.0, 14.0, 154.0, 66.0), panel_border, false, 1.0)
	var health_ratio: float = clampf(float(game.player_health) / float(game.max_player_health), 0.0, 1.0)
	draw_string(body_font, Vector2(292.0, 35.0), "HULL  %d%%" % roundi(health_ratio * 100.0), HORIZONTAL_ALIGNMENT_LEFT, 130.0, 11, Color("d8ffff"))
	draw_rect(Rect2(292.0, 49.0, 130.0, 12.0), Color(0.08, 0.14, 0.22, 0.94))
	draw_rect(Rect2(292.0, 49.0, 130.0 * health_ratio, 12.0), Color("62f5ff"))
	draw_rect(Rect2(292.0, 49.0, 130.0, 12.0), Color(0.65, 0.95, 1.0, 0.65), false, 1.0)

	draw_rect(game.PAUSE_BUTTON, Color(0.035, 0.085, 0.16, 0.94))
	draw_rect(game.PAUSE_BUTTON, Color("76dfff"), false, 1.5)
	draw_string(body_font, game.PAUSE_BUTTON.position + Vector2(0.0, 31.0), "II", HORIZONTAL_ALIGNMENT_CENTER, game.PAUSE_BUTTON.size.x, 18, Color.WHITE)

	if not game.boss_active:
		var stage_start: int = game.score_start_for_level()
		var target_span: int = maxi(1, game.score_target_for_level() - stage_start)
		var boss_progress: float = clampf(float(game.score - stage_start) / float(target_span), 0.0, 1.0)
		var gauge := Rect2(0.0, 174.0, 22.0, 510.0)
		draw_rect(gauge, Color(0.015, 0.03, 0.065, 0.92))
		draw_rect(Rect2(gauge.position + Vector2(2.0, gauge.size.y - (gauge.size.y - 4.0) * boss_progress - 2.0), Vector2(gauge.size.x - 4.0, (gauge.size.y - 4.0) * boss_progress)), Color("65efff"))
		draw_rect(gauge, Color(0.48, 0.91, 1.0, 0.62), false, 1.0)
		draw_circle(Vector2(11.0, 174.0), 10.0, Color("ffe66d") if boss_progress >= 1.0 else Color("2b5368"))
		var gauge_label := "BOSS #%d" % (game.endless_bosses_defeated + 1) if game.endless_mode else ("SPECIAL • %s" % game.get_story_boss_name() if game.special_stage_mode else "%s  P%d/3" % [game.get_story_boss_name(), game.stage_level])
		draw_string(story_font, Vector2(27.0, 192.0), gauge_label, HORIZONTAL_ALIGNMENT_LEFT, 170.0, 11, Color("ffe66d"))
	elif game.enemies.size() > 0:
		for enemy in game.enemies:
			if enemy.kind == game.BOSS_KIND and enemy.special_timer > 0.0:
				var alert_alpha: float = 0.55 + sin(game.menu_animation_time * 12.0) * 0.30
				draw_rect(Rect2(154.0, 91.0, 232.0, 34.0), Color(0.32, 0.025, 0.11, 0.82))
				draw_rect(Rect2(154.0, 91.0, 232.0, 34.0), Color(1.0, 0.35, 0.55, alert_alpha), false, 2.0)
				draw_string(title_font, Vector2(154.0, 115.0), "DODGE!", HORIZONTAL_ALIGNMENT_CENTER, 232.0, 16, Color.WHITE)
				break

	var slow_active: bool = game.is_slow_mode_active()
	var slow_center: Vector2 = game.SLOW_BUTTON.get_center()
	draw_circle(slow_center, game.SLOW_BUTTON.size.x * 0.5, Color("1599ad") if slow_active else Color(0.035, 0.085, 0.16, 0.90))
	draw_arc(slow_center, game.SLOW_BUTTON.size.x * 0.5 - 2.0, 0.0, TAU, 40, Color("a8f8ff"), 2.0)
	draw_string(body_font, Vector2(slow_center.x - 38.0, slow_center.y + 6.0), "SLOW", HORIZONTAL_ALIGNMENT_CENTER, 76.0, 13, Color.WHITE)
	if slow_active:
		draw_arc(game.player_pos, game.PLAYER_RADIUS, 0.0, TAU, 32, Color("7df9ff"), 1.5)
		draw_circle(game.player_pos, 3.0, Color("d8ffff"))

	if not String(game.player_stats.get("special", "")).is_empty():
		var ready: bool = game.special_cooldown_timer <= 0.0
		var special_center: Vector2 = game.SPECIAL_BUTTON.get_center()
		draw_circle(special_center, game.SPECIAL_BUTTON.size.x * 0.5, Color("a657c9") if ready else Color(0.11, 0.07, 0.17, 0.92))
		draw_arc(special_center, game.SPECIAL_BUTTON.size.x * 0.5 - 2.0, 0.0, TAU, 48, Color("ffd2fa") if ready else Color("80698c"), 3.0)
		var special_label := "SKILL" if ready else "%.1f" % game.special_cooldown_timer
		draw_string(body_font, Vector2(special_center.x - 43.0, special_center.y + 6.0), special_label, HORIZONTAL_ALIGNMENT_CENTER, 86.0, 14, Color.WHITE)

	if game.tutorial_visible:
		draw_first_stage_tutorial()


func draw_first_stage_tutorial() -> void:
	draw_rect(Rect2(26.0, 214.0, 278.0, 112.0), Color(0.018, 0.05, 0.12, 0.94))
	draw_rect(Rect2(26.0, 214.0, 278.0, 112.0), Color("65efff"), false, 2.0)
	draw_string(title_font, Vector2(42.0, 242.0), "BOSS GAUGE", HORIZONTAL_ALIGNMENT_LEFT, 240.0, 17, Color("eafcff"))
	draw_string(body_font, Vector2(42.0, 269.0), "Defeat enemies to fill the bar", HORIZONTAL_ALIGNMENT_LEFT, 240.0, 14, Color("8eeaff"))
	draw_string(body_font, Vector2(42.0, 292.0), "A boss appears when it reaches the top", HORIZONTAL_ALIGNMENT_LEFT, 244.0, 13, Color("d8ffff"))
	draw_line(Vector2(26.0, 276.0), Vector2(14.0, 276.0), Color("65efff"), 3.0)
	draw_string(body_font, Vector2(105.0, 842.0), "DRAG TO MOVE  ·  HOLD SLOW TO DODGE  ·  TAP SKILL", HORIZONTAL_ALIGNMENT_CENTER, 330.0, 12, Color("d8ffff"))

func draw_overlay(heading: String, subheading: String) -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.01, 0.015, 0.06, 0.78))
	draw_rect(Rect2(40.0, 330.0, 460.0, 250.0), Color(0.03, 0.06, 0.16, 0.96))
	draw_rect(Rect2(40.0, 330.0, 460.0, 250.0), Color(0.29, 0.88, 1.0, 0.68), false, 2.0)
	draw_string(title_font, Vector2(40.0, 415.0), heading, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 34, Color("eafcff"))
	draw_string(body_font, Vector2(40.0, 480.0), subheading, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 18, Color("8eeaff"))


func draw_pause_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.01, 0.015, 0.06, 0.84))
	draw_rounded_panel(Rect2(62.0, 270.0, 416.0, 414.0), Color(0.025, 0.07, 0.16, 0.98), Color("65efff"), 25, 4)
	draw_menu_gradient_text(title_font, Vector2(62.0, 340.0), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 416.0, 34)
	var buttons := [
		[game.PAUSE_RESUME_BUTTON, "RESUME", Color("087b91")],
		[game.PAUSE_RESTART_BUTTON, "RESTART", Color("9a6410")],
		[game.PAUSE_MENU_BUTTON, "MENU", Color("7e2444")]
	]
	for button_data in buttons:
		var rect: Rect2 = button_data[0]
		draw_rounded_panel(rect, button_data[2], Color("dfffff"), 15, 3)
		draw_menu_gradient_text(title_font, rect.position + Vector2(0.0, 44.0), button_data[1], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20)
	var warning := "ENDLESS rewards and score are kept" if game.endless_mode else "Leaving now gives no reward from this Stage"
	draw_string(body_font, Vector2(82.0, 657.0), warning, HORIZONTAL_ALIGNMENT_CENTER, 376.0, 13, Color("ffe391") if game.endless_mode else Color("ff9fb5"))


func draw_summary() -> void:
	var heading := "ENDLESS OVER" if game.endless_mode else ("VICTORY" if game.victory else "MISSION FAILED")
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.01, 0.015, 0.06, 0.82))
	draw_rect(Rect2(40.0, 278.0, 460.0, 400.0), Color(0.03, 0.06, 0.16, 0.96))
	draw_rect(Rect2(40.0, 278.0, 460.0, 400.0), Color(0.29, 0.88, 1.0, 0.68), false, 2.0)
	draw_string(title_font, Vector2(40.0, 353.0), heading, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 30, Color("eafcff"))
	var mode_detail := "BOSSES DEFEATED  %d" % game.endless_bosses_defeated if game.endless_mode else "STAGE %d  PHASE %d / %d" % [game.level, game.stage_level, game.LEVELS_PER_STAGE]
	draw_string(body_font, Vector2(40.0, 410.0), mode_detail, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 18, Color("8eeaff"))
	draw_string(title_font, Vector2(40.0, 479.0), "SCORE  %06d" % game.score, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 27, Color.WHITE)
	draw_string(body_font, Vector2(40.0, 527.0), "BEST  %08d" % (game.get_endless_best_score() if game.endless_mode else game.best_score), HORIZONTAL_ALIGNMENT_CENTER, 460.0, 20, Color("ffe66d"))
	draw_string(body_font, Vector2(40.0, 560.0), "COIN  %d" % game.sea_tokens, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 18, Color("ffe66d"))
	draw_string(body_font, Vector2(40.0, 591.0), "Returning to menu in %d" % ceili(game.summary_timer), HORIZONTAL_ALIGNMENT_CENTER, 460.0, 17, Color("8eeaff"))
	draw_string(body_font, Vector2(40.0, 630.0), "Tap anywhere to continue", HORIZONTAL_ALIGNMENT_CENTER, 460.0, 16, Color(0.68, 0.78, 0.90, 0.9))


func draw_turtle_shop() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color(0.01, 0.015, 0.06, 0.78))
	draw_menu_back()
	if shopkeeper_texture != null:
		draw_texture_rect(shopkeeper_texture, Rect2(340.0, 82.0, 76.0, 76.0), false)
	draw_string(body_font, Vector2(220.0, 145.0), "BULWARK SHOPKEEPER", HORIZONTAL_ALIGNMENT_RIGHT, 196.0, 12, Color("ffb454"))
	draw_string(title_font, Vector2(24.0, 83.0), "TURTLE SHOP", HORIZONTAL_ALIGNMENT_LEFT, 390.0, 30, Color("eafcff"))
	draw_string(title_font, Vector2(24.0, 125.0), "COIN  %d" % game.sea_tokens, HORIZONTAL_ALIGNMENT_LEFT, 390.0, 18, Color("ffe66d"))
	for ship_offer_index in range(game.TURTLE_SHIPS.size()):
		var ship_offer: Dictionary = game.TURTLE_SHIPS[ship_offer_index]
		var card: Rect2 = game.SHOP_SHIP_CARDS[ship_offer_index]
		var selected: bool = ship_offer_index == game.shop_selected_ship
		var owned: bool = game.is_ship_unlocked(int(ship_offer.ship_index))
		var coin_offer: bool = str(ship_offer.unlock_type) == "coin"
		var border := Color("65efff") if selected else Color(0.25, 0.42, 0.58, 0.55)
		draw_rect(card, Color(0.055, 0.09, 0.19, 0.98) if selected else Color(0.025, 0.04, 0.10, 0.92))
		draw_rect(card, border, false, 3.0 if selected else 1.0)
		if ship_textures[int(ship_offer.ship_index)] != null:
			draw_texture_rect(ship_textures[int(ship_offer.ship_index)], Rect2(card.position + Vector2(12.0, 8.0), Vector2(84.0, 84.0)), false, Color.WHITE if coin_offer or owned else Color(0.25, 0.29, 0.34, 0.9))
		draw_string(title_font, card.position + Vector2(110.0, 35.0), ship_offer.name, HORIZONTAL_ALIGNMENT_LEFT, 190.0, 20, Color.WHITE if owned or str(ship_offer.unlock_type) == "coin" else Color("718090"))
		var status: String = "OWNED"
		if not owned:
			match str(ship_offer.unlock_type):
				"coin":
					status = "%d COIN" % int(ship_offer.cost)
				"special_stage":
					status = "SPECIAL STAGE"
				_:
					status = "ENDLESS 30,000"
		draw_string(body_font, card.position + Vector2(110.0, 70.0), status, HORIZONTAL_ALIGNMENT_LEFT, 260.0, 15, Color("ffe66d") if owned or str(ship_offer.unlock_type) == "coin" else Color("718090"))
	var selected_ship_offer: Dictionary = game.TURTLE_SHIPS[game.shop_selected_ship]
	var already_owned: bool = game.is_ship_unlocked(int(selected_ship_offer.ship_index))
	var buy_label: String = "OWNED" if already_owned else "BUY"
	draw_home_circle_button(game.SHOP_BUY_BUTTON, "$", buy_label, "%d COIN" % int(selected_ship_offer.cost), game.can_buy_turtle_ship(game.shop_selected_ship))
	draw_string(body_font, Vector2(24.0, 780.0), "Earn 1 Coin for every Boss defeat", HORIZONTAL_ALIGNMENT_LEFT, 492.0, 15, Color("8eeaff"))

extends Node2D

const GAME_SIZE := Vector2(540.0, 960.0)
const PLAYER_RADIUS := 18.0
const BOSS_KIND := 3
# จำนวนด่านและคะแนนที่ต้องถึงเพื่อเรียกบอส: ด่าน 1-5 ใช้ 1-5 เท่าของค่านี้
const FINAL_LEVEL := 5
const LEVEL_SCORE_STEP := 5000
const LEVELS_PER_STAGE := 3
const ENDLESS_BOSS_SCORE_STEP := 5000
const MAX_SCOREBOARD_ENTRIES := 5
const COINS_PER_BOSS := 1
const SEA_TOKENS_PER_CLEAR := 3 # compatibility: Story มีบอส 3 Phase จึงได้รวม 3 Coin
const VIPER_ENDLESS_UNLOCK_SCORE := 30000
const SPECIAL_BOSS_LEVEL := 6
const SPECIAL_STAGE_SCORE_TARGET := 5000
# บอสแต่ละด่านมี 3 Phase ตามเนื้อเรื่อง โดยแต่ละ Phase ใช้เกจคะแนนและการต่อสู้หนึ่งรอบ
const BOSS_PHASE_2_RATIO := 0.75
const BOSS_SPECIAL_RATIO := 0.5
const BOSS_SPECIAL_WINDUP := 0.9
const BOSS_SPECIAL_COOLDOWN := 5.5
const BOSS_SPECIAL_PROJECTILES := 18
const BOSS_HP_BASE := 50
const BOSS_HP_PER_LEVEL := 14
const BOSS_DAMAGE_RATIO := 0.20
const POTION_HEAL_RATIO := 0.25
# โหมดเคลื่อนที่ช้า: กด Shift หรือกดปุ่ม SLOW ค้างบนจอสัมผัส
const SLOW_SPEED_MULTIPLIER := 0.42
const SLOW_BUTTON := Rect2(18.0, 866.0, 76.0, 76.0)
# เวลาที่หน้าสรุปคะแนนแสดงก่อนกลับเมนู (วินาที)
const SUMMARY_DURATION := 6.0
# รายการบทสนทนาแต่ละด่านอยู่ในไฟล์นี้; หน้าตาอยู่ที่ ui/dialogue_overlay.tscn
const DIALOGUE_CONFIG = preload("res://scripts/dialogue_config.gd")
const RESEARCH_CONFIG = preload("res://scripts/research_config.gd")
const PLAYER_CONFIG = preload("res://scripts/player_config.gd")
const VISUAL_CONFIG = preload("res://scripts/visual_config.gd")
const PAUSE_BUTTON := Rect2(448.0, 16.0, 76.0, 48.0)
const STAGE_CARDS := [
	Rect2(40.0, 174.0, 460.0, 100.0),
	Rect2(40.0, 286.0, 460.0, 100.0),
	Rect2(40.0, 398.0, 460.0, 100.0),
	Rect2(40.0, 510.0, 460.0, 100.0),
	Rect2(40.0, 622.0, 460.0, 100.0)
]
const SHOP_SHIP_CARDS := [
	Rect2(24.0, 166.0, 408.0, 100.0),
	Rect2(24.0, 278.0, 408.0, 100.0),
	Rect2(24.0, 390.0, 408.0, 100.0),
	Rect2(24.0, 502.0, 408.0, 100.0)
]
const HOME_SHIP_BUTTON := Rect2(24.0, 716.0, 72.0, 72.0)
const HOME_STAGE_BUTTON := Rect2(360.0, 700.0, 146.0, 198.0)
const HOME_SCOREBOARD_BUTTON := Rect2(34.0, 700.0, 300.0, 86.0)
const HOME_SHOP_BUTTON := HOME_SCOREBOARD_BUTTON
const HOME_COLLECTION_BUTTON := Rect2(34.0, 808.0, 300.0, 86.0)
const LAUNCH_BUTTON := Rect2(360.0, 700.0, 146.0, 198.0)
const MENU_BACK_BUTTON := Rect2(452.0, 24.0, 64.0, 64.0)
const SHIP_PREV_BUTTON := Rect2(22.0, 330.0, 72.0, 72.0)
const SHIP_NEXT_BUTTON := Rect2(446.0, 330.0, 72.0, 72.0)
const CAROUSEL_SWIPE_AREA := Rect2(0.0, 150.0, 540.0, 430.0)
const SHIP_LOCK_BUTTON := Rect2(208.0, 278.0, 124.0, 124.0)
const PURCHASE_CANCEL_BUTTON := Rect2(82.0, 588.0, 174.0, 68.0)
const PURCHASE_CONFIRM_BUTTON := Rect2(284.0, 588.0, 174.0, 68.0)
const STAGE_START_BUTTON := Rect2(150.0, 808.0, 240.0, 72.0)
const SCOREBOARD_START_BUTTON := Rect2(120.0, 792.0, 300.0, 82.0)
const QUEST_READ_BUTTON := Rect2(104.0, 760.0, 332.0, 72.0)
const SHOP_BUY_BUTTON := Rect2(424.0, 648.0, 96.0, 96.0)
const SPECIAL_BUTTON := Rect2(438.0, 856.0, 86.0, 86.0)
const PLAYER_SCENES: Array[PackedScene] = [
	preload("res://characters/player/player.tscn"),
	preload("res://characters/player/swift.tscn"),
	preload("res://characters/player/titan.tscn"),
	preload("res://characters/player/razor.tscn"),
	preload("res://characters/player/viper.tscn")
]
const PLAYER_VISUAL_KEYS := ["falcon", "swift", "titan", "razor", "viper"]
const ENEMY_VISUAL_KEYS := ["scout", "striker", "tank"]
const ENEMY_SCENES: Array[PackedScene] = [
	preload("res://characters/enemies/scout.tscn"),
	preload("res://characters/enemies/striker.tscn"),
	preload("res://characters/enemies/tank.tscn")
]
# ฉากบอสแยกจาก Tank เพื่อเลือกสกิลให้บอสได้โดยไม่เปลี่ยนศัตรูทั่วไป
const BOSS_SCENE: PackedScene = preload("res://characters/enemies/boss.tscn")
const SPECIAL_BOSS_SCENE: PackedScene = preload("res://characters/bosses/dreadnought.tscn")
const BOSS_REWARDS := {
	1: {"name": "บ้านของปูเสฉวน", "description": "บันทึกจากโทมัส • เปิดเส้นทางด่านพิเศษ Razor"},
	2: {"name": "เส้นใยในตัวปูม้า", "description": "บันทึกจากครามแห่งช่องกระแสน้ำขุ่น"},
	3: {"name": "เรื่องเล่าของเสนาหอย", "description": "บันทึกร่วมจากเสและนา"},
	4: {"name": "แผนที่ขยะทะเล", "description": "บันทึกการสำรวจจากหมึกเลนส์"},
	5: {"name": "เพื่อนร่วมทะเล", "description": "บันทึกชิ้นสุดท้ายจากทู รวมเป็นกุญแจแห่งพลัง"}
}
const TURTLE_SHIPS := [
	{"ship_index": 1, "name": "JOHNY SAPARROW", "cost": 2, "unlock_type": "coin"},
	{"ship_index": 2, "name": "PICHU JOHNY", "cost": 3, "unlock_type": "coin"},
	{"ship_index": 3, "name": "SANTA JOHNY", "cost": 0, "unlock_type": "special_stage"},
	{"ship_index": 4, "name": "STRAW HAT JOHNY", "cost": 0, "unlock_type": "endless_score"}
]
const DEFAULT_UNLOCKED_SHIPS := [0]
const COLLECTION_SAVE_PATH := "user://item_collection.json"

@onready var character_layer: Node2D = $CharacterLayer
@onready var player_sprite: Sprite2D = $CharacterLayer/Player
@onready var dialogue_overlay: Control = $DialogueLayer/DialogueOverlay

var player_pos := Vector2(270.0, 878.0)
var player_health := 4
var max_player_health := 4
var player_speed := 360.0
var fire_delay := 0.145
var player_extra_projectiles := 0
var player_stats: Dictionary = {}
var special_cooldown_timer := 0.0
var giant_shot_time_remaining := 0.0
var giant_shot_timer := 0.0
var giant_shot_count := 0
var viper_beam_time_remaining := 0.0
var viper_beam_hits: Dictionary = {}
var viper_beam_tick_timer := 0.0
var viper_beam_tick_index := 0
var beyblades: Array = []
var special_effects: Array = []
var laser_hit_ids: Dictionary = {}
var visual_textures: Dictionary = {}
var selected_character := 0
var selected_stage := 1
var menu_page := "home"
var purchase_overlay_visible := false
var quest_open_stage := 0
var item_collection: Array[int] = []
var sea_tokens := 0
var turtle_shop_unlocked := true
var unlocked_ships: Array[int] = [0]
var highest_unlocked_stage := 1
var razor_special_cleared := false
var special_stage_mode := false
var stage_one_tutorial_seen := false
var tutorial_visible := false
var tutorial_timer := 0.0
var menu_animation_time := 0.0
var carousel_slide_offset := 0.0
var stage_popup_progress := 0.0
var shop_selected_ship := 0
var collection_save_path := COLLECTION_SAVE_PATH
var stage_level := 1
var endless_mode := false
var endless_bosses_defeated := 0
var endless_scores: Array[int] = []
var selecting_character := true
var score := 0
var best_score := 0
var level := 1
var boss_active := false
var victory := false
var summary_timer := 0.0
var dialogue_active := false
var dialogue_lines: Array[Dictionary] = []
var dialogue_index := 0
var dialogue_completion := ""
var elapsed := 0.0
var fire_timer := 0.0
var spawn_timer := 0.0
var invulnerable_timer := 0.0
var shake_timer := 0.0
var flash_timer := 0.0
var paused := false
var game_over := false
var shake_offset := Vector2.ZERO
var pointer_active := false
# pointer_index: -2 = เมาส์หลังคลิกเลือกการควบคุม, -1 = เมาส์คลิกค้าง, 0 ขึ้นไป = นิ้วที่ลาก
var pointer_index := -1
var pointer_offset := Vector2.ZERO
var pointer_target := Vector2.ZERO
var slow_key_held := false
var slow_mouse_held := false
var slow_touch_index := -1
var last_mouse_click_ms := -1000
var last_mouse_click_position := Vector2.ZERO
var last_touch_tap_ms := -1000
var last_touch_tap_position := Vector2.ZERO
var last_touch_tap_index := -1
var menu_swipe_index := -1
var menu_swipe_start := Vector2.ZERO
var menu_swipe_initial_ship := 0
var menu_swipe_triggered := false
var menu_mouse_dragging := false

var bullets: Array = []
var enemy_bullets: Array = []
var enemies: Array = []
var particles: Array = []
var pickups: Array = []

var rng := RandomNumberGenerator.new()


func _enter_tree() -> void:
	# โหลดก่อน HUD._ready เพื่อให้การ์ดเลือกยานเห็นภาพที่ตั้งทับไว้ด้วย
	for key in VISUAL_CONFIG.TEXTURE_PATHS:
		var path: String = VISUAL_CONFIG.TEXTURE_PATHS[key]
		if not path.is_empty() and ResourceLoader.exists(path):
			visual_textures[key] = load(path) as Texture2D
	# Special attacks load the image declared in their own player config.
	for ship in PLAYER_CONFIG.SHIPS:
		var special_key: String = ship.get("special", "")
		var texture_path: String = ship.get("special_texture", "")
		if not special_key.is_empty() and not texture_path.is_empty() and ResourceLoader.exists(texture_path):
			var texture := load(texture_path) as Texture2D
			if texture != null:
				visual_textures[special_key] = texture


func _ready() -> void:
	rng.randomize()
	load_item_collection()
	show_character_select()


func load_item_collection() -> void:
	if not FileAccess.file_exists(collection_save_path):
		return
	var save_file := FileAccess.open(collection_save_path, FileAccess.READ)
	if save_file == null:
		return
	var stored: Variant = JSON.parse_string(save_file.get_as_text())
	if stored is Array:
		# Migrate the old save format that only stored collected item IDs.
		for entry in stored:
			var stage: int = int(entry)
			if BOSS_REWARDS.has(stage) and not item_collection.has(stage):
				item_collection.append(stage)
		turtle_shop_unlocked = true
	elif stored is Dictionary:
		item_collection.clear()
		for entry in stored.get("quest_items", []):
			var stage: int = int(entry)
			if BOSS_REWARDS.has(stage) and not item_collection.has(stage):
				item_collection.append(stage)
		sea_tokens = maxi(0, int(stored.get("sea_tokens", 0)))
		turtle_shop_unlocked = true
		highest_unlocked_stage = clampi(int(stored.get("highest_unlocked_stage", 1)), 1, FINAL_LEVEL)
		stage_one_tutorial_seen = bool(stored.get("stage_one_tutorial_seen", false))
		razor_special_cleared = bool(stored.get("razor_special_cleared", false))
		endless_scores.clear()
		for saved_score in stored.get("endless_scores", []):
			var valid_score := maxi(0, int(saved_score))
			if valid_score > 0:
				endless_scores.append(valid_score)
		endless_scores.sort_custom(func(a: int, b: int) -> bool: return a > b)
		if endless_scores.size() > MAX_SCOREBOARD_ENTRIES:
			endless_scores.resize(MAX_SCOREBOARD_ENTRIES)
		# Roster v2: Johny เริ่มต้นหนึ่งตัว, Saparrow/Pichu ซื้อด้วย Coin,
		# Razor มาจากด่านพิเศษ และ Viper มาจาก Endless 30,000 เท่านั้น
		unlocked_ships.assign(DEFAULT_UNLOCKED_SHIPS)
		var saved_unlocked_ships: Variant = stored.get("unlocked_ships", stored.get("unlocked_turtle_skins", []))
		for entry in saved_unlocked_ships:
			var ship_index: int = int(entry)
			if ship_index in [1, 2] and ship_index not in unlocked_ships:
				unlocked_ships.append(ship_index)
		if razor_special_cleared:
			unlocked_ships.append(3)
		if get_endless_best_score() >= VIPER_ENDLESS_UNLOCK_SCORE:
			unlocked_ships.append(4)
	for cleared_stage in item_collection:
		highest_unlocked_stage = maxi(highest_unlocked_stage, mini(cleared_stage + 1, FINAL_LEVEL))
	selected_stage = clampi(selected_stage, 1, highest_unlocked_stage)


func save_item_collection() -> void:
	var save_file := FileAccess.open(collection_save_path, FileAccess.WRITE)
	if save_file != null:
		save_file.store_string(JSON.stringify({
			"quest_items": item_collection,
			"sea_tokens": sea_tokens,
			"turtle_shop_unlocked": turtle_shop_unlocked,
			"unlocked_ships": unlocked_ships,
			"roster_version": 2,
			"razor_special_cleared": razor_special_cleared,
			"highest_unlocked_stage": highest_unlocked_stage,
			"stage_one_tutorial_seen": stage_one_tutorial_seen,
			"endless_scores": endless_scores
		}))


func is_ship_unlocked(ship_index: int) -> bool:
	return ship_index in unlocked_ships


func is_ship_visible(ship_index: int) -> bool:
	# Razor จะไม่โผล่ใน Carousel จนกว่าจะจบบทที่ 1
	return ship_index != 3 or item_collection.has(1) or razor_special_cleared


func get_visible_ship_indices() -> Array[int]:
	var result: Array[int] = []
	for ship_index in range(PLAYER_SCENES.size()):
		if is_ship_visible(ship_index):
			result.append(ship_index)
	return result


func get_adjacent_visible_ship(ship_index: int, direction: int) -> int:
	var visible := get_visible_ship_indices()
	var current := visible.find(ship_index)
	if current < 0:
		return visible[0]
	return visible[wrapi(current + direction, 0, visible.size())]


func is_stage_unlocked(stage: int) -> bool:
	return stage >= 1 and stage <= highest_unlocked_stage


func get_ship_display_name(ship_index: int) -> String:
	if ship_index == 0:
		return "JOHNY"
	for ship_offer in TURTLE_SHIPS:
		if int(ship_offer.ship_index) == ship_index:
			return str(ship_offer.name)
	return str(PLAYER_CONFIG.get_ship(ship_index).name)


func select_character_step(direction: int) -> void:
	selected_character = get_adjacent_visible_ship(selected_character, direction)
	purchase_overlay_visible = false
	carousel_slide_offset = 210.0 * signf(float(direction))


func get_selected_ship_offer_index() -> int:
	for offer_index in range(TURTLE_SHIPS.size()):
		if int(TURTLE_SHIPS[offer_index].ship_index) == selected_character:
			return offer_index
	return -1


func open_selected_ship_purchase() -> bool:
	if is_ship_unlocked(selected_character) or get_selected_ship_offer_index() < 0:
		return false
	if selected_character == 3:
		return false
	purchase_overlay_visible = true
	queue_redraw()
	return true


func get_selected_ship_purchase_status() -> String:
	var offer_index := get_selected_ship_offer_index()
	if offer_index < 0:
		return "THIS TURTLE IS NOT FOR SALE"
	var ship_offer: Dictionary = TURTLE_SHIPS[offer_index]
	match str(ship_offer.unlock_type):
		"special_stage":
			return "DEFEAT THE SPECIAL BOSS TO UNLOCK"
		"endless_score":
			return "REACH 30,000 SCORE IN ENDLESS MODE"
	if sea_tokens < int(ship_offer.cost):
		return "NEED %d MORE COIN" % (int(ship_offer.cost) - sea_tokens)
	return "READY TO BUY WITH COIN"


func confirm_selected_ship_purchase() -> bool:
	var offer_index := get_selected_ship_offer_index()
	if offer_index < 0 or not buy_turtle_ship(offer_index):
		return false
	purchase_overlay_visible = false
	queue_redraw()
	return true


func can_buy_turtle_ship(ship_offer_index: int) -> bool:
	if ship_offer_index < 0 or ship_offer_index >= TURTLE_SHIPS.size():
		return false
	var ship_offer: Dictionary = TURTLE_SHIPS[ship_offer_index]
	return str(ship_offer.unlock_type) == "coin" and int(ship_offer.ship_index) not in unlocked_ships and sea_tokens >= int(ship_offer.cost)


func buy_turtle_ship(ship_offer_index: int) -> bool:
	if not can_buy_turtle_ship(ship_offer_index):
		return false
	var ship_offer: Dictionary = TURTLE_SHIPS[ship_offer_index]
	sea_tokens -= int(ship_offer.cost)
	unlocked_ships.append(int(ship_offer.ship_index))
	selected_character = int(ship_offer.ship_index)
	save_item_collection()
	queue_redraw()
	return true


func is_razor_special_stage_available() -> bool:
	return selected_character == 3 and is_ship_visible(3) and not is_ship_unlocked(3) and item_collection.has(1)


func unlock_viper_from_endless() -> void:
	if 4 in unlocked_ships or score < VIPER_ENDLESS_UNLOCK_SCORE or not endless_mode:
		return
	unlocked_ships.append(4)
	save_item_collection()
	queue_redraw()


func show_character_select() -> void:
	for enemy in enemies:
		free_enemy_visual(enemy)
	enemies.clear()
	bullets.clear()
	enemy_bullets.clear()
	particles.clear()
	pickups.clear()
	beyblades.clear()
	special_effects.clear()
	laser_hit_ids.clear()
	special_cooldown_timer = 0.0
	giant_shot_time_remaining = 0.0
	giant_shot_timer = 0.0
	giant_shot_count = 0
	viper_beam_time_remaining = 0.0
	viper_beam_hits.clear()
	viper_beam_tick_timer = 0.0
	viper_beam_tick_index = 0
	paused = false
	game_over = false
	boss_active = false
	dialogue_active = false
	dialogue_lines.clear()
	dialogue_completion = ""
	dialogue_overlay.hide()
	pointer_active = false
	slow_key_held = false
	slow_mouse_held = false
	slow_touch_index = -1
	last_mouse_click_ms = -1000
	last_touch_tap_ms = -1000
	menu_swipe_index = -1
	menu_mouse_dragging = false
	selecting_character = true
	endless_mode = false
	endless_bosses_defeated = 0
	menu_page = "home"
	purchase_overlay_visible = false
	quest_open_stage = 0
	stage_popup_progress = 0.0
	special_stage_mode = false
	character_layer.position = Vector2.ZERO
	player_sprite.visible = false
	queue_redraw()


func start_selected_game(start_endless: bool = false) -> void:
	if not is_ship_unlocked(selected_character):
		open_selected_ship_purchase()
		return
	special_stage_mode = false
	endless_mode = start_endless
	endless_bosses_defeated = 0
	selecting_character = false
	apply_selected_character()
	reset_game()


func start_endless_game() -> void:
	start_selected_game(true)


func start_razor_special_stage() -> void:
	if not is_razor_special_stage_available():
		return
	special_stage_mode = true
	endless_mode = false
	endless_bosses_defeated = 0
	selecting_character = false
	# Johny เป็นผู้เข้าทดสอบและช่วยปลดล็อก Santa Johny (Razor)
	selected_character = 0
	apply_selected_character()
	reset_game()


func get_endless_best_score() -> int:
	return endless_scores[0] if not endless_scores.is_empty() else 0


func record_endless_score() -> void:
	if score <= 0:
		return
	endless_scores.append(score)
	endless_scores.sort_custom(func(a: int, b: int) -> bool: return a > b)
	if endless_scores.size() > MAX_SCOREBOARD_ENTRIES:
		endless_scores.resize(MAX_SCOREBOARD_ENTRIES)
	save_item_collection()


func apply_selected_character() -> void:
	if is_instance_valid(player_sprite):
		character_layer.remove_child(player_sprite)
		player_sprite.queue_free()
	player_sprite = PLAYER_SCENES[selected_character].instantiate() as Sprite2D
	apply_visual_override(player_sprite, PLAYER_VISUAL_KEYS[selected_character])
	character_layer.add_child(player_sprite)
	# ค่าหลักแก้ใน player_config.gd; สกิลเสริมที่ตั้งใน combatant_visual.gd ยังทำงาน
	player_stats = PLAYER_CONFIG.get_ship(selected_character)
	max_player_health = ceili(float(player_stats.base_health) * float(player_stats.health_multiplier))
	player_speed = float(player_stats.speed)
	fire_delay = float(player_stats.fire_delay)
	var modifiers: Dictionary = skill_modifiers_for(player_sprite)
	max_player_health = ceili(max_player_health * modifiers.max_health_multiplier)
	fire_delay = maxf(0.04, fire_delay * modifiers.fire_interval_multiplier)
	player_extra_projectiles = modifiers.extra_projectiles


func skill_modifiers_for(visual: Sprite2D) -> Dictionary:
	var combatant := visual as CombatantVisual
	if combatant != null:
		return combatant.get_skill_modifiers()
	return {"fire_interval_multiplier": 1.0, "max_health_multiplier": 1.0, "extra_projectiles": 0}


func reset_game() -> void:
	for enemy in enemies:
		free_enemy_visual(enemy)
	player_pos = Vector2(GAME_SIZE.x * 0.5, GAME_SIZE.y - 82.0)
	player_health = max_player_health
	level = SPECIAL_BOSS_LEVEL if special_stage_mode else selected_stage
	stage_level = 1
	score = 0
	boss_active = false
	victory = false
	summary_timer = 0.0
	pointer_active = false
	slow_key_held = false
	slow_mouse_held = false
	slow_touch_index = -1
	last_mouse_click_ms = -1000
	last_touch_tap_ms = -1000
	menu_swipe_index = -1
	menu_mouse_dragging = false
	pointer_target = player_pos
	elapsed = 0.0
	fire_timer = 0.18
	spawn_timer = 0.55
	invulnerable_timer = 1.0
	shake_timer = 0.0
	flash_timer = 0.0
	paused = false
	game_over = false
	dialogue_active = false
	dialogue_lines.clear()
	dialogue_index = 0
	dialogue_completion = ""
	dialogue_overlay.hide()
	shake_offset = Vector2.ZERO
	character_layer.position = Vector2.ZERO
	player_sprite.position = player_pos
	player_sprite.visible = true
	bullets.clear()
	enemy_bullets.clear()
	enemies.clear()
	particles.clear()
	pickups.clear()
	beyblades.clear()
	special_effects.clear()
	laser_hit_ids.clear()
	special_cooldown_timer = 0.0
	giant_shot_time_remaining = 0.0
	giant_shot_timer = 0.0
	giant_shot_count = 0
	viper_beam_time_remaining = 0.0
	viper_beam_hits.clear()
	viper_beam_tick_timer = 0.0
	viper_beam_tick_index = 0
	tutorial_visible = not special_stage_mode and selected_stage == 1 and not stage_one_tutorial_seen
	tutorial_timer = 9.0 if tutorial_visible else 0.0
	if tutorial_visible:
		stage_one_tutorial_seen = true
		save_item_collection()
	if not endless_mode:
		start_stage_intro()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	# ระหว่างบทสนทนา _input() จะรับการแตะ/คลิกก่อนเมนูและเกม
	if dialogue_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if selecting_character:
			if purchase_overlay_visible:
				if event.keycode == KEY_ESCAPE:
					purchase_overlay_visible = false
				elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
					confirm_selected_ship_purchase()
				queue_redraw()
				return
			if menu_page == "home":
				if event.keycode == KEY_A or event.keycode == KEY_LEFT:
					select_character_step(-1)
				elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
					select_character_step(1)
				elif event.keycode == KEY_T:
					if is_razor_special_stage_available():
						start_razor_special_stage()
					elif is_ship_unlocked(selected_character):
						menu_page = "stage"
						stage_popup_progress = 0.0
					else:
						open_selected_ship_purchase()
				elif event.keycode == KEY_C:
					menu_page = "collection"
					quest_open_stage = 0
				elif event.keycode == KEY_B:
					menu_page = "scoreboard"
				elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
					if is_razor_special_stage_available():
						start_razor_special_stage()
					elif is_ship_unlocked(selected_character):
						menu_page = "stage"
						stage_popup_progress = 0.0
					else:
						open_selected_ship_purchase()
			elif menu_page == "stage":
				if event.keycode == KEY_ESCAPE:
					menu_page = "home"
				if event.keycode == KEY_A or event.keycode == KEY_LEFT:
					selected_stage = wrapi(selected_stage - 2, 0, highest_unlocked_stage) + 1
				elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
					selected_stage = wrapi(selected_stage, 0, highest_unlocked_stage) + 1
				elif event.keycode >= KEY_1 and event.keycode < KEY_1 + FINAL_LEVEL:
					var requested_stage: int = event.keycode - KEY_1 + 1
					if is_stage_unlocked(requested_stage):
						selected_stage = requested_stage
				elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
					start_selected_game()
			elif menu_page == "scoreboard":
				if event.keycode == KEY_ESCAPE:
					menu_page = "home"
				elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
					start_endless_game()
			elif menu_page == "collection":
				if event.keycode == KEY_ESCAPE:
					if quest_open_stage > 0:
						quest_open_stage = 0
					else:
						menu_page = "home"
				elif (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE) and quest_open_stage > 0:
					open_quest_source()
			elif event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
				menu_page = "home"
			queue_redraw()
		elif game_over and (event.keycode == KEY_R or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			show_character_select()
		elif event.keycode == KEY_P and not game_over:
			paused = not paused
			pointer_active = false
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selecting_character:
			handle_menu_press(event.position)
		elif game_over:
			show_character_select()
	elif event is InputEventScreenTouch and event.pressed:
		if selecting_character:
			handle_menu_press(event.position)
		elif game_over:
			show_character_select()


func handle_menu_press(position: Vector2) -> void:
	var adjusted_position := position
	if purchase_overlay_visible:
		if PURCHASE_CANCEL_BUTTON.has_point(adjusted_position):
			purchase_overlay_visible = false
		elif PURCHASE_CONFIRM_BUTTON.has_point(adjusted_position):
			confirm_selected_ship_purchase()
		queue_redraw()
		return
	if menu_page == "stage":
		adjusted_position -= Vector2(0.0, (1.0 - stage_popup_progress) * 96.0)
	if menu_page == "home":
		if SHIP_PREV_BUTTON.has_point(adjusted_position):
			select_character_step(-1)
		elif SHIP_NEXT_BUTTON.has_point(adjusted_position):
			select_character_step(1)
		elif SHIP_LOCK_BUTTON.has_point(adjusted_position) and not is_ship_unlocked(selected_character):
			if not is_razor_special_stage_available():
				open_selected_ship_purchase()
		elif HOME_SCOREBOARD_BUTTON.has_point(adjusted_position):
			menu_page = "scoreboard"
		elif HOME_COLLECTION_BUTTON.has_point(adjusted_position):
			menu_page = "collection"
			quest_open_stage = 0
		elif LAUNCH_BUTTON.has_point(adjusted_position):
			if is_razor_special_stage_available():
				start_razor_special_stage()
			elif is_ship_unlocked(selected_character):
				menu_page = "stage"
				stage_popup_progress = 0.0
			else:
				open_selected_ship_purchase()
	elif menu_page == "stage" or menu_page == "collection" or menu_page == "shop" or menu_page == "scoreboard":
		if MENU_BACK_BUTTON.has_point(adjusted_position):
			if menu_page == "collection" and quest_open_stage > 0:
				quest_open_stage = 0
			else:
				menu_page = "home"
		elif menu_page == "stage":
			for i in range(STAGE_CARDS.size()):
				if STAGE_CARDS[i].has_point(adjusted_position) and is_stage_unlocked(i + 1):
					selected_stage = i + 1
					break
			if STAGE_START_BUTTON.has_point(adjusted_position):
				start_selected_game()
		elif menu_page == "shop":
			for i in range(SHOP_SHIP_CARDS.size()):
				if SHOP_SHIP_CARDS[i].has_point(adjusted_position):
					shop_selected_ship = i
					break
			if SHOP_BUY_BUTTON.has_point(adjusted_position):
				buy_turtle_ship(shop_selected_ship)
		elif menu_page == "scoreboard" and SCOREBOARD_START_BUTTON.has_point(adjusted_position):
			start_endless_game()
		elif menu_page == "collection":
			if quest_open_stage > 0 and QUEST_READ_BUTTON.has_point(adjusted_position):
				open_quest_source()
			elif quest_open_stage == 0:
				for stage in range(1, FINAL_LEVEL + 1):
					if STAGE_CARDS[stage - 1].has_point(adjusted_position) and item_collection.has(stage):
						quest_open_stage = stage
						break
	queue_redraw()


func get_open_research_entry() -> Dictionary:
	return RESEARCH_CONFIG.get_entry(quest_open_stage)


func open_quest_source() -> Error:
	var entry := get_open_research_entry()
	var source_url := str(entry.get("source_url", ""))
	if source_url.is_empty():
		return ERR_FILE_NOT_FOUND
	return OS.shell_open(source_url)


func handle_menu_swipe(event: InputEvent) -> void:
	if menu_page != "home" or purchase_overlay_visible:
		menu_swipe_index = -1
		menu_mouse_dragging = false
		return
	if event is InputEventScreenTouch:
		if event.pressed and CAROUSEL_SWIPE_AREA.has_point(event.position):
			menu_swipe_index = event.index
			menu_swipe_start = event.position
			menu_swipe_initial_ship = selected_character
			menu_swipe_triggered = false
		elif not event.pressed and event.index == menu_swipe_index:
			menu_swipe_index = -1
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and CAROUSEL_SWIPE_AREA.has_point(event.position):
			menu_mouse_dragging = true
			menu_swipe_start = event.position
			menu_swipe_initial_ship = selected_character
			menu_swipe_triggered = false
		elif not event.pressed:
			menu_mouse_dragging = false
	if menu_swipe_triggered:
		return
	var current_position := Vector2.ZERO
	if event is InputEventScreenDrag and event.index == menu_swipe_index:
		current_position = event.position
	elif event is InputEventMouseMotion and menu_mouse_dragging:
		current_position = event.position
	else:
		return
	var movement: Vector2 = current_position - menu_swipe_start
	if absf(movement.x) < 65.0 or absf(movement.x) <= absf(movement.y):
		return
	selected_character = menu_swipe_initial_ship
	select_character_step(1 if movement.x < 0.0 else -1)
	menu_swipe_triggered = true
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event.keycode == KEY_SHIFT or event.physical_keycode == KEY_SHIFT):
		slow_key_held = event.pressed
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_LEFT, KEY_DOWN, KEY_RIGHT] and pointer_index < 0:
		pointer_active = false
	if dialogue_active:
		# กดหนึ่งครั้งไปหนึ่งข้อความ; ปล่อยนิ้ว/ลากนิ้วไม่ข้ามข้อความ
		if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE)):
			advance_dialogue()
			get_viewport().set_input_as_handled()
		return
	if selecting_character:
		handle_menu_swipe(event)
		return
	if game_over:
		return
	# E/Space หรือปุ่ม SPECIAL ใช้ท่าพิเศษ; ปุ่มมือถือไม่รบกวนการลากยาน
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_E or event.keycode == KEY_SPACE):
		activate_special()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if PAUSE_BUTTON.has_point(event.position):
				pointer_active = false
				paused = not paused
				return
			if SLOW_BUTTON.has_point(event.position) and not paused:
				slow_touch_index = event.index
				return
			if SPECIAL_BUTTON.has_point(event.position) and not paused:
				activate_special()
				return
			var now_ms: int = Time.get_ticks_msec()
			if not paused and event.index == last_touch_tap_index and now_ms - last_touch_tap_ms <= 350 and event.position.distance_to(last_touch_tap_position) <= 48.0:
				last_touch_tap_ms = -1000
				activate_special()
				return
			last_touch_tap_ms = now_ms
			last_touch_tap_position = event.position
			last_touch_tap_index = event.index
			if not paused and (not pointer_active or pointer_index < 0):
				pointer_active = true
				pointer_index = event.index
				pointer_offset = player_pos - event.position
				pointer_target = player_pos
		elif slow_touch_index == event.index:
			slow_touch_index = -1
		elif pointer_active and pointer_index == event.index:
			pointer_active = false
	elif event is InputEventScreenDrag and pointer_active and pointer_index == event.index and not paused:
		if event.position.distance_to(last_touch_tap_position) > 48.0:
			last_touch_tap_ms = -1000
		pointer_target = event.position + pointer_offset
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if PAUSE_BUTTON.has_point(event.position):
				pointer_active = false
				paused = not paused
				return
			if SLOW_BUTTON.has_point(event.position) and not paused:
				slow_mouse_held = true
				return
			if SPECIAL_BUTTON.has_point(event.position) and not paused:
				activate_special()
				return
			var now_ms: int = Time.get_ticks_msec()
			if not paused and now_ms - last_mouse_click_ms <= 350 and event.position.distance_to(last_mouse_click_position) <= 48.0:
				last_mouse_click_ms = -1000
				activate_special()
				return
			last_mouse_click_ms = now_ms
			last_mouse_click_position = event.position
			if not paused and (not pointer_active or pointer_index < 0):
				pointer_active = true
				pointer_index = -1
				pointer_offset = player_pos - event.position
				pointer_target = player_pos
		elif slow_mouse_held:
			slow_mouse_held = false
		elif pointer_active and pointer_index == -1:
			pointer_index = -2
			pointer_offset = Vector2.ZERO
			pointer_target = event.position
	elif event is InputEventMouseMotion and not paused and pointer_active and pointer_index < 0:
		if event.position.distance_to(last_mouse_click_position) > 48.0:
			last_mouse_click_ms = -1000
		# เมาส์เลื่อนตามเป้าหลังคลิกเลือกการควบคุมแล้วเท่านั้น
		if pointer_index == -1:
			pointer_target = event.position + pointer_offset
		else:
			pointer_target = event.position


func _process(delta: float) -> void:
	menu_animation_time += delta
	if selecting_character:
		carousel_slide_offset = move_toward(carousel_slide_offset, 0.0, delta * 980.0)
		stage_popup_progress = move_toward(stage_popup_progress, 1.0 if menu_page == "stage" else 0.0, delta * 5.5)
	if not selecting_character and not paused and not game_over and not dialogue_active:
		update_game(delta)
	elif game_over:
		summary_timer -= delta
		if summary_timer <= 0.0:
			show_character_select()
	update_particles(delta)
	shake_timer = maxf(0.0, shake_timer - delta)
	flash_timer = maxf(0.0, flash_timer - delta)
	shake_offset = Vector2.ZERO
	if shake_timer > 0.0:
		shake_offset = Vector2(rng.randf_range(-5.0, 5.0), rng.randf_range(-4.0, 4.0))
	character_layer.position = shake_offset
	queue_redraw()


func update_game(delta: float) -> void:
	if dialogue_active:
		return
	elapsed += delta
	fire_timer -= delta
	spawn_timer -= delta
	invulnerable_timer = maxf(0.0, invulnerable_timer - delta)
	special_cooldown_timer = maxf(0.0, special_cooldown_timer - delta)
	if tutorial_visible:
		tutorial_timer = maxf(0.0, tutorial_timer - delta)
		tutorial_visible = tutorial_timer > 0.0

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	var move_speed := get_player_move_speed()
	if direction.length_squared() > 0.0:
		# การกดปุ่มเคลื่อนที่เลือกคีย์บอร์ด; เมาส์จะไม่แย่งการควบคุมจนกว่าจะคลิกอีกครั้ง
		if pointer_index < 0:
			pointer_active = false
		player_pos += direction.normalized() * move_speed * delta
	elif pointer_active:
		player_pos = player_pos.move_toward(pointer_target, move_speed * delta)
	player_pos.x = clampf(player_pos.x, 30.0, GAME_SIZE.x - 30.0)
	player_pos.y = clampf(player_pos.y, 225.0, GAME_SIZE.y - 34.0)

	if fire_timer <= 0.0:
		fire_player_weapon()

	if spawn_timer <= 0.0 and not boss_active:
		spawn_enemy()
		spawn_timer = maxf(0.30, 0.92 - elapsed * 0.007 - (stage_level - 1) * 0.07) * rng.randf_range(0.78, 1.15)

	update_bullets(delta)
	update_enemies(delta)
	update_special_effects(delta)
	if game_over or dialogue_active:
		return
	update_pickups(delta)
	resolve_collisions()
	player_sprite.position = player_pos
	player_sprite.visible = not game_over and (invulnerable_timer <= 0.0 or int(invulnerable_timer * 12.0) % 2 == 0)


func is_slow_mode_active() -> bool:
	return slow_key_held or slow_mouse_held or slow_touch_index >= 0


func get_player_move_speed() -> float:
	var configured_speed: float = float(player_stats.get("speed", player_speed))
	return configured_speed * SLOW_SPEED_MULTIPLIER if is_slow_mode_active() else configured_speed


func score_target_for_level() -> int:
	if endless_mode:
		return (endless_bosses_defeated + 1) * ENDLESS_BOSS_SCORE_STEP
	if special_stage_mode:
		return SPECIAL_STAGE_SCORE_TARGET
	return stage_level * LEVEL_SCORE_STEP


func score_start_for_level() -> int:
	if endless_mode:
		return endless_bosses_defeated * ENDLESS_BOSS_SCORE_STEP
	if special_stage_mode:
		return 0
	return (stage_level - 1) * LEVEL_SCORE_STEP


func refresh_stage_level() -> void:
	# Level progression only happens after defeating a boss and finishing its dialogue.
	stage_level = clampi(stage_level, 1, LEVELS_PER_STAGE)
	unlock_viper_from_endless()


func fire_player_weapon() -> void:
	fire_timer = fire_delay
	var speed: float = player_stats.bullet_speed
	match String(player_stats.weapon):
		"homing_dual":
			for side in [-1.0, 1.0]:
				spawn_player_bullet(Vector2(side * 12.0, -20.0), Vector2.UP * speed, "player_homing", 1.0, 5.0, 1.0, true)
		"wide":
			var count: int = player_stats.wide_shots
			for shot in range(count):
				var angle: float = (float(shot) - float(count - 1) * 0.5) * float(player_stats.wide_angle_step)
				spawn_player_bullet(Vector2(0.0, -23.0), Vector2.UP.rotated(angle) * speed, "player_wide", 1.0, 5.0, float(player_stats.boss_damage_multiplier))
		"heavy_v":
			for side in [-1.0, 1.0]:
				spawn_player_bullet(Vector2(side * 15.0, -17.0), Vector2.UP.rotated(side * float(player_stats.v_angle)) * speed, "player_heavy", float(player_stats.v_damage), float(player_stats.v_radius))
		_:
			for side in [-1.0, 1.0]:
				spawn_player_bullet(Vector2(side * 9.0, -20.0), Vector2(side * 24.0, -speed), "player_normal")
	# Spread Shot เพิ่มกระสุนเป็นคู่ โดยใช้ได้กับยานทุกแบบ
	for shot_index in range(player_extra_projectiles):
		var ring := int(shot_index / 2) + 1
		var side := -1.0 if shot_index % 2 == 0 else 1.0
		var angle := side * 0.28 * ring
		spawn_player_bullet(Vector2(0.0, -24.0), Vector2.UP.rotated(angle) * 600.0, "player_normal")
	spawn_sparks(player_pos + Vector2(0.0, -23.0), Color("7df9ff"), 2, 55.0)


func spawn_player_bullet(offset: Vector2, velocity: Vector2, visual_key: String, damage: float = 1.0, radius: float = 5.0, boss_multiplier: float = 1.0, homing: bool = false) -> void:
	bullets.append({"pos": player_pos + offset, "vel": velocity, "visual_key": visual_key,
		"damage": damage, "radius": radius, "boss_damage_multiplier": boss_multiplier,
		"homing": homing, "life": 4.0})


func spawn_enemy() -> void:
	var kind := 0
	var roll := rng.randf()
	# ด่านสูงขึ้นมีศัตรูหนักและศัตรูยิงถี่มากขึ้น
	var tank_chance := minf(0.40, 0.18 + (level - 1) * 0.04 + (stage_level - 1) * 0.03)
	var striker_chance := minf(0.68, 0.42 + (level - 1) * 0.05 + (stage_level - 1) * 0.03)
	if elapsed > 26.0 and roll < tank_chance:
		kind = 2
	elif elapsed > 10.0 and roll < striker_chance:
		kind = 1

	var radius := 17.0
	var hp := 1
	var speed := rng.randf_range(105.0, 155.0) + minf(elapsed * 1.2, 75.0)
	var worth := 100
	if kind == 1:
		radius = 20.0
		hp = 2
		worth = 180
		speed *= 0.82
	elif kind == 2:
		radius = 27.0
		hp = 5
		worth = 420
		speed *= 0.62

	var spawn_position := Vector2(rng.randf_range(radius + 15.0, GAME_SIZE.x - radius - 15.0), -radius - 8.0)
	var enemy_visual: Sprite2D = ENEMY_SCENES[kind].instantiate()
	apply_visual_override(enemy_visual, ENEMY_VISUAL_KEYS[kind])
	character_layer.add_child(enemy_visual)
	enemy_visual.position = spawn_position
	var modifiers: Dictionary = skill_modifiers_for(enemy_visual)
	hp = ceili(hp * modifiers.max_health_multiplier)
	enemies.append({
		"pos": spawn_position,
		"vel": Vector2(0.0, speed),
		"radius": radius,
		"hp": hp,
		"max_hp": hp,
		"kind": kind,
		"worth": worth,
		"phase": rng.randf_range(0.0, TAU),
		"shoot": rng.randf_range(0.8, 2.4) * modifiers.fire_interval_multiplier,
		"fire_interval_multiplier": modifiers.fire_interval_multiplier,
		"extra_projectiles": modifiers.extra_projectiles,
		"visual": enemy_visual
	})


func spawn_boss() -> void:
	boss_active = true
	spawn_timer = 1.5
	var radius := 70.0
	var hp := BOSS_HP_BASE + level * BOSS_HP_PER_LEVEL + (stage_level - 1) * 16
	var spawn_position := Vector2(GAME_SIZE.x * 0.5, -radius)
	var boss_scene := SPECIAL_BOSS_SCENE if special_stage_mode else BOSS_SCENE
	var boss_visual: CombatantVisual = boss_scene.instantiate() as CombatantVisual
	if not special_stage_mode:
		apply_visual_override(boss_visual, "boss")
	# สกิลบอสต่างกันตามด่าน เลือกก่อนคำนวณ HP และอัตรายิง
	boss_visual.equip_boss_level(level)
	character_layer.add_child(boss_visual)
	boss_visual.position = spawn_position
	var modifiers: Dictionary = skill_modifiers_for(boss_visual)
	hp = ceili(hp * modifiers.max_health_multiplier)
	enemies.append({
		"pos": spawn_position,
		"vel": Vector2.ZERO,
		"radius": radius,
		"hp": hp,
		"max_hp": hp,
		"kind": BOSS_KIND,
		"tags": ["Boss"],
		"boss_id": SPECIAL_BOSS_LEVEL if special_stage_mode else level,
		"worth": 500 * level,
		"phase": 0.0,
		"boss_phase": 1,
		"special_timer": -1.0,
		"special_cooldown": get_boss_special_cooldown(),
		"shoot": 1.0 * modifiers.fire_interval_multiplier,
		"fire_interval_multiplier": modifiers.fire_interval_multiplier,
		"extra_projectiles": modifiers.extra_projectiles,
		"visual": boss_visual
	})


func update_bullets(delta: float) -> void:
	for i in range(bullets.size() - 1, -1, -1):
		if bullets[i].get("homing", false):
			var target_index := -1
			var nearest_distance := INF
			for enemy_index in range(enemies.size()):
				if bullets[i].get("hit_ids", []).has(enemies[enemy_index].visual.get_instance_id()):
					continue
				var distance: float = bullets[i].pos.distance_squared_to(enemies[enemy_index].pos)
				if distance < nearest_distance:
					nearest_distance = distance
					target_index = enemy_index
			if target_index >= 0:
				var target_direction: Vector2 = (enemies[target_index].pos - bullets[i].pos).normalized()
				var desired_velocity: Vector2 = target_direction * bullets[i].vel.length()
				bullets[i].vel = bullets[i].vel.move_toward(desired_velocity, float(player_stats.homing_turn_speed) * delta)
		bullets[i].pos += bullets[i].vel * delta
		bullets[i].life = float(bullets[i].get("life", 4.0)) - delta
		if bullets[i].life <= 0.0 or bullets[i].pos.y < -30.0 or bullets[i].pos.y > GAME_SIZE.y + 30.0 or bullets[i].pos.x < -30.0 or bullets[i].pos.x > GAME_SIZE.x + 30.0:
			bullets.remove_at(i)
	for i in range(enemy_bullets.size() - 1, -1, -1):
		enemy_bullets[i].pos += enemy_bullets[i].vel * delta
		if enemy_bullets[i].pos.y > GAME_SIZE.y + 20.0 or enemy_bullets[i].pos.x < -20.0 or enemy_bullets[i].pos.x > GAME_SIZE.x + 20.0:
			enemy_bullets.remove_at(i)


func nearest_enemy_index(origin: Vector2) -> int:
	var result := -1
	var nearest := INF
	for i in range(enemies.size()):
		var distance: float = origin.distance_squared_to(enemies[i].pos)
		if distance < nearest:
			nearest = distance
			result = i
	return result


func nearest_enemy_index_excluding(origin: Vector2, excluded_id: int) -> int:
	var result := -1
	var nearest := INF
	for i in range(enemies.size()):
		if enemies[i].visual.get_instance_id() == excluded_id:
			continue
		var distance: float = origin.distance_squared_to(enemies[i].pos)
		if distance < nearest:
			nearest = distance
			result = i
	return result


func closest_border_point(origin: Vector2) -> Vector2:
	var distances := [origin.x, GAME_SIZE.x - origin.x, origin.y, GAME_SIZE.y - origin.y]
	var nearest_edge: int = distances.find(distances.min())
	match nearest_edge:
		0: return Vector2(0.0, origin.y)
		1: return Vector2(GAME_SIZE.x, origin.y)
		2: return Vector2(origin.x, 0.0)
		_: return Vector2(origin.x, GAME_SIZE.y)


func aim_blade_at_enemy(blade: Dictionary, excluded_id: int = -1) -> bool:
	var target_index := nearest_enemy_index_excluding(blade.pos, excluded_id)
	if target_index < 0:
		return false
	var direction: Vector2 = (enemies[target_index].pos - blade.pos).normalized()
	blade.vel = direction * float(player_stats.special_speed)
	return true


func send_blade_to_border(blade: Dictionary) -> void:
	blade.to_border = true
	blade.border_target = closest_border_point(blade.pos)
	var direction: Vector2 = (blade.border_target - blade.pos).normalized()
	blade.vel = direction * float(player_stats.special_speed)


func activate_special() -> void:
	if paused or selecting_character or game_over or dialogue_active or special_cooldown_timer > 0.0:
		return
	var special: String = player_stats.get("special", "")
	if special.is_empty():
		return
	special_cooldown_timer = float(player_stats.special_cooldown)
	match special:
		"giant_shot":
			giant_shot_time_remaining = float(player_stats.special_duration)
			giant_shot_timer = float(player_stats.special_interval)
			giant_shot_count = 1
			spawn_giant_shot()
		"laser":
			laser_hit_ids.clear()
			for line_index in range(int(player_stats.laser_count)):
				var offset: float = (float(line_index) - (float(player_stats.laser_count) - 1.0) * 0.5) * float(player_stats.laser_spacing)
				special_effects.append({"kind": "laser", "offset": offset, "life": 0.42})
			update_titan_laser_hits()
			spawn_sparks(player_pos, Color("83eaff"), 18, 200.0)
		"beyblade":
			beyblades.append({"pos": player_pos + Vector2(0.0, -26.0), "vel": Vector2.UP * float(player_stats.special_speed),
				"life": float(player_stats.special_duration), "hit_timer": 0.0, "to_border": false, "border_target": Vector2.ZERO,
				"visual_key": special, "visual_size": player_stats.get("special_texture_size", Vector2(72.0, 72.0)),
				"rotation": 0.0, "spin_speed": player_stats.get("special_spin_speed", 32.0),
				"trail": [], "trail_timer": 0.0})
		"viper_beam":
			viper_beam_time_remaining = float(player_stats.special_duration)
			viper_beam_hits.clear()
			viper_beam_tick_index = 0
			viper_beam_tick_timer = float(player_stats.special_interval)
			update_viper_beam_hits()
	queue_redraw()


func spawn_giant_shot() -> void:
	bullets.append({"pos": player_pos + Vector2(0.0, -30.0), "vel": Vector2.UP * float(player_stats.special_bullet_speed),
		"visual_key": "player_giant", "damage": float(player_stats.special_damage), "radius": float(player_stats.special_radius),
		"boss_damage_multiplier": 1.0, "homing": true, "life": 4.0,
		"pierce_remaining": int(player_stats.special_pierce), "hit_ids": []})


func update_viper_beam_hits() -> void:
	var boss_percentages: Array = player_stats.get("special_boss_percentages", [0.25, 0.15, 0.10])
	if viper_beam_tick_index >= boss_percentages.size():
		return
	var boss_percentage := float(boss_percentages[viper_beam_tick_index])
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var visual_id: int = enemy.visual.get_instance_id()
		if enemy.pos.y > player_pos.y:
			continue
		if absf(enemy.pos.x - player_pos.x) <= float(player_stats.beam_width) * 0.5 + float(enemy.radius):
			viper_beam_hits[visual_id] = viper_beam_tick_index
			var damage: float = float(enemy.max_hp) * boss_percentage if enemy.kind == BOSS_KIND else float(player_stats.special_damage)
			damage_enemy(i, damage)
			if dialogue_active:
				break
	viper_beam_tick_index += 1


func update_titan_laser_hits() -> void:
	var offsets: Array[float] = []
	for effect in special_effects:
		if effect.kind == "laser":
			offsets.append(float(effect.offset))
	if offsets.is_empty():
		return
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var visual_id: int = enemy.visual.get_instance_id()
		if laser_hit_ids.has(visual_id) or enemy.pos.y > player_pos.y:
			continue
		for offset in offsets:
			if absf(enemy.pos.x - (player_pos.x + offset)) <= float(player_stats.laser_width) * 0.5 + float(enemy.radius):
				laser_hit_ids[visual_id] = true
				var damage: float = float(player_stats.special_boss_damage) if enemy.kind == BOSS_KIND else float(player_stats.special_damage)
				damage_enemy(i, damage)
				break
		if dialogue_active:
			return


func update_special_effects(delta: float) -> void:
	for i in range(special_effects.size() - 1, -1, -1):
		special_effects[i].life -= delta
		if special_effects[i].life <= 0.0:
			special_effects.remove_at(i)
	update_titan_laser_hits()
	if giant_shot_time_remaining > 0.0:
		giant_shot_time_remaining = maxf(0.0, giant_shot_time_remaining - delta)
		giant_shot_timer -= delta
		while giant_shot_timer <= 0.0 and giant_shot_time_remaining > 0.0 and giant_shot_count < ceili(float(player_stats.special_duration) / float(player_stats.special_interval)):
			spawn_giant_shot()
			giant_shot_count += 1
			giant_shot_timer += float(player_stats.special_interval)
	if viper_beam_time_remaining > 0.0:
		viper_beam_time_remaining = maxf(0.0, viper_beam_time_remaining - delta)
		viper_beam_tick_timer -= delta
		while viper_beam_tick_timer <= 0.0 and viper_beam_tick_index < int(player_stats.get("special_boss_percentages", []).size()):
			update_viper_beam_hits()
			viper_beam_tick_timer += float(player_stats.special_interval)
			if dialogue_active:
				return
	for i in range(beyblades.size() - 1, -1, -1):
		var blade: Dictionary = beyblades[i]
		blade.life -= delta
		blade.hit_timer -= delta
		blade.rotation = fmod(float(blade.rotation) + float(blade.spin_speed) * delta, TAU)
		blade.trail_timer -= delta
		var trail: Array = blade.trail
		for trail_index in range(trail.size() - 1, -1, -1):
			trail[trail_index].life -= delta
			if trail[trail_index].life <= 0.0:
				trail.remove_at(trail_index)
		if blade.trail_timer <= 0.0:
			trail.append({"pos": blade.pos, "rotation": blade.rotation, "life": 0.20, "max_life": 0.20})
			blade.trail_timer = 0.025
			while trail.size() > 8:
				trail.pop_front()
		if blade.life <= 0.0:
			beyblades.remove_at(i)
			continue
		blade.pos += blade.vel * delta
		var touched_border: bool = blade.pos.x <= 0.0 or blade.pos.x >= GAME_SIZE.x or blade.pos.y <= 0.0 or blade.pos.y >= GAME_SIZE.y
		if touched_border:
			blade.pos = Vector2(clampf(blade.pos.x, 0.0, GAME_SIZE.x), clampf(blade.pos.y, 0.0, GAME_SIZE.y))
			blade.to_border = false
			if not aim_blade_at_enemy(blade):
				blade.vel = -blade.vel
			blade.hit_timer = float(player_stats.special_hit_interval)
		if blade.hit_timer <= 0.0 and not blade.to_border:
			for enemy_index in range(enemies.size() - 1, -1, -1):
				if blade.pos.distance_squared_to(enemies[enemy_index].pos) < pow(float(enemies[enemy_index].radius) + 14.0, 2.0):
					var hit_enemy: Dictionary = enemies[enemy_index]
					var hit_id: int = hit_enemy.visual.get_instance_id()
					var was_boss: bool = hit_enemy.kind == BOSS_KIND
					var damage: float = float(player_stats.special_boss_damage) if was_boss else float(player_stats.special_damage)
					damage_enemy(enemy_index, damage)
					blade.hit_timer = float(player_stats.special_hit_interval)
					if was_boss or not aim_blade_at_enemy(blade, hit_id):
						send_blade_to_border(blade)
					break
		if dialogue_active:
			return


func update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy = enemies[i]
		if enemy.kind == BOSS_KIND:
			# แต่ละช่วงเปลี่ยนระยะส่าย ความเร็ว และตำแหน่งของบอส
			var phase: int = enemy.boss_phase
			var target_y := 270.0 if phase == 1 else (285.0 if phase == 2 else 300.0)
			var sway_speed := 1.15 if phase == 1 else (1.55 if phase == 2 else 1.9)
			var sway_width := 115.0 if phase == 1 else (145.0 if phase == 2 else 165.0)
			enemy.pos.y = minf(target_y, enemy.pos.y + 130.0 * delta)
			enemy.pos.x = GAME_SIZE.x * 0.5 + sin(elapsed * sway_speed) * sway_width
		else:
			enemy.pos += enemy.vel * delta
		if enemy.kind == 1:
			enemy.pos.x += sin(elapsed * 3.1 + enemy.phase) * 85.0 * delta
		elif enemy.kind == 2:
			enemy.pos.x += sin(elapsed * 1.6 + enemy.phase) * 35.0 * delta
		enemy.pos.x = clampf(enemy.pos.x, enemy.radius, GAME_SIZE.x - enemy.radius)
		enemy.visual.position = enemy.pos
		if enemy.kind == 1:
			enemy.visual.rotation = sin(elapsed * 3.1 + enemy.phase) * 0.13
		if enemy.kind == BOSS_KIND:
			var was_charging: bool = enemy.special_timer > 0.0
			update_boss_special(enemy, delta)
			# ระหว่างเตือนท่าพิเศษ บอสหยุดยิงธรรมดาเพื่อให้มีช่องหลบ
			if was_charging or enemy.special_timer > 0.0:
				continue
		enemy.shoot -= delta
		if enemy.shoot <= 0.0 and enemy.pos.y > 30.0:
			fire_enemy_weapon(enemy)
			if enemy.kind == BOSS_KIND:
				var phase_delay := 1.0 if enemy.boss_phase == 1 else (0.85 if enemy.boss_phase == 2 else 0.7)
				enemy.shoot = maxf(0.38, maxf(0.95, 1.45 - level * 0.08) * phase_delay * enemy.fire_interval_multiplier)
			else:
				var base_shoot: float = rng.randf_range(1.5, 2.8) if enemy.kind != 2 else rng.randf_range(0.75, 1.25)
				enemy.shoot = maxf(0.15, base_shoot * enemy.fire_interval_multiplier)
		if enemy.kind != BOSS_KIND and enemy.pos.y > GAME_SIZE.y + enemy.radius:
			free_enemy_visual(enemy)
			enemies.remove_at(i)


func enemy_attack_damage(kind: int) -> int:
	match kind:
		0: return 5
		1: return 12
		2: return 25
		_: return ceili(max_player_health * BOSS_DAMAGE_RATIO)


func add_enemy_bullet(origin: Vector2, velocity: Vector2, radius: float, kind: int, special: bool = false) -> void:
	enemy_bullets.append({"pos": origin, "vel": velocity, "radius": radius, "damage": enemy_attack_damage(kind), "special": special})


func fire_enemy_weapon(enemy: Dictionary) -> void:
	var enemy_position: Vector2 = enemy.pos
	var aim: Vector2 = (player_pos - enemy_position).normalized()
	var speed := 240.0 + level * 15.0 if enemy.kind == BOSS_KIND else (260.0 if enemy.kind == 2 else 220.0)
	if enemy.kind == BOSS_KIND:
		var angles := [-0.32, 0.0, 0.32]
		if enemy.boss_phase == 2:
			angles = [-0.52, -0.26, 0.0, 0.26, 0.52]
		elif enemy.boss_phase == 3:
			angles = [-0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6]
		for angle in angles:
			add_enemy_bullet(enemy.pos + Vector2(0.0, enemy.radius), aim.rotated(angle) * speed, 7.0, enemy.kind)
	elif enemy.kind == 2:
		for angle in [-0.18, 0.0, 0.18]:
			add_enemy_bullet(enemy.pos + Vector2(0.0, enemy.radius), aim.rotated(angle) * speed, 6.0, enemy.kind)
	else:
		add_enemy_bullet(enemy.pos + Vector2(0.0, enemy.radius), aim * speed, 5.0, enemy.kind)
	# กระสุนเสริมของสกิลใช้ทิศเล็งเดียวกันกับศัตรูและบอส
	for shot_index in range(int(enemy.extra_projectiles)):
		var ring := int(shot_index / 2) + 1
		var side := -1.0 if shot_index % 2 == 0 else 1.0
		var angle := side * (0.46 + (ring - 1) * 0.16)
		add_enemy_bullet(enemy.pos + Vector2(0.0, enemy.radius), aim.rotated(angle) * speed, 6.0, enemy.kind)


func update_boss_phase(enemy: Dictionary) -> void:
	# เรียกหลังบอสโดนยิง จึงเปลี่ยนช่วงทันทีที่ HP ข้าม 75% หรือ 50%
	var health_ratio: float = float(enemy.hp) / float(enemy.max_hp)
	var next_phase := 1
	if health_ratio <= BOSS_SPECIAL_RATIO:
		next_phase = 3
	elif health_ratio <= BOSS_PHASE_2_RATIO:
		next_phase = 2
	if next_phase <= enemy.boss_phase:
		return
	enemy.boss_phase = next_phase
	enemy.visual.modulate = Color("ffb454") if next_phase == 2 else Color("ff62d7")
	spawn_sparks(enemy.pos, enemy.visual.modulate, 22, 160.0)
	if next_phase == 3:
		# ล้างกระสุนเก่าแล้วเริ่มสัญญาณเตือนก่อนท่าพิเศษครั้งแรก
		enemy_bullets.clear()
		enemy.special_timer = BOSS_SPECIAL_WINDUP
		enemy.shoot = maxf(enemy.shoot, BOSS_SPECIAL_WINDUP)


func update_boss_special(enemy: Dictionary, delta: float) -> void:
	if enemy.boss_phase != 3:
		return
	if enemy.special_timer > 0.0:
		enemy.special_timer -= delta
		if enemy.special_timer <= 0.0:
			fire_boss_special(enemy)
			enemy.special_timer = -1.0
			enemy.special_cooldown = get_boss_special_cooldown()
			enemy.shoot = maxf(enemy.shoot, 0.45)
	else:
		enemy.special_cooldown -= delta
		if enemy.special_cooldown <= 0.0:
			enemy.special_timer = BOSS_SPECIAL_WINDUP


func fire_boss_special(enemy: Dictionary) -> void:
	# คลื่นกระสุนวงกลมเว้นช่องว่าง 3 ตำแหน่ง แล้วมีกระสุนนำเป้า 1 นัดบังคับให้ขยับหลบ
	var origin: Vector2 = enemy.pos + Vector2(0.0, enemy.radius * 0.45)
	var aimed_direction: Vector2 = (player_pos - origin).normalized()
	var start_angle: float = aimed_direction.angle()
	var speed := 190.0 + level * 12.0
	var projectile_count := get_boss_special_projectile_count()
	for shot_index in range(projectile_count):
		if shot_index == 0 or shot_index == 1 or shot_index == projectile_count - 1:
			continue
		var direction := Vector2.RIGHT.rotated(start_angle + TAU * float(shot_index) / float(projectile_count))
		add_enemy_bullet(origin, direction * speed, 8.0, BOSS_KIND, true)
	add_enemy_bullet(origin, aimed_direction * (speed + 45.0), 9.0, BOSS_KIND, true)
	spawn_sparks(origin, Color("ffd166"), 28, 225.0)


func get_boss_special_projectile_count() -> int:
	# ด่านหลัง ๆ กระสุนวงพิเศษถี่ขึ้น แต่ยังเว้นช่องหลบ 3 ตำแหน่ง
	return BOSS_SPECIAL_PROJECTILES + maxi(0, level - 1) * 2


func get_boss_special_cooldown() -> float:
	# ท่าพิเศษใช้ซ้ำเร็วขึ้นตามด่าน โดยไม่เร็วกว่าขั้นต่ำนี้
	return maxf(3.8, BOSS_SPECIAL_COOLDOWN - maxi(0, level - 1) * 0.4)


func update_pickups(delta: float) -> void:
	for i in range(pickups.size() - 1, -1, -1):
		pickups[i].pos.y += 105.0 * delta
		pickups[i].phase += delta * 4.0
		if pickups[i].pos.y > GAME_SIZE.y + 20.0:
			pickups.remove_at(i)


func resolve_collisions() -> void:
	for bullet_index in range(bullets.size() - 1, -1, -1):
		var hit := false
		for enemy_index in range(enemies.size() - 1, -1, -1):
			var enemy = enemies[enemy_index]
			var enemy_id: int = enemy.visual.get_instance_id()
			if bullets[bullet_index].get("hit_ids", []).has(enemy_id):
				continue
			var bullet_radius: float = float(bullets[bullet_index].get("radius", 5.0))
			if bullets[bullet_index].pos.distance_squared_to(enemy.pos) < pow(float(enemy.radius) + bullet_radius, 2.0):
				spawn_sparks(bullets[bullet_index].pos, Color("ffd166"), 5, 145.0)
				if bullets[bullet_index].has("pierce_remaining"):
					bullets[bullet_index].hit_ids.append(enemy_id)
					bullets[bullet_index].pierce_remaining -= 1
					hit = bullets[bullet_index].pierce_remaining <= 0
				else:
					hit = true
				var damage: float = float(bullets[bullet_index].get("damage", 1.0))
				if enemy.kind == BOSS_KIND:
					damage *= float(bullets[bullet_index].get("boss_damage_multiplier", 1.0))
				damage_enemy(enemy_index, damage)
				if hit or game_over or dialogue_active:
					break
		if hit:
			bullets.remove_at(bullet_index)
			if game_over or dialogue_active:
				return

	if invulnerable_timer <= 0.0:
		for i in range(enemy_bullets.size() - 1, -1, -1):
			if enemy_bullets[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + enemy_bullets[i].radius, 2.0):
				var incoming_damage: int = int(enemy_bullets[i].get("damage", 5))
				enemy_bullets.remove_at(i)
				damage_player(incoming_damage)
				break

	if invulnerable_timer <= 0.0:
		for i in range(enemies.size() - 1, -1, -1):
			if enemies[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + enemies[i].radius - 4.0, 2.0):
				var contact_damage: int = enemy_attack_damage(enemies[i].kind)
				if enemies[i].kind != BOSS_KIND:
					spawn_explosion(enemies[i].pos, enemy_color(enemies[i].kind), 18)
					free_enemy_visual(enemies[i])
					enemies.remove_at(i)
				damage_player(contact_damage)
				break

	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + 14.0, 2.0):
			player_health = mini(max_player_health, player_health + ceili(max_player_health * POTION_HEAL_RATIO))
			score += 75
			refresh_stage_level()
			best_score = maxi(best_score, score)
			spawn_explosion(pickups[i].pos, Color("65ff9a"), 14)
			pickups.remove_at(i)
	if not game_over and not dialogue_active and not boss_active and score >= score_target_for_level():
		spawn_boss()


func damage_enemy(index: int, amount: float) -> void:
	if index < 0 or index >= enemies.size() or amount <= 0.0:
		return
	var enemy: Dictionary = enemies[index]
	var previous_health: float = float(enemy.hp)
	enemy.hp = float(enemy.hp) - amount
	if enemy.kind == BOSS_KIND:
		for threshold in [0.75, 0.50, 0.25]:
			if previous_health > float(enemy.max_hp) * threshold and float(enemy.hp) <= float(enemy.max_hp) * threshold:
				pickups.append({"pos": enemy.pos + Vector2(rng.randf_range(-35.0, 35.0), 45.0), "phase": 0.0})
	if enemy.hp <= 0.0:
		destroy_enemy(index)
	elif enemy.kind == BOSS_KIND:
		update_boss_phase(enemy)


func destroy_enemy(index: int) -> void:
	var enemy = enemies[index]
	var was_boss: bool = enemy_has_tag(enemy, "Boss")
	score += enemy.worth
	refresh_stage_level()
	if was_boss:
		sea_tokens += COINS_PER_BOSS
		save_item_collection()
	best_score = maxi(best_score, score)
	spawn_explosion(enemy.pos, enemy_color(enemy.kind), 12 + enemy.kind * 7)
	shake_timer = 0.09 if enemy.kind < 2 else 0.22
	if not was_boss and rng.randf() < potion_drop_chance():
		pickups.append({"pos": enemy.pos, "phase": 0.0})
	free_enemy_visual(enemy)
	enemies.remove_at(index)
	if was_boss:
		boss_active = false
		enemy_bullets.clear()
		if endless_mode:
			complete_endless_boss()
		else:
			start_boss_dialogue()
	elif not boss_active and score >= score_target_for_level():
		spawn_boss()


func enemy_has_tag(enemy: Dictionary, tag: String) -> bool:
	var tags: Array = enemy.get("tags", [])
	return tag in tags


func potion_drop_chance() -> float:
	return 0.15 + float(clampi(level, 1, FINAL_LEVEL) - 1) * 0.025


func complete_endless_boss() -> void:
	endless_bosses_defeated += 1
	stage_level = endless_bosses_defeated % LEVELS_PER_STAGE + 1
	level = clampi(floori(float(endless_bosses_defeated) / float(LEVELS_PER_STAGE)) + 1, 1, FINAL_LEVEL)
	spawn_timer = 1.25
	invulnerable_timer = maxf(invulnerable_timer, 1.0)
	player_health = mini(max_player_health, player_health + ceili(max_player_health * 0.15))


func start_stage_intro() -> void:
	var intro_lines: Array[Dictionary] = DIALOGUE_CONFIG.get_intro_lines(level)
	if intro_lines.is_empty():
		return
	dialogue_active = true
	dialogue_index = 0
	dialogue_lines = intro_lines
	dialogue_completion = "intro"
	pointer_active = false
	slow_mouse_held = false
	slow_touch_index = -1
	enemy_bullets.clear()
	show_dialogue_line()


func start_boss_dialogue() -> void:
	# Stage เดิมคงอยู่ บทหลังการต่อสู้จะพาไป Phase 1-3 ตาม STORY
	dialogue_active = true
	dialogue_index = 0
	dialogue_lines = DIALOGUE_CONFIG.get_lines(level, stage_level)
	dialogue_completion = "phase"
	pointer_active = false
	slow_mouse_held = false
	slow_touch_index = -1
	if dialogue_lines.is_empty():
		# ถ้าลบบทสนทนาทั้งหมด ให้จบระดับหลังระบบชนกระสุนรอบนี้เสร็จ
		complete_stage.call_deferred()
		return
	show_dialogue_line()


func show_dialogue_line() -> void:
	dialogue_overlay.call("show_line", dialogue_lines[dialogue_index], dialogue_index, dialogue_lines.size(), special_stage_mode or stage_level >= LEVELS_PER_STAGE)


func advance_dialogue() -> void:
	if not dialogue_active or dialogue_lines.is_empty():
		return
	dialogue_index += 1
	if dialogue_index < dialogue_lines.size():
		show_dialogue_line()
	elif dialogue_completion == "intro":
		complete_intro_dialogue()
	else:
		complete_stage()


func complete_intro_dialogue() -> void:
	if not dialogue_active:
		return
	dialogue_overlay.hide()
	dialogue_active = false
	dialogue_lines.clear()
	dialogue_completion = ""
	invulnerable_timer = maxf(invulnerable_timer, 1.25)
	queue_redraw()


func complete_stage() -> void:
	if not dialogue_active:
		return
	# ล้างวัตถุจากด่านเดิมหลังข้อความสุดท้ายเท่านั้น
	dialogue_overlay.hide()
	dialogue_active = false
	dialogue_lines.clear()
	dialogue_completion = ""
	for enemy in enemies:
		free_enemy_visual(enemy)
	enemies.clear()
	bullets.clear()
	enemy_bullets.clear()
	pickups.clear()
	beyblades.clear()
	special_effects.clear()
	laser_hit_ids.clear()
	giant_shot_time_remaining = 0.0
	viper_beam_time_remaining = 0.0
	viper_beam_hits.clear()
	if special_stage_mode:
		razor_special_cleared = true
		if 3 not in unlocked_ships:
			unlocked_ships.append(3)
		selected_character = 3
		save_item_collection()
		finish_game(true)
		return
	if stage_level >= LEVELS_PER_STAGE:
		collect_boss_item(level)
		highest_unlocked_stage = maxi(highest_unlocked_stage, mini(level + 1, FINAL_LEVEL))
		save_item_collection()
		finish_game(true)
		return
	stage_level += 1
	spawn_timer = 1.5
	invulnerable_timer = maxf(invulnerable_timer, 1.25)
	player_health = mini(max_player_health, player_health + ceili(max_player_health * 0.25))


func collect_boss_item(stage: int) -> void:
	if BOSS_REWARDS.has(stage) and not item_collection.has(stage):
		item_collection.append(stage)
		save_item_collection()


func get_story_boss_name(stage: int = level) -> String:
	return DIALOGUE_CONFIG.get_boss_name(stage)


func get_story_stage_area(stage: int = level) -> String:
	return DIALOGUE_CONFIG.get_stage_area(stage)


func free_enemy_visual(enemy: Dictionary) -> void:
	var visual := enemy.get("visual") as Node
	if is_instance_valid(visual):
		visual.queue_free()


func damage_player(amount: int = 5) -> void:
	if game_over or invulnerable_timer > 0.0:
		return
	player_health = maxi(0, player_health - amount)
	invulnerable_timer = 1.25
	shake_timer = 0.32
	flash_timer = 0.12
	spawn_explosion(player_pos, Color("7df9ff"), 22)
	if player_health <= 0:
		finish_game(false)


func finish_game(won: bool) -> void:
	if game_over:
		return
	game_over = true
	victory = won
	summary_timer = SUMMARY_DURATION
	best_score = maxi(best_score, score)
	if endless_mode:
		record_endless_score()
	pointer_active = false
	slow_mouse_held = false
	slow_touch_index = -1
	player_sprite.visible = false


func spawn_sparks(origin: Vector2, color: Color, count: int, speed: float) -> void:
	for i in range(count):
		var direction := Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
		particles.append({
			"pos": origin,
			"vel": direction * rng.randf_range(speed * 0.35, speed),
			"life": rng.randf_range(0.18, 0.42),
			"max_life": 0.42,
			"color": color,
			"size": rng.randf_range(1.5, 3.8)
		})


func spawn_explosion(origin: Vector2, color: Color, count: int) -> void:
	spawn_sparks(origin, color, count, 245.0)
	particles.append({"pos": origin, "vel": Vector2.ZERO, "life": 0.25, "max_life": 0.25, "color": Color.WHITE, "size": 13.0})


func update_particles(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		particles[i].life -= delta
		particles[i].pos += particles[i].vel * delta
		particles[i].vel *= 0.94
		if particles[i].life <= 0.0:
			particles.remove_at(i)


func enemy_color(kind: int) -> Color:
	if kind == BOSS_KIND:
		return Color("ff6961")
	if kind == 1:
		return Color("ff66d8")
	if kind == 2:
		return Color("ff9f43")
	return Color("ff4d6d")


func _draw() -> void:
	draw_set_transform(shake_offset)
	draw_world()
	draw_set_transform(Vector2.ZERO)


func draw_world() -> void:
	for pickup in pickups:
		draw_pickup(pickup)
	for bullet in bullets:
		var bullet_radius: float = float(bullet.get("radius", 5.0))
		if not draw_visual(String(bullet.get("visual_key", "player_normal")), bullet.pos, Vector2.ONE * bullet_radius * 3.0):
			draw_line(bullet.pos + Vector2(0.0, 13.0), bullet.pos, Color(0.30, 0.95, 1.0, 0.3), 5.0)
			draw_circle(bullet.pos, bullet_radius, Color("d8ffff"))
	for bullet in enemy_bullets:
		var is_special: bool = bullet.get("special", false)
		if not draw_visual("enemy_special" if is_special else "enemy_normal", bullet.pos, Vector2.ONE * (float(bullet.radius) + 5.0) * 2.0):
			draw_circle(bullet.pos, bullet.radius + 4.0, Color(1.0, 0.75, 0.25, 0.18) if is_special else Color(1.0, 0.1, 0.4, 0.12))
			draw_circle(bullet.pos, bullet.radius, Color("ffd166") if is_special else Color("ff477e"))
	for effect in special_effects:
		if effect.kind == "laser":
			var x: float = player_pos.x + float(effect.offset)
			var start := Vector2(x, player_pos.y)
			var end := Vector2(x, 0.0)
			draw_line(start, end, Color(0.3, 0.9, 1.0, 0.36), float(player_stats.laser_width) + 18.0)
			draw_line(start, end, Color("e9ffff"), float(player_stats.laser_width))
	if viper_beam_time_remaining > 0.0:
		var beam_alpha := minf(1.0, viper_beam_time_remaining * 4.0)
		var beam_start := player_pos + Vector2(0.0, -20.0)
		var beam_end := Vector2(player_pos.x, 0.0)
		draw_line(beam_start, beam_end, Color(0.45, 0.35, 1.0, 0.32 * beam_alpha), float(player_stats.beam_width) + 42.0)
		draw_line(beam_start, beam_end, Color(0.72, 0.5, 1.0, 0.85 * beam_alpha), float(player_stats.beam_width))
		draw_line(beam_start, beam_end, Color(1.0, 0.95, 1.0, beam_alpha), float(player_stats.beam_width) * 0.48)
		draw_circle(beam_start, float(player_stats.beam_width) * 0.52, Color(0.9, 0.65, 1.0, beam_alpha))
	for blade in beyblades:
		var visual_key: String = blade.get("visual_key", "beyblade")
		var visual_size: Vector2 = blade.get("visual_size", Vector2(72.0, 72.0))
		for trail_frame in blade.get("trail", []):
			var trail_alpha: float = 0.34 * float(trail_frame.life) / float(trail_frame.max_life)
			if not draw_rotated_visual(visual_key, trail_frame.pos, visual_size, float(trail_frame.rotation), Color(1.0, 1.0, 1.0, trail_alpha)):
				draw_circle(trail_frame.pos, 25.0, Color(1.0, 0.46, 0.82, trail_alpha))
		if not draw_rotated_visual(visual_key, blade.pos, visual_size, float(blade.get("rotation", 0.0))):
			draw_circle(blade.pos, 15.0, Color("ff75d0"))
	for enemy in enemies:
		if enemy.kind == BOSS_KIND and enemy.special_timer > 0.0:
			# วงเตือนจะขยายและสว่างขึ้นก่อนปล่อยกระสุนพิเศษ
			var charge: float = 1.0 - enemy.special_timer / BOSS_SPECIAL_WINDUP
			draw_arc(enemy.pos, enemy.radius + 13.0 + charge * 12.0, 0.0, TAU, 48, Color(1.0, 0.82, 0.4, 0.45 + charge * 0.5), 4.0)
		if enemy.kind == BOSS_KIND:
			var boss_bar_width: float = enemy.radius * 2.45
			var boss_bar_position: Vector2 = enemy.pos + Vector2(-boss_bar_width * 0.5, -enemy.radius - 20.0)
			var boss_bar := Rect2(boss_bar_position, Vector2(boss_bar_width, 9.0))
			var boss_ratio: float = clampf(float(enemy.hp) / float(enemy.max_hp), 0.0, 1.0)
			var boss_color := Color("ff5f72") if enemy.boss_phase == 1 else (Color("ffb454") if enemy.boss_phase == 2 else Color("ff62d7"))
			draw_rect(boss_bar.grow(3.0), Color(0.01, 0.015, 0.04, 0.88))
			draw_rect(boss_bar, Color(0.20, 0.035, 0.08, 0.94))
			draw_rect(Rect2(boss_bar.position, Vector2(boss_bar.size.x * boss_ratio, boss_bar.size.y)), boss_color)
			draw_rect(boss_bar, Color(1.0, 0.82, 0.88, 0.82), false, 1.0)
		elif enemy.max_hp > 1 and enemy.hp < enemy.max_hp:
			var width: float = enemy.radius * 1.8
			draw_rect(Rect2(enemy.pos + Vector2(-width * 0.5, -enemy.radius - 11.0), Vector2(width, 3.0)), Color(0.15, 0.05, 0.1, 0.9))
			draw_rect(Rect2(enemy.pos + Vector2(-width * 0.5, -enemy.radius - 11.0), Vector2(width * float(enemy.hp) / float(enemy.max_hp), 3.0)), Color("ffe66d"))
	for particle in particles:
		var ratio: float = clampf(particle.life / particle.max_life, 0.0, 1.0)
		var color: Color = particle.color
		color.a = ratio
		draw_circle(particle.pos, particle.size * (0.55 + ratio * 0.45), color)
func draw_pickup(pickup: Dictionary) -> void:
	var pos: Vector2 = pickup.pos
	var pulse := 1.0 + sin(pickup.phase) * 0.12
	if draw_visual("health_pickup", pos, Vector2.ONE * 33.0 * pulse):
		return
	draw_circle(pos, 18.0 * pulse, Color(0.2, 1.0, 0.5, 0.12))
	draw_circle(pos, 12.0, Color("22c96b"))
	draw_rect(Rect2(pos - Vector2(2.5, 8.0), Vector2(5.0, 16.0)), Color.WHITE)
	draw_rect(Rect2(pos - Vector2(8.0, 2.5), Vector2(16.0, 5.0)), Color.WHITE)


func draw_visual(key: String, center: Vector2, size: Vector2) -> bool:
	var texture: Texture2D = visual_textures.get(key)
	if texture == null:
		return false
	draw_texture_rect(texture, Rect2(center - size * 0.5, size), false)
	return true


func draw_rotated_visual(key: String, center: Vector2, size: Vector2, rotation: float, modulate: Color = Color.WHITE) -> bool:
	var texture: Texture2D = visual_textures.get(key)
	if texture == null:
		return false
	draw_set_transform(shake_offset + center, rotation)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, modulate)
	draw_set_transform(shake_offset)
	return true


func apply_visual_override(visual: Sprite2D, key: String) -> void:
	# ถ้า path ใน visual_config.gd ว่าง ให้ใช้ภาพที่เลือกใน Scene ตามเดิม
	var texture: Texture2D = visual_textures.get(key)
	if texture != null:
		visual.texture = texture

extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func finish_intro(game: Node) -> void:
	assert(game.dialogue_active)
	assert(game.dialogue_completion == "intro")
	var guard := 0
	while game.dialogue_active and guard < 100:
		game.advance_dialogue()
		guard += 1
	assert(not game.dialogue_active and guard < 100)


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	game.collection_save_path = "user://item_collection_smoke.json"
	if FileAccess.file_exists(game.collection_save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(game.collection_save_path))
	game.item_collection.clear()
	game.sea_tokens = 0
	game.turtle_shop_unlocked = true
	game.highest_unlocked_stage = 1
	game.stage_one_tutorial_seen = false
	game.endless_scores.clear()
	game.unlocked_ships.clear()
	for ship_index in range(game.PLAYER_SCENES.size()):
		game.unlocked_ships.append(ship_index)
	var menu_click := InputEventMouseButton.new()
	menu_click.button_index = MOUSE_BUTTON_LEFT
	menu_click.pressed = true
	assert(game.menu_page == "home")
	menu_click.position = game.LAUNCH_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "stage")
	game._process(1.0)
	assert(game.stage_popup_progress == 1.0)
	menu_click.position = game.STAGE_CARDS[2].get_center()
	game._unhandled_input(menu_click)
	assert(game.selected_stage == 1)
	assert(not game.is_stage_unlocked(3))
	game.highest_unlocked_stage = 3
	game._unhandled_input(menu_click)
	assert(game.selected_stage == 3 and game.is_stage_unlocked(3))
	menu_click.position = game.STAGE_START_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(not game.selecting_character)
	assert(game.level == 3 and game.score == 0)
	assert(game.dialogue_overlay.visible)
	assert(game.dialogue_lines[0].speaker == "เส")
	assert(game.DIALOGUE_CONFIG.get_stage(3).record == "เรื่องเล่าของเสนาหอย")
	finish_intro(game)
	assert(game.score_target_for_level() == game.LEVEL_SCORE_STEP)
	game.score = 1000
	game.refresh_stage_level()
	assert(game.stage_level == 1)
	game.score = 2000
	game.refresh_stage_level()
	assert(game.stage_level == 1)
	game.score = game.LEVEL_SCORE_STEP
	game.resolve_collisions()
	assert(game.boss_active and game.enemies[0].boss_phase == 1)
	game.show_character_select()
	menu_click.position = game.LAUNCH_BUTTON.get_center()
	game._unhandled_input(menu_click)
	game._process(1.0)
	menu_click.position = game.STAGE_CARDS[0].get_center()
	game._unhandled_input(menu_click)
	menu_click.position = game.MENU_BACK_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.selected_stage == 1)
	game.highest_unlocked_stage = 1
	assert(game.menu_page == "home")
	var swipe_start := InputEventScreenTouch.new()
	swipe_start.index = 0
	swipe_start.pressed = true
	swipe_start.position = Vector2(400.0, 400.0)
	game._input(swipe_start)
	var swipe_drag := InputEventScreenDrag.new()
	swipe_drag.index = 0
	swipe_drag.position = Vector2(290.0, 400.0)
	game._input(swipe_drag)
	assert(game.selected_character == 1)
	swipe_start.pressed = false
	game._input(swipe_start)
	assert(game.is_ship_unlocked(1))
	assert(game.selected_character == 1)
	game.selected_character = 2
	menu_click.position = game.LAUNCH_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "stage" and game.selecting_character)
	game._process(1.0)
	menu_click.position = game.STAGE_START_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.dialogue_active and game.dialogue_lines[0].text.begins_with("โทมัส?"))
	assert(game.get_story_boss_name() == "โทมัส")
	assert(game.get_story_stage_area() == "แนวปะการังและโพรงหิน")
	finish_intro(game)
	game.spawn_enemy()
	await process_frame
	var background = game.get_node("ParallaxBackground")
	assert(not game.selecting_character)
	assert(game.max_player_health == 100)
	assert(game.player_sprite is CombatantVisual)
	assert(game.player_sprite.get_skill_names().is_empty())
	assert("HULL 100" in game.get_node("HUD/Renderer").ship_stat_lines[2][0])
	assert(game.get_node("HUD/Renderer").ship_stat_lines.size() == 5)
	assert(game.get_node("HUD/Renderer").ship_textures.size() == 5)
	assert(game.get_node("HUD/Renderer").has_method("draw_menu_gradient_text"))
	assert(game.get_node("HUD/Renderer").MENU_TEXT_STROKE_SIZE == 4)
	assert(game.get_node("HUD/Renderer").MENU_TEXT_INNER_STROKE_SIZE == 2)
	assert(game.get_node("HUD/Renderer").MENU_TEXT_SHADOW_OFFSET == Vector2(5.0, 7.0))
	assert(game.get_node("HUD/Renderer").ship_textures[3] != game.get_node("HUD/Renderer").ship_textures[4])
	assert(game.player_sprite.texture != null)
	assert(game.get_ship_display_name(0) == "JOHNY")
	assert(game.get_ship_display_name(1) == "JOHNY SAPARROW")
	assert(game.get_ship_display_name(2) == "PICHU JOHNY")
	assert(game.get_ship_display_name(3) == "SANTA JOHNY")
	assert(game.get_ship_display_name(4) == "STRAW HAT JOHNY")
	assert(game.DIALOGUE_CONFIG.CHARACTERS.size() >= 7)
	assert(game.DIALOGUE_CONFIG.STAGES.size() == game.FINAL_LEVEL + 1)
	var expected_story_bosses := ["โทมัส", "คราม", "เส และ นา", "หมึกเลนส์", "ทู"]
	var expected_records := ["บ้านของปูเสฉวน", "เส้นใยในตัวปูม้า", "เรื่องเล่าของเสนาหอย", "แผนที่ขยะทะเล", "เพื่อนร่วมทะเล"]
	for story_stage in range(1, game.FINAL_LEVEL + 1):
		assert(game.DIALOGUE_CONFIG.get_boss_name(story_stage) == expected_story_bosses[story_stage - 1])
		assert(game.DIALOGUE_CONFIG.get_record_name(story_stage) == expected_records[story_stage - 1])
		assert(not game.DIALOGUE_CONFIG.get_intro_lines(story_stage).is_empty())
		for story_phase in range(1, game.LEVELS_PER_STAGE + 1):
			assert(not game.DIALOGUE_CONFIG.get_lines(story_stage, story_phase).is_empty())
	assert(game.DIALOGUE_CONFIG.get_boss_name(game.SPECIAL_BOSS_LEVEL) == "ผู้พิทักษ์ Razor")
	assert(not game.DIALOGUE_CONFIG.get_intro_lines(game.SPECIAL_BOSS_LEVEL).is_empty())
	assert(not game.DIALOGUE_CONFIG.get_lines(game.SPECIAL_BOSS_LEVEL, 1).is_empty())
	assert(game.RESEARCH_CONFIG.RESEARCH_BY_STAGE.size() == game.FINAL_LEVEL)
	assert(str(game.RESEARCH_CONFIG.get_entry(1).source_url).begins_with("https://doi.org/"))
	assert("กุญแจ" in game.DIALOGUE_CONFIG.get_lines(5, 3)[3].text)
	assert(game.DIALOGUE_CONFIG.get_lines(1, 1)[1].speaker == "Johny")
	assert(game.enemies.size() == 1)
	assert(background.active_layers.size() == 3)
	var health_before_escape: int = game.player_health
	var escaped_enemy: Dictionary = game.enemies[0]
	escaped_enemy.pos = Vector2(100.0, game.GAME_SIZE.y + escaped_enemy.radius - 1.0)
	escaped_enemy.shoot = 10.0
	game.invulnerable_timer = 0.0
	game.update_enemies(0.1)
	assert(game.enemies.is_empty())
	assert(game.player_health == health_before_escape)
	assert(not game.game_over)
	game.spawn_enemy()
	game.enemies[0].pos = game.player_pos
	game.resolve_collisions()
	assert(game.enemies.is_empty())
	assert(game.player_health == health_before_escape - 5)
	assert(game.enemy_attack_damage(0) == 5)
	assert(game.enemy_attack_damage(1) == 12)
	assert(game.enemy_attack_damage(2) == 25)
	assert(game.enemy_attack_damage(game.BOSS_KIND) == 20)
	assert(is_equal_approx(game.potion_drop_chance(), 0.15))
	game.player_health = 50
	game.pickups.append({"pos": game.player_pos, "phase": 0.0})
	game.resolve_collisions()
	assert(game.player_health == 75)
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 540)
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 960)
	assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep")
	assert(game.LEVEL_SCORE_STEP == 5000 and game.LEVELS_PER_STAGE == 3)
	game.spawn_timer = 100.0
	game.fire_timer = 0.0
	game.update_game(0.1)
	assert(not game.bullets.is_empty())
	game.bullets.clear()
	game.fire_timer = 100.0
	var touch_start := InputEventScreenTouch.new()
	touch_start.index = 0
	touch_start.pressed = true
	touch_start.position = game.player_pos
	game._input(touch_start)
	var touch_drag := InputEventScreenDrag.new()
	touch_drag.index = 0
	touch_drag.position = game.player_pos + Vector2(80.0, -40.0)
	game._input(touch_drag)
	var old_x: float = game.player_pos.x
	var touch_start_pos: Vector2 = game.player_pos
	game.update_game(0.1)
	assert(game.player_pos.x > old_x)
	assert(is_equal_approx(game.player_pos.distance_to(touch_start_pos), game.player_speed * 0.1))
	touch_start.pressed = false
	game._input(touch_start)
	assert(not game.pointer_active)
	var mouse_down := InputEventMouseButton.new()
	mouse_down.button_index = MOUSE_BUTTON_LEFT
	mouse_down.pressed = true
	mouse_down.position = game.player_pos
	game._input(mouse_down)
	var mouse_drag := InputEventMouseMotion.new()
	mouse_drag.position = game.player_pos + Vector2(-80.0, 0.0)
	game._input(mouse_drag)
	old_x = game.player_pos.x
	game.update_game(0.1)
	assert(game.player_pos.x < old_x)
	mouse_down.pressed = false
	game._input(mouse_down)
	assert(game.pointer_active and game.pointer_index == -2)
	var mouse_hover := InputEventMouseMotion.new()
	mouse_hover.position = game.player_pos + Vector2(80.0, 0.0)
	game._input(mouse_hover)
	assert(game.pointer_active and game.pointer_index == -2)
	old_x = game.player_pos.x
	game.update_game(0.1)
	assert(is_equal_approx(game.player_pos.x - old_x, game.player_speed * 0.1))
	var move_key := InputEventKey.new()
	move_key.keycode = KEY_A
	move_key.pressed = true
	game._input(move_key)
	assert(not game.pointer_active)
	old_x = game.player_pos.x
	mouse_hover.position = game.player_pos + Vector2(80.0, 0.0)
	game._input(mouse_hover)
	game.update_game(0.1)
	assert(game.player_pos.x == old_x)
	mouse_down.pressed = true
	mouse_down.position = game.player_pos
	game._input(mouse_down)
	assert(game.pointer_active and game.pointer_index == -1)
	mouse_down.pressed = false
	game._input(mouse_down)
	# Shift ลดความเร็วจริงทั้งเวลาขยับด้วยเมาส์และปุ่มบนคีย์บอร์ด
	game.player_pos = Vector2(270.0, 850.0)
	game.pointer_target = Vector2(470.0, 850.0)
	game.fire_timer = 100.0
	game.spawn_timer = 100.0
	game.update_game(0.1)
	var normal_move: float = game.player_pos.x - 270.0
	var shift_key := InputEventKey.new()
	shift_key.keycode = KEY_SHIFT
	shift_key.pressed = true
	game._input(shift_key)
	assert(game.is_slow_mode_active())
	game.player_pos = Vector2(270.0, 850.0)
	game.update_game(0.1)
	var slow_move: float = game.player_pos.x - 270.0
	assert(is_equal_approx(slow_move, normal_move * game.SLOW_SPEED_MULTIPLIER))
	shift_key.pressed = false
	game._input(shift_key)
	assert(not game.is_slow_mode_active())
	# มือถือกดปุ่ม SLOW ค้างด้วยนิ้วที่สองได้ โดยไม่ปล่อยนิ้วที่ควบคุมยาน
	var slow_touch := InputEventScreenTouch.new()
	slow_touch.index = 1
	slow_touch.pressed = true
	slow_touch.position = game.SLOW_BUTTON.get_center()
	game._input(slow_touch)
	assert(game.is_slow_mode_active() and game.pointer_active)
	slow_touch.pressed = false
	game._input(slow_touch)
	assert(not game.is_slow_mode_active() and game.pointer_active)
	var pause_touch := InputEventScreenTouch.new()
	pause_touch.index = 1
	pause_touch.pressed = true
	pause_touch.position = Vector2(480.0, 40.0)
	game._input(pause_touch)
	assert(game.paused)
	pause_touch.pressed = false
	game._input(pause_touch)
	pause_touch.pressed = true
	game._input(pause_touch)
	assert(not game.paused)
	var expected_boss_names := ["Bulwark", "Bulwark", "Bulwark"]
	var expected_extra_shots := [0, 0, 0]
	var expected_fire_multipliers := [1.0, 1.0, 1.0]
	var previous_boss_hp := 0
	for expected_level in range(1, game.LEVELS_PER_STAGE + 1):
		assert(is_equal_approx(game.potion_drop_chance(), 0.15))
		game.score = expected_level * game.LEVEL_SCORE_STEP - 100
		game.spawn_enemy()
		assert(game.enemies.size() == 1)
		game.enemies[0].pos = Vector2(100.0, 350.0)
		game.enemies[0].hp = 1
		game.bullets.append({"pos": Vector2(100.0, 350.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.boss_active)
		assert(game.enemies.size() == 1)
		assert(game.enemies[0].kind == game.BOSS_KIND)
		var potion_count_before_boss: int = game.pickups.size()
		var boss_visual: CombatantVisual = game.enemies[0].visual as CombatantVisual
		assert(boss_visual.get_skill_names() == PackedStringArray([expected_boss_names[expected_level - 1]]))
		assert(game.enemies[0].max_hp == ceili((game.BOSS_HP_BASE + game.level * game.BOSS_HP_PER_LEVEL + (expected_level - 1) * 16) * 1.5))
		assert(game.enemies[0].max_hp > previous_boss_hp)
		previous_boss_hp = game.enemies[0].max_hp
		assert(game.enemies[0].boss_phase == 1)
		assert(game.enemies[0].extra_projectiles == expected_extra_shots[expected_level - 1])
		assert(is_equal_approx(game.enemies[0].fire_interval_multiplier, expected_fire_multipliers[expected_level - 1]))
		game.fire_enemy_weapon(game.enemies[0])
		assert(game.enemy_bullets.size() == 3 + expected_extra_shots[expected_level - 1])
		assert(game.enemy_bullets[0].damage == 20)
		game.enemy_bullets.clear()
		if expected_level == 1:
			var health_before_boss_contact: int = game.player_health
			game.invulnerable_timer = 0.0
			game.enemies[0].pos = game.player_pos
			game.resolve_collisions()
			assert(game.player_health == health_before_boss_contact - 20)
			assert(game.boss_active and game.enemies.size() == 1)
		# ทุกด่านต้องเปลี่ยนรูปแบบยิงที่ HP 75% และเริ่มท่าพิเศษที่ HP 50%
		game.enemies[0].pos = Vector2(270.0, 300.0)
		game.enemies[0].hp = floori(game.enemies[0].max_hp * game.BOSS_PHASE_2_RATIO) + 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.enemies[0].boss_phase == 2)
		assert(game.pickups.size() == potion_count_before_boss + 1)
		assert(game.enemies[0].special_timer < 0.0)
		game.fire_enemy_weapon(game.enemies[0])
		assert(game.enemy_bullets.size() == 5 + expected_extra_shots[expected_level - 1])
		game.enemy_bullets.clear()
		game.enemies[0].hp = floori(game.enemies[0].max_hp * game.BOSS_SPECIAL_RATIO) + 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.enemies[0].boss_phase == 3)
		assert(game.pickups.size() == potion_count_before_boss + 2)
		assert(game.enemies[0].special_timer == game.BOSS_SPECIAL_WINDUP)
		game.fire_enemy_weapon(game.enemies[0])
		assert(game.enemy_bullets.size() == 7 + expected_extra_shots[expected_level - 1])
		game.enemy_bullets.clear()
		game.enemies[0].shoot = 100.0
		game.update_enemies(game.BOSS_SPECIAL_WINDUP * 0.5)
		assert(game.enemy_bullets.is_empty())
		game.update_enemies(game.BOSS_SPECIAL_WINDUP * 0.5 + 0.05)
		assert(game.enemy_bullets.size() == game.get_boss_special_projectile_count() - 2)
		for special_bullet in game.enemy_bullets:
			assert(special_bullet.special)
		game.enemy_bullets.clear()
		assert(is_equal_approx(game.enemies[0].special_cooldown, game.get_boss_special_cooldown()))
		game.update_enemies(game.get_boss_special_cooldown() + 0.05)
		assert(game.enemies[0].special_timer > 0.0)
		game.update_enemies(game.BOSS_SPECIAL_WINDUP + 0.05)
		assert(game.enemy_bullets.size() == game.get_boss_special_projectile_count() - 2)
		game.enemy_bullets.clear()
		game.enemies[0].pos = Vector2(270.0, 300.0)
		game.enemies[0].hp = floori(game.enemies[0].max_hp * 0.25) + 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.pickups.size() == potion_count_before_boss + 3)
		game.enemies[0].pos = Vector2(270.0, 300.0)
		game.enemies[0].hp = 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.enemies.is_empty())
		assert(not game.boss_active)
		assert(game.dialogue_active)
		assert(game.dialogue_overlay.visible)
		assert(game.dialogue_completion == "phase")
		assert(game.level == 1 and game.stage_level == expected_level)
		assert(not game.game_over)
		var dialogue_body: Label = game.dialogue_overlay.get_node("Panel/Body")
		var dialogue_counter: Label = game.dialogue_overlay.get_node("Panel/Counter")
		assert(dialogue_body.get_theme_font("font").has_char(0x0E01))
		assert(dialogue_body.text == game.dialogue_lines[0].text)
		assert(game.dialogue_lines[0].speaker == "โทมัส")
		assert(dialogue_counter.text == "1 / %d" % game.dialogue_lines.size())
		var original_dialogue_count: int = game.dialogue_lines.size()
		if expected_level == 1:
			game.dialogue_lines.append({"speaker": "ทดสอบ", "text": "เพิ่มข้อความ", "portrait": "", "accent": "#ff6961"})
			game.show_dialogue_line()
			assert(game.dialogue_lines.size() == original_dialogue_count + 1)
		elif expected_level == 2:
			game.dialogue_lines.remove_at(1)
			game.show_dialogue_line()
			assert(game.dialogue_lines.size() == original_dialogue_count - 1)
		var frozen_elapsed: float = game.elapsed
		var frozen_spawn_timer: float = game.spawn_timer
		game._process(2.0)
		assert(game.elapsed == frozen_elapsed)
		assert(game.spawn_timer == frozen_spawn_timer)
		var dialogue_count: int = game.dialogue_lines.size()
		assert(dialogue_count >= 1)
		for line_index in range(dialogue_count):
			if expected_level == 1:
				var next_touch := InputEventScreenTouch.new()
				next_touch.index = 0
				next_touch.pressed = true
				game._input(next_touch)
				next_touch.pressed = false
				game._input(next_touch)
			elif expected_level == 2:
				var next_click := InputEventMouseButton.new()
				next_click.button_index = MOUSE_BUTTON_LEFT
				next_click.pressed = true
				game._input(next_click)
				next_click.pressed = false
				game._input(next_click)
			else:
				var next_key := InputEventKey.new()
				next_key.keycode = KEY_SPACE
				next_key.pressed = true
				game._input(next_key)
			if line_index < dialogue_count - 1:
				assert(game.dialogue_active)
				assert(game.dialogue_index == line_index + 1)
				assert(dialogue_body.text == game.dialogue_lines[line_index + 1].text)
				assert(dialogue_counter.text == "%d / %d" % [line_index + 2, dialogue_count])
				assert(game.level == 1 and game.stage_level == expected_level)
				assert(not game.game_over)
		assert(not game.dialogue_active)
		assert(not game.dialogue_overlay.visible)
		if expected_level < game.LEVELS_PER_STAGE:
			assert(not game.item_collection.has(1))
			assert(game.stage_level == expected_level + 1)
			assert(not game.game_over)
			assert(game.sea_tokens == expected_level)
		else:
			assert(game.item_collection.has(1))
			assert(game.turtle_shop_unlocked and game.sea_tokens == game.SEA_TOKENS_PER_CLEAR)
	assert(game.game_over and game.victory)
	assert(game.score >= game.LEVELS_PER_STAGE * game.LEVEL_SCORE_STEP)
	var final_score: int = game.score
	game._process(game.SUMMARY_DURATION + 0.1)
	assert(game.selecting_character)
	assert(game.best_score == final_score)
	assert(game.item_collection.size() == 1)
	game.collection_save_path = "user://item_collection_smoke.json"
	assert(game.highest_unlocked_stage == 2)
	game.save_item_collection()
	assert(FileAccess.file_exists(game.collection_save_path))
	game.item_collection.clear()
	game.load_item_collection()
	assert(game.item_collection.size() == 1)
	assert(game.sea_tokens == game.SEA_TOKENS_PER_CLEAR)
	assert(game.turtle_shop_unlocked)
	assert(game.highest_unlocked_stage == 2)
	assert(game.stage_one_tutorial_seen)
	game.unlocked_ships.clear()
	for default_ship in game.DEFAULT_UNLOCKED_SHIPS:
		game.unlocked_ships.append(default_ship)
	assert(game.DEFAULT_UNLOCKED_SHIPS == [0])
	assert(game.is_ship_unlocked(0))
	assert(not game.is_ship_unlocked(1) and not game.is_ship_unlocked(2) and not game.is_ship_unlocked(3) and not game.is_ship_unlocked(4))
	game.selected_character = 1
	assert(game.can_buy_turtle_ship(0))
	menu_click.position = game.SHIP_LOCK_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.purchase_overlay_visible)
	await process_frame
	assert(game.get_selected_ship_purchase_status() == "READY TO BUY WITH COIN")
	menu_click.position = game.PURCHASE_CONFIRM_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(not game.purchase_overlay_visible)
	assert(game.sea_tokens == 1 and game.is_ship_unlocked(1) and game.selected_character == 1)
	game.selected_character = 4
	assert(not game.can_buy_turtle_ship(3))
	assert(game.get_selected_ship_purchase_status() == "REACH 30,000 SCORE IN ENDLESS MODE")
	game.selected_character = 3
	assert(game.is_ship_visible(3) and game.is_razor_special_stage_available())
	menu_click.position = game.LAUNCH_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.special_stage_mode and not game.selecting_character and game.level == game.SPECIAL_BOSS_LEVEL)
	assert(game.selected_character == 0 and game.dialogue_active)
	finish_intro(game)
	assert(game.score_target_for_level() == game.SPECIAL_STAGE_SCORE_TARGET)
	game.spawn_boss()
	assert(game.enemies[0].visual.scene_file_path == "res://characters/bosses/dreadnought.tscn")
	assert(game.enemy_has_tag(game.enemies[0], "Boss"))
	var special_boss_visual: CombatantVisual = game.enemies[0].visual as CombatantVisual
	assert(special_boss_visual.get_skill_names() == PackedStringArray(["Razor Guardian"]))
	game.enemies[0].pos = Vector2(270.0, 300.0)
	game.enemies[0].hp = 1
	game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
	game.resolve_collisions()
	assert(game.dialogue_active and game.sea_tokens == 2)
	while game.dialogue_active:
		game.advance_dialogue()
	assert(game.game_over and game.victory and game.razor_special_cleared)
	assert(game.is_ship_unlocked(3) and game.selected_character == 3)
	game._process(game.SUMMARY_DURATION + 0.1)
	assert(game.selecting_character and not game.special_stage_mode)
	menu_click.position = game.HOME_SCOREBOARD_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "scoreboard")
	await process_frame
	menu_click.position = game.SCOREBOARD_START_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.endless_mode and not game.selecting_character and game.score == 0)
	game.score = game.VIPER_ENDLESS_UNLOCK_SCORE - 100
	game.spawn_boss()
	game.enemies[0].pos = Vector2(270.0, 300.0)
	game.enemies[0].hp = 1
	game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
	game.resolve_collisions()
	assert(game.endless_bosses_defeated == 1)
	assert(game.is_ship_unlocked(4))
	assert(game.sea_tokens == 3)
	assert(not game.dialogue_active and not game.game_over)
	assert(game.score_target_for_level() == game.ENDLESS_BOSS_SCORE_STEP * 2)
	var recorded_endless_score: int = game.score
	game.finish_game(false)
	assert(game.endless_scores.has(recorded_endless_score))
	assert(game.get_endless_best_score() >= recorded_endless_score)
	game.show_character_select()
	assert(not game.endless_mode and game.menu_page == "home")
	game.selected_character = 2
	assert(game.sea_tokens == 3 and game.can_buy_turtle_ship(1))
	assert(game.buy_turtle_ship(1))
	assert(game.sea_tokens == 0 and game.is_ship_unlocked(2))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.collection_save_path))
	menu_click.position = game.HOME_COLLECTION_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "collection")
	menu_click.position = game.STAGE_CARDS[0].get_center()
	game._unhandled_input(menu_click)
	assert(game.quest_open_stage == 1)
	assert("plastic homes" in str(game.get_open_research_entry().title))
	assert(str(game.get_open_research_entry().source_url).begins_with("https://doi.org/"))
	menu_click.position = game.MENU_BACK_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "collection" and game.quest_open_stage == 0)
	game._unhandled_input(menu_click)
	assert(game.menu_page == "home")
	game.start_selected_game()
	finish_intro(game)
	game.player_health = 1
	game.invulnerable_timer = 0.0
	game.damage_player()
	assert(game.game_over and not game.victory)
	menu_click.position = Vector2(270.0, 500.0)
	game._unhandled_input(menu_click)
	assert(game.selecting_character)
	game.start_selected_game()
	finish_intro(game)
	game.level = 99
	game.stage_level = game.LEVELS_PER_STAGE
	game.start_boss_dialogue()
	assert(game.dialogue_active)
	assert(not game.dialogue_overlay.visible)
	await process_frame
	assert(not game.dialogue_active)
	assert(game.game_over and game.victory)
	game.show_character_select()
	game.selected_character = 0
	game.start_selected_game()
	finish_intro(game)
	assert(game.max_player_health == 150)
	assert(is_equal_approx(game.fire_delay, 0.15))
	game.bullets.clear()
	game.fire_player_weapon()
	assert(game.bullets.size() == 2)
	game.show_character_select()
	game.selected_character = 1
	game.start_selected_game()
	finish_intro(game)
	assert(game.player_extra_projectiles == 0)
	game.bullets.clear()
	game.fire_player_weapon()
	assert(game.bullets.size() == 2)
	assert(not game.bullets[0].homing and not game.bullets[1].homing)
	assert(game.player_speed == 350.0 and game.max_player_health == 100)
	assert(game.fire_delay > 0.15)
	game.spawn_enemy()
	game.enemies[0].pos = Vector2(400.0, 400.0)
	game.update_bullets(0.1)
	assert(game.bullets[0].vel.x == -24.0)
	game.enemies[0].hp = 20.0
	game.bullets.clear()
	var special_touch := InputEventScreenTouch.new()
	special_touch.index = 1
	special_touch.pressed = true
	special_touch.position = game.SPECIAL_BUTTON.get_center()
	game._input(special_touch)
	assert(is_equal_approx(game.special_cooldown_timer, 10.0))
	assert(is_equal_approx(game.giant_shot_time_remaining, 6.0))
	assert(game.bullets.size() == 1 and game.bullets[0].radius == 28.0)
	assert(game.bullets[0].homing)
	game.update_bullets(0.1)
	assert(game.bullets[0].vel.x > 0.0)
	game.enemies[0].pos = game.bullets[0].pos
	game.resolve_collisions()
	assert(game.enemies[0].hp == 19.0 and game.bullets.size() == 1)
	game.resolve_collisions()
	assert(game.enemies[0].hp == 19.0)
	for target_index in range(9):
		game.spawn_enemy()
		game.enemies[-1].pos = game.bullets[0].pos
		game.enemies[-1].hp = 20.0
	game.resolve_collisions()
	assert(game.bullets.is_empty())
	for enemy in game.enemies:
		assert(enemy.hp == 19.0)
	game.update_special_effects(2.01)
	assert(game.giant_shot_count == 2)
	game.update_special_effects(2.0)
	assert(game.giant_shot_count == 3)
	game.update_special_effects(2.0)
	assert(game.giant_shot_count == 3 and game.giant_shot_time_remaining == 0.0)
	game.activate_special()
	assert(game.giant_shot_count == 3)
	game.show_character_select()
	game.selected_character = 2
	game.start_selected_game()
	finish_intro(game)
	assert(game.max_player_health == 100 and game.player_speed == 318.0)
	game.fire_player_weapon()
	assert(game.bullets.size() == 5)
	assert(game.fire_delay > 0.25)
	game.spawn_boss()
	game.enemies[0].pos = Vector2(270.0, 500.0)
	var boss_hp_before: float = game.enemies[0].hp
	game.bullets.clear()
	game.bullets.append({"pos": Vector2(270.0, 500.0), "vel": Vector2.ZERO, "boss_damage_multiplier": game.player_stats.boss_damage_multiplier})
	game.resolve_collisions()
	assert(is_equal_approx(boss_hp_before - float(game.enemies[0].hp), 0.35))
	# เลเซอร์ห้าเส้นต้องถึงบอสที่ตำแหน่งต่อสู้ปกติจากจุดเริ่มต้นของผู้เล่น
	game.enemies[0].pos = Vector2(270.0, 300.0)
	boss_hp_before = game.enemies[0].hp
	var special_key := InputEventKey.new()
	special_key.keycode = KEY_E
	special_key.pressed = true
	game._input(special_key)
	assert(is_equal_approx(boss_hp_before - float(game.enemies[0].hp), 13.5))
	assert(game.special_effects.size() == 5)
	assert(is_equal_approx(game.special_cooldown_timer, 7.0))
	game.player_pos.x += 40.0
	game.spawn_enemy()
	game.enemies[-1].pos = game.player_pos + Vector2(80.0, -300.0)
	game.enemies[-1].hp = 20.0
	game.update_special_effects(0.1)
	assert(game.enemies[-1].hp == 11.0)
	game.show_character_select()
	game.selected_character = 3
	game.start_selected_game()
	finish_intro(game)
	assert(game.max_player_health == 100 and game.player_speed == 440.0)
	assert(is_equal_approx(game.fire_delay, 0.22))
	game.fire_player_weapon()
	assert(game.bullets.size() == 2)
	game.spawn_enemy()
	game.enemies[0].pos = game.player_pos + Vector2(0.0, -45.0)
	game.enemies[0].hp = 20.0
	special_key.keycode = KEY_SPACE
	game._input(special_key)
	assert(game.beyblades.size() == 1)
	assert(game.beyblades[0].visual_size == Vector2(72.0, 72.0))
	assert(float(game.beyblades[0].spin_speed) >= 30.0)
	var blade_rotation_before: float = game.beyblades[0].rotation
	game.update_special_effects(0.1)
	assert(game.beyblades[0].rotation != blade_rotation_before)
	assert(not game.beyblades[0].trail.is_empty())
	assert(game.enemies[0].hp == 18.0 and game.beyblades[0].to_border)
	game.update_special_effects(0.4)
	assert(not game.beyblades[0].to_border)
	game.update_special_effects(0.3)
	assert(game.enemies[0].hp < 18.0)
	assert(is_equal_approx(game.special_cooldown_timer, 8.0))
	assert(game.beyblades[0].life < 6.0)
	game.show_character_select()
	game.selected_character = 3
	game.start_selected_game()
	finish_intro(game)
	game.spawn_boss()
	game.enemies[0].pos = game.player_pos + Vector2(0.0, -45.0)
	var razor_boss_hp: float = game.enemies[0].hp
	game._input(special_key)
	game.update_special_effects(0.1)
	assert(game.beyblades[0].to_border)
	game.update_special_effects(0.4)
	game.update_special_effects(0.3)
	assert(float(game.enemies[0].hp) < razor_boss_hp - float(game.player_stats.special_boss_damage))
	game.show_character_select()
	game.selected_character = 3
	var ship_menu_key := InputEventKey.new()
	ship_menu_key.keycode = KEY_RIGHT
	ship_menu_key.pressed = true
	game._unhandled_input(ship_menu_key)
	assert(game.menu_page == "home")
	assert(game.selected_character == 4)
	assert(game.carousel_slide_offset > 0.0)
	game.start_selected_game()
	finish_intro(game)
	assert(game.max_player_health == 120 and game.player_speed == 440.0)
	game.fire_player_weapon()
	assert(game.bullets.size() == 2)
	assert(is_equal_approx(game.bullets[0].radius, 12.6) and game.bullets[0].damage == 1.5)
	assert(game.bullets[0].vel.x < 0.0 and game.bullets[1].vel.x > 0.0)
	assert(game.visual_textures.size() >= 9)
	assert(game.visual_textures.has("beyblade") and game.visual_textures.has("player_giant"))
	assert(game.visual_textures["beyblade"].resource_path == "res://assets/sprites/beyblade.png")
	game.spawn_boss()
	game.enemies[0].pos = game.player_pos + Vector2(0.0, -280.0)
	var viper_boss_max_hp: float = game.enemies[0].max_hp
	special_key.keycode = KEY_E
	game._input(special_key)
	assert(is_equal_approx(float(game.enemies[0].hp), viper_boss_max_hp * 0.75))
	assert(game.viper_beam_tick_index == 1 and is_equal_approx(game.viper_beam_time_remaining, 3.0))
	game.update_special_effects(1.0)
	assert(is_equal_approx(float(game.enemies[0].hp), viper_boss_max_hp * 0.60))
	game.update_special_effects(1.0)
	assert(is_equal_approx(float(game.enemies[0].hp), viper_boss_max_hp * 0.50))
	assert(game.viper_beam_tick_index == 3)
	game.show_character_select()
	game.selected_character = 4
	game.start_selected_game()
	finish_intro(game)
	game.spawn_enemy()
	game.enemies[0].pos = game.player_pos + Vector2(0.0, -280.0)
	game.enemies[0].hp = 20.0
	special_key.keycode = KEY_E
	game._input(special_key)
	assert(game.enemies[0].hp == 12.0)
	assert(is_equal_approx(game.special_cooldown_timer, 12.0))
	assert(game.viper_beam_time_remaining > 0.0)
	game.update_special_effects(0.1)
	assert(game.enemies[0].hp == 12.0)
	game.special_cooldown_timer = 0.0
	var double_tap := InputEventScreenTouch.new()
	double_tap.index = 0
	double_tap.position = game.player_pos + Vector2(0.0, -90.0)
	double_tap.pressed = true
	game._input(double_tap)
	double_tap.pressed = false
	game._input(double_tap)
	double_tap.pressed = true
	game._input(double_tap)
	assert(is_equal_approx(game.special_cooldown_timer, 12.0))
	game.special_cooldown_timer = 0.0
	var double_click := InputEventMouseButton.new()
	double_click.button_index = MOUSE_BUTTON_LEFT
	double_click.position = game.player_pos + Vector2(0.0, -90.0)
	double_click.pressed = true
	game._input(double_click)
	double_click.pressed = false
	game._input(double_click)
	double_click.pressed = true
	game._input(double_click)
	assert(is_equal_approx(game.special_cooldown_timer, 12.0))
	var striker: CombatantVisual = load("res://characters/enemies/striker.tscn").instantiate() as CombatantVisual
	striker.skills.append(load("res://skills/fortify.tres"))
	assert(striker.get_skill_modifiers().max_health_multiplier == 1.5)
	striker.free()
	if FileAccess.file_exists(game.collection_save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(game.collection_save_path))
	print("SMOKE TEST PASSED: Quest folders, Coin economy, six bosses, Razor trial, Viper 30K unlock and 25-15-10% beam")
	quit(0)

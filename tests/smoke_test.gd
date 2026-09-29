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


func clear_combat(game: Node) -> void:
	for enemy in game.enemies:
		game.free_enemy_visual(enemy)
	game.enemies.clear()
	game.bullets.clear()
	game.enemy_bullets.clear()
	game.boss_hazards.clear()
	game.boss_active = false


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	game.collection_save_path = ProjectSettings.globalize_path("res://tests/item_collection_smoke.json")
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
	var expected_dialogue_portraits := [
		"res://assets/sprites/player_ship.png", "res://assets/sprites/player_swift.png",
		"res://assets/sprites/player_titan.png", "res://assets/sprites/player_razor.png",
		"res://assets/sprites/player_viper.png"
	]
	for ship_index in range(game.PLAYER_SCENES.size()):
		game.selected_character = ship_index
		game.apply_selected_character()
		var preview_lines: Array[Dictionary] = game.personalize_dialogue_lines(game.DIALOGUE_CONFIG.get_intro_lines(1))
		assert(preview_lines[0].speaker == "จอร์นนี่" and preview_lines[0].portrait == expected_dialogue_portraits[ship_index])
	game.selected_character = 0
	game.apply_selected_character()
	var menu_click := InputEventMouseButton.new()
	menu_click.button_index = MOUSE_BUTTON_LEFT
	menu_click.pressed = true
	assert(game.menu_page == "home")
	menu_click.position = game.SETTINGS_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.menu_page == "settings")
	menu_click.position = Vector2(game.SETTINGS_SLIDERS[0].position.x + game.SETTINGS_SLIDERS[0].size.x * 0.5, game.SETTINGS_SLIDERS[0].get_center().y)
	game._unhandled_input(menu_click)
	assert(is_equal_approx(game.master_volume, 0.5))
	menu_click.position = game.CLEAR_USER_DATA_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.clear_data_confirmation_visible)
	menu_click.position = game.CLEAR_DATA_CANCEL_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(not game.clear_data_confirmation_visible)
	menu_click.position = game.MENU_BACK_BUTTON.get_center()
	game._unhandled_input(menu_click)
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
	assert(game.dialogue_lines[0].speaker == "กุ้ง")
	assert(bool(game.dialogue_overlay.call("is_typing")))
	game.dialogue_overlay.call("finish_typing")
	assert(not bool(game.dialogue_overlay.call("is_typing")))
	assert(game.DIALOGUE_CONFIG.get_stage(3).record == "พลังแห่งมันกุ้ง")
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
	var scaled_enemy: Dictionary = game.enemies[-1]
	var normal_enemy_radii := [17.0, 20.0, 27.0]
	assert(is_equal_approx(game.ENEMY_SIZE_MULTIPLIER, 2.55))
	assert(is_equal_approx(float(scaled_enemy.radius), normal_enemy_radii[int(scaled_enemy.kind)] * game.ENEMY_SIZE_MULTIPLIER))
	var background = game.get_node("ParallaxBackground")
	assert(not game.selecting_character)
	assert(not game.boss_active and game.get_music_key() == "boss_1")
	assert(game.MUSIC_TRACKS["boss_2"].resource_path == "res://Sound/Boss_Krame.mp3")
	assert(game.MUSIC_TRACKS["boss_5_narkom"].resource_path == "res://Sound/NARKOM.mp3")
	game.level = 2
	assert(game.get_music_key() == "boss_2")
	game.level = 5
	game.lens_uses_narkom = false
	assert(game.get_music_key() == "boss_5")
	game.lens_uses_narkom = true
	assert(game.get_music_key() == "boss_5_narkom")
	game.level = 1
	game.lens_uses_narkom = false
	game.dialogue_active = true
	assert(game.get_music_key() == "boss_1")
	game.dialogue_active = false
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
	assert(game.get_node("HUD/Renderer").coin_texture != null)
	assert(game.get_node("HUD/Renderer").chest_texture != null)
	assert(game.get_node("HUD/Renderer").settings_texture != null)
	assert(game.get_node("HUD/Renderer").version_label == "Ver 0.8.0-beta.1")
	assert(game.has_node("MusicPlayer") and game.has_node("EffectPlayer"))
	assert(game.DIFFICULTY_BUTTONS[0].end.y <= game.CAROUSEL_SWIPE_AREA.position.y)
	assert(game.SHIP_LOCK_BUTTON.size.x < 124.0)
	game.set_audio_setting(0, 0.64, false)
	game.set_audio_setting(1, 0.52, false)
	game.set_audio_setting(2, 0.41, false)
	assert(is_equal_approx(game.master_volume, 0.64) and is_equal_approx(game.music_volume, 0.52) and is_equal_approx(game.effect_volume, 0.41))
	assert(FileAccess.file_exists("res://export_presets.cfg"))
	assert(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility")
	assert(game.player_sprite.texture != null)
	assert(game.get_ship_display_name(0) == "JOHNY")
	assert(game.get_ship_display_name(1) == "JOHNY SAPARROW")
	assert(game.get_ship_display_name(2) == "PICHU JOHNY")
	assert(game.get_ship_display_name(3) == "SANTA JOHNY")
	assert(game.get_ship_display_name(4) == "STRAW HAT JOHNY")
	assert(game.DIALOGUE_CONFIG.CHARACTERS.size() >= 7)
	assert(game.DIALOGUE_CONFIG.STAGES.size() == game.FINAL_LEVEL + 1)
	var expected_story_bosses := ["โทมัส", "คราม", "กุ้ง", "เส และ นา", "หมึกเลนส์", "Plastic Man"]
	var expected_records := ["บ้านของปูเสฉวน", "เส้นใยในตัวปูม้า", "พลังแห่งมันกุ้ง", "เรื่องเล่าของเสนาหอย", "แผนที่หมึกและสัตว์ร่วมทะเล", "แผนที่ขยะทะเล"]
	var expected_boss_models := ["thomas", "khram", "kung", "se_na", "lens", "plastic_man", "red_guy"]
	assert(game.BOSS_SCENES.size() == 7)
	for boss_index in range(game.BOSS_SCENES.size()):
		var model: CombatantVisual = game.BOSS_SCENES[boss_index].instantiate() as CombatantVisual
		assert(model.scene_file_path == "res://characters/bosses/%s.tscn" % expected_boss_models[boss_index])
		var expected_texture_paths := [
			"res://assets/sprites/boss_thomas.png",
			"res://assets/sprites/boss_khram.png",
			"res://assets/sprites/boss_kung_idle.png",
			"res://assets/sprites/boss_se_idle.png",
			"res://assets/sprites/boss_lens.png",
			"res://assets/sprites/boss_plastic_man.png",
			"res://assets/sprites/boss_red_guy.png"
		]
		var expected_texture_path: String = expected_texture_paths[boss_index]
		assert(model.texture != null and model.texture.resource_path == expected_texture_path)
		model.free()
	for pair_texture in [game.SE_IDLE_TEXTURE, game.SE_ATTACK_TEXTURE, game.NA_IDLE_TEXTURE, game.NA_ATTACK_TEXTURE]:
		assert(pair_texture != null and pair_texture.resource_path.get_extension().to_lower() == "png")
	var latest_enemy_pngs := ["enemy_scout.png", "enemy_striker.png", "enemy_tank.png"]
	for enemy_scene_index in range(game.ENEMY_SCENES.size()):
		var latest_enemy: Sprite2D = game.ENEMY_SCENES[enemy_scene_index].instantiate()
		assert(latest_enemy.texture.resource_path == "res://assets/sprites/%s" % latest_enemy_pngs[enemy_scene_index])
		latest_enemy.free()
	for story_stage in range(1, game.FINAL_LEVEL + 1):
		assert(game.DIALOGUE_CONFIG.get_boss_name(story_stage) == expected_story_bosses[story_stage - 1])
		assert(game.DIALOGUE_CONFIG.get_record_name(story_stage) == expected_records[story_stage - 1])
		assert(not game.DIALOGUE_CONFIG.get_intro_lines(story_stage).is_empty())
		for story_phase in range(1, game.LEVELS_PER_STAGE + 1):
			assert(not game.DIALOGUE_CONFIG.get_lines(story_stage, story_phase).is_empty())
	assert(game.DIALOGUE_CONFIG.get_boss_name(game.SPECIAL_BOSS_LEVEL) == "Red Guy")
	assert(not game.DIALOGUE_CONFIG.get_intro_lines(game.SPECIAL_BOSS_LEVEL).is_empty())
	assert(not game.DIALOGUE_CONFIG.get_lines(game.SPECIAL_BOSS_LEVEL, 1).is_empty())
	assert(game.RESEARCH_CONFIG.RESEARCH_BY_STAGE.size() == game.FINAL_LEVEL)
	assert(str(game.RESEARCH_CONFIG.get_entry(1).source_url).begins_with("https://doi.org/"))
	var expected_research_order := ["5", "1", "3-A", "2", "3-B", "4"]
	for research_stage in range(1, game.FINAL_LEVEL + 1):
		assert(str(game.RESEARCH_CONFIG.get_entry(research_stage).research_number) == expected_research_order[research_stage - 1])
	assert(game.RESEARCH_CONFIG.get_entry(2).source_url == "https://webopac.lib.buu.ac.th/bibitem?bibid=b00339347")
	assert(game.RESEARCH_CONFIG.get_entry(4).source_url == "https://webopac.lib.buu.ac.th/bibitem?bibid=b00344058")
	assert(game.RESEARCH_CONFIG.get_entry(6).source_url == "https://webopac.lib.buu.ac.th/bibitem?bibid=b00339175")
	assert(game.RESEARCH_CONFIG.get_entry(3).source_url == game.RESEARCH_CONFIG.get_entry(5).source_url)
	game.item_collection.assign([3])
	game.quest_open_stage = 3
	assert(not game.get_open_research_entry().fragment_complete)
	assert(game.open_quest_source() == ERR_UNAVAILABLE)
	game.item_collection.append(5)
	assert(game.get_open_research_entry().fragment_complete)
	assert(game.get_open_research_entry().summary == game.get_open_research_entry().full_summary)
	assert(not game.is_nightmare_unlocked() and not game.set_difficulty_multiplier(2))
	game.item_collection.assign([1, 2, 3, 4, 5, 6])
	assert(game.is_nightmare_unlocked() and game.set_difficulty_multiplier(3))
	assert(game.difficulty_multiplier == 3)
	game.set_difficulty_multiplier(1)
	game.item_collection.clear()
	game.quest_open_stage = 0
	var stage_six_mentions_key := false
	for final_line in game.DIALOGUE_CONFIG.get_lines(6, 3):
		stage_six_mentions_key = stage_six_mentions_key or "กุญแจ" in str(final_line.text)
	assert(stage_six_mentions_key)
	assert(game.DIALOGUE_CONFIG.get_lines(1, 1)[1].speaker == "จอร์นนี่")
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
	assert(is_equal_approx(game.POTION_SIZE_MULTIPLIER, 2.2))
	assert(is_equal_approx(game.POTION_VISUAL_SIZE, 72.6))
	game.player_health = 50
	game.pickups.append({"pos": game.player_pos + Vector2(40.0, 0.0), "phase": 0.0})
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
	assert(game.player_sprite.rotation > 0.0 and not game.player_afterimages.is_empty())
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
	assert(game.player_sprite.rotation < 0.0)
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
	var expected_boss_names := ["Thomas Frenzy", "Thomas Frenzy", "Thomas Frenzy"]
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
		assert(boss_visual.scene_file_path == "res://characters/bosses/thomas.tscn")
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
		# โทมัสเปลี่ยนรูปแบบยิงตาม HP และยิงรัวเมื่อเหลือ 50%
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
		game.fire_enemy_weapon(game.enemies[0])
		assert(game.enemy_bullets.size() == 7 + expected_extra_shots[expected_level - 1])
		assert(is_equal_approx(game.get_named_boss_fire_delay(game.enemies[0]), 0.50))
		game.enemy_bullets.clear()
		game.enemies[0].pos = Vector2(270.0, 300.0)
		game.enemies[0].hp = floori(game.enemies[0].max_hp * 0.25) + 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		assert(game.pickups.size() == potion_count_before_boss + 3)
		# 10%: กลับกลาง หมุนหนึ่งรอบใน 10 วินาที และปล่อยกระสุนรูปบวก 12 นัดทุก 2 วินาที
		game.enemies[0].hp = floori(game.enemies[0].max_hp * 0.10) + 1
		game.bullets.append({"pos": Vector2(270.0, 300.0), "vel": Vector2.ZERO})
		game.resolve_collisions()
		game.enemies[0].ability_timer = 0.0
		game.update_enemies(0.01)
		assert(game.enemy_bullets.size() == 12)
		assert(is_equal_approx(game.enemies[0].ability_timer, 5.0))
		assert(game.enemies[0].pos.distance_to(Vector2(270.0, 280.0)) < 21.0)
		game.enemy_bullets.clear()
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
			if bool(game.dialogue_overlay.call("is_typing")):
				game.dialogue_overlay.call("finish_typing")
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
	game.collection_save_path = ProjectSettings.globalize_path("res://tests/item_collection_smoke.json")
	assert(game.highest_unlocked_stage == 2)
	var save_probe := FileAccess.open(game.collection_save_path, FileAccess.WRITE)
	var can_test_save := save_probe != null
	if can_test_save:
		save_probe.close()
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
	assert(game.enemies[0].visual.scene_file_path == "res://characters/bosses/red_guy.tscn")
	assert(game.enemy_has_tag(game.enemies[0], "Boss"))
	var special_boss_visual: CombatantVisual = game.enemies[0].visual as CombatantVisual
	assert(special_boss_visual.get_skill_names() == PackedStringArray(["Red Guy"]))
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
	# Giant Shot ใช้ดาเมจบอสโดยเฉพาะ ไม่ใช่ค่าดาเมจศัตรูทั่วไปที่เล็กจนมองไม่เห็น
	clear_combat(game)
	game.special_cooldown_timer = 0.0
	game.giant_shot_time_remaining = 0.0
	game.spawn_boss()
	game.enemies[0].pos = Vector2(270.0, 300.0)
	var giant_shot_boss_hp := float(game.enemies[0].hp)
	game.bullets.clear()
	game.activate_special()
	assert(game.bullets.size() == 1)
	game.bullets[0].pos = game.enemies[0].pos
	game.resolve_collisions()
	assert(is_equal_approx(giant_shot_boss_hp - float(game.enemies[0].hp), float(game.player_stats.special_boss_damage)))
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
	assert(game.visual_textures.size() >= 10)
	assert(game.visual_textures.has("beyblade") and game.visual_textures.has("player_giant"))
	assert(game.visual_textures["beyblade"].resource_path == "res://assets/sprites/beyblade.png")
	assert(game.visual_textures["senahoy_special"].resource_path == "res://assets/sprites/SENAHOY_Bullet.png")
	assert(game.visual_textures["health_pickup"].resource_path == "res://assets/sprites/pickup_health.png")
	assert(game.visual_textures.has("viper_beam"))
	assert(game.visual_textures["viper_beam"].resource_path == "res://assets/sprites/Viper_Skill.png")
	game.spawn_boss()
	game.enemies[0].pos = game.player_pos + Vector2(0.0, -280.0)
	var viper_boss_max_hp: float = game.enemies[0].max_hp
	special_key.keycode = KEY_E
	game._input(special_key)
	assert(is_equal_approx(float(game.enemies[0].hp), viper_boss_max_hp * 0.75))
	assert(game.viper_beam_tick_index == 1 and is_equal_approx(game.viper_beam_time_remaining, 3.0))
	assert(is_zero_approx(game.viper_beam_elapsed))
	game.update_special_effects(1.0)
	assert(is_equal_approx(game.viper_beam_elapsed, 1.0))
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

	# คราม: ทุก 20% สะสม dash หนึ่งครั้ง, ชน 20%, และต่ำกว่า 10% Frenzy 3 วินาที
	clear_combat(game)
	game.special_stage_mode = false
	game.endless_mode = false
	game.level = 2
	game.stage_level = 1
	game.spawn_boss()
	var khram: Dictionary = game.enemies[0]
	khram.hp = float(khram.max_hp) * 0.91
	game.damage_enemy(0, float(khram.max_hp) * 0.02)
	assert(khram.dash_queue == 0)
	khram.hp = float(khram.max_hp) * 0.81
	game.damage_enemy(0, float(khram.max_hp) * 0.02)
	assert(khram.dash_queue == 1)
	game.update_enemies(0.01)
	assert(khram.dash_timer > 0.0)
	assert(is_equal_approx(Vector2(khram.dash_velocity).length(), game.KHRAM_DASH_SPEED))
	game.player_health = game.max_player_health
	game.invulnerable_timer = 0.0
	khram.pos = game.player_pos
	game.resolve_collisions()
	assert(game.player_health == game.max_player_health - ceili(game.max_player_health * game.KHRAM_CONTACT_DAMAGE_RATIO))
	khram.frenzy_timer = 0.0
	khram.dash_queue = 0
	khram.dash_timer = 0.01
	game.update_khram_boss(khram, 0.02)
	assert(khram.khram_recovering)
	var khram_miss_position := Vector2(khram.pos)
	var khram_recover_distance := khram_miss_position.distance_to(Vector2(khram.khram_recover_target))
	game.update_khram_boss(khram, 0.10)
	assert(Vector2(khram.pos).distance_to(Vector2(khram.khram_recover_target)) < khram_recover_distance)
	assert(Vector2(khram.pos).distance_to(khram_miss_position) <= game.KHRAM_RECOVER_SPEED * 0.10 + 0.1)
	khram.hp = float(khram.max_hp) * 0.11
	game.damage_enemy(0, float(khram.max_hp) * 0.02)
	assert(khram.frenzy_used and is_equal_approx(float(khram.frenzy_timer), game.KHRAM_FRENZY_DURATION))

	# Kung Phase 1-2: ใช้ภาพ Attack และปล่อยกระสุนจากขอบบนสลับฟันปลาต่อเนื่อง 5 วินาที
	clear_combat(game)
	game.level = 3
	game.stage_level = 1
	game.spawn_boss()
	var kung: Dictionary = game.enemies[0]
	assert(kung.visual.scene_file_path == "res://characters/bosses/kung.tscn")
	assert(kung.visual.texture.resource_path == "res://assets/sprites/boss_kung_idle.png")
	game.apply_boss_horizontal_lean(kung, float(kung.pos.x) - 30.0, 0.1)
	assert(kung.visual.rotation > 0.0)
	kung.kung_skill_cooldown = 0.0
	game.update_kung_boss(kung, 0.01)
	assert(is_equal_approx(float(kung.kung_wave_time), 5.0))
	game.update_kung_boss(kung, 0.10)
	assert(game.enemy_bullets.size() == 4)
	assert(kung.visual.texture.resource_path == "res://assets/sprites/boss_kung_attack.png")
	var first_kung_row_x: Array[float] = []
	for kung_bullet in game.enemy_bullets:
		first_kung_row_x.append(float(kung_bullet.pos.x))
		assert(kung_bullet.pos.y == -18.0 and kung_bullet.vel.y > 0.0)
	game.enemy_bullets.clear()
	game.update_kung_boss(kung, 0.28)
	assert(game.enemy_bullets.size() == 4 and not is_equal_approx(float(game.enemy_bullets[0].pos.x), first_kung_row_x[0]))

	# Kung Phase 3: dash from a moving patrol point, return there, then patrol again after a short cooldown.
	clear_combat(game)
	game.level = 3
	game.stage_level = 3
	game.spawn_boss()
	kung = game.enemies[0]
	kung.kung_final_initialized = true
	kung.kung_home = Vector2(82.0, 118.0)
	kung.pos = Vector2(170.0, 180.0)
	kung.kung_dive_state = "rest"
	kung.kung_rest_timer = 0.0
	game.player_pos = Vector2(410.0, 820.0)
	var kung_skill_origin := Vector2(kung.pos)
	game.update_kung_final_phase(kung, 0.01)
	var remembered_target := Vector2(kung.kung_dive_target)
	var kung_dash_direction := Vector2(kung.kung_dash_direction)
	assert(kung.kung_dive_state == "dive" and remembered_target == game.player_pos)
	assert(Vector2(kung.kung_home).distance_to(kung_skill_origin) < 4.0)
	assert(kung_dash_direction.dot((remembered_target - kung_skill_origin).normalized()) > 0.99)
	game.player_pos = Vector2(120.0, 700.0)
	game.update_kung_final_phase(kung, 0.10)
	assert(Vector2(kung.kung_dive_target) == remembered_target)
	assert(kung.visual.texture.resource_path == "res://assets/sprites/boss_kung_attack.png")
	# Contact pushes the player in exactly the same direction as the dash.
	game.player_pos = Vector2(270.0, 600.0)
	kung.pos = game.player_pos
	game.invulnerable_timer = 0.0
	var player_before_kung_hit: Vector2 = game.player_pos
	game.resolve_collisions()
	var player_knockback: Vector2 = game.player_pos - player_before_kung_hit
	assert(kung.kung_knockback_used and player_knockback.dot(kung_dash_direction) > 0.0)
	kung.kung_dive_state = "return"
	kung.pos = Vector2(kung.kung_home)
	game.update_kung_final_phase(kung, 0.01)
	assert(kung.kung_dive_state == "rest" and is_equal_approx(float(kung.kung_rest_timer), game.KUNG_PHASE_THREE_COOLDOWN))
	assert(game.KUNG_PHASE_THREE_COOLDOWN < 5.0)
	var returned_position := Vector2(kung.pos)
	game.elapsed += 0.4
	game.update_kung_final_phase(kung, 0.10)
	assert(Vector2(kung.pos) != returned_position)

	# เสนาหอย: เส/นาแยกตำแหน่งและมี Idle/Attack คนละ Sprite; X ตัดกลางแผนที่เท่านั้น
	clear_combat(game)
	game.level = 4
	game.stage_level = 1
	game.spawn_boss()
	var se_na: Dictionary = game.enemies[0]
	assert(is_instance_valid(se_na.partner_visual))
	assert(se_na.visual.texture.resource_path == "res://assets/sprites/boss_se_idle.png")
	assert(se_na.partner_visual.texture.resource_path == "res://assets/sprites/boss_na_idle.png")
	game.update_se_na_boss(se_na, 0.1)
	assert(Vector2(se_na.se_pos) != Vector2(se_na.na_pos))
	se_na.hp = float(se_na.max_hp) * 0.91
	game.damage_enemy(0, float(se_na.max_hp) * 0.02)
	assert(game.boss_hazards.size() == 1 and game.boss_hazards[0].kind == "x_laser")
	var x_segments: Array = game.boss_hazards[0].segments
	assert(x_segments.size() == 2)
	assert(Vector2(x_segments[0][0]) == Vector2.ZERO and Vector2(x_segments[0][1]) == game.GAME_SIZE)
	assert(Vector2(x_segments[1][0]) == Vector2(game.GAME_SIZE.x, 0.0) and Vector2(x_segments[1][1]) == Vector2(0.0, game.GAME_SIZE.y))
	assert(se_na.visual.texture.resource_path == "res://assets/sprites/boss_se_attack.png")
	assert(se_na.partner_visual.texture.resource_path == "res://assets/sprites/boss_na_attack.png")
	# Phase 2 alternates full-height rainbow columns and always leaves dodge gaps.
	clear_combat(game)
	game.level = 4
	game.stage_level = 2
	game.spawn_boss()
	se_na = game.enemies[0]
	se_na.se_na_rainbow_timer = 0.0
	game.update_se_na_boss(se_na, 0.01)
	assert(game.boss_hazards.size() == 1 and game.boss_hazards[0].kind == "rainbow_lights")
	var first_rainbow_columns: Array = game.boss_hazards[0].columns
	assert(first_rainbow_columns.size() == 3)
	se_na.se_na_rainbow_timer = 0.0
	game.update_se_na_boss(se_na, 0.01)
	assert(game.boss_hazards.size() == 2 and game.boss_hazards[1].columns.size() == 3)
	assert(game.boss_hazards[1].columns != first_rainbow_columns)
	# Phase 3 launches four slow missiles from both sides continuously below 50% HP.
	clear_combat(game)
	game.level = 4
	game.stage_level = 3
	game.spawn_boss()
	se_na = game.enemies[0]
	assert(se_na.se_na_phase_three)
	game.update_enemies(0.1)
	assert(game.enemy_bullets.is_empty())
	se_na.hp = float(se_na.max_hp) * 0.50
	se_na.se_na_special_timer = 0.0
	game.update_enemies(0.01)
	assert(game.enemy_bullets.size() == 4)
	var missiles_from_left := 0
	var missiles_from_right := 0
	for sena_bullet in game.enemy_bullets:
		assert(sena_bullet.visual_key == "senahoy_special")
		assert(is_equal_approx(float(sena_bullet.radius), 16.0))
		assert(int(sena_bullet.damage) == ceili(game.max_player_health * 0.15))
		assert(is_equal_approx(Vector2(sena_bullet.vel).length(), game.SENA_MISSILE_SPEED))
		if sena_bullet.vel.x > 0.0:
			missiles_from_left += 1
		else:
			missiles_from_right += 1
	assert(missiles_from_left == 2 and missiles_from_right == 2)
	se_na.hp = float(se_na.max_hp) * 0.91
	game.damage_enemy(0, float(se_na.max_hp) * 0.02)
	assert(game.boss_hazards.is_empty())

	# หมึกเลนส์ Phase 3: หนวดโจมตีจากด้านข้าง 1.3 วินาที 3 เส้น และกำแพงหนวดรับดาเมจแทนบอส
	clear_combat(game)
	game.level = 5
	game.stage_level = 3
	game.spawn_boss()
	var lens: Dictionary = game.enemies[0]
	game.update_enemies(1.31)
	assert(game.boss_hazards.size() == 3)
	for tentacle in game.boss_hazards:
		assert(tentacle.kind == "side_tentacle" and is_equal_approx(float(tentacle.warning), 1.3))
		assert(abs(int(tentacle.side)) == 1)
	assert(game.LENS_TENTACLE_TEXTURE.resource_path == "res://assets/sprites/boss_lens_tentacle.png")
	lens.hp = float(lens.max_hp) * 0.51
	game.damage_enemy(0, float(lens.max_hp) * 0.02)
	assert(is_equal_approx(float(lens.tentacle_barrier_max_hp), maxf(12.0, float(lens.max_hp) * game.LENS_BARRIER_HP_RATIO)))
	assert(game.LENS_BARRIER_HP_RATIO > 0.35)
	var lens_hp_behind_barrier := float(lens.hp)
	var barrier_before := float(lens.tentacle_barrier_hp)
	game.damage_enemy(0, 3.0)
	assert(is_equal_approx(float(lens.hp), lens_hp_behind_barrier) and float(lens.tentacle_barrier_hp) < barrier_before)

	# Stage 6 spawns exactly ten separated ships every three seconds.
	clear_combat(game)
	game.special_stage_mode = false
	game.endless_mode = false
	game.level = 6
	game.stage_level = 1
	game.score = 0
	game.spawn_timer = 0.0
	game.fire_timer = 999.0
	game.update_game(0.01)
	assert(game.enemies.size() == game.STAGE_SIX_WAVE_SIZE)
	assert(is_equal_approx(float(game.spawn_timer), game.STAGE_SIX_WAVE_INTERVAL))
	var first_wave_position := Vector2(game.enemies[0].pos)
	var second_wave_position := Vector2(game.enemies[1].pos)
	assert(first_wave_position.distance_to(second_wave_position) > 80.0)
	# General enemies embedded in one another are separated without moving a boss.
	game.enemies[0].pos = Vector2(270.0, 300.0)
	game.enemies[1].pos = Vector2(270.0, 300.0)
	game.resolve_combatant_overlaps()
	assert(Vector2(game.enemies[0].pos).distance_to(Vector2(game.enemies[1].pos)) > 1.0)

	# Plastic Man HP gains are +10%/+40%/+60% for Phase 1/2/3.
	for plastic_phase in range(1, 4):
		clear_combat(game)
		game.level = 6
		game.stage_level = plastic_phase
		game.spawn_boss()
		var phase_plastic: Dictionary = game.enemies[0]
		var phase_modifiers: Dictionary = game.skill_modifiers_for(phase_plastic.visual)
		var base_plastic_hp: int = game.BOSS_HP_BASE + 6 * game.BOSS_HP_PER_LEVEL + (plastic_phase - 1) * 16
		var modified_plastic_hp := ceili(base_plastic_hp * float(phase_modifiers.max_health_multiplier) * float(game.difficulty_multiplier))
		var expected_plastic_hp := ceili(float(modified_plastic_hp) * float(game.PLASTIC_PHASE_HP_MULTIPLIERS[plastic_phase - 1]) * game.PLASTIC_HEALTH_MULTIPLIER)
		assert(phase_plastic.max_hp == expected_plastic_hp)

	# Plastic Man: 20 ตัวต่อ Wave, 2 Wave ที่ HP 100/50%; บอสอมตะและลูกสมุนห้ามออกสนาม
	clear_combat(game)
	game.level = 6
	game.stage_level = 2
	game.spawn_boss()
	var plastic_man: Dictionary = game.enemies[0]
	assert(game.enemies.size() == 21 and plastic_man.plastic_waves_spawned == 1)
	assert(game.count_plastic_minions() == 20 and plastic_man.plastic_wave_active)
	for minion_index in range(1, game.enemies.size()):
		assert(game.enemies[minion_index].kind == 1 and game.enemy_has_tag(game.enemies[minion_index], "PlasticMinion"))
		assert(is_equal_approx(float(game.enemies[minion_index].radius), 20.0 * game.ENEMY_SIZE_MULTIPLIER))
	var protected_hp := float(plastic_man.hp)
	game.damage_enemy(0, 30.0)
	assert(is_equal_approx(float(plastic_man.hp), protected_hp))
	game.enemies[1].pos = Vector2(-80.0, game.GAME_SIZE.y + 90.0)
	game.update_plastic_minion(game.enemies[1], 0.1)
	assert(game.enemies[1].pos.x >= game.enemies[1].radius and game.enemies[1].pos.y < game.GAME_SIZE.y)
	for minion_index in range(game.enemies.size() - 1, 0, -1):
		game.free_enemy_visual(game.enemies[minion_index])
		game.enemies.remove_at(minion_index)
	assert(game.count_plastic_minions() == 0)
	var mimic_order: Array = plastic_man.plastic_mimic_order.duplicate()
	var sorted_mimic_order: Array = mimic_order.duplicate()
	sorted_mimic_order.sort()
	assert(mimic_order.size() == 5 and sorted_mimic_order == [1, 2, 3, 4, 5])
	assert(game.get_plastic_mimic_phase(1.0) == 1 and game.get_plastic_mimic_phase(0.79) == 2)
	assert(game.get_plastic_mimic_phase(0.59) == 3 and game.get_plastic_mimic_phase(0.39) == 4 and game.get_plastic_mimic_phase(0.19) == 5)
	plastic_man.plastic_mimic_order = [1, 2, 3, 4, 5]
	for mimic_phase in range(1, 6):
		game.enemy_bullets.clear()
		game.boss_hazards.clear()
		plastic_man.plastic_mimic_state = ""
		plastic_man.plastic_mimic_phase = 0
		plastic_man.hp = float(plastic_man.max_hp) * (1.0 - float(mimic_phase - 1) * 0.20 - 0.01)
		game.update_plastic_mimic_skill(plastic_man, 0.0)
		plastic_man.plastic_mimic_timer = 0.0
		game.update_plastic_mimic_skill(plastic_man, 0.01)
		assert(int(plastic_man.plastic_mimic_phase) == mimic_phase)
		if mimic_phase == 1:
			assert(game.enemy_bullets.size() == 12)
		elif mimic_phase == 2:
			assert(plastic_man.plastic_mimic_state == "dash")
		elif mimic_phase == 3:
			assert(game.enemy_bullets.size() == 4)
		elif mimic_phase == 4:
			assert(game.boss_hazards.size() == 1 and game.boss_hazards[0].kind == "rainbow_lights")
		elif mimic_phase == 5:
			assert(game.boss_hazards.size() >= 2 and game.boss_hazards[0].kind == "side_tentacle")
		assert(float(plastic_man.plastic_mimic_timer) >= game.PLASTIC_MIMIC_MIN_INTERVAL)
	plastic_man.hp = protected_hp
	game.damage_enemy(0, protected_hp * 0.60)
	assert(is_equal_approx(float(plastic_man.hp), float(plastic_man.max_hp) * 0.50))
	assert(plastic_man.plastic_waves_spawned == 2 and game.count_plastic_minions() == 20)
	var second_wave_hp := float(plastic_man.hp)
	game.damage_enemy(0, 10.0)
	assert(is_equal_approx(float(plastic_man.hp), second_wave_hp))
	# At 30% HP Plastic Man dashes at the player and fires rapidly for three seconds.
	for minion_index in range(game.enemies.size() - 1, 0, -1):
		game.free_enemy_visual(game.enemies[minion_index])
		game.enemies.remove_at(minion_index)
	plastic_man.hp = float(plastic_man.max_hp) * 0.30
	game.player_pos = Vector2(420.0, 760.0)
	game.enemy_bullets.clear()
	var plastic_before_dash := Vector2(plastic_man.pos)
	game.update_plastic_man_boss(plastic_man, 0.01)
	assert(plastic_man.plastic_dash_used and plastic_man.plastic_dash_state == "dash")
	assert(Vector2(plastic_man.pos).distance_to(game.player_pos) < plastic_before_dash.distance_to(game.player_pos))
	assert(game.enemy_bullets.size() >= 1 and float(plastic_man.plastic_rapid_fire_timer) > 2.9)
	for rapid_step in range(6):
		game.update_plastic_rapid_fire(plastic_man, 0.5)
	assert(is_equal_approx(float(plastic_man.plastic_rapid_fire_timer), 0.0) and game.enemy_bullets.size() > 10)

	# Red Guy: แทนกระสุนปกติด้วย Beyblade 3 อัน และรอ 8 วินาทีต่อชุด
	clear_combat(game)
	game.special_stage_mode = true
	game.level = game.SPECIAL_BOSS_LEVEL
	game.stage_level = 1
	game.spawn_boss()
	var red_guy: Dictionary = game.enemies[0]
	assert(is_equal_approx(float(red_guy.shoot), 8.0))
	game.fire_enemy_weapon(red_guy)
	assert(game.enemy_bullets.size() == 3 and is_equal_approx(game.get_named_boss_fire_delay(red_guy), 8.0))
	for red_blade in game.enemy_bullets:
		assert(red_blade.visual_key == "enemy_beyblade" and is_equal_approx(float(red_blade.radius), 18.0))

	# Nightmare ปลดล็อกเมื่อได้งานวิจัยครบ: บอส X2/X3 และ Endless ใช้ตารางคะแนนแยก
	clear_combat(game)
	game.item_collection.assign([1, 2, 3, 4, 5, 6])
	assert(game.set_difficulty_multiplier(2))
	game.special_stage_mode = false
	game.endless_mode = false
	game.level = 1
	game.stage_level = 1
	game.spawn_boss()
	var nightmare_boss: Dictionary = game.enemies[0]
	var nightmare_modifiers: Dictionary = game.skill_modifiers_for(nightmare_boss.visual)
	var expected_nightmare_hp := ceili((game.BOSS_HP_BASE + game.BOSS_HP_PER_LEVEL) * float(nightmare_modifiers.max_health_multiplier) * 2.0)
	assert(nightmare_boss.max_hp == expected_nightmare_hp)
	game.enemy_bullets.clear()
	game.add_enemy_bullet(Vector2.ZERO, Vector2.DOWN * 100.0, 8.0, game.BOSS_KIND, true, 10)
	assert(game.enemy_bullets[0].damage == 20)
	assert(is_equal_approx(Vector2(game.enemy_bullets[0].vel).length(), 100.0 * sqrt(2.0)))
	clear_combat(game)
	game.endless_mode = true
	game.score = 12345
	game.record_endless_score()
	assert(game.nightmare_endless_scores.has(12345) and not game.endless_scores.has(12345))

	# Story Nightmare จบ Phase 3 แล้วต่อ Stage ถัดไปทันที ไม่กลับเมนู
	game.endless_mode = false
	game.special_stage_mode = false
	game.selecting_character = false
	game.level = 1
	game.selected_stage = 1
	game.stage_level = game.LEVELS_PER_STAGE
	game.dialogue_active = true
	game.dialogue_completion = "phase"
	game.complete_stage()
	assert(game.level == 2 and game.stage_level == 1 and game.dialogue_active)
	assert(game.dialogue_completion == "intro" and not game.game_over)
	finish_intro(game)
	clear_combat(game)
	game.set_difficulty_multiplier(1)

	# Pause Menu: Story ที่ออกก่อนจบคืนรางวัล ส่วน Endless เก็บ Coin และบันทึกคะแนน
	clear_combat(game)
	game.special_stage_mode = false
	game.endless_mode = false
	game.selecting_character = false
	game.run_start_coins = 10
	game.sea_tokens = 12
	game.paused = true
	game.exit_run_to_menu()
	assert(game.sea_tokens == 10 and game.selecting_character and not game.paused)
	game.endless_mode = true
	game.selecting_character = false
	game.run_start_coins = 10
	game.sea_tokens = 12
	game.score = 4321
	game.paused = true
	game.exit_run_to_menu()
	assert(game.sea_tokens == 12 and game.endless_scores.has(4321))

	# [AdminTest] arms only after the exact keyboard sequence and unlocks on START.
	game.show_character_select()
	game.menu_page = "home"
	game.item_collection.clear()
	game.unlocked_ships.assign([0])
	game.highest_unlocked_stage = 1
	game.razor_special_cleared = false
	game.turtle_shop_unlocked = false
	game.stage_one_tutorial_seen = false
	game.sea_tokens = 0
	game.endless_scores.clear()
	game.best_score = 0
	game.selected_character = 0
	game.admin_test_progress = 0
	game.admin_test_armed = false
	game.admin_test_active = false
	for admin_keycode in game.ADMIN_TEST_SEQUENCE:
		var admin_key := InputEventKey.new()
		admin_key.keycode = admin_keycode
		admin_key.pressed = true
		game._unhandled_input(admin_key)
	assert(game.admin_test_armed and not game.admin_test_active)
	assert(game.item_collection.is_empty() and game.unlocked_ships == [0])
	assert(game.highest_unlocked_stage == 1 and game.sea_tokens == 0)
	assert(game.selected_character == 0)
	menu_click.position = game.LAUNCH_BUTTON.get_center()
	game._unhandled_input(menu_click)
	assert(game.admin_test_active and not game.admin_test_armed)
	assert(game.menu_page == "stage")
	assert(game.item_collection.size() == game.FINAL_LEVEL)
	assert(game.unlocked_ships.size() == game.PLAYER_SCENES.size())
	assert(game.highest_unlocked_stage == game.FINAL_LEVEL and game.razor_special_cleared)
	assert(game.turtle_shop_unlocked and game.stage_one_tutorial_seen)
	assert(game.sea_tokens == game.ADMIN_TEST_COIN_AMOUNT)
	assert(game.get_endless_best_score() >= game.VIPER_ENDLESS_UNLOCK_SCORE)
	assert(game.best_score >= game.VIPER_ENDLESS_UNLOCK_SCORE)
	if can_test_save:
		assert(FileAccess.file_exists(game.collection_save_path))
	assert(game.clear_user_data())
	assert(game.item_collection.is_empty() and game.unlocked_ships == [0])
	assert(game.sea_tokens == 0 and game.highest_unlocked_stage == 1)
	assert(not game.razor_special_cleared and game.endless_scores.is_empty() and game.nightmare_endless_scores.is_empty())
	assert(game.difficulty_multiplier == 1 and game.selected_character == 0 and game.selected_stage == 1)
	assert(game.best_score == 0 and is_equal_approx(game.master_volume, 0.90))
	assert(not FileAccess.file_exists(game.collection_save_path))
	game.music_player.stop()
	game.effect_player.stop()
	game.music_player.stream = null
	game.effect_player.stream = null
	root.remove_child(game)
	game.free()
	await process_frame
	await process_frame
	print("SMOKE TEST PASSED: seven PNG bosses, กุ้ง, animated dialogue, audio settings, Viper sprite skill, Nightmare and Web readiness")
	quit(0)

extends SceneTree

func _initialize() -> void:
	_run.call_deferred()


func prepare_clear(game: Node, stage: int, phase: int = 3, special: bool = false) -> void:
	game.level = stage
	game.stage_level = phase
	game.special_stage_mode = special
	game.endless_mode = false
	game.selecting_character = false
	game.game_over = false
	game.dialogue_active = true
	game.dialogue_completion = "phase"


func _run() -> void:
	var game := (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await process_frame
	game.collection_save_path = "res://tests/achievement_test_save.json"
	game.item_collection.clear()
	game.paused = false
	game.difficulty_multiplier = 1
	var notifications: Node = game.get_node("AchievementLayer/Notifications")
	assert(not notifications.visible and notifications.current.is_empty())
	assert(game.get_node("AchievementLayer").layer > game.get_node("CreditsLayer").layer)

	# A phase is not a stage clear; failed/unfinished stages show no achievement.
	prepare_clear(game, 1, 1)
	game.complete_stage()
	assert(not notifications.visible and notifications.pending.is_empty())

	# Stage and new Quest are displayed in order without replacing each other.
	prepare_clear(game, 1)
	game.complete_stage()
	assert(game.game_over and game.victory)
	assert(notifications.visible and notifications.current.title == "STAGE 1 CLEARED")
	assert(notifications.pending.size() == 1)
	assert(notifications.pending[0].title == "QUEST COMPLETED")
	assert(notifications.pending[0].detail == game.BOSS_REWARDS[1].name)
	game.complete_stage()
	assert(notifications.pending.size() == 1)

	# Pausing preserves time, then both banners expire and leave no stale state.
	game.paused = true
	notifications._process(10.0)
	assert(is_zero_approx(notifications.elapsed))
	game.paused = false
	notifications._process(notifications.DISPLAY_DURATION)
	assert(notifications.current.title == "QUEST COMPLETED")
	notifications._process(notifications.DISPLAY_DURATION)
	assert(not notifications.visible and notifications.current.is_empty())

	# Replaying reports the Stage clear without awarding the same Quest again.
	prepare_clear(game, 1)
	game.complete_stage()
	assert(notifications.current.title == "STAGE 1 CLEARED")
	assert(notifications.pending.is_empty())
	notifications.clear_notifications()

	# Special Stage uses its name and reveals the newly unlocked character.
	game.razor_special_cleared = false
	prepare_clear(game, 7, 1, true)
	game.complete_stage()
	assert(notifications.current.title == "SPECIAL STAGE CLEARED")
	assert(notifications.current.detail == "ปลดล็อก RAZOR")
	assert(notifications.pending.is_empty())
	notifications.clear_notifications()

	# Nightmare keeps the banner while continuing to the next stage's dialogue.
	game.item_collection.assign([1, 2, 3, 4, 5, 6])
	game.difficulty_multiplier = 2
	prepare_clear(game, 1)
	game.complete_stage()
	assert(game.level == 2 and game.dialogue_active and not game.game_over)
	assert(notifications.current.title == "STAGE 1 CLEARED")
	notifications.clear_notifications()

	# The last stage's banner remains above credits, and reset removes the queue.
	game.difficulty_multiplier = 1
	prepare_clear(game, 6)
	game.item_collection.erase(6)
	game.complete_stage()
	assert(game.credits_visible and notifications.visible)
	assert(notifications.current.title == "STAGE 6 CLEARED")
	assert(notifications.pending.size() == 1)
	assert(game.clear_user_data())
	assert(not notifications.visible and notifications.pending.is_empty())
	assert(not FileAccess.file_exists(game.collection_save_path))
	game.queue_free()
	await process_frame
	print("ACHIEVEMENT TEST PASSED: stages, new quests, replay, pause, Special Stage, Nightmare, credits and reset")
	quit()

extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	game.selected_character = 2
	game.start_selected_game()
	game.spawn_enemy()
	await process_frame
	var background = game.get_node("ParallaxBackground")
	assert(not game.selecting_character)
	assert(game.max_player_health == 6)
	assert(game.player_sprite.texture != null)
	assert(game.enemies.size() == 1)
	assert(background.active_layers.size() == 3)
	print("SMOKE TEST PASSED: selection, sprites, enemy spawn, and 3 parallax layers")
	quit(0)

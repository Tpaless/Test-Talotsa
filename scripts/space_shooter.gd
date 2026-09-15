extends Node2D

const GAME_SIZE := Vector2(960.0, 540.0)
const PLAYER_RADIUS := 18.0
const PLAYER_SCENES: Array[PackedScene] = [
	preload("res://characters/player/player.tscn"),
	preload("res://characters/player/swift.tscn"),
	preload("res://characters/player/titan.tscn")
]
const SHIP_NAMES := ["FALCON", "SWIFT", "TITAN"]
const SHIP_ROLES := ["BALANCED", "SPEED", "HEAVY"]
const ENEMY_SCENES: Array[PackedScene] = [
	preload("res://characters/enemies/scout.tscn"),
	preload("res://characters/enemies/striker.tscn"),
	preload("res://characters/enemies/tank.tscn")
]

@onready var character_layer: Node2D = $CharacterLayer
@onready var player_sprite: Sprite2D = $CharacterLayer/Player

var player_pos := Vector2(480.0, 458.0)
var player_health := 4
var max_player_health := 4
var player_speed := 360.0
var fire_delay := 0.145
var selected_character := 0
var selecting_character := true
var score := 0
var best_score := 0
var elapsed := 0.0
var fire_timer := 0.0
var spawn_timer := 0.0
var invulnerable_timer := 0.0
var shake_timer := 0.0
var flash_timer := 0.0
var paused := false
var game_over := false
var shake_offset := Vector2.ZERO

var bullets: Array = []
var enemy_bullets: Array = []
var enemies: Array = []
var particles: Array = []
var pickups: Array = []

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	show_character_select()


func show_character_select() -> void:
	for enemy in enemies:
		free_enemy_visual(enemy)
	enemies.clear()
	bullets.clear()
	enemy_bullets.clear()
	particles.clear()
	pickups.clear()
	paused = false
	game_over = false
	selecting_character = true
	character_layer.position = Vector2.ZERO
	player_sprite.visible = false
	queue_redraw()


func start_selected_game() -> void:
	selecting_character = false
	apply_selected_character()
	reset_game()


func apply_selected_character() -> void:
	if is_instance_valid(player_sprite):
		character_layer.remove_child(player_sprite)
		player_sprite.queue_free()
	player_sprite = PLAYER_SCENES[selected_character].instantiate() as Sprite2D
	character_layer.add_child(player_sprite)
	match selected_character:
		1:
			max_player_health = 3
			player_speed = 440.0
			fire_delay = 0.10
		2:
			max_player_health = 6
			player_speed = 285.0
			fire_delay = 0.23
		_:
			max_player_health = 4
			player_speed = 360.0
			fire_delay = 0.145


func reset_game() -> void:
	for enemy in enemies:
		free_enemy_visual(enemy)
	player_pos = Vector2(GAME_SIZE.x * 0.5, GAME_SIZE.y - 82.0)
	player_health = max_player_health
	score = 0
	elapsed = 0.0
	fire_timer = 0.18
	spawn_timer = 0.55
	invulnerable_timer = 1.0
	shake_timer = 0.0
	flash_timer = 0.0
	paused = false
	game_over = false
	shake_offset = Vector2.ZERO
	character_layer.position = Vector2.ZERO
	player_sprite.position = player_pos
	player_sprite.visible = true
	bullets.clear()
	enemy_bullets.clear()
	enemies.clear()
	particles.clear()
	pickups.clear()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if selecting_character:
			if event.keycode == KEY_A or event.keycode == KEY_LEFT:
				selected_character = wrapi(selected_character - 1, 0, PLAYER_SCENES.size())
			elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
				selected_character = wrapi(selected_character + 1, 0, PLAYER_SCENES.size())
			elif event.keycode >= KEY_1 and event.keycode <= KEY_3:
				selected_character = event.keycode - KEY_1
			elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
				start_selected_game()
			queue_redraw()
		elif event.keycode == KEY_R and game_over:
			show_character_select()
		elif event.keycode == KEY_P and not game_over:
			paused = not paused
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selecting_character:
		for i in range(PLAYER_SCENES.size()):
			if Rect2(130.0 + i * 240.0, 130.0, 220.0, 260.0).has_point(event.position):
				selected_character = i
				queue_redraw()
				return
		if Rect2(360.0, 425.0, 240.0, 50.0).has_point(event.position):
			start_selected_game()


func _process(delta: float) -> void:
	if not selecting_character and not paused and not game_over:
		update_game(delta)
	update_particles(delta)
	shake_timer = maxf(0.0, shake_timer - delta)
	flash_timer = maxf(0.0, flash_timer - delta)
	shake_offset = Vector2.ZERO
	if shake_timer > 0.0:
		shake_offset = Vector2(rng.randf_range(-5.0, 5.0), rng.randf_range(-4.0, 4.0))
	character_layer.position = shake_offset
	queue_redraw()


func update_game(delta: float) -> void:
	elapsed += delta
	fire_timer -= delta
	spawn_timer -= delta
	invulnerable_timer = maxf(0.0, invulnerable_timer - delta)

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction.length_squared() > 0.0:
		player_pos += direction.normalized() * player_speed * delta
	player_pos.x = clampf(player_pos.x, 30.0, GAME_SIZE.x - 30.0)
	player_pos.y = clampf(player_pos.y, 82.0, GAME_SIZE.y - 34.0)

	if (Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and fire_timer <= 0.0:
		fire_player_weapon()

	if spawn_timer <= 0.0:
		spawn_enemy()
		spawn_timer = maxf(0.30, 0.92 - elapsed * 0.007) * rng.randf_range(0.78, 1.15)

	update_bullets(delta)
	update_enemies(delta)
	update_pickups(delta)
	resolve_collisions()
	player_sprite.position = player_pos
	player_sprite.visible = not game_over and (invulnerable_timer <= 0.0 or int(invulnerable_timer * 12.0) % 2 == 0)


func fire_player_weapon() -> void:
	fire_timer = fire_delay
	if selected_character == 1:
		bullets.append({"pos": player_pos + Vector2(0.0, -24.0), "vel": Vector2(0.0, -680.0)})
	elif selected_character == 2:
		bullets.append({"pos": player_pos + Vector2(-15.0, -18.0), "vel": Vector2(-55.0, -560.0)})
		bullets.append({"pos": player_pos + Vector2(0.0, -25.0), "vel": Vector2(0.0, -590.0)})
		bullets.append({"pos": player_pos + Vector2(15.0, -18.0), "vel": Vector2(55.0, -560.0)})
	else:
		bullets.append({"pos": player_pos + Vector2(-9.0, -20.0), "vel": Vector2(-24.0, -590.0)})
		bullets.append({"pos": player_pos + Vector2(9.0, -20.0), "vel": Vector2(24.0, -590.0)})
	spawn_sparks(player_pos + Vector2(0.0, -23.0), Color("7df9ff"), 2, 55.0)


func spawn_enemy() -> void:
	var kind := 0
	var roll := rng.randf()
	if elapsed > 26.0 and roll < 0.18:
		kind = 2
	elif elapsed > 10.0 and roll < 0.42:
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
	character_layer.add_child(enemy_visual)
	enemy_visual.position = spawn_position
	enemies.append({
		"pos": spawn_position,
		"vel": Vector2(0.0, speed),
		"radius": radius,
		"hp": hp,
		"max_hp": hp,
		"kind": kind,
		"worth": worth,
		"phase": rng.randf_range(0.0, TAU),
		"shoot": rng.randf_range(0.8, 2.4),
		"visual": enemy_visual
	})


func update_bullets(delta: float) -> void:
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].pos += bullets[i].vel * delta
		if bullets[i].pos.y < -20.0:
			bullets.remove_at(i)
	for i in range(enemy_bullets.size() - 1, -1, -1):
		enemy_bullets[i].pos += enemy_bullets[i].vel * delta
		if enemy_bullets[i].pos.y > GAME_SIZE.y + 20.0 or enemy_bullets[i].pos.x < -20.0 or enemy_bullets[i].pos.x > GAME_SIZE.x + 20.0:
			enemy_bullets.remove_at(i)


func update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy = enemies[i]
		enemy.pos += enemy.vel * delta
		if enemy.kind == 1:
			enemy.pos.x += sin(elapsed * 3.1 + enemy.phase) * 85.0 * delta
		elif enemy.kind == 2:
			enemy.pos.x += sin(elapsed * 1.6 + enemy.phase) * 35.0 * delta
		enemy.pos.x = clampf(enemy.pos.x, enemy.radius, GAME_SIZE.x - enemy.radius)
		enemy.visual.position = enemy.pos
		if enemy.kind == 1:
			enemy.visual.rotation = sin(elapsed * 3.1 + enemy.phase) * 0.13
		enemy.shoot -= delta
		if enemy.shoot <= 0.0 and enemy.pos.y > 30.0:
			fire_enemy_weapon(enemy)
			enemy.shoot = rng.randf_range(1.5, 2.8) if enemy.kind != 2 else rng.randf_range(0.75, 1.25)
		if enemy.pos.y > GAME_SIZE.y + enemy.radius:
			free_enemy_visual(enemy)
			enemies.remove_at(i)
			damage_player()


func fire_enemy_weapon(enemy: Dictionary) -> void:
	var enemy_position: Vector2 = enemy.pos
	var aim: Vector2 = (player_pos - enemy_position).normalized()
	var speed := 220.0 if enemy.kind != 2 else 260.0
	if enemy.kind == 2:
		for angle in [-0.18, 0.0, 0.18]:
			enemy_bullets.append({"pos": enemy.pos + Vector2(0.0, enemy.radius), "vel": aim.rotated(angle) * speed, "radius": 6.0})
	else:
		enemy_bullets.append({"pos": enemy.pos + Vector2(0.0, enemy.radius), "vel": aim * speed, "radius": 5.0})


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
			if bullets[bullet_index].pos.distance_squared_to(enemy.pos) < pow(enemy.radius + 5.0, 2.0):
				enemy.hp -= 1
				spawn_sparks(bullets[bullet_index].pos, Color("ffd166"), 5, 145.0)
				hit = true
				if enemy.hp <= 0:
					destroy_enemy(enemy_index)
				break
		if hit:
			bullets.remove_at(bullet_index)

	if invulnerable_timer <= 0.0:
		for i in range(enemy_bullets.size() - 1, -1, -1):
			if enemy_bullets[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + enemy_bullets[i].radius, 2.0):
				enemy_bullets.remove_at(i)
				damage_player()
				break

	if invulnerable_timer <= 0.0:
		for i in range(enemies.size() - 1, -1, -1):
			if enemies[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + enemies[i].radius - 4.0, 2.0):
				spawn_explosion(enemies[i].pos, enemy_color(enemies[i].kind), 18)
				free_enemy_visual(enemies[i])
				enemies.remove_at(i)
				damage_player()
				break

	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].pos.distance_squared_to(player_pos) < pow(PLAYER_RADIUS + 14.0, 2.0):
			player_health = mini(max_player_health, player_health + 1)
			score += 75
			spawn_explosion(pickups[i].pos, Color("65ff9a"), 14)
			pickups.remove_at(i)


func destroy_enemy(index: int) -> void:
	var enemy = enemies[index]
	score += enemy.worth
	best_score = maxi(best_score, score)
	spawn_explosion(enemy.pos, enemy_color(enemy.kind), 12 + enemy.kind * 7)
	shake_timer = 0.09 if enemy.kind < 2 else 0.22
	if rng.randf() < 0.075 and player_health < max_player_health:
		pickups.append({"pos": enemy.pos, "phase": 0.0})
	free_enemy_visual(enemy)
	enemies.remove_at(index)


func free_enemy_visual(enemy: Dictionary) -> void:
	var visual := enemy.get("visual") as Node
	if is_instance_valid(visual):
		visual.queue_free()


func damage_player() -> void:
	if game_over or invulnerable_timer > 0.0:
		return
	player_health -= 1
	invulnerable_timer = 1.25
	shake_timer = 0.32
	flash_timer = 0.12
	spawn_explosion(player_pos, Color("7df9ff"), 22)
	if player_health <= 0:
		game_over = true
		best_score = maxi(best_score, score)
		bullets.clear()
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
		draw_line(bullet.pos + Vector2(0.0, 13.0), bullet.pos, Color(0.30, 0.95, 1.0, 0.3), 5.0)
		draw_circle(bullet.pos, 3.2, Color("d8ffff"))
	for bullet in enemy_bullets:
		draw_circle(bullet.pos, bullet.radius + 4.0, Color(1.0, 0.1, 0.4, 0.12))
		draw_circle(bullet.pos, bullet.radius, Color("ff477e"))
		draw_circle(bullet.pos, maxf(1.5, bullet.radius - 3.0), Color("fff0f5"))
	for enemy in enemies:
		if enemy.max_hp > 1 and enemy.hp < enemy.max_hp:
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
	draw_circle(pos, 18.0 * pulse, Color(0.2, 1.0, 0.5, 0.12))
	draw_circle(pos, 12.0, Color("22c96b"))
	draw_rect(Rect2(pos - Vector2(2.5, 8.0), Vector2(5.0, 16.0)), Color.WHITE)
	draw_rect(Rect2(pos - Vector2(8.0, 2.5), Vector2(16.0, 5.0)), Color.WHITE)

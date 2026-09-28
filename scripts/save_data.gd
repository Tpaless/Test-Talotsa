extends Node

const SAVE_PATH := "user://save_game.cfg"
const CHARACTER_IDS := ["falcon", "swift", "titan"]
const MAX_WEAPON_LEVEL := 5

var dugong_tokens := 0
var unlocked_characters: Array[String] = ["falcon"]
var weapon_levels: Dictionary = {"falcon": 1, "swift": 1, "titan": 1}
var persistence_enabled := true


func _ready() -> void:
	load_data()


func load_data() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == OK:
		dugong_tokens = maxi(0, int(config.get_value("wallet", "dugong_tokens", 0)))
		var loaded_characters: PackedStringArray = config.get_value("progress", "unlocked_characters", PackedStringArray(["falcon"]))
		unlocked_characters.clear()
		for character_id in loaded_characters:
			if character_id in CHARACTER_IDS and character_id not in unlocked_characters:
				unlocked_characters.append(character_id)
		if "falcon" not in unlocked_characters:
			unlocked_characters.append("falcon")
		for character_id in CHARACTER_IDS:
			weapon_levels[character_id] = clampi(int(config.get_value("weapons", character_id, 1)), 1, MAX_WEAPON_LEVEL)
	elif error != ERR_FILE_NOT_FOUND:
		push_warning("Could not load save data: error %d" % error)


func add_dugong_tokens(amount: int) -> void:
	if amount <= 0:
		return
	dugong_tokens += amount
	save_data()


func spend_dugong_tokens(amount: int) -> bool:
	if amount <= 0 or dugong_tokens < amount:
		return false
	dugong_tokens -= amount
	save_data()
	return true


func is_character_unlocked(character_id: String) -> bool:
	return character_id in unlocked_characters


func unlock_character(character_id: String) -> void:
	if character_id in CHARACTER_IDS and character_id not in unlocked_characters:
		unlocked_characters.append(character_id)
		save_data()


func get_weapon_level(character_id: String) -> int:
	return int(weapon_levels.get(character_id, 1))


func get_weapon_upgrade_cost(character_id: String) -> int:
	return 75 * get_weapon_level(character_id)


func upgrade_weapon(character_id: String) -> bool:
	var current_level := get_weapon_level(character_id)
	if not is_character_unlocked(character_id) or current_level >= MAX_WEAPON_LEVEL:
		return false
	if not spend_dugong_tokens(get_weapon_upgrade_cost(character_id)):
		return false
	weapon_levels[character_id] = current_level + 1
	save_data()
	return true


func save_data() -> void:
	if not persistence_enabled:
		return
	var config := ConfigFile.new()
	config.set_value("wallet", "dugong_tokens", dugong_tokens)
	config.set_value("progress", "unlocked_characters", PackedStringArray(unlocked_characters))
	for character_id in CHARACTER_IDS:
		config.set_value("weapons", character_id, get_weapon_level(character_id))
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Could not save data: error %d" % error)

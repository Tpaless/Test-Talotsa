extends Sprite2D
class_name CombatantVisual

# ไฟล์สกิลใช้ซ้ำได้: แก้ค่าของสกิลใน skills/*.tres แล้วทุกตัวที่ใช้สกิลนั้นจะเปลี่ยนตาม
const RAPID_FIRE = preload("res://skills/rapid_fire.tres")
const SPREAD_SHOT = preload("res://skills/spread_shot.tres")
const FORTIFY = preload("res://skills/fortify.tres")
const BOSS_BULWARK = preload("res://skills/boss_bulwark.tres")
const BOSS_CROSSFIRE = preload("res://skills/boss_crossfire.tres")
const BOSS_KUNG = preload("res://skills/boss_kung.tres")
const BOSS_PURSUIT = preload("res://skills/boss_pursuit.tres")
const BOSS_BARRAGE = preload("res://skills/boss_barrage.tres")
const BOSS_OVERDRIVE = preload("res://skills/boss_overdrive.tres")
const BOSS_RED_GUY = preload("res://skills/boss_red_guy.tres")

# ตั้งสกิลตรงนี้ได้เลย ไม่ต้องเปิด Inspector
# ด้านซ้ายคือที่อยู่ไฟล์ Scene ของตัวละคร (player.tscn คือ Johny)
# เพิ่มสกิลให้ยานหรือศัตรูทั่วไป: ใส่ชื่อสกิลหลังเครื่องหมายจุลภาค
# เอาสกิลออก: ลบชื่อสกิลออกจากวงเล็บเหลี่ยม; [] หมายถึงไม่มีสกิล
# สกิลเดียวกันใส่ให้ผู้เล่น ศัตรู หรือบอสหลายตัวได้
const SKILL_LOADOUTS := {
	"res://characters/player/player.tscn": [],
	"res://characters/player/swift.tscn": [],
	"res://characters/player/titan.tscn": [],
	"res://characters/player/razor.tscn": [],
	"res://characters/player/viper.tscn": [],
	"res://characters/enemies/scout.tscn": [],
	"res://characters/enemies/striker.tscn": [],
	"res://characters/enemies/tank.tscn": [],
	"res://characters/enemies/boss.tscn": [], # บอสใช้ BOSS_SKILLS_BY_LEVEL ด้านล่าง
}

# บอสเนื้อเรื่อง 6 ตัวและบอสพิเศษใช้โมเดลและสกิลคนละไฟล์
# เปลี่ยนสกิล: แก้ชื่อภายใน [] ของด่านนั้น; เพิ่มด่านใหม่: เพิ่มเลขด่านและไฟล์สกิล
const BOSS_SKILLS_BY_LEVEL := {
	1: [BOSS_BULWARK],
	2: [BOSS_CROSSFIRE],
	3: [BOSS_KUNG],
	4: [BOSS_PURSUIT],
	5: [BOSS_BARRAGE],
	6: [BOSS_OVERDRIVE],
	7: [BOSS_RED_GUY],
}

# สำหรับสกิลที่เพิ่มระหว่างรันเกมด้วยโค้ด เช่น character.skills.append(FORTIFY)
var skills: Array[SkillDefinition] = []


func equip_boss_level(stage: int) -> void:
	# เรียกเมื่อสร้างบอส เพื่อให้แต่ละด่านอ่านชุดสกิลของตัวเอง
	skills.clear()
	for resource in BOSS_SKILLS_BY_LEVEL.get(stage, []):
		var skill := resource as SkillDefinition
		if skill != null:
			skills.append(skill)


func get_equipped_skills() -> Array[SkillDefinition]:
	var equipped: Array[SkillDefinition] = []
	for resource in SKILL_LOADOUTS.get(scene_file_path, []):
		var skill := resource as SkillDefinition
		if skill != null:
			equipped.append(skill)
	equipped.append_array(skills)
	return equipped


func get_skill_modifiers() -> Dictionary:
	var fire_multiplier := 1.0
	var health_multiplier := 1.0
	var extra_shots := 0
	for skill in get_equipped_skills():
		if skill == null:
			continue
		fire_multiplier *= skill.fire_interval_multiplier
		health_multiplier *= skill.max_health_multiplier
		extra_shots += skill.extra_projectiles
	return {
		"fire_interval_multiplier": maxf(0.1, fire_multiplier),
		"max_health_multiplier": maxf(1.0, health_multiplier),
		"extra_projectiles": maxi(0, extra_shots)
	}


func get_skill_names() -> PackedStringArray:
	var names := PackedStringArray()
	for skill in get_equipped_skills():
		if skill != null:
			names.append(skill.display_name)
	return names

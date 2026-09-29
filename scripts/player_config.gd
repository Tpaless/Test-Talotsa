extends RefCounted

# ลำดับ 0-4 ตรงกับ PLAYER_SCENES ใน space_shooter.gd
# ปรับ HP, ความเร็ว, ช่วงเวลายิง, ดาเมจ และท่าพิเศษของยานแต่ละลำได้ตรงนี้
# health_multiplier 1.5 = HP 150%; fire_delay ยิ่งน้อยยิ่งยิงถี่
# base_health เป็น HP ตั้งต้น (เกมปัด HP หลังคูณขึ้นเป็นจำนวนเต็ม)
# speed = ความเร็วเดิน, bullet_speed = ความเร็วกระสุน, weapon = รูปแบบยิง
# special_cooldown = วินาทีรอใช้ท่าซ้ำ, special_duration = เวลาท่าทำงาน
# special_damage = ดาเมจทั่วไป, special_boss_damage = ดาเมจเฉพาะบอส
# ภาพยานและกระสุนแก้ที่ visual_config.gd
# แต่ละท่าพิเศษตั้งภาพ PNG, WebP หรือ SVG ของตัวเองได้ด้วย special_texture
# และกำหนดขนาดภาพในเกมด้วย special_texture_size
const SHIPS := [
	# ตัวที่ 1: เรือมาตรฐานเร็ว HP 150% ยิงคู่ตรง
	{
		"name": "JOHNY", "role": "STANDARD / FAST", "weapon_label": "TWIN SHOT",
		"base_health": 100, "health_multiplier": 1.5, "speed": 440.0,
		"fire_delay": 0.15, "weapon": "twin", "bullet_speed": 610.0,
		"special": "", "special_label": "NONE", "special_cooldown": 0.0
	},
	# ตัวที่ 2: กระสุนปกติสองนัดตรง; ท่าพิเศษยิงกระสุนยักษ์ติดตามทุก 2 วินาทีเป็นเวลา 6 วินาที
	# กระสุนยักษ์แต่ละนัดเจาะได้ 10 เป้าหมาย และทำดาเมจแต่ละเป้าหมายครั้งเดียว
	{
		"name": "JOHNY SAPARROW", "role": "SPECIAL HOMING", "weapon_label": "2 STRAIGHT SHOTS",
		"base_health": 100, "health_multiplier": 1.0, "speed": 350.0,
		"fire_delay": 0.25, "weapon": "twin", "bullet_speed": 510.0,
		"homing_turn_speed": 1100.0,
		"special": "giant_shot", "special_label": "GIANT SHOT",
		"special_cooldown": 10.0, "special_duration": 6.0,
		"special_interval": 2.0, "special_pierce": 10,
		"special_bullet_speed": 520.0, "special_radius": 28.0,
		"special_damage": 1.0, "special_boss_damage": 5.0
	},
	# ตัวที่ 3: ยิงพัดกว้าง 5 นัด ช้าที่สุด; เลเซอร์ห้าเส้นทำดาเมจเพิ่ม 50%
	{
		"name": "PICHU JOHNY", "role": "WIDE / SLOW", "weapon_label": "WIDE FAN",
		"base_health": 100, "health_multiplier": 1.0, "speed": 318.0,
		"fire_delay": 0.38, "weapon": "wide", "bullet_speed": 550.0,
		"wide_shots": 5, "wide_angle_step": 0.24, "boss_damage_multiplier": 0.35,
		"special": "laser", "special_label": "FIVE LASERS",
		"special_cooldown": 7.0, "laser_count": 5,
		"laser_spacing": 80.0, "laser_width": 22.0,
		"special_damage": 9.0, "special_boss_damage": 13.5
	},
	# ตัวที่ 4: Beyblade เคลื่อนที่ตรงจนโดนศัตรูหรือขอบจอ แล้วสะท้อนไปหาเป้าหมายใหม่
	{
		"name": "SANTA JOHNY", "role": "STANDARD / FAST", "weapon_label": "TWIN SHOT",
		"base_health": 100, "health_multiplier": 1.0, "speed": 440.0,
		"fire_delay": 0.22, "weapon": "twin", "bullet_speed": 610.0,
		"special": "beyblade", "special_label": "BEYBLADE",
		"special_texture": "res://assets/sprites/beyblade.png",
		"special_texture_size": Vector2(72.0, 72.0),
		"special_spin_speed": 32.0,
		"special_cooldown": 8.0, "special_duration": 6.0,
		"special_speed": 370.0, "special_damage": 2.0,
		"special_boss_damage": 1.5, "special_hit_interval": 0.22
	},
	# ตัวที่ 5: ลำแสงทำดาเมจบอสตาม Max HP ต่อเนื่อง 3 วินาที: 25%, 15%, 10%
	{
		"name": "STRAW HAT JOHNY", "role": "V CANNON / FAST", "weapon_label": "2 HEAVY V SHOTS",
		"base_health": 100, "health_multiplier": 1.2, "speed": 440.0,
		"fire_delay": 0.15, "weapon": "heavy_v", "bullet_speed": 600.0,
		"v_angle": 0.24, "v_damage": 1.5, "v_radius": 12.6,
		"special": "viper_beam", "special_label": "BOSS MELTER 50%", "special_cooldown": 12.0,
		"special_texture": "res://assets/sprites/Viper_Skill.png",
		"special_texture_size": Vector2(132.0, 920.0),
		"special_duration": 3.0, "special_interval": 1.0, "beam_width": 100.0,
		"special_damage": 8.0, "special_boss_percentages": [0.25, 0.15, 0.10]
	}
]


static func get_ship(index: int) -> Dictionary:
	return SHIPS[index]

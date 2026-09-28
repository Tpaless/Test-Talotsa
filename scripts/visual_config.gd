extends RefCounted

# เปลี่ยนภาพของยาน ศัตรู กระสุน ไอเทม และท่าพิเศษได้ด้วยการแก้ path ด้านล่าง
# รองรับ PNG, WebP และ SVG
# ยาน/ศัตรู path ว่าง = ใช้ Texture ใน Scene; ใส่ path ใหม่เพื่อทับ Scene
# กระสุน/ไอเทม/เอฟเฟกต์ path ว่าง = เกมวาดรูปพื้นฐานแทน
# ภาพพื้นหลังแก้ที่ parallax_background.gd และภาพบทสนทนาแก้ที่ dialogue_config.gd
const TEXTURE_PATHS := {
	"falcon": "", # characters/player/player.tscn
	"swift": "", # characters/player/swift.tscn
	"titan": "", # characters/player/titan.tscn
	"razor": "", # characters/player/razor.tscn
	"viper": "", # characters/player/viper.tscn
	"scout": "", # characters/enemies/scout.tscn
	"striker": "", # characters/enemies/striker.tscn
	"tank": "", # characters/enemies/tank.tscn
	"boss": "", # characters/enemies/boss.tscn
	"player_normal": "res://assets/sprites/bullet_normal.svg",
	"player_homing": "res://assets/sprites/bullet_homing.svg",
	"player_wide": "res://assets/sprites/bullet_wide.svg",
	"player_heavy": "res://assets/sprites/bullet_heavy.svg",
	"player_giant": "res://assets/sprites/bullet_giant.svg",
	"enemy_normal": "res://assets/sprites/bullet_enemy.svg",
	"enemy_special": "res://assets/sprites/bullet_special.svg",
	"health_pickup": "res://assets/sprites/pickup_health.svg",
}

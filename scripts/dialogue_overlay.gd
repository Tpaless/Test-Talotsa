extends Control

# หน้าตาและตำแหน่งของแต่ละโหนดปรับได้ที่ res://ui/dialogue_overlay.tscn
# สคริปต์นี้ใส่ข้อความ/รูปจาก dialogue_config.gd และอัปเดตตัวนับเท่านั้น
@onready var accent_bar: ColorRect = $Panel/AccentBar
@onready var portrait: TextureRect = $Panel/Portrait
@onready var speaker_label: Label = $Panel/Speaker
@onready var body_label: Label = $Panel/Body
@onready var counter_label: Label = $Panel/Counter
@onready var next_hint: Label = $Panel/NextHint

# ปรับคำใบ้เริ่มต้นได้จาก Inspector ของโหนด DialogueOverlay ในฉาก
@export var next_line_hint := "แตะ / คลิก เพื่ออ่านข้อความถัดไป"
@export var next_stage_hint := "แตะ / คลิก เพื่อไปด่านถัดไป"
@export var finish_game_hint := "แตะ / คลิก เพื่อดูสรุปคะแนน"


func show_line(line: Dictionary, index: int, total: int, final_stage: bool) -> void:
	# คีย์ทุกตัวเป็นตัวเลือกได้: ถ้าไม่ใส่ portrait จะซ่อนรูป
	speaker_label.text = str(line.get("speaker", ""))
	body_label.text = str(line.get("text", ""))
	var accent_color := Color(str(line.get("accent", "#65efff")))
	accent_bar.color = accent_color
	speaker_label.add_theme_color_override("font_color", accent_color)
	var portrait_path := str(line.get("portrait", ""))
	portrait.texture = load(portrait_path) as Texture2D if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path) else null
	portrait.visible = portrait.texture != null
	counter_label.text = "%d / %d" % [index + 1, total]
	if index + 1 < total:
		next_hint.text = str(line.get("hint", next_line_hint))
	elif final_stage:
		next_hint.text = str(line.get("hint", finish_game_hint))
	else:
		next_hint.text = str(line.get("hint", next_stage_hint))
	show()

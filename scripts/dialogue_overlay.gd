extends Control

# หน้าตาและตำแหน่งของแต่ละโหนดปรับได้ที่ res://ui/dialogue_overlay.tscn
# สคริปต์นี้ใส่ข้อความ/รูปจาก dialogue_config.gd และอัปเดตตัวนับเท่านั้น
@onready var accent_bar: ColorRect = $Panel/AccentBar
@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var speaker_label: Label = $Panel/Speaker
@onready var body_label: Label = $Panel/Body
@onready var counter_label: Label = $Panel/Counter
@onready var next_hint: Label = $Panel/NextHint

# ปรับคำใบ้เริ่มต้นได้จาก Inspector ของโหนด DialogueOverlay ในฉาก
@export var next_line_hint := "แตะ / คลิก เพื่ออ่านข้อความถัดไป"
@export var next_stage_hint := "แตะ / คลิก เพื่อไปด่านถัดไป"
@export var finish_game_hint := "แตะ / คลิก เพื่อดูสรุปคะแนน"
@export_range(20.0, 120.0, 1.0) var characters_per_second := 72.0

var full_body_text := ""
var reveal_progress := 0.0
var typing := false
var line_tween: Tween


func _process(delta: float) -> void:
	if typing:
		reveal_progress += delta * characters_per_second
		body_label.visible_characters = mini(full_body_text.length(), floori(reveal_progress))
		if body_label.visible_characters >= full_body_text.length():
			finish_typing()
	else:
		next_hint.modulate.a = 0.68 + sin(Time.get_ticks_msec() * 0.006) * 0.30


func is_typing() -> bool:
	return typing


func finish_typing() -> void:
	typing = false
	body_label.visible_characters = -1
	next_hint.modulate.a = 1.0


func show_line(line: Dictionary, index: int, total: int, final_stage: bool) -> void:
	# คีย์ทุกตัวเป็นตัวเลือกได้: ถ้าไม่ใส่ portrait จะซ่อนรูป
	speaker_label.text = str(line.get("speaker", ""))
	full_body_text = str(line.get("text", ""))
	body_label.text = full_body_text
	body_label.visible_characters = 0
	reveal_progress = 0.0
	typing = not full_body_text.is_empty()
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
	next_hint.modulate.a = 0.0
	show()
	if line_tween != null and line_tween.is_valid():
		line_tween.kill()
	panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	panel.position = Vector2(0.0, 18.0)
	portrait.scale = Vector2(0.88, 0.88)
	portrait.pivot_offset = portrait.size * 0.5
	line_tween = create_tween().set_parallel(true)
	line_tween.tween_property(panel, "modulate", Color.WHITE, 0.12)
	line_tween.tween_property(panel, "position", Vector2.ZERO, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	line_tween.tween_property(portrait, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

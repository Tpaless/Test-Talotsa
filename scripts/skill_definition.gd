extends Resource
class_name SkillDefinition

# สกิลหนึ่งไฟล์ใช้ซ้ำได้กับยาน ศัตรูทั่วไป และบอส
# ค่า 1.0 หมายถึงไม่เปลี่ยนค่าเดิม; ยิงถี่ขึ้นใช้ค่าต่ำกว่า 1.0
@export var display_name: String = "New Skill"
@export_multiline var description: String = ""
@export_range(0.1, 3.0, 0.05) var fire_interval_multiplier: float = 1.0
# 1.5 หมายถึง HP สูงขึ้น 50%; ใช้ได้ทั้งผู้เล่นและศัตรู
@export_range(1.0, 5.0, 0.1) var max_health_multiplier: float = 1.0
# จำนวนกระสุนเสริมต่อการยิงหนึ่งครั้ง เช่น 2 = เพิ่มซ้ายและขวา
@export_range(0, 8, 1) var extra_projectiles: int = 0

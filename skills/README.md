# ตั้งสกิลเสริมใน Script (ไม่ต้องใช้ Inspector)

ค่าสถานะและอาวุธหลักของยานทั้ง 5 ลำอยู่ใน [`scripts/player_config.gd`](../scripts/player_config.gd) ส่วนรายการด้านล่างใช้เพิ่มสกิล Resource เสริมให้ยานหรือศัตรูได้ตามต้องการ ค่าเริ่มต้นของยานทั้ง 5 ลำเป็น `[]` เพื่อให้ค่าสถานะตรงกับที่ระบุใน `player_config.gd`

เปิด [`scripts/combatant_visual.gd`](../scripts/combatant_visual.gd) แล้วแก้รายการ `SKILL_LOADOUTS` ที่ต้นไฟล์ สกิลที่ใส่ให้แต่ละตัวอยู่ในวงเล็บเหลี่ยม `[]`:

```gdscript
const SKILL_LOADOUTS := {
	"res://characters/player/player.tscn": [], # ยาน Falcon
	"res://characters/player/swift.tscn": [],
	"res://characters/player/titan.tscn": [],
	"res://characters/player/razor.tscn": [],
	"res://characters/player/viper.tscn": [],
	"res://characters/enemies/scout.tscn": [],           # ไม่มีสกิล
	"res://characters/enemies/striker.tscn": [],
	"res://characters/enemies/tank.tscn": [],
	"res://characters/enemies/boss.tscn": [], # สกิลบอสตั้งแยกตามด่านด้านล่าง
}
```

ตัวอย่าง: ถ้าต้องการให้ยาน Falcon ยิงถี่ขึ้นและมีกระสุนเสริม ให้แก้บรรทัด `player.tscn` เป็น `"res://characters/player/player.tscn": [RAPID_FIRE, SPREAD_SHOT],` กด `Ctrl+S` แล้วเริ่มเกมใหม่ ไม่ต้องแก้ Scene หรือ Inspector ที่อยู่ไฟล์ด้านซ้ายต้องตรงกับ Scene ของตัวนั้น ทั้งนี้สกิลเสริมจะเปลี่ยนค่าสถานะจากค่าหลักที่ตั้งใน `player_config.gd`

สกิลหนึ่งชุดใช้ซ้ำได้กับผู้เล่น ศัตรู และบอส ใส่ชื่อสกิลเดียวกันให้หลายตัวใน `SKILL_LOADOUTS` ได้ การเพิ่มสกิลระหว่างรันเกมจากสคริปต์อื่นใช้ `character.skills.append(load("res://skills/fortify.tres"))` ได้

## เปลี่ยนสกิลบอสแต่ละด่าน

บอสใช้ Scene เดียวกัน แต่เมื่อเกมสร้างบอสจะใส่สกิลตามเลขด่านจาก `BOSS_SKILLS_BY_LEVEL` ใน [`combatant_visual.gd`](../scripts/combatant_visual.gd):

```gdscript
const BOSS_SKILLS_BY_LEVEL := {
	1: [BOSS_BULWARK],
	2: [BOSS_CROSSFIRE],
	3: [BOSS_PURSUIT],
	4: [BOSS_BARRAGE],
	5: [BOSS_OVERDRIVE],
}
```

ถ้าจะเปลี่ยนบอสด่าน 3 ให้ใช้สกิลอื่น ให้แก้บรรทัด `3` เช่น `3: [BOSS_CROSSFIRE, RAPID_FIRE],` สกิลหลายอันใส่พร้อมกันได้ `[]` หมายถึงบอสไม่มีสกิล หากสร้างไฟล์สกิลใหม่ ให้เพิ่ม `const MY_BOSS_SKILL = preload("res://skills/my_boss_skill.tres")` ที่ต้นสคริปต์ แล้วใส่ `MY_BOSS_SKILL` ในด่านที่ต้องการ

## สกิลที่มีให้ใช้

| ชื่อที่ใช้ใน Script | ไฟล์สกิล | ผล |
| --- | --- | --- |
| `RAPID_FIRE` | [`rapid_fire.tres`](rapid_fire.tres) | ลดเวลาระหว่างยิงเหลือ 65% |
| `SPREAD_SHOT` | [`spread_shot.tres`](spread_shot.tres) | เพิ่มกระสุนเฉียงซ้ายและขวา 2 นัด |
| `FORTIFY` | [`fortify.tres`](fortify.tres) | เพิ่ม HP สูงสุด 50% |

บอสทั้ง 5 ด่านมีไฟล์เฉพาะ จึงแก้ค่าแต่ละตัวได้อิสระ:

| ด่าน | ไฟล์สกิล | ผล |
| --- | --- | --- |
| 1 | [`boss_bulwark.tres`](boss_bulwark.tres) | เพิ่ม HP 50% |
| 2 | [`boss_crossfire.tres`](boss_crossfire.tres) | เพิ่ม HP 50% และกระสุนเสริม 2 นัด |
| 3 | [`boss_pursuit.tres`](boss_pursuit.tres) | เหมือนด่าน 2 แต่ยิงถี่ขึ้น |
| 4 | [`boss_barrage.tres`](boss_barrage.tres) | เพิ่มกระสุนเสริมเป็น 3 นัด และยิงถี่ขึ้นอีก |
| 5 | [`boss_overdrive.tres`](boss_overdrive.tres) | เพิ่ม HP 70% กระสุนเสริม 4 นัด และยิงถี่ที่สุด |

## สร้างสกิลใหม่

1. คัดลอกไฟล์ `.tres` ในโฟลเดอร์นี้ ตั้งชื่อใหม่ เช่น `my_skill.tres` แล้วแก้ `display_name`, `description` และค่าต่าง ๆ ในไฟล์ได้โดยตรง หรือเปิดไฟล์สกิลใน Godot เพื่อแก้ค่า
2. เพิ่มบรรทัด `const MY_SKILL = preload("res://skills/my_skill.tres")` ใกล้กับ `RAPID_FIRE` ที่ต้น [`combatant_visual.gd`](../scripts/combatant_visual.gd)
3. ใส่ `MY_SKILL` ใน `SKILL_LOADOUTS` สำหรับยาน/ศัตรูทั่วไป หรือใน `BOSS_SKILLS_BY_LEVEL` สำหรับบอสด่านที่ต้องการ แล้วบันทึก

ค่า `fire_interval_multiplier` ต่ำกว่า `1.0` ทำให้ยิงถี่ขึ้น (เช่น `0.5` คือเร็วขึ้นสองเท่า); `max_health_multiplier` เช่น `1.5` เพิ่ม HP 50%; `extra_projectiles` คือจำนวนกระสุนเสริมต่อการยิงหนึ่งครั้ง สกิลหลายอันคูณผลด้านความเร็วยิง/HP และบวกจำนวนกระสุนเสริมเข้าด้วยกัน

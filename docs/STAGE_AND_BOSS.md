# ระบบ Stage และ Boss Fight

ค่าด่านเริ่มต้นอยู่ใน `stages/stage_01.tres`, `stage_02.tres` และ `stage_03.tres` เปิดไฟล์เหล่านี้ใน Godot Inspector แล้วปรับค่าได้โดยไม่ต้องแก้ระบบต่อสู้

## ค่าที่ปรับได้

- `Stage Id`, `Display Name`, `Difficulty Label`: ข้อมูลที่ใช้แสดงบนเมนูและ HUD
- `Enemy Health Multiplier`: ตัวคูณพลังชีวิตศัตรูทั่วไป
- `Enemy Speed Multiplier`: ตัวคูณความเร็วศัตรูทั่วไป
- `Spawn Interval Multiplier`: ช่วงห่างการเกิดศัตรู ค่าน้อยทำให้เกิดถี่ขึ้น
- `Boss Score Requirement`: คะแนนที่ต้องเก็บเพื่อเรียกบอส
- `Boss Max Health`, `Boss Move Speed`, `Boss Fire Interval`: ความยากของบอส
- `Boss Score Reward`: คะแนนที่ได้เมื่อกำจัดบอส
- `Clear Token Reward`: พยูนTOKEN พื้นฐานเมื่อผ่านด่าน
- `Score Per Bonus Token`: ทุกกี่คะแนนจะได้รับโบนัส 1 TOKEN

สูตรรางวัลคือ `Clear Token Reward + floor(Final Score / Score Per Bonus Token)` และมอบเพียงครั้งเดียวเมื่อบอสถูกกำจัด

## เพิ่ม Stage สำหรับ Milestone 2

1. คลิกขวา `stages/stage_01.tres` ใน FileSystem ของ Godot แล้วเลือก **Duplicate**
2. ตั้งชื่อ เช่น `stage_02.tres`
3. เปิดไฟล์ใหม่และแก้ `Stage Id` ไม่ให้ซ้ำ รวมถึงความยาก เงื่อนไขบอส และรางวัล
4. เพิ่ม Resource ใหม่เข้า `STAGE_CONFIGS` ที่ส่วนบนของ `scripts/space_shooter.gd` เพื่อให้ปรากฏในหน้า Stage Select

หน้า Stage Select จะส่ง Resource ที่ผู้เล่นเลือกให้ฉาก Battle โดยตรง ด่าน 1–3 ใช้พื้นหลัง Parallax ชุดเดียวกันในตอนนี้

## เปลี่ยนภาพบอส

เปิด `characters/bosses/dreadnought.tscn` เลือกโหนด `Dreadnought` แล้วลาก PNG, WebP หรือ SVG ใหม่ใส่ช่อง `Texture` ภาพ Placeholder ปัจจุบันอยู่ที่ `assets/sprites/boss_dreadnought.svg`

พยูนTOKEN ถูกเก็บใน `user://save_game.cfg` ซึ่งเป็นโฟลเดอร์ข้อมูลของเกมในแต่ละเครื่อง ไม่ควรเพิ่มไฟล์เซฟนี้เข้า Git

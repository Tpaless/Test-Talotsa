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

บอสทั้งเจ็ดแยก Scene อยู่ใน `characters/bosses/` ได้แก่ `thomas.tscn`, `khram.tscn`, `kung.tscn`, `se_na.tscn`, `lens.tscn`, `plastic_man.tscn` และ `red_guy.tscn` แต่ละ Scene ใช้ PNG ใน `assets/sprites/` จึงเปลี่ยนภาพแยกตัวได้โดยไม่กระทบบอสอื่น

## Mechanics บอสปัจจุบัน

- **โทมัส:** HP 50% ยิงรัวและเร็ว; HP 10% กลับกลางสนาม หมุนครบหนึ่งรอบใน 10 วินาที และปล่อยกระสุนรูปบวกทุก 2 วินาที
- **คราม:** พุ่งชนทุกช่วง HP 20% และหลัง Dash พลาดจะเคลื่อนกลับอย่างต่อเนื่องโดยไม่กระโดดตำแหน่ง
- **กุ้ง:** Phase 1–2 ปล่อย Wave กระสุนสลับฟันปลาจากบนลงล่างต่อเนื่อง 5 วินาที; Phase 3 ลาดตระเวนด้านบน พุ่งไปยังตำแหน่งล่าสุดของ Player ผลัก Player ตามทิศพุ่ง กลับจุดเริ่มสกิล และพัก 2 วินาที
- **เสนาหอย:** Phase 1 ปล่อยเลเซอร์ X ทุก HP 10%; Phase 2 เพิ่มม่านแสงสีรุ้งแนวตั้งเต็มสนามที่สลับคอลัมน์และเว้นช่องหลบ; Phase 3 เมื่อ HP เหลือ 50% จะยิง SENAHOY_Bullet.png ช้า 4 ลูกจากซ้ายและขวาทุก 1.8 วินาที
- **หมึกเลนส์:** Phase 3 สร้างกำแพง HP 60% ของบอส โดยใช้ boss_lens_tentacle สองฝั่งวางจากซ้ายไปขวาและขวาไปซ้าย
- **Plastic Man:** HP ลดลง 20% และมี 5 ช่วง HP ภายในไฟต์ โดยสุ่มลำดับสกิลของบอสห้าตัวก่อนหน้าแบบไม่ซ้ำ พร้อมสุ่มช่วงเวลาใช้แต่ละสกิล
- **Red Guy:** ยิง Beyblade 3 อันแทนกระสุนปกติทุก 8 วินาที

Pause Overlay มี **Resume**, **Restart**, **Menu** การออกหรือ Restart Story ก่อนผ่านด่านจะคืน Coin ที่ได้ในรอบนั้นทั้งหมด ส่วน Endless จะเก็บ Coin และบันทึกคะแนนก่อนออก/เริ่มใหม่

เมื่อเก็บงานวิจัยครบทั้ง 6 Stage จะปลดล็อก **Nightmare X2/X3** ซึ่งเพิ่ม HP, ดาเมจ, ความเร็วกระสุน และความถี่โจมตีของบอส Story Nightmare ต้องเล่น Stage 1–6 ต่อเนื่องและจะเริ่ม Stage 1 ใหม่เมื่อตาย ส่วน Endless Nightmare ใช้ตารางคะแนนแยกจาก Endless ปกติ

พยูนTOKEN ถูกเก็บใน `user://save_game.cfg` ซึ่งเป็นโฟลเดอร์ข้อมูลของเกมในแต่ละเครื่อง ไม่ควรเพิ่มไฟล์เซฟนี้เข้า Git

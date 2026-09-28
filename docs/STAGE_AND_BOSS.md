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
- **คราม:** พุ่งชนหนึ่งครั้งทุก HP 10% ที่เสียไป ทำดาเมจ 30% ของ HP สูงสุดผู้เล่น; ต่ำกว่า 10% พุ่งต่อเนื่อง 5 วินาที
- **กุ้ง:** Phase 1–2 ปล่อย Wave กระสุนสลับฟันปลาจากบนลงล่างต่อเนื่อง 5 วินาที; Phase 3 ใช้ภาพ Attack หมุน 180 องศา พุ่งจากมุมบนไปยังตำแหน่งล่าสุดของ Player กลับจุดเดิม พัก 5 วินาที แล้ววนซ้ำ
- **เสนาหอย:** เสและนาเคลื่อนที่แยกกันและใช้ PNG คนละชุด Idle/Attack รวม 4 ภาพ Phase 1–2 ปล่อยเลเซอร์ X จากมุมซ้าย–ขวาโดยจุดตัดอยู่กลาง Map เท่านั้นทุก HP 10%; Phase 3 เปลี่ยนเป็นยิง `SENAHOY_Bullet.png` จากทั้งสองตัวเล็งใส่ Player ทุก 1.35 วินาที ลูกละ 20% HP
- **หมึกเลนส์:** หนวดมี Sprite แยกและพุ่งจากด้านข้างหลังเงาเตือน 1.3 วินาที Phase 1–2 ใช้ 2 เส้น และ Phase 3 ใช้ 3 เส้น; ที่ HP 50% ของ Phase 3 จะสร้างกำแพงหนวดจากขอบซ้าย–ขวาและต้องทำลายเกราะก่อนโจมตีตัวบอส
- **Plastic Man:** ทุก Phase เรียกลูกสมุน 20 ตัวที่ HP 100% และอีก 20 ตัวที่ HP 50% รวม 2 Wave ต่อ Phase ตัวบอสไม่รับดาเมจระหว่างที่ลูกสมุนยังอยู่ และลูกสมุนจะประจำสนาม ยิงตอบโต้ และไม่ออกจาก Map จนกว่าจะถูกกำจัด
- **Red Guy:** ยิง Beyblade 3 อันแทนกระสุนปกติทุก 8 วินาที

Pause Overlay มี **Resume**, **Restart**, **Menu** การออกหรือ Restart Story ก่อนผ่านด่านจะคืน Coin ที่ได้ในรอบนั้นทั้งหมด ส่วน Endless จะเก็บ Coin และบันทึกคะแนนก่อนออก/เริ่มใหม่

เมื่อเก็บงานวิจัยครบทั้ง 6 Stage จะปลดล็อก **Nightmare X2/X3** ซึ่งเพิ่ม HP, ดาเมจ, ความเร็วกระสุน และความถี่โจมตีของบอส Story Nightmare ต้องเล่น Stage 1–6 ต่อเนื่องและจะเริ่ม Stage 1 ใหม่เมื่อตาย ส่วน Endless Nightmare ใช้ตารางคะแนนแยกจาก Endless ปกติ

พยูนTOKEN ถูกเก็บใน `user://save_game.cfg` ซึ่งเป็นโฟลเดอร์ข้อมูลของเกมในแต่ละเครื่อง ไม่ควรเพิ่มไฟล์เซฟนี้เข้า Git

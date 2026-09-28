# ตั้งค่าเนื้อเรื่องและบทสนทนา

เนื้อเรื่องอ้างอิง [`PROJECT _ DESIGN/STORY/Game Design.md`](../PROJECT%20_%20DESIGN/STORY/Game%20Design.md) เกมจะแสดงบทเปิดหลังเข้า Stage และแสดงบทสนทนาหลังชนะ Phase 1–3 ระหว่างนั้นศัตรู กระสุน การเคลื่อนที่ และการยิงจะหยุด ผู้เล่นแตะหน้าจอ คลิกเมาส์ หรือกด `Enter`/`Space` หนึ่งครั้งเพื่อไปหนึ่งข้อความ

หลัง Phase 1 และ 2 บรรทัดสุดท้ายจะคงคำใบ้จุดอ่อนของ Phase ถัดไปไว้บนจอ หลัง Phase 3 บอสจะเป็นอิสระและมอบบันทึกแห่งพลังเข้า Item Collection ในหน้า Home ส่วน Stage 5 มีฉากรวมกุญแจแห่งพลังและบทจบ

## แก้ข้อความ เพิ่ม หรือ ลบ

เปิด [`scripts/dialogue_config.gd`](../scripts/dialogue_config.gd) แล้วแก้ส่วนเหล่านี้:

- `CHARACTERS` กำหนดชื่อ ชนิดสัตว์ บทบาท ภาพ และสีของ Johny/บอส
- `STAGES` กำหนดชื่อเรื่อง พื้นที่ บอส บันทึก และแนวโจมตีของ Story Stage 1–5 รวมถึงด่านพิเศษ Razor ลำดับที่ 6
- `INTRO_BY_STAGE` คือบทเปิดและบทก่อน Phase 1
- `AFTER_PHASE_BY_STAGE` คือบทหลัง Phase 1–3 โดยบทหลัง Phase 1/2 รวมคำเกริ่น Phase ถัดไป

```gdscript
["johny", "ข้อความที่ Johny พูด"],
["thomas", "ข้อความของโทมัส", "คำใบ้ Phase ถัดไป"],
```

รหัสตัวละครที่มีคือ `johny`, `thomas`, `khram`, `se`, `na`, `lens`, `tu`, `author`, `guardian` สมาชิกตัวที่สามเป็นคำใบ้แบบเลือกใส่ได้ คัดลอกรายการ `[ ... ]` เพื่อเพิ่มบทและตรวจจุลภาคระหว่างรายการเสมอ ถ้าจะเพิ่ม Stage ให้เพิ่มข้อมูลใน `STAGES`, `INTRO_BY_STAGE`, `AFTER_PHASE_BY_STAGE` และปรับ `FINAL_LEVEL` ใน [`scripts/space_shooter.gd`](../scripts/space_shooter.gd)

## Quest Archive และแหล่งงานวิจัย

หน้า Quest แสดงบันทึกที่เก็บได้เป็นแฟ้ม กดแฟ้มที่ปลดล็อกแล้วเพื่ออ่านคำอธิบายย่อ และกด **READ SOURCE** เพื่อเปิด DOI หรือหน้าค้นหาของคลังสถาบันต้นทาง รายการชื่อเรื่อง บรรณานุกรม คำอธิบาย และ URL อยู่ใน [`scripts/research_config.gd`](../scripts/research_config.gd)

## ปรับหน้าตาใน Godot Editor

เปิด [`dialogue_overlay.tscn`](dialogue_overlay.tscn) เพื่อดูและแก้ตำแหน่ง ขนาด สี ฟอนต์ และรูปแบบใน Inspector ฉากนี้ถูกวางไว้ใน `main.tscn` ใต้ `DialogueLayer` ซึ่งอยู่เหนือ HUD

| โหนด | สิ่งที่ปรับได้ |
| --- | --- |
| `Dim` | สีและความทึบของพื้นหลังที่มืดลง |
| `Panel` | ตำแหน่ง/ขนาดกล่อง และสี ขอบ มุมโค้งใน `StyleBoxFlat` |
| `AccentBar` | ตำแหน่ง/ขนาดแถบสี; สีจริงมาจาก `accent` ของข้อความ |
| `Portrait` | ตำแหน่ง/ขนาดภาพ; ภาพจริงมาจาก `portrait` ของข้อความ |
| `Speaker` | ตำแหน่ง ขนาดตัวอักษร และฟอนต์ชื่อผู้พูด; สีจริงมาจาก `accent` |
| `Body` | ตำแหน่ง ขนาดตัวอักษร ฟอนต์ สี และพื้นที่ตัดบรรทัดของเนื้อหา |
| `Counter` | รูปแบบตัวนับข้อความ เช่น `1 / 2` |
| `NextHint` | ตำแหน่ง สี และฟอนต์ข้อความใบ้ด้านล่าง |

ข้อความไทยในฉากใช้ฟอนต์ `assets/fonts/NotoSansThai.ttf` ที่เพิ่มไว้ใน `Theme Overrides > Fonts` ของ Label แต่ละตัว หากเปลี่ยนฟอนต์ ให้เลือกไฟล์ที่รองรับอักษรไทยเพื่อไม่ให้ข้อความกลายเป็นช่องว่าง ใบอนุญาตของฟอนต์อยู่ที่ `assets/fonts/OFL.txt`

เลือกโหนด `DialogueOverlay` เพื่อแก้ข้อความใบ้เริ่มต้น `Next Line Hint`, `Next Stage Hint`, และ `Finish Game Hint` ใน Inspector ได้ หากต้องการแก้เฉพาะหนึ่งข้อความ ให้ใส่คีย์ `hint` ใน `dialogue_config.gd`

อย่าเปลี่ยนชื่อโหนด `Panel`, `AccentBar`, `Portrait`, `Speaker`, `Body`, `Counter`, `NextHint` โดยไม่แก้พาธใน [`scripts/dialogue_overlay.gd`](../scripts/dialogue_overlay.gd) ให้ตรงกัน

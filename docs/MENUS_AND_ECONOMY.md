# Menu, Upgrade และ Summon

Flow ปัจจุบัน:

```text
Main Menu
├─ Play → Stage Select → Character Select → Battle → Result
├─ Upgrade Shop
└─ Summon Character
```

## พยูนTOKEN

- ได้รับจากการชนะ Boss Fight
- ใช้ซื้อ Weapon Upgrade หรือสุ่มตัวละคร
- ยอด TOKEN, ตัวละครที่ปลดล็อก และระดับอาวุธบันทึกที่ `user://save_game.cfg`

## Upgrade Shop

- อัปเกรดได้เฉพาะตัวละครที่ปลดล็อกแล้ว
- อาวุธเริ่ม Level 1 และสูงสุด Level 5
- ราคาอัปเกรดคือ `75 × Level ปัจจุบัน`
- Damage ของกระสุนเท่ากับ Weapon Level

## Summon Character

- ใช้ 100 พยูนTOKEN ต่อครั้ง
- Falcon เป็นตัวเริ่มต้น
- ระบบการันตีตัวละครใหม่จนกว่าจะปลดล็อก Swift และ Titan ครบ
- เมื่อมีครบแล้ว การสุ่มได้ตัวซ้ำจะคืน 35 TOKEN

ปุ่มทุกหน้ารองรับเมาส์และการแตะหน้าจอ ส่วน `Escape` ใช้ย้อนกลับบนคอมพิวเตอร์

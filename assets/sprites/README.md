# เปลี่ยนภาพทั้งหมด

แก้ path ของยาน ศัตรู กระสุน และไอเทมใน [`scripts/visual_config.gd`](../../scripts/visual_config.gd) ได้เลย รองรับ PNG, WebP และ SVG ส่วนท่าพิเศษตั้งภาพของตัวเองด้วย `special_texture` และ `special_texture_size` ใน [`scripts/player_config.gd`](../../scripts/player_config.gd) เช่น Beyblade ใช้ `"special_texture": "res://assets/sprites/beyblade.png"` จากนั้นเปิดเกมใหม่ ภาพพื้นหลังตั้งใน `scripts/parallax_background.gd` และภาพผู้พูดใน `scripts/dialogue_config.gd`

ยานและศัตรูตั้ง path ว่างไว้เป็นค่าเริ่มต้น หมายถึงใช้ Texture ที่อยู่ใน Scene หากใส่ path ใหม่ใน `visual_config.gd` ภาพนั้นจะใช้แทนในเกมและการ์ดเลือกยาน ถ้าอยากแก้ด้วย Inspector ให้เปิด Scene, เลือกโหนด Sprite2D แล้วเปลี่ยนช่อง Texture

| key ใน visual_config.gd | Scene / ภาพเดิม |
| --- | --- |
| `falcon` | `characters/player/player.tscn` / `player_ship.png` |
| `swift` | `characters/player/swift.tscn` / `player_swift.png` |
| `titan` | `characters/player/titan.tscn` / `player_titan.png` |
| `razor` | `characters/player/razor.tscn` / `player_razor.png` |
| `viper` | `characters/player/viper.tscn` / `player_viper.png` |
| `scout` | `characters/enemies/scout.tscn` / `enemy_scout.svg` |
| `striker` | `characters/enemies/striker.tscn` / `enemy_striker.svg` |
| `tank` | `characters/enemies/tank.tscn` / `enemy_tank.svg` |
| `boss` | `characters/enemies/boss.tscn` / ภาพบอสใน Scene |

ภาพที่เกมใช้อยู่ใน `visual_config.gd` มี `player_normal`, `player_homing`, `player_wide`, `player_heavy`, `player_giant`, `enemy_normal`, `enemy_special` และ `health_pickup` โดยค่าเริ่มต้นชี้ไปยังไฟล์ชื่อเดียวกันในโฟลเดอร์นี้ หากตั้ง path ว่าง เกมจะวาดรูปพื้นฐานแทน ส่วน Beyblade อ่าน `special_texture` จากข้อมูลของ Santa Johny ใน `player_config.gd` โดยตรง เลเซอร์ของ Pichu Johny และลำแสงของ Straw Hat Johny วาดด้วยโค้ด

แนะนำภาพโปร่งใส ยานควรหันหัวขึ้นและศัตรูควรหันหัวลง ขนาดต้นฉบับประมาณ 64–96 px สำหรับยาน, 52–76 px สำหรับศัตรู; เกมจะปรับขนาดกระสุนและเอฟเฟกต์ตอนวาดอัตโนมัติ

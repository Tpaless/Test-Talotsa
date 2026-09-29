# ส่งเกมขึ้น itch.io สำหรับ Web Browser

โปรเจกต์มี preset `Web (itch.io)` ใน `export_presets.cfg` แล้ว โดยใช้ Compatibility renderer, Canvas แบบปรับตามพื้นที่ Browser และปิด Thread เพื่อให้เล่นได้บนมือถือและ PC โดยไม่ต้องตั้งค่า Cross-Origin Isolation

## เตรียม Godot

1. ใช้ Godot **4.7.2 Stable** ให้ตรงกับเวอร์ชันโปรเจกต์
2. เปิด `Editor > Manage Export Templates`
3. ดาวน์โหลดและติดตั้ง Export Template ของ Godot 4.7.2
4. เปิด `Project > Export` แล้วเลือก `Web (itch.io)`

หากไม่มี Template จะพบข้อความ `web_nothreads_release.zip` not found และยัง Export ไม่ได้

## สร้างไฟล์ Web

กด **Export Project** และเลือก `Compress File/index.html` หรือรัน:

```powershell
godot --headless --path . --export-release "Web (itch.io)" "Compress File/index.html"
```

จากนั้น ZIP ไฟล์ index.* ทั้งหมดภายใน Compress File เป็น Test-Talotsa-v0.8.0-beta.1-Web.zip โดยให้ index.html อยู่ที่ระดับบนสุดของ ZIP

## ตั้งค่า itch.io

1. สร้าง Project ใหม่และเลือก Kind of project เป็น **HTML**
2. อัปโหลด ZIP ที่สร้างไว้
3. เปิดตัวเลือก **This file will be played in the browser**
4. เลือก Embed in page และตั้งขนาดเริ่มต้นใกล้เคียง `540 × 960`
5. เปิด Mobile Friendly และ Fullscreen button

เกมรักษาสัดส่วนแนวตั้งอัตโนมัติ อินพุตรองรับ Mouse, Keyboard และ Touch ส่วนเสียงใน Browser จะเริ่มหลังผู้เล่นแตะหรือคลิกครั้งแรกตามข้อจำกัด autoplay ของ Browser

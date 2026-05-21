<!-- Payroll Anomaly Detector — ตรวจจับความผิดปกติ/โกงเงินเดือน

โจทย์: แสดง Architecture Diagram และอธิบายว่าจะจัดการเรื่อง Data Privacy ของข้อมูลพนักงานอย่างไรเมื่อต้องส่งข้อมูลให้ AI Model -->

# ข้อ 7: AI Feature Design
**หัวข้อที่เลือก:** Payroll Anomaly Detector (ระบบ AI ตรวจจับความผิดปกติของเงินเดือน)

## 1. Architecture Diagram (สถาปัตยกรรมระบบ)
การทำงานจะคั่นกลางด้วย "Data Sanitizer Service" เพื่อปกป้องข้อมูลพนักงานก่อนส่งออกไปยัง AI Model

```text
[1. HR/Payroll System]
        | (ดึงข้อมูลเงินเดือนดิบ: ชื่อ, เลขบัญชี, เงินเดือน, OT)
        v
[2. Data Sanitizer / Anonymization Service] 🔒 (จุดป้องกัน Data Privacy)
        | (ถอด PII ออก: แปลงชื่อเป็น UUID, ลบเลขบัญชี, ลบข้อมูลส่วนตัว)
        v
[3. Anonymized Payload] 
        | (ข้อมูลที่ส่ง: { "emp_hash": "A1B2", "base": 30000, "ot_hours": 85, "shift_count": 20 })
        v
[4. AI Model (Anomaly Detector)] 🧠
        | (วิเคราะห์หาความผิดปกติ เช่น OT สูงเกินจริงเมื่อเทียบกับกะทำงาน)
        v
[5. AI Response (Flagged Anomalies)]
        | (ส่งกลับ: { "emp_hash": "A1B2", "risk": "High", "reason": "OT exceed normal limits" })
        v
[6. Re-identification Service] 🔑
        | (นำ UUID กลับมาจับคู่กับชื่อพนักงานจริงใน Database)
        v
[7. HR Admin Dashboard]
        (แสดงผลแจ้งเตือน HR: "พบความผิดปกติของ OT นายสมชาย")
```

## 2. การจัดการ Data Privacy (Data Protection Strategy)
ในการส่งข้อมูลเงินเดือนไปให้ AI ประมวลผล เรามีมาตรการจัดการด้าน Privacy ดังนี้:
```text
1. Data Anonymization & Pseudonymization (การทำข้อมูลนิรนาม): ก่อนที่ข้อมูลจะถูกส่งออกจากเซิร์ฟเวอร์ของบริษัท ระบบจะทำการลบ PII (Personally Identifiable Information) ทั้งหมด เช่น ชื่อ-นามสกุล, เลขบัตรประชาชน, และเลขบัญชีธนาคาร โดยจะแปลงรหัสพนักงานเป็น Hash (เช่น UUID) เพื่อไม่ให้ AI หรือบุคคลภายนอกรู้ได้ว่าข้อมูลนี้เป็นของใคร

2. Data Minimization (หลักการจำกัดข้อมูล): ส่งเฉพาะชุดข้อมูล (Features) ที่จำเป็นต่อการตรวจจับความผิดปกติเท่านั้น เช่น ตัวเลขฐานเงินเดือน, จำนวนชั่วโมง OT, และประเภทกะ โดยไม่ส่งข้อมูลที่ไม่จำเป็น เช่น ศาสนา ที่อยู่ หรือเบอร์โทรศัพท์

3. Re-identification at Client-side (การระบุตัวตนกลับที่ปลายทาง): เมื่อ AI ส่งผลการวิเคราะห์กลับมา ระบบ Backend ภายในของเราจะเป็นผู้จับคู่ Hash คืนค่าเป็นชื่อพนักงานจริง เพื่อแสดงผลบนหน้าจอ HR เท่านั้น ทำให้มั่นใจได้ว่าข้อมูลส่วนบุคคลจะไม่รั่วไหลออกไปสู่ External AI Provider โดยเด็ดขาด
```
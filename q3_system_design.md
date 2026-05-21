<!-- จงออกแบบ REST API และ Database Schema สำหรับระบบ "แก้ไขเงินเดือนย้อนหลัง" โดย:

แสดง Table Schema ที่รองรับ Audit Trail (เก็บค่าเก่า, ค่าใหม่, ใครแก้, เมื่อไหร่)
อธิบายกลไกป้องกันไม่ให้พนักงาน IT แอบแก้เงินเดือนตัวเองใน Database โดยไม่ผ่านระบบ -->

# ข้อ 3: System Design & Audit Trail (ระบบแก้ไขเงินเดือนย้อนหลัง)

## 1. Database Schema (รองรับ Audit Trail)
ออกแบบตาราง 2 ส่วน คือตารางเก็บเงินเดือนหลัก และตารางเก็บประวัติการแก้ไข (Audit Log)

```sql
-- ตารางเก็บข้อมูลเงินเดือนพนักงาน
CREATE TABLE employee_salaries (
    emp_id VARCHAR(50) PRIMARY KEY,
    base_salary DECIMAL(10, 2) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ตารางเก็บประวัติการแก้ไข (Audit Trail)
CREATE TABLE salary_audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id VARCHAR(50) NOT NULL,
    old_salary DECIMAL(10, 2) NOT NULL,
    new_salary DECIMAL(10, 2) NOT NULL,
    modified_by VARCHAR(50) NOT NULL,
    modified_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL
);
```

## 2. REST API Design

```
Endpoint: PUT /api/v1/salaries/retroactive-adjust
Method: PUT
Headers: Authorization: Bearer <JWT_TOKEN>
Request Body (JSON): {
  "emp_id": "EMP1029",
  "new_salary": 45000.00,
  "reason": "ปรับขึ้นเงินเดือนย้อนหลังตามผลประเมิน Q1"
}
```

## 3. Security Mechanism

```
1.Principle of Least Privilege (จำกัดสิทธิ์ระดับ Database): พนักงาน IT หรือ DBA จะได้รับแค่สิทธิ์ READ-ONLY สำหรับตรวจสอบข้อมูลเท่านั้น ระบบจะไม่อนุญาตให้ User ของพนักงาน IT มีคำสั่ง UPDATE บนตาราง employee_salaries โดยเด็ดขาด สิทธิ์ในการ UPDATE จะถูกผูกไว้กับ "Database User ของ Application (API)" เท่านั้น

2.Database Trigger (บังคับบันทึก Log เสมอ): สร้าง SQL Trigger ฝังไว้ใน Database โดยตรง เพื่อกำหนดว่า "ทุกครั้งที่มีการ UPDATE ตารางเงินเดือน ระบบจะต้อง INSERT ข้อมูลลงตาราง Audit Log อัตโนมัติ" ดังนั้นต่อให้ IT พยายามแอบเจาะเข้า Database เพื่อแก้เงินเดือนตัวเอง ระบบก็จะบันทึกหลักฐาน (Log) ทิ้งไว้โดยที่ IT ไม่สามารถลบหรือหลีกเลี่ยงได้
```
<!-- ออกแบบ Database Schema ที่รองรับการ Shift Swapping (สลับกะ) โดยต้องเก็บสถานะการ Approve จากหัวหน้า และสามารถคำนวณเบี้ยเลี้ยงกะดึกได้ถูกต้องแม้จะมีการแลกงานกัน -->

# ข้อ 5: Database Modeling for Shifts (ระบบสลับกะและการคำนวณเบี้ยเลี้ยง)

เพื่อให้ระบบสามารถรองรับการสลับกะ (Shift Swapping) โดยยังคงรักษาประวัติการทำงาน (Data Traceability) ไว้อย่างสมบูรณ์ เราจะออกแบบ Database Schema และ Logic ดังนี้:

## 1. Table: `employee_shifts` (ตารางตารางงานหลัก)
ตารางนี้จะทำหน้าที่เป็น Ledger เพื่อบันทึกประวัติทั้งหมดโดยไม่มีการลบข้อมูล
* `shift_id` (PK)
* `emp_id` (FK) -> รหัสพนักงาน
* `shift_date` (DATE) -> วันที่เข้ากะ
* `shift_type` (ENUM: 'Morning', 'Evening', 'Night') 
* `allowance_amount` (DECIMAL) -> เบี้ยเลี้ยง
* `status` (ENUM: 'Scheduled', 'Swapped_Out', 'Covering')
* `parent_shift_id` (FK, Nullable) -> อ้างอิงไปยังกะเดิม กรณีที่เป็นการมารับกะแทน

## 2. Table: `shift_swap_requests` (ตารางคำขอสลับกะ)
ตารางนี้ใช้เก็บประวัติการขอสลับกะ และสถานะการอนุมัติจากหัวหน้า
* `swap_id` (PK)
* `requester_emp_id` (FK) -> ผู้ขอ
* `target_emp_id` (FK) -> ผู้รับ
* `original_shift_id` (FK) -> กะที่ต้องการสลับ
* `manager_status` (ENUM: 'Pending', 'Approved', 'Rejected')
* `approved_by` (FK) -> หัวหน้าผู้อนุมัติ

## 3. Business Logic (การรักษา Audit Trail)
แทนที่จะอัปเดตทับข้อมูลเดิม เราจะใช้หลักการ Insert แทนเพื่อรักษาประวัติ:
1. **เมื่อหัวหน้า Approve:** * ระบบจะ **UPDATE** กะเดิมใน `employee_shifts` ให้ `status = 'Swapped_Out'` (พนักงานเดิมไม่ได้เงิน)
   * จากนั้นระบบจะ **INSERT** กะใหม่ลงใน `employee_shifts` สำหรับผู้ที่มารับแทน โดยตั้ง `status = 'Covering'` และเชื่อม `parent_shift_id` ไปหา ID ของกะเดิม
2. **การคำนวณเบี้ยเลี้ยง (Payroll):**
   * ตอนสิ้นเดือน ระบบ Payroll เพียงแค่ดึงข้อมูลจาก `employee_shifts` ที่มีสถานะเป็น `'Scheduled'` และ `'Covering'` มาคำนวณ ทำให้การจ่ายเบี้ยเลี้ยงกะดึกถูกต้องแม่นยำ และยังสามารถตรวจสอบย้อนหลังประวัติการสลับกะบนตารางหลักได้ทันที
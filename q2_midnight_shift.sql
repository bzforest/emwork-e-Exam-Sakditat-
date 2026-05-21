-- โรงงานมีพนักงาน 3 กะ:

-- Morning   08:00–16:00
-- Evening   16:00–00:00
-- Night     00:00–08:00 ของวันถัดไป

-- จงเขียน SQL เพื่อหาพนักงานกะ Night Shift ของวันที่ 19 มีนาคม 2026 ที่มาสาย (Clock-in หลัง 00:05 น.) โดยต้องรองรับกรณีที่พนักงานสแกนนิ้วก่อนเที่ยงคืน (เช่น 23:55 น. ของวันที่ 18 มีนาคม) เพื่อเข้ากะวันที่ 19

-- ----------------------------------------------------------------

สมมติฐานโครงสร้างตาราง (Table Assumption): 'attendance_logs'
emp_id (รหัสพนักงาน)
shift_date (วันที่ของกะงาน เช่น '2026-03-19')
hift_type (ประเภทกะ เช่น 'Night')
clock_in_time (เวลาที่สแกนนิ้วจริง ชนิด DATETIME)

สมมติว่าเรากำลังรันสคริปต์นี้ใน "วันปัจจุบัน" (เช่น วันนี้คือวันที่ 19 มีนาคม 2026)

SELECT 
    emp_id, 
    clock_in_time
FROM 
    attendance_logs
WHERE 
    shift_date = CURDATE()  
    AND shift_type = 'Night'
    AND clock_in_time > CONCAT(CURDATE(), ' 00:05:00')
    AND clock_in_time <= CONCAT(CURDATE(), ' 08:00:00');


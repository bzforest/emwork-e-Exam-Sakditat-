// async function processPayroll(empId, baseSalary, otHours) {

//     const sso = baseSalary * 0.05;

//     const otRate = (baseSalary / 30 / 8) * 1.5;

//     const gross = baseSalary + (otHours * otRate);

//     const net = gross - sso;

//     await db.query(`UPDATE salaries SET balance = balance + ${net}

//                     WHERE emp_id = ${empId}`);

//     return net;

// }

// -----------------------------------------------------------------------------------------

async function processPayroll(empId, baseSalary, otHours) {
    
    try {
        
        await db.query('BEGIN');
        
        const sso = Math.round((baseSalary * 0.05) * 100) / 100;

        const otRate = Math.round((baseSalary / 30 / 8) * 1.5 * 100) / 100;
        
        const gross = baseSalary + (otHours * otRate);

        const net = Math.round((gross - sso) * 100) / 100;

        const updateQuery = `UPDATE salaries SET balance = balance + ? WHERE emp_id = ?`;

        await db.query(updateQuery, [net, empId]);

        await db.query('COMMIT');
        
        return net;

    } catch (error) {
        await db.query('ROLLBACK');
        console.error("Payroll processing failed:", error);
        throw error;
    }
}

// 
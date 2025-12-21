# Business Analytics Queries

This document explains how analytics enhance decision-making in the QR Smart Building system.

1. Daily Access Trend Analysis
Analyzes number of access attempts per day.

```sql
SELECT TRUNC(attempt_time) AS access_date,
       COUNT(*) AS total_attempts
FROM access_attempts
GROUP BY TRUNC(attempt_time)
ORDER BY access_date;

## 2.Unauthorized Access Analysis

SELECT COUNT(*) AS unauthorized_attempts
FROM access_attempts
WHERE result = 'UNAUTHORIZED';
Insight: Measures security risk level.
3. Most Active Users
SELECT u.full_name, COUNT(e.log_id) AS total_entries
FROM users u
JOIN entry_logs e ON u.user_id = e.user_id
GROUP BY u.full_name
ORDER BY total_entries DESC;


Insight: Identifies frequent building users.

4. Role-Based Access Analysis
SELECT role, COUNT(*) AS total_users
FROM users
GROUP BY role;


Insight: Shows distribution of employees, visitors, and security staff.

5. Trigger Enforcement Analysis
SELECT operation, COUNT(*) AS blocked_operations
FROM audit_log
WHERE details LIKE '%Blocked%'
GROUP BY operation;


Insight: Confirms policy enforcement effectiveness.

Conclusion

These analytics support:

Security monitoring

Operational planning

Compliance auditing

Data-driven decision making

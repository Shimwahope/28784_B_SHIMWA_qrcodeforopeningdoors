

Retrieve all users
SELECT * FROM users;

Retrieve all entry logs
SELECT * FROM entry_logs;

Retrieve all access attempts
SELECT * FROM access_attempts;

Users with their entry and exit times
SELECT u.user_id,
       u.full_name,
       u.role,
       e.entry_time,
       e.exit_time
FROM users u
JOIN entry_logs e
ON u.user_id = e.user_id;

Access attempts with user names (including unauthorized)
SELECT a.attempt_id,
       a.qr_code_value,
       u.full_name,
       a.attempt_time,
       a.result
FROM access_attempts a
LEFT JOIN users u
ON a.user_id = u.user_id;

Number of users per role
SELECT role,
       COUNT(*) AS total_users
FROM users
GROUP BY role;

Number of entry logs per user
SELECT u.full_name,
       COUNT(e.log_id) AS total_entries
FROM users u
JOIN entry_logs e
ON u.user_id = e.user_id
GROUP BY u.full_name;

Unauthorized access attempts count
SELECT COUNT(*) AS unauthorized_attempts
FROM access_attempts
WHERE result = 'UNAUTHORIZED';

SUBQUERIES
Users who are currently inside the building
SELECT *
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM entry_logs
    WHERE exit_time IS NULL
);

Users who never entered the building
SELECT full_name
FROM users
WHERE user_id NOT IN (
    SELECT user_id
    FROM entry_logs
);


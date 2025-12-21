
--Test Case 1: Valid QR code
SELECT verify_qr('QR_0001') FROM dual;
--Test Case 2: Invalid QR code
SELECT verify_qr('FAKE_QR_999') FROM dual;
--Procedure: log_entry(p_qr_code)
EXEC log_entry('QR_0001');
--Procedure: log_exit(p_qr_code)
EXEC log_exit('QR_0001');
--Test Case: INSERT on weekday
--Trigger: trg_users_restrict_dml
INSERT INTO users VALUES (999, 'Blocked User', 'Employee', 'QR_BLOCK', 'ACTIVE');
--Edge Cases Validated
--Edge Case	Expected Behavior	Result
--Invalid QR code	Logged as UNAUTHORIZED Passed
--Inactive user	Access denied	Passed
--Exit without entry	Logged as NO OPEN ENTRY	Passed
--Duplicate QR code	Prevented by UNIQUE constraint	Passed
--Delete user with logs	Blocked by trigger	Passed
--Access on holiday	Blocked by restriction trigger Passed
--Performance Verified
--Bulk Data Test
--Inserted 200+ users
--Generated 1000+ entry and access logs
--Executed procedures in loops

BEGIN
  FOR i IN 1..100 LOOP
    log_entry('QR_0001');
    log_exit('QR_0001');
  END LOOP;
END;
/
--Verification Queries
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM entry_logs;
SELECT COUNT(*) FROM access_attempts;
SELECT COUNT(*) FROM audit_log;

--Sample Logged Data
SELECT * FROM access_attempts
WHERE result = 'UNAUTHORIZED';

SELECT * FROM audit_log
ORDER BY operation_time DESC;

--Trigger Blocks INSERT on Weekday (DENIED)
--Test Condition
--Test executed on a weekday (Monday–Friday)
--SQL Executed

INSERT INTO users (
  user_id, full_name, role, qr_code_value, status
)
VALUES (
  seq_users.NEXTVAL,
  'Weekday Test User',
  'Employee',
  'QR_WEEKDAY_' || seq_users.CURRVAL,
  'ACTIVE'
);

--Trigger Allows INSERT on Weekend (ALLOWED)
--Test Condition
--Test executed on Saturday or Sunday
--SQL Executed

INSERT INTO users (
  user_id, full_name, role, qr_code_value, status
)
VALUES (
  seq_users.NEXTVAL,
  'Weekend Test User',
  'Employee',
  'QR_WEEKEND_' || seq_users.CURRVAL,
  'ACTIVE'
);

--Trigger Blocks INSERT on Holiday (DENIED)
--Test Setup
--Insert a holiday:

INSERT INTO holidays (holiday_date, holiday_name)
VALUES (TRUNC(SYSDATE), 'Test Holiday');

COMMIT;

--SQL Executed
INSERT INTO users (
  user_id, full_name, role, qr_code_value, status
)
VALUES (
  seq_users.NEXTVAL,
  'Holiday Test User',
  'Employee',
  'QR_HOLIDAY_' || seq_users.CURRVAL,
  'ACTIVE'
);
--Audit Log Captures All Attempts
--Verification Query
SELECT object_name,
       operation,
       performed_by,
       details,
       operation_time
FROM audit_log
ORDER BY operation_time DESC;

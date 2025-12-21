
--Test Case 1: Valid QR code
SELECT verify_qr('QR_EMP_001') FROM dual;
--Test Case 2: Invalid QR code
SELECT verify_qr('QR_FAKE_999') FROM dual;
--Test Case: Authorized user entry
EXEC log_entry('QR_EMP_001');
--Test Case: Valid exit scan
EXEC log_exit('QR_EMP_001');
--Test Case: INSERT on weekday
INSERT INTO users VALUES (99, 'Test User', 'Employee', 'QR_TEST', 'ACTIVE');
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
    log_entry('QR_EMP_001');
    log_exit('QR_EMP_001');
  END LOOP;
END;
/
--Test Results Documented
--Evidence Collected
--SQL Developer execution results
--Trigger error messages
--Query outputs
--Audit log records
--Example verification query:
SELECT * FROM audit_log ORDER BY operation_time DESC;

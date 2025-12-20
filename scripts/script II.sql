## Create historical entry/exit logs and access_attempts for testing (via PL/SQL)

DECLARE
  CURSOR c_users IS SELECT user_id, qr_code_value FROM users WHERE role = 'Employee';
  v_logid NUMBER;
  v_attemptid NUMBER;
BEGIN
  FOR r IN c_users LOOP
    -- create between 1 and 5 random visits per user
    FOR j IN 1..(TRUNC(DBMS_RANDOM.VALUE(1,5))) LOOP
      v_logid := seq_logs.NEXTVAL;
      INSERT INTO entry_logs(log_id, user_id, entry_time, exit_time)
      VALUES (v_logid, r.user_id, SYSTIMESTAMP - NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(1,30)), 'DAY'),
              SYSTIMESTAMP - NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(0,29)), 'DAY'));
      v_attemptid := seq_attempts.NEXTVAL;
      INSERT INTO access_attempts(attempt_id, qr_code_value, user_id, attempt_time, result)
      VALUES (v_attemptid, r.qr_code_value, r.user_id, SYSTIMESTAMP - NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(1,30)), 'DAY'), 'SUCCESS');
    END LOOP;
  END LOOP;
  COMMIT;
END;
/

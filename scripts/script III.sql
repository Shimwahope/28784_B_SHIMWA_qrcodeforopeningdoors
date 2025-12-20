1)verify_qr function

CREATE OR REPLACE FUNCTION verify_qr(p_qr_code VARCHAR2)
RETURN NUMBER
IS
    v_user_id NUMBER;
BEGIN
    SELECT user_id INTO v_user_id
    FROM users
    WHERE qr_code_value = p_qr_code
      AND status = 'ACTIVE';

    RETURN v_user_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

2) log_entry and log_exit 

CREATE OR REPLACE PROCEDURE log_entry(p_qr_code VARCHAR2, p_performed_by VARCHAR2 DEFAULT 'SYSTEM')
IS
    v_user_id NUMBER;
BEGIN
    v_user_id := verify_qr(p_qr_code);

    IF v_user_id IS NOT NULL THEN
        INSERT INTO entry_logs(log_id, user_id, entry_time)
        VALUES (seq_logs.NEXTVAL, v_user_id, SYSTIMESTAMP);

        INSERT INTO access_attempts(attempt_id, qr_code_value, user_id, result)
        VALUES (seq_attempts.NEXTVAL, p_qr_code, v_user_id, 'SUCCESS');

        INSERT INTO audit_log(audit_id, object_name, operation, performed_by, details)
        VALUES (seq_audit.NEXTVAL, 'ENTRY_LOGS', 'INSERT', p_performed_by, 'Entry logged for user_id='||v_user_id);

        COMMIT;
    ELSE
        INSERT INTO access_attempts(attempt_id, qr_code_value, user_id, result)
        VALUES (seq_attempts.NEXTVAL, p_qr_code, NULL, 'UNAUTHORIZED');

        INSERT INTO audit_log(audit_id, object_name, operation, performed_by, details)
        VALUES (seq_audit.NEXTVAL, 'ACCESS_ATTEMPTS', 'INSERT', p_performed_by, 'Unauthorized attempt for '||p_qr_code);

        COMMIT;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE log_exit(p_qr_code VARCHAR2, p_performed_by VARCHAR2 DEFAULT 'SYSTEM')
IS
    v_user_id NUMBER;
    v_rows_updated NUMBER;
BEGIN
    v_user_id := verify_qr(p_qr_code);

    IF v_user_id IS NOT NULL THEN
        UPDATE entry_logs
        SET exit_time = SYSTIMESTAMP
        WHERE user_id = v_user_id
          AND exit_time IS NULL;

        v_rows_updated := SQL%ROWCOUNT;

        INSERT INTO access_attempts(attempt_id, qr_code_value, user_id, result)
        VALUES (seq_attempts.NEXTVAL, p_qr_code, v_user_id, CASE WHEN v_rows_updated>0 THEN 'EXIT LOGGED' ELSE 'NO OPEN ENTRY' END);

        INSERT INTO audit_log(audit_id, object_name, operation, performed_by, details)
        VALUES (seq_audit.NEXTVAL, 'ENTRY_LOGS', 'UPDATE', p_performed_by, 'Exit update for user='||v_user_id||' rows='||v_rows_updated);

        COMMIT;
    ELSE
        INSERT INTO access_attempts(attempt_id, qr_code_value, user_id, result)
        VALUES (seq_attempts.NEXTVAL, p_qr_code, NULL, 'UNAUTHORIZED EXIT');

        INSERT INTO audit_log(audit_id, object_name, operation, performed_by, details)
        VALUES (seq_audit.NEXTVAL, 'ACCESS_ATTEMPTS', 'INSERT', p_performed_by, 'Unauthorized exit attempt '||p_qr_code);

        COMMIT;
    END IF;
END;
/
Package: qr_access_pkg (spec + body)

A package to group functions/procedures and provide helper cursors.

CREATE OR REPLACE PACKAGE qr_access_pkg AS
  FUNCTION verify_qr_fn(p_qr_code VARCHAR2) RETURN NUMBER;
  PROCEDURE log_entry_proc(p_qr_code VARCHAR2, p_by VARCHAR2 := 'SYSTEM');
  PROCEDURE log_exit_proc(p_qr_code VARCHAR2, p_by VARCHAR2 := 'SYSTEM');

  -- cursor to find people currently inside
  TYPE t_current IS REF CURSOR;
  PROCEDURE get_currently_inside(p_cursor OUT t_current);
END qr_access_pkg;
/

CREATE OR REPLACE PACKAGE BODY qr_access_pkg AS
 FUNCTION verify_qr_fn(p_qr_code VARCHAR2) RETURN NUMBER IS
    v_user NUMBER;
  BEGIN
    v_user := verify_qr(p_qr_code);
    RETURN v_user;
  END verify_qr_fn;

  PROCEDURE log_entry_proc(p_qr_code VARCHAR2, p_by VARCHAR2 := 'SYSTEM') IS
  BEGIN
    log_entry(p_qr_code, p_by);
  END log_entry_proc;

  PROCEDURE log_exit_proc(p_qr_code VARCHAR2, p_by VARCHAR2 := 'SYSTEM') IS
  BEGIN
    log_exit(p_qr_code, p_by);
  END log_exit_proc;

  PROCEDURE get_currently_inside(p_cursor OUT t_current) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT u.user_id, u.full_name, u.role, MIN(el.entry_time) AS last_entry
      FROM users u
      JOIN entry_logs el ON u.user_id = el.user_id
      WHERE el.exit_time IS NULL
      GROUP BY u.user_id, u.full_name, u.role
      ORDER BY last_entry;
  END get_currently_inside;

END qr_access_pkg;
/

Restriction function

CREATE OR REPLACE FUNCTION restriction_check(p_username VARCHAR2, p_operation VARCHAR2)
RETURN VARCHAR2
IS
    v_today_date DATE := TRUNC(SYSDATE);
    v_is_holiday NUMBER;
    v_day_of_week INTEGER := TO_NUMBER(TO_CHAR(v_today_date, 'D')); -- NLS dependent: commonly 1=Sunday
    v_nls_char CHAR(1);
BEGIN
    SELECT COUNT(*) INTO v_is_holiday FROM holidays WHERE holiday_date = v_today_date;

    -- we want to block Monday-Friday. Determine weekday number using ISO day number:
    IF TO_CHAR(v_today_date,'DY','NLS_DATE_LANGUAGE=ENGLISH') IN ('MON','TUE','WED','THU','FRI') THEN
        RETURN 'WEEKDAY_NOT_ALLOWED';
    END IF;

    IF v_is_holiday > 0 THEN
        RETURN 'HOLIDAY_NOT_ALLOWED';
    END IF;

    RETURN 'OK';
END;
/
CREATE OR REPLACE TRIGGER trg_users_restrict_dml
BEFORE INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
DECLARE
  v_check_result VARCHAR2(100);
  v_user          VARCHAR2(100);
  v_operation     VARCHAR2(20);
BEGIN
 
-- Get current database user
  v_user := NVL(SYS_CONTEXT('USERENV','SESSION_USER'), USER);

  -- Determine operation type (PL/SQL context)
  IF INSERTING THEN
    v_operation := 'INSERT';
  ELSIF UPDATING THEN
    v_operation := 'UPDATE';
  ELSE
    v_operation := 'DELETE';
  END IF;

  -- Check restriction rule
  v_check_result := restriction_check(v_user, v_operation);

  IF v_check_result <> 'OK' THEN
    -- Audit blocked operation
    INSERT INTO audit_log (
      audit_id,
      object_name,
      operation,
      performed_by,
      details
    )
    VALUES (
      seq_audit.NEXTVAL,
      'USERS',
      v_operation,
      v_user,
      'Blocked by restriction: ' || v_check_result ||
      ' at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );

    RAISE_APPLICATION_ERROR(
      -20020,
      'Operation denied due to policy: ' || v_check_result
    );
  ELSE
    -- Audit allowed operation
    INSERT INTO audit_log (
      audit_id,
      object_name,
      operation,
      performed_by,
      details
    )
    VALUES (
      seq_audit.NEXTVAL,
      'USERS',
      v_operation,
      v_user,
      'Allowed operation'
    );
  END IF;
END;
/

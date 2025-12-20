## Table implementation + sequences + realistic test data

-- 1. Sequences
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_logs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_attempts START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_audit START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 2. Tables
CREATE TABLE users (
    user_id        NUMBER PRIMARY KEY,
    full_name      VARCHAR2(100) NOT NULL,
    role           VARCHAR2(50) NOT NULL,
    qr_code_value  VARCHAR2(200) UNIQUE NOT NULL,
    status         VARCHAR2(30) DEFAULT 'ACTIVE' NOT NULL
);

CREATE TABLE entry_logs (
    log_id      NUMBER PRIMARY KEY,
    user_id     NUMBER NOT NULL,
    entry_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
    exit_time   TIMESTAMP,
    CONSTRAINT fk_entry_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE access_attempts (
    attempt_id      NUMBER PRIMARY KEY,
    qr_code_value   VARCHAR2(200) NOT NULL,
    user_id         NUMBER,
    attempt_time    TIMESTAMP DEFAULT SYSTIMESTAMP,
    result          VARCHAR2(50),
    CONSTRAINT fk_attempts_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE audit_log (
    audit_id       NUMBER PRIMARY KEY,
    object_name    VARCHAR2(100),
    operation      VARCHAR2(20),
    performed_by   VARCHAR2(100),
    operation_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    details        CLOB
);

CREATE TABLE holidays (
    holiday_date DATE PRIMARY KEY,
    holiday_name VARCHAR2(100)
);

## Generate realistic users + QR codes (example 200 users)

DECLARE
  v_cnt INTEGER := 200;        -- change as needed (100-500 recommended)
  v_name VARCHAR2(100);
  v_role VARCHAR2(50);
BEGIN
  FOR i IN 1..v_cnt LOOP
    IF MOD(i,10) = 0 THEN
      v_role := 'Visitor';
    ELSIF MOD(i,7) = 0 THEN
      v_role := 'Security';
    ELSE
      v_role := 'Employee';
    END IF;

    v_name := 'User_' || LPAD(i,4,'0');
    INSERT INTO users(user_id, full_name, role, qr_code_value, status)
    VALUES (seq_users.NEXTVAL, v_name, v_role, 'QR' || TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISS') || '_' || i, 'ACTIVE');
    -- small delay to vary timestamps if needed
    DBMS_LOCK.SLEEP(0.01);
  END LOOP;
  COMMIT;
END;

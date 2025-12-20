# Data Dictionary

## PROJECT: QR Code Verification for Smart Building Entry Logging 

This data dictionary defines all database objects used in the system, including tables, columns, data types, constraints, and business meanings. It supports understanding, maintenance, and auditing of the database.

---

## 1. USERS

Stores all authorized people who can access the building.

| Column Name   | Data Type     | Constraints                | Description                             |
| ------------- | ------------- | -------------------------- | --------------------------------------- |
| user_id       | NUMBER        | PRIMARY KEY                | Unique identifier for each user         |
| full_name     | VARCHAR2(100) | NOT NULL                   | User’s full legal name                  |
| role          | VARCHAR2(50)  | NOT NULL                   | User role (Employee, Visitor, Security) |
| qr_code_value | VARCHAR2(200) | UNIQUE, NOT NULL           | Unique QR code assigned to the user     |
| status        | VARCHAR2(30)  | DEFAULT 'ACTIVE', NOT NULL | Indicates if user is ACTIVE or INACTIVE |

**Notes:**

* Each user is assigned exactly one QR code.
* Inactive users are denied access by the system.

---

## 2. ENTRY_LOGS

Records entry and exit times for users entering or leaving the building.

| Column Name | Data Type | Constraints                  | Description                          |
| ----------- | --------- | ---------------------------- | ------------------------------------ |
| log_id      | NUMBER    | PRIMARY KEY                  | Unique identifier for each entry log |
| user_id     | NUMBER    | FOREIGN KEY → USERS(user_id) | User who entered or exited           |
| entry_time  | TIMESTAMP | DEFAULT SYSTIMESTAMP         | Time the user entered the building   |
| exit_time   | TIMESTAMP | NULLABLE                     | Time the user exited the building    |

**Notes:**

* A NULL exit_time indicates the user is currently inside the building.
* A user can have multiple entry records.

---

## 3. ACCESS_ATTEMPTS

Logs every QR code scan attempt, whether authorized or unauthorized.

| Column Name   | Data Type     | Constraints                            | Description                                                        |
| ------------- | ------------- | -------------------------------------- | ------------------------------------------------------------------ |
| attempt_id    | NUMBER        | PRIMARY KEY                            | Unique identifier for each access attempt                          |
| qr_code_value | VARCHAR2(200) | NOT NULL                               | QR code that was scanned                                           |
| user_id       | NUMBER        | FOREIGN KEY → USERS(user_id), NULLABLE | User linked to QR code if valid                                    |
| attempt_time  | TIMESTAMP     | DEFAULT SYSTIMESTAMP                   | Time the QR code was scanned                                       |
| result        | VARCHAR2(50)  |                                        | Result of scan (SUCCESS, UNAUTHORIZED, EXIT LOGGED, NO OPEN ENTRY) |

**Notes:**

* user_id is NULL for unauthorized QR codes.
* This table supports security monitoring and analytics.

---

## 4. AUDIT_LOG

Stores audit records for database operations enforced by triggers.

| Column Name    | Data Type     | Constraints          | Description                         |
| -------------- | ------------- | -------------------- | ----------------------------------- |
| audit_id       | NUMBER        | PRIMARY KEY          | Unique identifier for audit record  |
| object_name    | VARCHAR2(100) |                      | Database object affected            |
| operation      | VARCHAR2(20)  |                      | INSERT, UPDATE, or DELETE           |
| performed_by   | VARCHAR2(100) |                      | Database user or system             |
| operation_time | TIMESTAMP     | DEFAULT SYSTIMESTAMP | Time operation occurred             |
| details        | CLOB          |                      | Description of the action performed |

**Notes:**

* Automatically populated using database triggers.
* Used for accountability and investigations.

---

## 5. HOLIDAYS

Defines public holidays used to enforce business rules.

| Column Name  | Data Type     | Constraints | Description            |
| ------------ | ------------- | ----------- | ---------------------- |
| holiday_date | DATE          | PRIMARY KEY | Date of public holiday |
| holiday_name | VARCHAR2(100) |             | Name of the holiday    |

**Notes:**

* Used by restriction triggers to block operations on holidays.

---

## 6. Relationships Summary

* USERS (1) → (M) ENTRY_LOGS
* USERS (1) → (M) ACCESS_ATTEMPTS
* ENTRY_LOGS operations are tracked in AUDIT_LOG
* HOLIDAYS supports business rule enforcement (logical relationship)

---

## 7. Design Notes

* All primary keys are generated using Oracle sequences.
* The schema is normalized to Third Normal Form (3NF).
* Business rules are enforced using PL/SQL triggers and functions.

---

## End of Data Dictionary

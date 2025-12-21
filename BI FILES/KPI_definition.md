# Key Performance Indicator (KPI) Definitions

## Project: QR Code Smart Building Access System

This document defines the Key Performance Indicators (KPIs) used to evaluate security, efficiency, and system usage.

---

## KPI 1: Total Access Attempts
**Description:** Total number of QR scans recorded.
**Formula:** COUNT(access_attempts.attempt_id) = (203)
**Purpose:** Measures system usage and traffic volume.

---

## KPI 2: Successful Access Rate
**Description:** Percentage of successful access attempts.
**Formula:** 
(SUCCESS attempts / Total attempts) × 100 = (123/203) x100
**Purpose:** Indicates effectiveness of access control.

---

## KPI 3: Unauthorized Access Attempts
**Description:** Number of failed or unauthorized QR scans.
**Formula:** COUNT WHERE result = 'UNAUTHORIZED' = (80)
**Purpose:** Identifies security threats and misuse.

---

## KPI 4: Average Daily Entries
**Description:** Average number of building entries per day.
**Formula:** COUNT(entry_logs.log_id) / Number of days
**Purpose:** Measures building occupancy trends.

---

## KPI 5: Active Users
**Description:** Number of currently active users.
**Formula:** COUNT WHERE status = 'ACTIVE'
**Purpose:** Tracks valid access population.

---

## KPI 6: Trigger Block Rate
**Description:** Number of blocked database operations.
**Formula:** COUNT(audit_log WHERE details LIKE '%Blocked%')
**Purpose:** Evaluates enforcement of business rules.

---

## KPI 7: Peak Entry Time
**Description:** Time range with highest entry activity.
**Formula:** GROUP BY hour(entry_time)
**Purpose:** Helps optimize staffing and security coverage.



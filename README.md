# 28784\_B\_SHIMWA\_qrcodeforopeningdoor

Student: SHIMWA HOPE

Registration Number: 28784

Course: DATABASE WITH PL/SQL

PROJECT:QR Code Verification for Smart Building Entry Logging

Project Overview

This project implements a QR Code–based Smart Building Entry Logging System using Oracle Database and PL/SQL. The system replaces manual logbooks and traditional access cards with a secure, automated, and auditable solution.

Each authorized user is assigned a unique QR code stored in the database. When scanned at the building entrance or exit, the system automatically verifies the QR code, logs entry/exit times, and records unauthorized access attempts.


A.OBJECTIVES:

1.Automate building entry and exit logging

2.Improve security and access control

3.Detect and log unauthorized QR code attempts

4.Provide accurate audit trails for investigations

5.Enable analytics and reporting for decision-making



B.System Features

1.QR code verification for access control

2.Automatic entry and exit time logging

3.Unauthorized access attempt detection

4.Audit logging using database triggers

5.Business rule enforcement (weekday/holiday restrictions)

6.Analytical queries for monitoring and reporting

C.Database Schema

The system uses the following main tables:

1.USERS – Stores authorized users and QR codes

2.ENTRY\_LOGS – Records entry and exit times

4.ACCESS\_ATTEMPTS – Logs all QR scan attempts

5.AUDIT\_LOG – Stores audit records for DML operations

6.HOLIDAYS – Defines public holidays for restriction rules

An ER diagram and data dictionary are provided in the repository.



D.PL/SQL Components

1.Function verify\_qr – Validates QR codes and returns user ID

2.Procedures log\_entry, log\_exit – Handle entry and exit logging

3.Package qr\_access\_pkg – Groups related procedures and cursors

4. Triggers

1.Prevent deletion of users with logs

2.Enforce weekdays/holiday restrictions

3.Capture audit\_logs automatically



E.Business Rules

1.Only active users can access the building

2.Employees are restricted from INSERT/UPDATE/DELETE operations on weekdays and public holidays

3.Users with entry logs cannot be deleted

4.All unauthorized access attempts are logged

F.Analytics \& BI

1.The system supports analytics such as:

2.Current occupancy (users inside the building)

3.Daily entry counts by role

4.Unauthorized access trends

5.Average time spent in the building

6.Peak entry hours

These insights help security teams and administrators make data-driven decisions.

G.Testing

1.Test data is generated using PL/SQL loops and sequences. Scripts include:

2.Sample users (employees, visitors, security)

3.Entry and exit logs

4.Authorized and unauthorized access attempts

Triggers can be temporarily disabled during bulk data loading.

H.How to Run

1.Create sequences and tables using scripts in /database/scripts/

2.Insert test data (disable restriction triggers if required)

3.Compile PL/SQL functions, procedures, packages, and triggers

4.Execute test procedures (log\_entry, log\_exit)

Run analytics queries for reports


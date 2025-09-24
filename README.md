Markdown

# Hospital Management System: An Advanced SQL Analysis Project

This project is a deep dive into SQL, where I tackled 20 analytical questions using a fictional hospital's operational dataset. It was a fantastic opportunity to apply a wide range of SQL techniques, from basic joins to advanced window functions, to solve real-world healthcare administration problems.

***

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Tools Used](#tools-used)
- [Setup](#setup)
- [Sample Analysis & Queries](#sample-analysis--queries)
- [Key SQL Concepts Covered](#key-sql-concepts-covered)

***

## Project Overview

The main goal was to practice and showcase my SQL skills by analyzing patient demographics, appointment scheduling, departmental workload, and readmission rates. The project involves loading raw CSV data into a PostgreSQL database and then running a series of queries to extract meaningful insights for hospital administration.

***

## Dataset

The dataset consists of four simple CSV files that mimic a real hospital's database:

- **`Patients.csv`**: Contains information about each patient.
- **`Doctors.csv`**: Contains details for each doctor, including their specialty and department.
- **`Appointments.csv`**: The transactional table linking patients to doctors for scheduled visits.
- **`Departments.csv`**: Contains information about the various hospital departments.

***

## Tools Used

- **Database**: PostgreSQL
- **Language**: Python (for data loading)
- **Libraries**: `pandas`, `psycopg2`, `SQLAlchemy`

***

## Setup

To get this project running locally:

1.  Make sure you have Python and PostgreSQL installed.
2.  Install the required Python libraries: `pip install pandas psycopg2-binary SQLAlchemy`.
3.  Create a new database in PostgreSQL.
4.  Update the connection details (username, password, database name) in the `load_hms_data.py` script.
5.  Run the script from your terminal: `python load_hms_data.py`. This will create the necessary tables and load all the data from the CSV files.

***

## Sample Analysis & Queries

The `hms_analysis.sql` file contains the solutions to all 20 questions. Here are a few highlights:

### 1. Analyzing 30-Day Patient Readmission Rates

-   **Business Question**: What is our 30-day readmission rate, and which patients are being readmitted?
-   **Approach**: This complex, multi-step analysis first required finding each patient's admission dates. Then, using the `LEAD()` window function, I calculated the time gap between a patient's discharge and their next admission. Finally, I filtered this list to identify readmissions occurring within 30 days. This insight is critical for patient care quality and operational efficiency.

```sql
-- Query to find patients readmitted within 30 days
WITH PatientAdmissions AS (
    SELECT
        Patient_ID,
        Appointment_Date,
        LEAD(Appointment_Date, 1) OVER (
            PARTITION BY Patient_ID ORDER BY Appointment_Date
        ) AS Next_Admission_Date
    FROM
        Appointments
    WHERE
        -- Assuming an 'Admission' appointment type exists
        Appointment_Type = 'Admission'
),
ReadmissionGaps AS (
    SELECT
        Patient_ID,
        Appointment_Date,
        Next_Admission_Date,
        (Next_Admission_Date - Appointment_Date) AS Days_To_Next_Admission
    FROM
        PatientAdmissions
    WHERE
        Next_Admission_Date IS NOT NULL
)
SELECT
    P.Name,
    R.Appointment_Date AS Initial_Admission,
    R.Next_Admission_Date AS Readmission,
    R.Days_To_Next_Admission
FROM
    ReadmissionGaps R
JOIN
    Patients P ON R.Patient_ID = P.Patient_ID
WHERE
    R.Days_To_Next_Admission <= 30
ORDER BY
    P.Name;
2. Calculating Departmental Patient Load Month-over-Month
Business Question: How is patient load distributed across departments, and what is the monthly trend?

Approach: This required another multi-step process. First, I aggregated the number of appointments by department and month. Then, I used the LAG() window function to get the previous month's appointment count, allowing me to calculate the percentage growth. This is key for resource allocation and spotting departmental workload trends.

SQL

-- Query for Month-over-Month Growth in Departmental Appointments
WITH MonthlyDeptAppointments AS (
    SELECT
        D.Department_Name,
        DATE_TRUNC('month', A.Appointment_Date) AS Appointment_Month,
        COUNT(A.Appointment_ID) AS Total_Appointments
    FROM Appointments AS A
    INNER JOIN Doctors AS Doc ON A.Doctor_ID = Doc.Doctor_ID
    INNER JOIN Departments AS D ON Doc.Department_ID = D.Department_ID
    GROUP BY D.Department_Name, Appointment_Month
),
AppointmentsWithLag AS (
    SELECT
        *,
        LAG(Total_Appointments, 1, 0) OVER (PARTITION BY Department_Name ORDER BY Appointment_Month) AS Previous_Month_Appointments
    FROM MonthlyDeptAppointments
)
SELECT
    Department_Name,
    TO_CHAR(Appointment_Month, 'YYYY-MM') AS Appointment_Month,
    Total_Appointments,
    ROUND(((Total_Appointments - Previous_Month_Appointments) * 100.0 / Previous_Month_Appointments), 2) AS MoM_Growth_Percentage
FROM AppointmentsWithLag
WHERE Previous_Month_Appointments > 0;
Key SQL Concepts Covered
This project provided hands-on experience with a wide array of SQL features, including:

JOINS (Inner, Left, Self-Join)

Aggregate Functions (SUM, COUNT, AVG)

Grouping & Filtering (GROUP BY, HAVING)

Subqueries & Common Table Expressions (CTEs)

Conditional Logic (CASE statements)

Window Functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE)

Date & String Manipulation

Calculating Running Totals, Rolling Averages, and Percent-of-Total

Thanks for checking out my project!

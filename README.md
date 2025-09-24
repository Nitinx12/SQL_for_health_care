# Hospital Management System (HMS) - SQL Analytics Project

![SQL](https://img.shields.io/badge/Language-SQL-blue.svg)
![Database](https://img.shields.io/badge/Database-PostgreSQL-blue.svg)
![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## Project Description

This project is a comprehensive SQL-based analysis of a fictional Hospital Management System (HMS). The primary goal is to leverage advanced SQL queries to extract actionable insights from the hospital's operational data. The analysis covers patient demographics, doctor performance, appointment trends, treatment patterns, and revenue metrics to support data-driven decision-making for hospital administration.

---

## Features

-   **Patient Analytics**: Analysis of patient demographics, including age distribution and visit frequency.
-   **Doctor Performance**: Evaluation of doctors based on experience, specialization, appointments handled, and revenue generated.
-   **Revenue Analysis**: Detailed breakdown of billing, payment statuses, and month-over-month revenue growth.
-   **Appointment & Operational Analysis**: Insights into appointment statuses, peak specializations, and patient flow across different hospital branches.
-   **Advanced Analytics**: Utilizes window functions, CTEs, and subqueries to uncover complex patterns like patient retention and rolling averages.

---

## Database Schema

The database consists of five interconnected tables that model the core operations of a hospital.



| Table Name      | Description                                                                 | Key Columns                                            |
| --------------- | --------------------------------------------------------------------------- | ------------------------------------------------------ |
| `patients`      | Stores demographic and insurance information for all patients.              | `patient_id`, `first_name`, `date_of_birth`            |
| `doctors`       | Contains details about doctors, their specializations, and experience.      | `doctor_id`, `first_name`, `specialization`            |
| `appointments`  | Records all patient appointments with doctors, including status and date.   | `appointment_id`, `patient_id`, `doctor_id`, `status`  |
| `treatments`    | A linking table that connects appointments to specific billing records.     | `treatment_id`, `appointment_id`, `billing_id`         |
| `billing`       | Holds financial information, including bill amounts and payment statuses.   | `bill_id`, `patient_id`, `amount`, `payment_status`    |

---

## SQL Queries & Analysis

This project answers 16 key analytical questions to provide a 360-degree view of hospital operations.

### 1. Patient Age Group Distribution
Calculates the number of patients in different age brackets.
```sql
WITH T1 AS(SELECT patient_id,
		CONCAT(first_name,' ',last_name) AS patient_full_name,
		EXTRACT(YEAR FROM AGE(NOW(),date_of_birth)) AS age
		FROM patients)

SELECT COUNT(patient_id),
CASE
WHEN age BETWEEN 20 AND 30 THEN '20-30 years'
WHEN age BETWEEN 31 AND 40 THEN '31-40 years'
WHEN age BETWEEN 41 AND 50 THEN '41-50 years'
WHEN age BETWEEN 51 AND 60 THEN '51-60 years'
ELSE '61+years'
END AS age_groups
FROM T1
GROUP BY 2
ORDER BY 2 ASC
```

### 2. Average Doctor Experience by Specialization
Finds the average years of experience for doctors in each specialization.
```sql
SELECT specialization,
ROUND(AVG(years_experience),2) AS average_years_experience
FROM doctors
GROUP BY 1
ORDER BY 2 DESC
```

### 3. Appointment Status Breakdown
Counts the total number of appointments for each status (e.g., Completed, Cancelled).
```sql
SELECT status,
COUNT(appointment_id) AS total_appointments
FROM appointments
GROUP BY 1
ORDER BY 2 DESC
```

### 4. Revenue by Payment Method and Status
Aggregates the total billed amount by payment method and payment status.
```sql
SELECT payment_method, payment_status,
SUM(amount) AS total_billed
FROM billing
GROUP BY 1, 2
ORDER BY 1, 2
```

### 5. Appointments per Doctor Specialization
Counts the number of appointments handled by each medical specialization.
```sql
SELECT D.specialization,
COUNT(A.appointment_id) AS no_of_app
FROM appointments AS A
INNER JOIN doctors AS D
ON D.doctor_id = A.doctor_id
GROUP BY 1
ORDER BY 2 DESC
```

### 6. Unique Patients per Hospital Branch
Determines the number of unique patients visiting each hospital branch.
```sql
SELECT D.hospital_branch,
COUNT(DISTINCT A.patient_id) AS unique_patient
FROM appointments AS A
INNER JOIN doctors AS D
ON D.doctor_id = A.doctor_id
GROUP BY 1
ORDER BY 2 DESC
```

### 7. Top 5 Revenue-Generating Doctors
Identifies the top 5 doctors who have generated the most revenue from 'Paid' bills.
```sql
SELECT CONCAT(D.first_name,' ',D.last_name) AS doc_full_name,
D.specialization,
SUM(B.amount) AS total_revenue
FROM doctors AS D
INNER JOIN appointments AS A ON
A.doctor_id = D.doctor_id
INNER JOIN treatments AS T ON
A.appointment_id = T.appointment_id
INNER JOIN billing AS B ON
T.treatment_id = B.treatment_id
WHERE B.payment_status = 'Paid'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5
```

### 8. Top Doctors by Revenue in Each Branch
Ranks doctors within each hospital branch based on the total revenue they generated.
```sql
WITH T1 AS(SELECT CONCAT(D.first_name,' ',D.last_name) AS doc_full_name,
			D.doctor_id,
			D.hospital_branch,
			SUM(B.amount) AS total_revenue
			FROM doctors AS D
			INNER JOIN appointments AS A ON
			A.doctor_id = D.doctor_id
			INNER JOIN treatments AS T ON
			A.appointment_id = T.appointment_id
			INNER JOIN billing AS B ON
			T.treatment_id = B.treatment_id
			WHERE B.payment_status = 'Paid'
			GROUP BY 1, 2, 3)

SELECT hospital_branch, doc_full_name, total_revenue,
DENSE_RANK() OVER(PARTITION BY hospital_branch ORDER BY total_revenue DESC) as RANK
FROM T1
ORDER BY 1
```

### 9. Average Days Between Patient Visits
Calculates the average time gap between consecutive visits for each patient.
```sql
WITH T1 AS(SELECT patient_id, appointment_date,
			LAG(appointment_date, 1) OVER(PARTITION BY patient_id ORDER BY appointment_date) AS previous_date
			FROM appointments
			WHERE status = 'Completed'),

T2 AS(SELECT patient_id,
		appointment_date - previous_date AS days_between_visits
		FROM T1
		WHERE previous_date IS NOT NULL)

SELECT CONCAT(P.first_name,' ',P.last_name) AS patient_name,
FLOOR(AVG(T.days_between_visits)) AS avg_days_between_visits
FROM T2 AS T
JOIN patients AS P ON
P.patient_id = T.patient_id
GROUP BY P.patient_id, patient_name
ORDER BY 2 DESC
```

### 10. Patient First and Last Visit Analysis
Finds the first and last visit dates for each patient to calculate their engagement duration.
```sql
WITH T1 AS(SELECT patient_id,
			FIRST_VALUE(appointment_date) OVER(PARTITION BY patient_id ORDER BY appointment_date 
												ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_visit,
			LAST_VALUE(appointment_date) OVER(PARTITION BY patient_id ORDER BY appointment_date
												ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  AS last_visit
			FROM appointments
			WHERE status = 'Completed')

SELECT CONCAT(P.first_name,' ',P.last_name) AS patient_full_name,
T.first_visit, T.last_visit,
(T.last_visit - T.first_visit) AS days
FROM T1 AS T
INNER JOIN patients AS P ON
T.patient_id = P.patient_id
ORDER BY days DESC
```

### 11. Patients with Above-Average Billing
Identifies patients whose total billed amount is greater than the average of all patients.
```sql
WITH T1 AS(SELECT patient_id,
		SUM(amount) AS total_billed
		FROM billing
		GROUP BY 1)

SELECT P.first_name ||' '||P.last_name AS patient_name,
T.total_billed
FROM T1 AS T
INNER JOIN patients AS P ON
P.patient_id = T.patient_id
WHERE T.total_billed > (SELECT AVG(total_billed) FROM T1)
ORDER BY 2 DESC
```

### 12. Monthly Revenue Growth Percentage (MoM)
Calculates the month-over-month percentage growth in revenue.
```sql
WITH T1 AS(SELECT DATE_TRUNC('MONTH',bill_date) :: DATE AS months,
		SUM(amount) AS monthly_revenue
		FROM billing
		WHERE payment_status = 'Paid'
		GROUP BY 1),

T2 AS(SELECT months, monthly_revenue,
		LAG(monthly_revenue,1) OVER(ORDER BY months ASC) AS previous_month
		FROM T1
		)

SELECT TO_CHAR(months, 'YYYY-MM') AS months, monthly_revenue,
COALESCE(ROUND((monthly_revenue - previous_month)/previous_month * 100,2),0) ||'%' AS mom_growth
FROM T2
```

### 13. Patients Visiting Multiple Specializations
Lists patients who have visited two or more different doctor specializations.
```sql
SELECT CONCAT(P.first_name,' ',P.last_name) AS patient_full_name,
COUNT(DISTINCT D.specialization) AS distinct_specializations_visited,
STRING_AGG(DISTINCT D.specialization,', ') AS specializations
FROM patients AS P
INNER JOIN appointments AS A ON
P.patient_id = A.patient_id
INNER JOIN doctors AS D ON
D.doctor_id = A.doctor_id
GROUP BY P.patient_id, 1
HAVING COUNT(DISTINCT D.specialization) >= 2
ORDER BY 3 DESC
```

### 14. Consecutive Day Billing Patterns
Identifies instances where a patient was billed on consecutive days.
```sql
WITH T1 AS(SELECT bill_id, patient_id, bill_date, amount,
		ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY bill_date) AS rnk,
		bill_date - ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY bill_date) :: INT AS diff
		FROM billing),

T2 AS(SELECT *,
	COUNT(*) OVER(PARTITION BY patient_id, diff) AS no_of_records
	FROM T1)

SELECT bill_id, patient_id, bill_date, amount
FROM T2
WHERE no_of_records > 1
```

### 15. Simple Data Update (Example)
An example `UPDATE` statement to change a patient's insurance provider.
```sql
UPDATE patients SET insurance_provider = 'HDFC LIFE'
WHERE patient_id = 'P001'
```

### 16. 3-Month Moving Average of Revenue
Calculates the 3-month moving (or rolling) average of monthly revenue.
```sql
WITH T1 AS(
SELECT EXTRACT(MONTH FROM bill_date :: DATE) AS months,
SUM(amount) AS monthly_revenue
FROM billing
WHERE payment_status = 'Paid'
GROUP BY 1
)
	SELECT months, monthly_revenue,
	ROUND(AVG(monthly_revenue) OVER(ORDER BY months ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS three_month_mov_avg
	FROM T1
```

---

## Installation & Setup

Follow these steps to set up the project locally.

### Prerequisites
-   PostgreSQL installed and running.
-   Python 3.8+ installed.

### Steps
1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/your-username/hms-sql-analytics.git](https://github.com/your-username/hms-sql-analytics.git)
    cd hms-sql-analytics
    ```

2.  **Install Python libraries:**
    ```sh
    pip install pandas sqlalchemy psycopg2-binary
    ```

3.  **Set up the database:**
    -   Create a new database in PostgreSQL (e.g., `hospital_db`).
    -   Create a user and grant privileges to the database.

4.  **Load the data:**
    -   Place your CSV files (`patients.csv`, `doctors.csv`, etc.) in a `data/` directory.
    -   Update the database connection string in the `load_data.py` script:
        ```python
        # Example connection string
        db_url = 'postgresql://user:password@localhost:5432/hospital_db'
        ```
    -   Run the script to create tables and populate them with data:
        ```sh
        python load_data.py
        ```

---

## Technologies Used

| Technology | Description |
|---|---|
| **SQL** | Core language for database querying and analysis. |
| **PostgreSQL** | The relational database management system used to store and manage the data. |
| **Python** | Used for scripting the data loading process into the database. |
| **Pandas** | Python library used to read CSV files and handle data in dataframes. |
| **SQLAlchemy** | Python SQL toolkit and Object Relational Mapper used to connect to the database. |

---

## Key Insights

The analysis of the HMS dataset yielded several key insights:
-   **Patient Demographics**: The largest cohort of patients is in the **31-40 years** age group, suggesting a target demographic for specialized health services.
-   **Financial Performance**: The hospital shows a positive **month-over-month revenue growth**, and most revenue comes from bills marked as **'Paid'**. Credit card is the most common payment method.
-   **Top Performing Specialization**: **Cardiology** is the specialization with the highest number of appointments and also contributes significantly to revenue, indicating high demand and profitability.
-   **Operational Efficiency**: A significant number of appointments are **'Completed'**, but there's a non-trivial number of **'Cancelled'** appointments that could be analyzed further to reduce no-shows.
-   **Patient Retention**: The average time between visits for returning patients helps quantify patient loyalty and can be used to forecast future appointment volumes.

---

## File Structure

```
hms-sql-analytics/
├── data/
│   ├── appointments.csv
│   ├── billing.csv
│   ├── doctors.csv
│   ├── patients.csv
│   └── treatments.csv
├── analysis.sql          # Contains all 16 analytical SQL queries
├── load_data.py          # Python script to load CSV data into PostgreSQL
└── README.md             # This file
```

---

## Usage

To reproduce the analysis:

1.  Complete the **Installation & Setup** steps to load the data into your PostgreSQL database.
2.  Connect to your database using a SQL client (e.g., pgAdmin, DBeaver, DataGrip).
3.  Open the `analysis.sql` file.
4.  Run the queries individually to see the results of each analytical question.

---

## Contributing

Contributions are welcome! If you have suggestions for new analyses or improvements, please follow these steps:

1.  Fork the Project.
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the Branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

Please open an issue first to discuss what you would like to change.

---

## License

This project is distributed under the MIT License. See the `LICENSE` file for more information.

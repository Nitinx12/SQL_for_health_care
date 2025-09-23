# **Hospital Management System: An Advanced SQL Analysis Project**

This project is a deep dive into SQL, where I tackled 16 analytical questions using a fictional HMS dataset. It was a fantastic opportunity to apply a wide range of SQL techniques, from basic joins to advanced window functions, to solve real-world business problems.

---

## **Table of Contents**

* [Project Overview](https://www.google.com/search?q=%23project-overview&authuser=1)  
* [Dataset](https://www.google.com/search?q=%23dataset&authuser=1)  
* [Tools Used](https://www.google.com/search?q=%23tools-used&authuser=1)  
* [Setup](https://www.google.com/search?q=%23setup&authuser=1)  
* [Sample Analysis & Queries](https://www.google.com/search?q=%23sample-analysis--queries&authuser=1)  
* [Key SQL Concepts Covered](https://www.google.com/search?q=%23key-sql-concepts-covered&authuser=1)

---

## **Project Overview**

The main goal of this project was to leverage advanced SQL to extract meaningful insights from a hospital's operational data. By analyzing patient demographics, doctor performance, and financial records, I aimed to provide a comprehensive view of the hospital's health and efficiency. This project demonstrates how SQL can be a powerful tool for business intelligence, enabling a data-driven approach to management and decision-making.

---

## **Dataset**

The project utilizes a relational dataset composed of five tables that simulate a real Hospital Management System. The data is stored in simple CSV files, which are loaded into a PostgreSQL database for analysis.

* **`patients`**: Contains detailed demographic information for each patient, including age and contact details.  
* **`appointments`**: Tracks every patient appointment, recording the doctor, date, time, and visit status.  
* **`doctors`**: Stores information on all doctors, including their specialization and years of experience.  
* **`billing`**: Manages all financial transactions, detailing the amount, payment method, and status for each bill.  
* **`treatments`**: Records the type and cost of every medical treatment provided to patients.

---

## **Tools Used**

* **Database**: PostgreSQL  
* **Language**: Python (for data loading)  
* **Libraries**: `pandas`, `psycopg2`, `SQLAlchemy`

---

## **Setup**

To get this project running locally:

1. Make sure you have Python and PostgreSQL installed.  
2. Install the required Python libraries: `pip install pandas psycopg2-binary SQLAlchemy`.  
3. Create a new database in PostgreSQL.  
4. Update the connection details (username, password, database name) in the `load_csv_files.py` script.  
5. Run the script from your terminal: `python load_csv_files.py`. This will create the necessary tables and load all the data from the CSV files.

---

## **Sample Analysis & Queries**

The `HMS project FOR SQL.sql` file contains the solutions to all 16 analytical questions. Here are a few highlights that demonstrate key SQL concepts.

### **1\. Patient Demographics by Age Group**

* **Business Question**: How many patients fall into specific age brackets, such as 20-30, 31-40, and so on?  
* **Approach**: This query uses a **Common Table Expression (CTE)** to first calculate the precise age of each patient. Then, a **`CASE` statement** categorizes each patient into a predefined age group. Finally, an aggregation is performed to count the number of patients in each group, revealing key demographic insights.

SQL  
\-- Query to find the number of patients in each age group  
WITH T1 AS(SELECT patient\_id,  
		CONCAT(first\_name,' ',last\_name) AS patient\_full\_name,  
		EXTRACT(YEAR FROM AGE(NOW(),date\_of\_birth)) AS age  
		FROM patients)

SELECT COUNT(patient\_id),  
CASE  
WHEN age BETWEEN 20 AND 30 THEN '20-30 years'  
WHEN age BETWEEN 31 AND 40 THEN '31-40 years'  
WHEN age BETWEEN 41 AND 50 THEN '41-50 years'  
WHEN age BETWEEN 51 AND 60 THEN '51-60 years'  
ELSE '61+years'  
END AS age\_groups  
FROM T1  
GROUP BY 2  
ORDER BY 2 ASC

### **2\. Monthly Revenue Growth Percentage**

* **Business Question**: What is the month-over-month growth of our paid bill revenue?  
* **Approach**: This multi-step analysis involves two CTEs. The first CTE, `MonthlyRevenue`, calculates the total paid revenue for each month. The second CTE, `LaggedRevenue`, uses the **`LAG()` window function** to retrieve the previous month's revenue, partitioned by month. This setup allows for a straightforward calculation of the percentage growth for each month, a critical metric for financial performance.

SQL  
\-- Query for Monthly Revenue Growth Percentage  
WITH MonthlyRevenue AS (  
    SELECT  
        DATE\_TRUNC('month', bill\_date) AS bill\_month,  
        SUM(amount) AS monthly\_revenue  
    FROM billing  
    WHERE payment\_status \= 'Paid'  
    GROUP BY 1  
),  
LaggedRevenue AS (  
    SELECT  
        \*,  
        LAG(monthly\_revenue, 1, 0\) OVER (ORDER BY bill\_month) AS previous\_month  
    FROM MonthlyRevenue  
)  
SELECT  
    TO\_CHAR(bill\_month, 'YYYY-MM') AS month,  
    monthly\_revenue,  
    previous\_month,  
    ROUND((monthly\_revenue \- previous\_month) \* 100.0 / previous\_month, 2\) AS mom\_growth  
FROM LaggedRevenue  
WHERE previous\_month \> 0;

---

## **Key SQL Concepts Covered**

This project provided hands-on experience with a wide array of SQL features, including:

* **Data Joins**: Inner, Left, and Self-Joins to combine data from multiple tables.  
* **Aggregate Functions**: `SUM`, `COUNT`, `AVG`, `MIN`, and `MAX`.  
* **Grouping & Filtering**: `GROUP BY` and `HAVING` to perform aggregations on specific groups.  
* **Subqueries & CTEs**: Using `WITH` clauses for complex, multi-step queries.  
* **Conditional Logic**: Employing `CASE` statements for data categorization.  
* **Window Functions**:  
  * `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, and `NTILE()` for ranking and distribution analysis.  
  * `LAG()` and `LEAD()` for comparing current rows with previous or next rows.  
  * Calculating running totals and rolling averages.  
* **Date & String Manipulation**: Functions like `DATE_TRUNC`, `EXTRACT`, and `CONCAT` for data formatting.  
* **Data Modification**: `UPDATE` statements to modify existing data.


-- Question 1

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

-- Question 2

SELECT specialization,
ROUND(AVG(years_experience),2) AS average_years_experience
FROM doctors
GROUP BY 1
ORDER BY 2 DESC

-- Question 3

SELECT status,
COUNT(appointment_id) AS total_appointments
FROM appointments
GROUP BY 1
ORDER BY 2 DESC

-- Question 4

SELECT payment_method, payment_status,
SUM(amount) AS total_billed
FROM billing
GROUP BY 1, 2
ORDER BY 1, 2


-- Question 5

SELECT D.specialization,
COUNT(A.appointment_id) AS no_of_app
FROM appointments AS A
INNER JOIN doctors AS D
ON D.doctor_id = A.doctor_id
GROUP BY 1
ORDER BY 2 DESC

-- Question 6

SELECT D.hospital_branch,
COUNT(DISTINCT A.patient_id) AS unique_patient
FROM appointments AS A
INNER JOIN doctors AS D
ON D.doctor_id = A.doctor_id
GROUP BY 1
ORDER BY 2 DESC

-- Question 7

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

-- Question 8

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

-- Question 9

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

-- Question 10

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

-- Question 11

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

-- Question 12

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

-- Question 13

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


-- Question 14

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

-- Question 15

UPDATE patients SET insurance_provider = 'HDFC LIFE'
WHERE patient_id = 'P001'

-- Question 16

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






















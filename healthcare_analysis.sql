/*
Healthcare Data Analysis Portfolio Project
Dialect: Microsoft SQL Server (T-SQL)
Dataset: healthcare_dataset_copy.csv (10,000 rows; 15 columns)
IMPORTANT: This is a public/sample dataset for portfolio practice, not a live clinical database.
Run after importing the CSV into a table named dbo.healthcare_dataset_copy.
*/

-- 1. Dataset size
SELECT COUNT(*) AS total_records
FROM dbo.healthcare_dataset_copy;

-- 2. Basic age statistics
SELECT
    MIN(Age) AS minimum_age,
    MAX(Age) AS maximum_age,
    CAST(AVG(CAST(Age AS decimal(10,2))) AS decimal(10,2)) AS average_age
FROM dbo.healthcare_dataset_copy;

-- 3. Patient records by age
SELECT Age, COUNT(*) AS patient_count
FROM dbo.healthcare_dataset_copy
GROUP BY Age
ORDER BY Age DESC;

-- 4. Most frequent ages, including ties
SELECT Age, COUNT(*) AS patient_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Age
ORDER BY frequency_rank, Age DESC;

-- 5. Medication counts by medical condition
SELECT Medical_Condition, Medication, COUNT(*) AS record_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Medical_Condition, Medication
ORDER BY frequency_rank, Medical_Condition, Medication;

-- 6. Records by insurance provider
SELECT Insurance_Provider, COUNT(*) AS record_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Insurance_Provider
ORDER BY record_count DESC, Insurance_Provider;

-- 7. Records by hospital
SELECT Hospital, COUNT(*) AS record_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Hospital
ORDER BY record_count DESC, Hospital;

-- 8. Average billed amount by medical condition
SELECT Medical_Condition,
       CAST(AVG(Billing_Amount) AS decimal(12,2)) AS average_billing_amount,
       DENSE_RANK() OVER (ORDER BY AVG(Billing_Amount) DESC) AS cost_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Medical_Condition
ORDER BY average_billing_amount DESC;

-- 9. Length of stay by record and hospital-level average
-- DATEDIFF counts date boundaries crossed; interpret as calendar-day difference.
WITH stay_data AS (
    SELECT Hospital, Medical_Condition, Name,
           DATEDIFF(DAY,
                    TRY_CONVERT(date, Date_of_Admission, 105),
                    TRY_CONVERT(date, Discharge_Date, 105)) AS length_of_stay_days,
           Billing_Amount
    FROM dbo.healthcare_dataset_copy
)
SELECT Hospital, Medical_Condition, Name, length_of_stay_days, Billing_Amount,
       CAST(AVG(CAST(length_of_stay_days AS decimal(10,2)))
            OVER (PARTITION BY Hospital) AS decimal(10,2)) AS hospital_avg_stay_days
FROM stay_data
ORDER BY Hospital, length_of_stay_days DESC;

-- 10. Test-result counts by condition (descriptive only; not a measure of hospital success)
SELECT Medical_Condition, Test_Results, COUNT(*) AS record_count
FROM dbo.healthcare_dataset_copy
GROUP BY Medical_Condition, Test_Results
ORDER BY Medical_Condition, record_count DESC;

-- 11. Blood type distribution for ages 20 to 45
SELECT Age, [Blood Type] AS Blood_Type, COUNT(*) AS record_count
FROM dbo.healthcare_dataset_copy
WHERE Age BETWEEN 20 AND 45
GROUP BY Age, [Blood Type]
ORDER BY record_count DESC, Age;

-- 12. Blood type record counts (not a clinical donor eligibility assessment)
SELECT [Blood Type] AS Blood_Type, COUNT(*) AS record_count
FROM dbo.healthcare_dataset_copy
GROUP BY [Blood Type]
ORDER BY record_count DESC;

-- 13. Admission counts by year and hospital
-- The original notes mentioned 2024 and 2025, but the original SQL filtered 2019 and 2023.
-- This version uses 2024 and 2025 as described in the notes. Change years if needed.
SELECT Hospital, YEAR(TRY_CONVERT(date, Date_of_Admission, 105)) AS admission_year,
       COUNT(*) AS admission_count
FROM dbo.healthcare_dataset_copy
WHERE YEAR(TRY_CONVERT(date, Date_of_Admission, 105)) IN (2024, 2025)
GROUP BY Hospital, YEAR(TRY_CONVERT(date, Date_of_Admission, 105))
ORDER BY admission_year, admission_count DESC;

-- 14. Billing summary by insurance provider
SELECT Insurance_Provider,
       CAST(AVG(Billing_Amount) AS decimal(12,2)) AS average_billing,
       CAST(MIN(Billing_Amount) AS decimal(12,2)) AS minimum_billing,
       CAST(MAX(Billing_Amount) AS decimal(12,2)) AS maximum_billing,
       CAST(SUM(Billing_Amount) AS decimal(16,2)) AS total_billing
FROM dbo.healthcare_dataset_copy
GROUP BY Insurance_Provider
ORDER BY total_billing DESC;

-- 15. Descriptive test-result grouping.
-- These labels are not a validated medical risk score and must not guide patient care.
SELECT Name, Medical_Condition, Test_Results,
       CASE
           WHEN Test_Results = 'Inconclusive' THEN 'Requires clinical review'
           WHEN Test_Results = 'Abnormal' THEN 'Requires clinical review'
           WHEN Test_Results = 'Normal' THEN 'Normal result recorded'
           ELSE 'Unknown result'
       END AS descriptive_followup_category
FROM dbo.healthcare_dataset_copy;

-- 16. Total billed amount by insurance provider
SELECT Insurance_Provider,
       CAST(SUM(Billing_Amount) AS decimal(16,2)) AS total_billing_amount
FROM dbo.healthcare_dataset_copy
GROUP BY Insurance_Provider
ORDER BY total_billing_amount DESC;

/*
Safety note:
The original Blood_Matcher procedure pairs O- and AB+ records by name/hospital/age.
That is not sufficient to establish donor eligibility or blood compatibility and must
not be used for real donor matching. Clinical blood transfusion decisions require
validated protocols and qualified professionals. It has therefore not been reproduced
as a production procedure in this reviewed script.
*/

/*
Healthcare Data Analysis Portfolio Project
Dialect: Microsoft SQL Server (T-SQL)
Dataset: healthcare_dataset_copy.csv (10,000 rows; 15 columns)
IMPORTANT: This is a public/sample dataset for portfolio practice, not a live clinical database.
Run after importing the CSV into a table named dbo.healthcare_dataset_copy.
*/
USE PortfolioProject01;

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
-- Findings : The output will display a list of unique ages present in the "Healthcare" table along with the count of occurrences for each age, sorted from oldest 	to youngest.

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

-- Findings : This query retrieves a breakdown of medical conditions recorded in a healthcare dataset along with the total number of patients diagnosed with each condition. It groups the data by distinct medical conditions, counting the occurrences of each condition across the dataset. The result is presented in descending order based on the total number of patients affected by each medical condition, providing an insight into the prevalence or frequency of various health issues within the dataset

-- 6. Records by insurance provider
SELECT Insurance_Provider, COUNT(*) AS record_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Insurance_Provider
ORDER BY record_count DESC, Insurance_Provider;

-- Findings : This information helps identify the most prevalent insurance providers among the patient population, offering valuable data for resource allocation, understanding coverage preferences, and potentially indicating trends in healthcare accessibility based on insurance networks


-- 7. Records by hospital
SELECT Hospital, COUNT(*) AS record_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Hospital
ORDER BY record_count DESC, Hospital;


-- Finding : The output provides insight into the most common medications used for various medical conditions, assigning a rank to each medication based on how frequently its prescribed within its corresponding condition.

-- 8. Average billed amount by medical condition
SELECT Medical_Condition,
       CAST(AVG(Billing_Amount) AS decimal(12,2)) AS average_billing_amount,
       DENSE_RANK() OVER (ORDER BY AVG(Billing_Amount) DESC) AS cost_rank
FROM dbo.healthcare_dataset_copy
GROUP BY Medical_Condition
ORDER BY average_billing_amount DESC;

-- Findings :  It offers insights into the typical costs associated with various medical conditions. This information can be valuable for analyzing the financial impact of different health issues, identifying expensive conditions, or assisting in resource allocation within healthcare facilities.

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

-- Findings : This query retrieves a dataset showing the names of patients, their respective medical conditions, billed amounts (rounded to two decimal places), the hospitals they visited, and the duration of their hospital stay in days. Insights gleaned include: 
		-- Individual Patient Details: It presents a comprehensive view of patients, their medical conditions, billed amounts, and hospitals involved, aiding in understanding the scope of medical services availed by patients.
		-- Financial Overview: The rounded billing amounts provide an overview of the costs incurred by patients for their treatments, assisting in analyzing the financial aspect of healthcare services.
		-- Hospital Performance: By knowing the length of hospital stays, an evaluation of the efficiency of hospitals in managing patient care and treatment duration is possible.
		-- Potential Patterns: Patterns in medical conditions, billed amounts, and duration of hospitalization may emerge, offering insights into prevalent health issues and associated costs in the healthcare dataset.

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

-- Findings: This query filters healthcare data for individuals aged between 20 and 45, grouping them by their age and blood type. It then counts the occurrences of each blood type within this age range. The output provides a breakdown of blood type distribution among individuals aged 20 to 45, revealing the prevalence of different blood types within this specific age bracket. The results may offer insights into any potential correlations between age groups and blood type occurrences within the dataset.

-- 12. Blood type record counts (not a clinical donor eligibility assessment)
SELECT [Blood Type] AS Blood_Type, COUNT(*) AS record_count
FROM dbo.healthcare_dataset_copy
GROUP BY [Blood Type]
ORDER BY record_count DESC;

-- Findings : This query extracts specific counts of individuals with particular blood types ('O-' and 'AB+') from the healthcare dataset. It compares the count of 'O-' blood type individuals (considered universal donors) against the count of 'AB+' blood type individuals (considered universal recipients). The result showcases the stark contrast in the prevalence of these two blood types within the dataset, highlighting the potential availability of universal donors compared to universal recipients.

-- 13. Admission counts by year and hospital
-- The original notes mentioned 2024 and 2025, but the original SQL filtered 2019 and 2023.
-- This version uses 2024 and 2025 as described in the notes. Change years if needed.
SELECT Hospital, YEAR(TRY_CONVERT(date, Date_of_Admission, 105)) AS admission_year,
       COUNT(*) AS admission_count
FROM dbo.healthcare_dataset_copy
WHERE YEAR(TRY_CONVERT(date, Date_of_Admission, 105)) IN (2024, 2025)
GROUP BY Hospital, YEAR(TRY_CONVERT(date, Date_of_Admission, 105))
ORDER BY admission_year, admission_count DESC;

-- Findings : This query provides insights into the total admissions in different hospitals for the years 2024 and 2025. It retrieves the count of distinct admissions per hospital within the specified timeframe. The results are ordered in descending order based on the total number of admissions, highlighting hospitals with the highest influx of patients during these years. This data can aid in identifying healthcare facilities experiencing higher patient volumes across the specified period, aiding in resource allocation or further analysis of healthcare demand.

-- 14. Billing summary by insurance provider
SELECT Insurance_Provider,
       CAST(AVG(Billing_Amount) AS decimal(12,2)) AS average_billing,
       CAST(MIN(Billing_Amount) AS decimal(12,2)) AS minimum_billing,
       CAST(MAX(Billing_Amount) AS decimal(12,2)) AS maximum_billing,
       CAST(SUM(Billing_Amount) AS decimal(16,2)) AS total_billing
FROM dbo.healthcare_dataset_copy
GROUP BY Insurance_Provider
ORDER BY total_billing DESC;

-- Findings : This query provides insights into billing amounts across different insurance providers in the healthcare dataset. It calculates the average, minimum, and maximum billing amounts per insurance provider. By examining these metrics, we can understand the typical billing amount range associated with each insurance provider. This information helps identify patterns in healthcare expenses linked to specific insurance companies, highlighting variations in billing practices or potential cost disparities among providers.

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

	-- Findings : This query provides a summary of patients status based on their test results for various medical conditions. 
	--It categorizes patients into distinct statuses: those requiring additional checks and unable to be discharged due to inconclusive results,
	-- individuals fit for discharge but needing strict adherence to prescribed medications for normal results, and those needing more 
	--attention and further tests for abnormal findings. It also displays associated details like the patient's name, hospital, 
	--and attending doctor, offering an overview of patient conditions, discharge possibilities, and necessary follow-up actions.

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

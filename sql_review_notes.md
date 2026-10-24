# SQL Project Review Notes

## What is already good
- The project covers multiple analysis categories: dataset overview, age distribution, medication and condition counts, hospital/insurance counts, billing summaries, length of stay, blood-type counts, and a stored procedure.
- It uses useful SQL concepts including `GROUP BY`, aggregate functions, `CASE`, window functions (`RANK`, `DENSE_RANK`), `DATEDIFF`, and a stored procedure.
- The project notes explain the dataset columns and intended analysis areas.

## Issues to fix or explain
1. **Year filter mismatch:** The notes say 2024 and 2025, but the original query filters 2019 and 2023. The reviewed query uses 2024 and 2025 to match the notes.
2. **Hospital total calculation:** The original windowed `SUM(Billing_Amount) OVER (PARTITION BY Hospital ORDER BY Hospital DESC)` is an ordered running total, not a clearly defined hospital total, and the ordering is not useful. The reviewed query instead shows individual billing and hospital average length of stay.
3. **“Successful discharge after normal test” claim:** A `Normal` test result plus the discharge date does not prove that the hospital caused a successful outcome or how long it took for the result to become normal. The data only has the recorded result and dates.
4. **Risk categorisation:** The original labels do not actually classify high, medium, and low risk based on a validated medical model. They map test-result text to follow-up descriptions. The reviewed version uses neutral descriptive labels.
5. **Blood matcher procedure:** The original procedure pairs records with O- and AB+ blood types and age/hospital constraints. These conditions are not enough to determine actual donor eligibility or safe transfusion matching. The reviewed file deliberately does not reproduce this as an operational procedure.
6. **Procedure logic:** The original comment says same-hospital matches have priority, but the filter `D.Hospital <> R.Hospital` excludes same-hospital pairs. This contradicts the comment.
7. **Date parsing:** The source CSV dates are strings in `dd-mm-yyyy` form. Confirm the SQL Server import and date type before running `DATEDIFF` or `YEAR`.
8. **Names and privacy:** The dataset includes patient-name-like values. If publishing the project, remove the Name column from any exported results and use aggregate outputs.
9. **Interpretation:** Counts of hospital records are not evidence that patients prefer a hospital; the dataset may not represent actual hospital choice. Similarly, billing differences do not establish value or quality of care.

## Recommended additions for internship readiness
- Add 4–6 business questions and a short finding for each, based on query outputs you have actually run.
- Add a small ER/schema diagram or a data dictionary.
- Add screenshots of query results with names hidden.
- Add one dashboard in Power BI or Excel if you want a stronger analytics portfolio.
- Include a short section on limitations and ethical handling of healthcare data.
- State the SQL dialect as Microsoft SQL Server (T-SQL), because the original uses `USE`, `dbo`, `DATEDIFF`, `CREATE OR ALTER PROCEDURE`, and `GO`.

## Accuracy note
This review checks the query text and CSV structure, but the SQL queries have not been executed against your SQL Server database here. Validate them in your own SQL Server environment before publishing.

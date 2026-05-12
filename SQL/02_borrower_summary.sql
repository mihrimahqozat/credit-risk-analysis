-- Borrower demographics and financial profile by default status
WITH borrower_profile AS (
    SELECT
        serious_dlqin2yrs,
        CASE
            WHEN age BETWEEN 18 AND 29 THEN '18-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END                                                 AS age_group,
        CASE
            WHEN monthly_income < 3000  THEN 'Low (<$3K)'
            WHEN monthly_income < 6000  THEN 'Middle ($3K-$6K)'
            WHEN monthly_income < 10000 THEN 'Upper Middle ($6K-$10K)'
            ELSE 'High (>$10K)'
        END                                                 AS income_tier,
        ROUND(AVG(revolving_utilization)::NUMERIC, 4)      AS avg_utilization,
        ROUND(AVG(debt_ratio)::NUMERIC, 4)                 AS avg_debt_ratio,
        ROUND(AVG(monthly_income)::NUMERIC, 2)             AS avg_monthly_income,
        ROUND(AVG(number_open_credit_lines)::NUMERIC, 2)   AS avg_credit_lines,
        ROUND(AVG(number_dependents)::NUMERIC, 2)          AS avg_dependents,
        COUNT(*)                                            AS total_borrowers
    FROM borrowers
    GROUP BY serious_dlqin2yrs, age_group, income_tier
)
SELECT *,
    ROUND(total_borrowers * 100.0 /
        SUM(total_borrowers) OVER (
            PARTITION BY age_group), 2)                    AS pct_within_age_group
FROM borrower_profile
ORDER BY age_group, income_tier, serious_dlqin2yrs;
-- Borrower risk ranking with percentiles and cumulative defaults
WITH borrower_scores AS (
    SELECT
        borrower_id,
        age,
        monthly_income,
        revolving_utilization,
        debt_ratio,
        times_90_days_late,
        serious_dlqin2yrs,
        CASE WHEN revolving_utilization > 0.75  THEN 3
             WHEN revolving_utilization > 0.50  THEN 2
             WHEN revolving_utilization > 0.25  THEN 1
             ELSE 0 END +
        CASE WHEN debt_ratio > 0.50             THEN 2
             WHEN debt_ratio > 0.35             THEN 1
             ELSE 0 END +
        CASE WHEN times_90_days_late > 0        THEN 3
             ELSE 0 END +
        CASE WHEN times_60_89_days_late > 0     THEN 2
             ELSE 0 END +
        CASE WHEN times_30_59_days_late > 1     THEN 2
             WHEN times_30_59_days_late = 1     THEN 1
             ELSE 0 END +
        CASE WHEN monthly_income < 3000         THEN 2
             WHEN monthly_income < 5000         THEN 1
             ELSE 0 END +
        CASE WHEN age < 25                      THEN 1
             ELSE 0 END                                   AS risk_score
    FROM borrowers
)
SELECT
    borrower_id,
    age,
    ROUND(monthly_income::NUMERIC, 2)                     AS monthly_income,
    revolving_utilization,
    debt_ratio,
    risk_score,
    serious_dlqin2yrs,
    RANK() OVER (ORDER BY risk_score DESC)                 AS risk_rank,
    NTILE(10) OVER (ORDER BY risk_score DESC)              AS risk_decile,
    ROUND(AVG(risk_score) OVER (
        ORDER BY risk_score DESC
        ROWS BETWEEN 2 PRECEDING
        AND 2 FOLLOWING)::NUMERIC, 2)                      AS smoothed_risk_score,
    ROUND(SUM(serious_dlqin2yrs::NUMERIC) OVER (
        ORDER BY risk_score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW), 0)                               AS cumulative_defaults
FROM borrower_scores
ORDER BY risk_rank
LIMIT 100;
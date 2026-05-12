-- Rule-based credit risk scoring system
WITH risk_factors AS (
    SELECT
        borrower_id,
        serious_dlqin2yrs,
        age,
        monthly_income,
        revolving_utilization,
        debt_ratio,
        -- Assign risk points based on credit risk indicators
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
),
risk_tiered AS (
    SELECT *,
        CASE
            WHEN risk_score >= 7  THEN 'Very High Risk'
            WHEN risk_score >= 5  THEN 'High Risk'
            WHEN risk_score >= 3  THEN 'Medium Risk'
            ELSE 'Low Risk'
        END                                               AS risk_tier
    FROM risk_factors
)
SELECT
    risk_tier,
    COUNT(*)                                              AS total_borrowers,
    SUM(serious_dlqin2yrs)                                AS actual_defaults,
    ROUND(SUM(serious_dlqin2yrs) * 100.0 /
        NULLIF(COUNT(*), 0), 2)                           AS default_rate_pct,
    ROUND(AVG(monthly_income)::NUMERIC, 2)                AS avg_monthly_income,
    ROUND(AVG(revolving_utilization)::NUMERIC, 4)         AS avg_utilization,
    ROUND(AVG(debt_ratio)::NUMERIC, 4)                    AS avg_debt_ratio,
    ROUND(AVG(risk_score)::NUMERIC, 2)                    AS avg_risk_score
FROM risk_tiered
GROUP BY risk_tier
ORDER BY avg_risk_score DESC;
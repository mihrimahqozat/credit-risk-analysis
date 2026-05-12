-- Default rate by age group and delinquency history
WITH delinquency_stats AS (
    SELECT
        CASE
            WHEN age BETWEEN 18 AND 29 THEN '18-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END                                                AS age_group,
        COUNT(*)                                           AS total_borrowers,
        SUM(serious_dlqin2yrs)                             AS total_defaults,
        ROUND(AVG(revolving_utilization)::NUMERIC, 4)      AS avg_utilization,
        ROUND(AVG(debt_ratio)::NUMERIC, 4)                 AS avg_debt_ratio,
        ROUND(AVG(monthly_income)::NUMERIC, 2)             AS avg_monthly_income,
        SUM(times_30_59_days_late)                         AS total_30_59_late,
        SUM(times_60_89_days_late)                         AS total_60_89_late,
        SUM(times_90_days_late)                            AS total_90_plus_late
    FROM borrowers
    GROUP BY age_group
)
SELECT *,
    ROUND(total_defaults * 100.0 /
        NULLIF(total_borrowers, 0), 2)                     AS default_rate_pct,
    RANK() OVER (ORDER BY
        total_defaults * 100.0 /
        NULLIF(total_borrowers, 0) DESC)                   AS default_rank
FROM delinquency_stats
ORDER BY default_rank;
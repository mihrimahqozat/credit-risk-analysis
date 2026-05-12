DROP TABLE IF EXISTS borrowers;

CREATE TABLE borrowers (
    borrower_id                         SERIAL PRIMARY KEY,
    serious_dlqin2yrs                   INTEGER,
    revolving_utilization               NUMERIC(10, 6),
    age                                 INTEGER,
    times_30_59_days_late               INTEGER,
    debt_ratio                          NUMERIC(10, 6),
    monthly_income                      NUMERIC(15, 2),
    number_open_credit_lines            INTEGER,
    times_90_days_late                  INTEGER,
    number_real_estate_loans            INTEGER,
    times_60_89_days_late               INTEGER,
    number_dependents                   NUMERIC(5, 1)
);
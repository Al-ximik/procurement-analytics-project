-- 08_monthly_trends.sql
-- Monthly spend, savings, previous-month spend and MoM change using LAG().

USE procurement_analytics;

WITH monthly_performance AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month_label,
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS month_start,
        COUNT(*) AS procurement_count,
        SUM(actual_total_azn) AS total_spend,
        SUM(estimated_total_azn) AS estimated_spend,
        SUM(savings_azn) AS total_savings
    FROM vw_procurement_clean
    GROUP BY
        DATE_FORMAT(order_date, '%Y-%m'),
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE)
),
monthly_with_previous AS (
    SELECT
        month_label,
        month_start,
        procurement_count,
        total_spend,
        estimated_spend,
        total_savings,
        LAG(total_spend) OVER (ORDER BY month_start) AS previous_month_spend
    FROM monthly_performance
)
SELECT
    month_label,
    procurement_count,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(estimated_spend, 2) AS estimated_spend,
    ROUND(total_savings, 2) AS total_savings,
    ROUND(previous_month_spend, 2) AS previous_month_spend,
    ROUND(
        (total_spend - previous_month_spend)
        / NULLIF(previous_month_spend, 0) * 100,
        2
    ) AS mom_spend_change_pct
FROM monthly_with_previous
ORDER BY month_start;

-- Top 5 monthly increases
WITH monthly_spend AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month_label,
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS month_start,
        SUM(actual_total_azn) AS total_spend
    FROM vw_procurement_clean
    GROUP BY
        DATE_FORMAT(order_date, '%Y-%m'),
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE)
),
monthly_change AS (
    SELECT
        month_label,
        month_start,
        total_spend,
        LAG(total_spend) OVER (ORDER BY month_start) AS previous_month_spend
    FROM monthly_spend
)
SELECT
    month_label,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(previous_month_spend, 2) AS previous_month_spend,
    ROUND((total_spend - previous_month_spend) / NULLIF(previous_month_spend, 0) * 100, 2) AS mom_change_pct
FROM monthly_change
WHERE previous_month_spend IS NOT NULL
ORDER BY mom_change_pct DESC
LIMIT 5;

-- Top 5 monthly decreases
WITH monthly_spend AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month_label,
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS month_start,
        SUM(actual_total_azn) AS total_spend
    FROM vw_procurement_clean
    GROUP BY
        DATE_FORMAT(order_date, '%Y-%m'),
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE)
),
monthly_change AS (
    SELECT
        month_label,
        month_start,
        total_spend,
        LAG(total_spend) OVER (ORDER BY month_start) AS previous_month_spend
    FROM monthly_spend
)
SELECT
    month_label,
    ROUND(total_spend, 2) AS total_spend,
    ROUND((total_spend - previous_month_spend) / NULLIF(previous_month_spend, 0) * 100, 2) AS mom_change_pct
FROM monthly_change
WHERE previous_month_spend IS NOT NULL
ORDER BY mom_change_pct ASC
LIMIT 5;

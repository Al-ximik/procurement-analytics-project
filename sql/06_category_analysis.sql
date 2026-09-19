-- 06_category_analysis.sql
-- Category performance using JOIN, CTE, and RANK().

USE procurement_analytics;

SELECT
    c.category,
    COUNT(*) AS procurement_count,
    ROUND(SUM(v.actual_total_azn), 2) AS total_spend,
    ROUND(SUM(v.savings_azn), 2) AS total_savings,
    ROUND(
        SUM(v.savings_azn)
        / NULLIF(SUM(v.estimated_total_azn), 0) * 100,
        2
    ) AS savings_pct
FROM vw_procurement_clean v
INNER JOIN categories c
    ON v.category_id = c.category_id
GROUP BY c.category
ORDER BY total_spend DESC;

WITH category_performance AS (
    SELECT
        c.category,
        COUNT(*) AS procurement_count,
        SUM(v.actual_total_azn) AS total_spend,
        SUM(v.savings_azn) AS total_savings,
        SUM(v.estimated_total_azn) AS estimated_spend
    FROM vw_procurement_clean v
    INNER JOIN categories c
        ON v.category_id = c.category_id
    GROUP BY c.category
)
SELECT
    category,
    procurement_count,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(total_savings, 2) AS total_savings,
    ROUND(total_savings / NULLIF(estimated_spend, 0) * 100, 2) AS savings_pct,
    RANK() OVER (ORDER BY total_savings DESC) AS savings_rank
FROM category_performance
ORDER BY savings_rank;

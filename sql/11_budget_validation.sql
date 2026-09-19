-- 11_budget_validation.sql
-- IMPORTANT: This script is a data-validation exercise, not a validated budget-performance conclusion.
-- The department annual_budget_azn values appear to be on a different scale/definition from procurement spend.

USE procurement_analytics;

SELECT
    department_id,
    department_name,
    annual_budget_azn,
    primary_region
FROM departments
ORDER BY annual_budget_azn DESC;

-- Compare annual procurement spend with the combined department budget.
SELECT
    YEAR(v.order_date) AS spend_year,
    ROUND(SUM(v.actual_total_azn), 2) AS total_procurement_spend,
    ROUND(SUM(DISTINCT d.annual_budget_azn), 2) AS combined_department_budget
FROM vw_procurement_clean v
INNER JOIN departments d
    ON v.department_id = d.department_id
GROUP BY YEAR(v.order_date)
ORDER BY spend_year;

-- Observed combined department budget: 18.15M AZN.
-- Annual procurement spend is substantially larger, so utilization percentages
-- should not be treated as validated budget overruns without clarifying the business definition.

-- 03_data_quality_checks.sql
-- Baseline profiling of the raw transaction table.

USE procurement_analytics;

SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS missing_supplier,
    SUM(CASE WHEN estimated_unit_price_azn IS NULL THEN 1 ELSE 0 END) AS missing_estimate,
    SUM(
        CASE
            WHEN status = 'Completed' AND actual_delivery_date IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_delivery_date,
    SUM(
        CASE
            WHEN status = 'Completed' AND quality_score IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_quality_score
FROM procurement_transactions_raw;

-- Expected results:
-- total_transactions      = 10000
-- missing_supplier        = 59
-- missing_estimate        = 68
-- missing_delivery_date   = 21
-- missing_quality_score   = 28

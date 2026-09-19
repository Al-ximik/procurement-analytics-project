-- 05_kpi_analysis.sql
-- Core KPIs and procurement-method performance.

USE procurement_analytics;

-- Executive KPI summary
SELECT
    ROUND(SUM(actual_total_azn), 2) AS total_spend,
    ROUND(SUM(estimated_total_azn), 2) AS estimated_spend,
    ROUND(SUM(savings_azn), 2) AS total_savings,
    ROUND(SUM(savings_azn) / NULLIF(SUM(estimated_total_azn), 0) * 100, 2) AS savings_pct,
    COUNT(DISTINCT procurement_id) AS procurement_count,
    COUNT(DISTINCT CASE
        WHEN supplier_id_clean <> 'SUP-UNKNOWN' THEN supplier_id_clean
    END) AS active_supplier_count
FROM vw_procurement_clean;

-- Like-for-like actual spend where an estimate exists
SELECT
    ROUND(SUM(CASE
        WHEN estimate_data_status = 'Available' THEN actual_total_azn
    END), 2) AS comparable_actual_spend,
    ROUND(SUM(estimated_total_azn), 2) AS estimated_spend,
    ROUND(SUM(savings_azn), 2) AS total_savings
FROM vw_procurement_clean;

-- Estimate coverage
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN estimate_data_status = 'Available' THEN 1 ELSE 0 END) AS transactions_with_estimate,
    ROUND(
        SUM(CASE WHEN estimate_data_status = 'Available' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS estimate_coverage_pct
FROM vw_procurement_clean;

-- Procurement method performance
SELECT
    procurement_method,
    COUNT(*) AS procurement_count,
    ROUND(SUM(actual_total_azn), 2) AS total_spend,
    ROUND(SUM(savings_azn), 2) AS total_savings,
    ROUND(
        SUM(savings_azn) / NULLIF(SUM(estimated_total_azn), 0) * 100,
        2
    ) AS savings_pct
FROM vw_procurement_clean
GROUP BY procurement_method
ORDER BY total_savings DESC;

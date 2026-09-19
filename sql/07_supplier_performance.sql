-- 07_supplier_performance.sql
-- Supplier delivery, quality, savings, spend, and ranking.

USE procurement_analytics;

SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.risk_level,
    COUNT(*) AS procurement_count,
    ROUND(SUM(v.actual_total_azn), 2) AS total_spend,
    ROUND(SUM(v.savings_azn), 2) AS total_savings,
    ROUND(AVG(v.quality_score), 2) AS avg_quality_score,
    SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
    SUM(CASE WHEN v.delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(
        SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN v.delivery_status IN ('On Time', 'Late') THEN 1 ELSE 0 END),
            0
        ) * 100,
        2
    ) AS on_time_delivery_pct
FROM vw_procurement_clean v
INNER JOIN suppliers s
    ON v.supplier_id_clean = s.supplier_id
WHERE v.supplier_id_clean <> 'SUP-UNKNOWN'
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.risk_level
ORDER BY total_spend DESC;

WITH supplier_performance AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.risk_level,
        COUNT(*) AS procurement_count,
        SUM(v.actual_total_azn) AS total_spend,
        AVG(v.quality_score) AS avg_quality_score,
        SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
        SUM(CASE WHEN v.delivery_status IN ('On Time', 'Late') THEN 1 ELSE 0 END) AS completed_with_delivery
    FROM vw_procurement_clean v
    INNER JOIN suppliers s
        ON v.supplier_id_clean = s.supplier_id
    WHERE v.supplier_id_clean <> 'SUP-UNKNOWN'
    GROUP BY s.supplier_id, s.supplier_name, s.risk_level
)
SELECT
    supplier_id,
    supplier_name,
    risk_level,
    procurement_count,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(avg_quality_score, 2) AS avg_quality_score,
    ROUND(on_time_deliveries / NULLIF(completed_with_delivery, 0) * 100, 2) AS on_time_delivery_pct,
    RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM supplier_performance
ORDER BY spend_rank;

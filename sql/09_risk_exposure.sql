-- 09_risk_exposure.sql
-- High-risk supplier exposure by procurement category.

USE procurement_analytics;

SELECT
    c.category,
    COUNT(DISTINCT s.supplier_id) AS high_risk_supplier_count,
    COUNT(v.procurement_id) AS procurement_count,
    ROUND(SUM(v.actual_total_azn), 2) AS high_risk_spend,
    ROUND(
        SUM(v.actual_total_azn)
        / NULLIF(SUM(SUM(v.actual_total_azn)) OVER (), 0) * 100,
        2
    ) AS share_of_high_risk_spend_pct,
    ROUND(AVG(v.quality_score), 2) AS avg_quality_score,
    ROUND(
        SUM(CASE WHEN v.delivery_status = 'Late' THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN v.delivery_status IN ('Late', 'On Time') THEN 1 ELSE 0 END),
            0
        ) * 100,
        2
    ) AS late_delivery_pct
FROM vw_procurement_clean v
INNER JOIN suppliers s
    ON v.supplier_id_clean = s.supplier_id
INNER JOIN categories c
    ON v.category_id = c.category_id
WHERE s.risk_level = 'High'
GROUP BY c.category
ORDER BY high_risk_spend DESC;

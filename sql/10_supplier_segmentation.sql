-- 10_supplier_segmentation.sql
-- Segments suppliers using delivery and quality benchmarks,
-- then summarizes financial exposure by segment.

USE procurement_analytics;

WITH supplier_metrics AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.country,
        s.risk_level,
        COUNT(*) AS procurement_count,
        SUM(v.actual_total_azn) AS total_spend,
        AVG(v.quality_score) AS avg_quality_score,
        SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
        SUM(CASE WHEN v.delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_deliveries,
        SUM(CASE WHEN v.delivery_status IN ('On Time', 'Late') THEN 1 ELSE 0 END) AS delivery_observations
    FROM vw_procurement_clean v
    INNER JOIN suppliers s
        ON v.supplier_id_clean = s.supplier_id
    WHERE v.supplier_id_clean <> 'SUP-UNKNOWN'
    GROUP BY s.supplier_id, s.supplier_name, s.country, s.risk_level
),
supplier_scored AS (
    SELECT
        supplier_id,
        supplier_name,
        country,
        risk_level,
        procurement_count,
        total_spend,
        avg_quality_score,
        on_time_deliveries,
        late_deliveries,
        delivery_observations,
        on_time_deliveries / NULLIF(delivery_observations, 0) * 100 AS on_time_delivery_pct,
        late_deliveries / NULLIF(delivery_observations, 0) * 100 AS late_delivery_pct
    FROM supplier_metrics
)
SELECT
    supplier_id,
    supplier_name,
    country,
    risk_level,
    procurement_count,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(avg_quality_score, 2) AS avg_quality_score,
    ROUND(on_time_delivery_pct, 2) AS on_time_delivery_pct,
    ROUND(late_delivery_pct, 2) AS late_delivery_pct,
    CASE
        WHEN on_time_delivery_pct >= 50 AND avg_quality_score >= 4 THEN 'High Performer'
        WHEN on_time_delivery_pct < 50 AND avg_quality_score >= 4 THEN 'Delivery Risk'
        WHEN on_time_delivery_pct >= 50 AND avg_quality_score < 4 THEN 'Quality Risk'
        ELSE 'Critical Supplier'
    END AS supplier_segment
FROM supplier_scored
WHERE delivery_observations >= 10
ORDER BY
    CASE
        WHEN on_time_delivery_pct < 50 AND avg_quality_score < 4 THEN 1
        WHEN on_time_delivery_pct < 50 THEN 2
        WHEN avg_quality_score < 4 THEN 3
        ELSE 4
    END,
    total_spend DESC;

-- Segment summary
WITH supplier_metrics AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        SUM(v.actual_total_azn) AS total_spend,
        AVG(v.quality_score) AS avg_quality_score,
        SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
        SUM(CASE WHEN v.delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_deliveries,
        SUM(CASE WHEN v.delivery_status IN ('On Time', 'Late') THEN 1 ELSE 0 END) AS delivery_observations
    FROM vw_procurement_clean v
    INNER JOIN suppliers s
        ON v.supplier_id_clean = s.supplier_id
    WHERE v.supplier_id_clean <> 'SUP-UNKNOWN'
    GROUP BY s.supplier_id, s.supplier_name
),
supplier_scored AS (
    SELECT
        supplier_id,
        supplier_name,
        total_spend,
        avg_quality_score,
        delivery_observations,
        on_time_deliveries / NULLIF(delivery_observations, 0) * 100 AS on_time_delivery_pct
    FROM supplier_metrics
    WHERE delivery_observations >= 10
),
supplier_segmented AS (
    SELECT
        supplier_id,
        supplier_name,
        total_spend,
        CASE
            WHEN on_time_delivery_pct >= 50 AND avg_quality_score >= 4 THEN 'High Performer'
            WHEN on_time_delivery_pct < 50 AND avg_quality_score >= 4 THEN 'Delivery Risk'
            WHEN on_time_delivery_pct >= 50 AND avg_quality_score < 4 THEN 'Quality Risk'
            ELSE 'Critical Supplier'
        END AS supplier_segment
    FROM supplier_scored
)
SELECT
    supplier_segment,
    COUNT(*) AS supplier_count,
    ROUND(SUM(total_spend), 2) AS segment_spend,
    ROUND(
        SUM(total_spend) / SUM(SUM(total_spend)) OVER () * 100,
        2
    ) AS share_of_total_spend_pct,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_supplier
FROM supplier_segmented
GROUP BY supplier_segment
ORDER BY segment_spend DESC;

-- Top 10 critical suppliers by spend
WITH supplier_metrics AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.country,
        s.risk_level,
        SUM(v.actual_total_azn) AS total_spend,
        AVG(v.quality_score) AS avg_quality_score,
        SUM(CASE WHEN v.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
        SUM(CASE WHEN v.delivery_status IN ('On Time', 'Late') THEN 1 ELSE 0 END) AS delivery_observations
    FROM vw_procurement_clean v
    INNER JOIN suppliers s
        ON v.supplier_id_clean = s.supplier_id
    WHERE v.supplier_id_clean <> 'SUP-UNKNOWN'
    GROUP BY s.supplier_id, s.supplier_name, s.country, s.risk_level
),
supplier_scored AS (
    SELECT
        *,
        on_time_deliveries / NULLIF(delivery_observations, 0) * 100 AS on_time_delivery_pct
    FROM supplier_metrics
    WHERE delivery_observations >= 10
)
SELECT
    supplier_id,
    supplier_name,
    country,
    risk_level,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(avg_quality_score, 2) AS avg_quality_score,
    ROUND(on_time_delivery_pct, 2) AS on_time_delivery_pct
FROM supplier_scored
WHERE on_time_delivery_pct < 50
  AND avg_quality_score < 4
ORDER BY total_spend DESC
LIMIT 10;

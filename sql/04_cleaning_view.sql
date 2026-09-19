-- 04_cleaning_view.sql
-- Creates the analytical cleaning layer used by downstream SQL analysis.

USE procurement_analytics;

DROP VIEW IF EXISTS vw_procurement_clean;

CREATE VIEW vw_procurement_clean AS
SELECT
    procurement_id,
    order_date,
    department_id,
    category_id,

    COALESCE(NULLIF(TRIM(supplier_id), ''), 'SUP-UNKNOWN') AS supplier_id_clean,

    procurement_method,
    quantity,
    estimated_unit_price_azn,
    actual_unit_price_azn,
    contract_date,
    expected_delivery_date,
    actual_delivery_date,
    status,

    CASE UPPER(TRIM(region))
        WHEN 'BAKU' THEN 'Baku'
        WHEN 'ABSHERON' THEN 'Absheron'
        WHEN 'GANJA' THEN 'Ganja'
        WHEN 'SUMGAYIT' THEN 'Sumgayit'
        WHEN 'SHAKI' THEN 'Shaki'
        WHEN 'LANKARAN' THEN 'Lankaran'
        WHEN 'MINGACHEVIR' THEN 'Mingachevir'
        WHEN 'SHIRVAN' THEN 'Shirvan'
        ELSE TRIM(region)
    END AS region_clean,

    quality_score,

    CASE
        WHEN supplier_id IS NULL OR TRIM(supplier_id) = ''
        THEN 'Missing Supplier'
        ELSE 'Available'
    END AS supplier_data_status,

    CASE
        WHEN estimated_unit_price_azn IS NULL
        THEN 'Missing Estimate'
        ELSE 'Available'
    END AS estimate_data_status,

    CASE
        WHEN status = 'Completed' AND quality_score IS NULL
        THEN 'Missing Quality Score'
        ELSE 'Available'
    END AS quality_data_status,

    CASE
        WHEN estimated_unit_price_azn IS NULL THEN NULL
        ELSE quantity * estimated_unit_price_azn
    END AS estimated_total_azn,

    quantity * actual_unit_price_azn AS actual_total_azn,

    CASE
        WHEN estimated_unit_price_azn IS NULL THEN NULL
        ELSE (quantity * estimated_unit_price_azn)
             - (quantity * actual_unit_price_azn)
    END AS savings_azn,

    CASE
        WHEN estimated_unit_price_azn IS NULL
          OR quantity * estimated_unit_price_azn = 0
        THEN NULL
        ELSE (
            (quantity * estimated_unit_price_azn)
            - (quantity * actual_unit_price_azn)
        ) / (quantity * estimated_unit_price_azn)
    END AS savings_pct,

    CASE
        WHEN status <> 'Completed' OR actual_delivery_date IS NULL
        THEN NULL
        ELSE DATEDIFF(actual_delivery_date, expected_delivery_date)
    END AS delivery_delay_days,

    CASE
        WHEN status <> 'Completed' THEN 'Not Applicable'
        WHEN actual_delivery_date IS NULL THEN 'Missing Delivery Date'
        WHEN actual_delivery_date <= expected_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status

FROM procurement_transactions_raw;

-- Validate the view.
SELECT COUNT(*) AS clean_transactions
FROM vw_procurement_clean;

SELECT
    region_clean,
    COUNT(*) AS transaction_count
FROM vw_procurement_clean
GROUP BY region_clean
ORDER BY transaction_count DESC;

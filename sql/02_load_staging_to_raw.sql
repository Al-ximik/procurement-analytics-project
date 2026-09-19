-- 02_load_staging_to_raw.sql
-- Converts text staging values into properly typed MySQL fields.
-- Empty strings become NULL rather than causing rows to be rejected.

USE procurement_analytics;

SELECT COUNT(*) AS stage_transactions
FROM procurement_transactions_stage;
-- Expected: 10000

TRUNCATE TABLE procurement_transactions_raw;

INSERT INTO procurement_transactions_raw (
    procurement_id,
    order_date,
    department_id,
    category_id,
    supplier_id,
    procurement_method,
    quantity,
    estimated_unit_price_azn,
    actual_unit_price_azn,
    contract_date,
    expected_delivery_date,
    actual_delivery_date,
    status,
    region,
    quality_score
)
SELECT
    procurement_id,
    STR_TO_DATE(order_date, '%Y-%m-%d'),
    department_id,
    category_id,
    NULLIF(TRIM(supplier_id), ''),
    procurement_method,
    CAST(quantity AS UNSIGNED),
    CAST(NULLIF(TRIM(estimated_unit_price_azn), '') AS DECIMAL(18,2)),
    CAST(actual_unit_price_azn AS DECIMAL(18,2)),
    STR_TO_DATE(contract_date, '%Y-%m-%d'),
    STR_TO_DATE(expected_delivery_date, '%Y-%m-%d'),
    STR_TO_DATE(NULLIF(TRIM(actual_delivery_date), ''), '%Y-%m-%d'),
    status,
    region,
    CAST(NULLIF(TRIM(quality_score), '') AS DECIMAL(4,2))
FROM procurement_transactions_stage;

SELECT COUNT(*) AS transactions
FROM procurement_transactions_raw;
-- Expected: 10000

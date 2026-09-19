# Data Dictionary

## `procurement_transactions_raw`

| Column | Description |
|---|---|
| `procurement_id` | Unique procurement transaction ID |
| `order_date` | Procurement/order date |
| `department_id` | Department key |
| `category_id` | Category key |
| `supplier_id` | Supplier key; intentionally contains missing values |
| `procurement_method` | Open Tender, Request for Quotation, Framework Agreement, or Direct Purchase |
| `quantity` | Ordered quantity |
| `estimated_unit_price_azn` | Estimated unit price in AZN; intentionally contains missing values |
| `actual_unit_price_azn` | Actual unit price in AZN |
| `contract_date` | Contract date |
| `expected_delivery_date` | Expected delivery date |
| `actual_delivery_date` | Actual delivery date; may be missing |
| `status` | Completed, In Progress, Pending, or Cancelled |
| `region` | Raw region text with deliberate whitespace/case inconsistencies |
| `quality_score` | Quality score; completed transactions may contain missing values |

## `suppliers`

| Column | Description |
|---|---|
| `supplier_id` | Supplier key |
| `supplier_name` | Supplier name |
| `country` | Supplier country |
| `supplier_category` | Supplier category |
| `registration_date` | Supplier registration date |
| `risk_level` | Low, Medium, or High |

## `departments`

| Column | Description |
|---|---|
| `department_id` | Department key |
| `department_name` | Department name |
| `annual_budget_azn` | Annual budget field; scale/business definition requires validation |
| `primary_region` | Primary department region |

## `categories`

| Column | Description |
|---|---|
| `category_id` | Category key |
| `category` | Procurement category |
| `subcategory` | Procurement subcategory |
| `supplier_group` | Supplier group |

## Derived fields in `vw_procurement_clean`

| Field | Logic |
|---|---|
| `supplier_id_clean` | Missing supplier IDs replaced with `SUP-UNKNOWN` |
| `region_clean` | Trims and standardizes region text |
| `supplier_data_status` | Available / Missing Supplier |
| `estimate_data_status` | Available / Missing Estimate |
| `quality_data_status` | Available / Missing Quality Score |
| `estimated_total_azn` | Quantity × estimated unit price |
| `actual_total_azn` | Quantity × actual unit price |
| `savings_azn` | Estimated total − actual total |
| `savings_pct` | Savings ÷ estimated total |
| `delivery_delay_days` | Actual delivery date − expected delivery date |
| `delivery_status` | On Time / Late / Missing Delivery Date / Not Applicable |

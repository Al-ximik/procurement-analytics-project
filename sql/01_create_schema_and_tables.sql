-- 01_create_schema_and_tables.sql
-- MySQL 8.0
-- Creates the schema, dimension tables, a typed raw fact table,
-- and a text-based staging table used to preserve all CSV rows during import.

CREATE DATABASE IF NOT EXISTS procurement_analytics;
USE procurement_analytics;

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(150),
    country VARCHAR(50),
    supplier_category VARCHAR(100),
    registration_date DATE,
    risk_level VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS departments (
    department_id VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(150),
    annual_budget_azn DECIMAL(18,2),
    primary_region VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS categories (
    category_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100),
    subcategory VARCHAR(150),
    supplier_group VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS procurement_transactions_raw (
    procurement_id VARCHAR(30) PRIMARY KEY,
    order_date DATE,
    department_id VARCHAR(20),
    category_id VARCHAR(20),
    supplier_id VARCHAR(20),
    procurement_method VARCHAR(50),
    quantity INT,
    estimated_unit_price_azn DECIMAL(18,2),
    actual_unit_price_azn DECIMAL(18,2),
    contract_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status VARCHAR(30),
    region VARCHAR(50),
    quality_score DECIMAL(4,2)
);

DROP TABLE IF EXISTS procurement_transactions_stage;
CREATE TABLE procurement_transactions_stage (
    procurement_id VARCHAR(30),
    order_date VARCHAR(20),
    department_id VARCHAR(20),
    category_id VARCHAR(20),
    supplier_id VARCHAR(20),
    procurement_method VARCHAR(50),
    quantity VARCHAR(20),
    estimated_unit_price_azn VARCHAR(50),
    actual_unit_price_azn VARCHAR(50),
    contract_date VARCHAR(20),
    expected_delivery_date VARCHAR(20),
    actual_delivery_date VARCHAR(20),
    status VARCHAR(30),
    region VARCHAR(100),
    quality_score VARCHAR(20)
);

-- Next steps in MySQL Workbench:
-- 1) Import suppliers.csv -> suppliers
-- 2) Import departments.csv -> departments
-- 3) Import categories.csv -> categories
-- 4) Import procurement_transactions_raw.csv -> procurement_transactions_stage
-- 5) Run 02_load_staging_to_raw.sql

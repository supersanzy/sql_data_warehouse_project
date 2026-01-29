/*
********************************************************
Quality Checks
********************************************************

Script Purpose:
    This script performs various quality checks for data validation, integrity, consistency
    and accuracy of the Gold layer


Usage Notes:
    -   Run these checks after loading the Gold Layer.
    -   Ivestigate and resolve any discrepancies found during the checks
*************************************************
*/




-- ===============================================
-- Checking gold.fact_sales
-- ===============================================

SELECT * FROM gold.fact_sales AS f
JOIN gold.dim_products AS p
ON p.product_key = f.product_key
JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
LIMIT 50;


-- ================================================
-- Data Standardization - gold.dim_customers
-- ================================================

SELECT DISTINCT gender FROM gold.dim_customers


-- =================================================
-- Checking duplicates of dim_customers primary key:
--       - gold.dim_customers
-- =================================================

SELECT customer_key, COUNT(*) FROM gold.dim_customers
GROUP BY 1
HAVING COUNT(*) > 1


-- ================================================
-- Checking duplicates of dim_products primary key:
--       - gold.dim_products
-- ================================================

SELECT product_key, COUNT(*) FROM gold.dim_products
GROUP BY 1
HAVING COUNT(*) > 1
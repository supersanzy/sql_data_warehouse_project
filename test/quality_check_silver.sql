/*
********************************************************
Quality Checks
********************************************************

Script Purpose:
    This script performs various quality checks for data consistency, accuracy and standardization
    across the 'siver' schema. It includes checks for
    -   Null or duplicate primary types
    -   Data Standardization and consistency
    -   Invalid date ranges and orders
    -   Unwanted spaces in string fields
    -   Data consistency between related field

Usage Notes:
    -   Run these checks after loading the Silver Layer.
    -   Ivestigate and resolve any discrepancies found during the checks
*************************************************
*/



-- =================================================
-- Checking 'silver.crm_cust_info'
-- ===================================================

-- Check and remove primary key duplicates
SELECT *
	FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last FROM silver.crm_cust_info) 
WHERE flag_last = 1;


-- Check and remove unwanted spaces
SELECT * FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT * FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


-- Data Standardization and Data Consistency
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info


-- Normalize marital status to readable format
CASE
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'	
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'N/A'
END AS cst_marital_status 
FROM silver.crm_cust_info


-- ==================================================
-- Checking silver.crm_prd_info
-- ==================================================

-- Check for trailing spaces
SELECT * FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for NULLS or Negative Numbers
SELECT * FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;


-- Check for Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


-- Check for invalid date orders
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
FROM silver.crm_prd_info


--=====================================
-- Checking silver.crm_sales_details
-- =====================================


-- Check for invalid date orders
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- Check for missing and NULL values
SELECT sls_sales FROM silver.crm_sales_details
WHERE sls_sales = 0 OR sls_sales IS NULL OR sls_sales < 0 


-- Checking for trailing spaces
SELECT sls_ord_num FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)


--=====================================
-- Checking silver.erp_cust_az12
-- =====================================

-- Check birthdate future inconsistency
SELECT * FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- Check trailing spaces
SELECT gen FROM silver.erp_cust_az12
WHERE gen != TRIM(gen)


-- Data Standardization & Consistency
SELECT DISTINCT gen FROM silver.erp_cust_az12
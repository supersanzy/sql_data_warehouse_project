/*
    Script Purpose:
        This script is the transformation layer.
        This script does 
*/



-- Check and remove primary key duplicates
CREATE OR REPLACE PROCEDURE silver.transform_and_load()
LANGUAGE plpgsql
AS $$
BEGIN

    RAISE NOTICE '===============================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '===============================================';

    RAISE NOTICE '-----------------------------------------------';
    RAISE NOTICE 'Loading CRM Table';
    RAISE NOTICE '-----------------------------------------------';

    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;


    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
        )
    SELECT cst_id, cst_key,
            TRIM(cst_lastname) AS cst_lastname,		-- Removing unwanted spaces
            TRIM(cst_firstname) AS cst_firstname, 	-- Removing unwanted spaces
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'	-- Normalize marital status to readable format
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'N/A'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'		-- Normalize gender values to readable format
                ELSE 'N/A'
            END AS cst_gndr,
            cst_create_date
        FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last FROM bronze.crm_cust_info) 
    WHERE flag_last = 1; -- Remove primary key duplicate



    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    
    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id, 
        prd_key, 
        cat_key, 
        sls_prd_key,
        prd_nm, 
        prd_cost, 
        prd_line, 
        prd_start_dt,
        prd_end_dt
	    )
    SELECT  prd_id, 
            prd_key, 
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_key, -- Derived a new column 
            SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS sls_prd_key, -- Derived a new column
            prd_nm, 
            COALESCE(prd_cost, 0) AS prd_cost, -- Handle missing values (NULL)
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line, -- Map product line to descriptive values
            prd_start_dt::DATE AS prd_start_dt, -- DataType Cast
            LEAD(prd_start_dt::DATE) 
            OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 
            AS prd_end_dt -- Calculate end_dt as one day before the next date start & DataType Casting
    FROM bronze.crm_prd_info;



    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    

    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
        )
    SELECT 
        sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN LENGTH(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(sls_order_dt AS DATE)
		END AS sls_order_dt,
		CASE WHEN LENGTH(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(sls_ship_dt AS DATE)
		END AS sls_ship_dt,
		CASE WHEN LENGTH(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(sls_due_dt AS DATE)
		END AS sls_due_dt,
		CASE 
			WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN (sls_quantity * ABS(sls_price))
			ELSE sls_sales
		END AS sls_sales,		-- Recalculate sales if original values are missing or incorrect
		sls_quantity,
		CASE 
			WHEN sls_price < 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price		-- Derive price if original value is incorrect or missing
    FROM
        (
            SELECT  sls_ord_num,
                    sls_prd_key,
                    sls_cust_id,
                    sls_order_dt::VARCHAR, -- Cast the datatype to VARCHAR
                    sls_ship_dt::VARCHAR,
                    sls_due_dt::VARCHAR,
                    sls_sales,
                    sls_quantity,
                    sls_price
            FROM bronze.crm_sales_details
        )
    ;


    RAISE NOTICE '-----------------------------------------------';
    RAISE NOTICE 'Loading CRM Table';
    RAISE NOTICE '-----------------------------------------------';

    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    

    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (
	cid, 
    bdate, 
    gen
	    )
    SELECT CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
                ELSE cid
            END AS cid,				-- Remove 'NAS' prefix if present
            CASE WHEN bdate > CURRENT_DATE THEN NULL
                ELSE bdate
            END AS bdate,			-- Set future birthdates to NULL
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'N/A'
            END AS gen				-- Normalize gender values and handle unknown cases
    FROM bronze.erp_cust_az12;


    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    

    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (
		cid, 
        cntry
	    )
    SELECT  REPLACE(cid, '-', '') AS cid,		-- Replace invalid values
            CASE
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'N/A'
                ELSE TRIM(cntry)
            END AS cntry 						-- Normalize and handle missing values
    FROM bronze.erp_loc_a101;


    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    

    RAISE NOTICE '>> Inserting Transformed Data Into Table: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (
	    id, 
        cat, 
        subcat, 
        maintenance
	    )
    SELECT id, cat, subcat, maintenance
    FROM bronze.erp_px_cat_g1v2;



END;
$$;
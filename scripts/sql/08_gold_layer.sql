/*
	Script Purpose:
		Loads transformed and clean data from the Silver layer to the Gold layer.
		The Gold layer uses view instead of tables
		It either creates new view or replaces created one.
		Be aware of this before using.

		Each view performs transformations and combines data from the silver layer
		to produce a clean, enriched and business-ready dataset.

	Usage:
		- These views can be queried directly for analytics

*/

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT  
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
			ELSE COALESCE(ca.gen, 'N/A')
		END AS gender,
		ci.cst_marital_status AS marital_status,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON la.cid = ci.cst_key;



CREATE OR REPLACE VIEW gold.dim_products AS
SELECT 
		ROW_NUMBER() OVER(ORDER BY pi.prd_start_dt, pi.sls_prd_key) AS product_key,
		pi.prd_id AS product_id,
		pi.sls_prd_key AS product_number,
		pi.prd_nm AS product_name,
		pi.cat_key AS category_number,
		cg.cat AS category,
		cg.subcat AS sub_category,
		pi.prd_line AS product_line,
		pi.prd_cost AS product_cost,
		cg.maintenance,
		pi.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pi
JOIN silver.erp_px_cat_g1v2 AS cg
ON pi.cat_key = cg.id
WHERE pi.prd_end_dt IS NULL;		-- Filters out historical data




CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
		sls_ord_num AS order_number,
		cu.customer_key,
		pr.product_key,
		sls_price AS price,
		sls_quantity AS quantity,
		sls_sales AS sales_amount,
		sls_order_dt AS order_date,
		sls_ship_dt AS shipping_date,
		sls_due_dt AS due_date		
 FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number;
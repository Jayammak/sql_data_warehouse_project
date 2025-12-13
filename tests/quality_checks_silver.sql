/*
==================================================================================
Quality Checks
==================================================================================
Script Purpose
This script performs various quality checks for data consistency, data accuracy,
and standardization across the 'silver' schema. It included checks for:
  - Null or duplicate in primary key.
  - Unwanted space in string field.
  - Data standardization and consistency.
  - Invalid date range and orders.
  - Data consistency between related fields.

Usage Notes :

  - Run these checks after loading in silver layer.
  - Investigate and resolve any discrepancies found during the checks.
==================================================================================
*/
--==================================================================================
--Data Quality Check
--==================================================================================

--==================================================================================
-- Checking: silver.crm_cust_info
--==================================================================================
--Check for nulls or dublicate in Primary Key
-- Expectation: no results

SELECT cst_id,
COUNT(*) AS Counts
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL

--Check unwanted spaces
--Expectation: No result

SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname!= TRIM(cst_firstname) 

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname!= TRIM(cst_lastname)

--Check the consistency of values in low cardinality columns
SELECT DISTINCT cst_gender
FROM silver.crm_cust_info

--==================================================================================
--Checking: silver.crm_prd_info
--==================================================================================
  
--Check unwanted spaces
--Expectation: No result
SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm!= TRIM(prd_nm) 

SELECT prd_nm 
FROM Silver.crm_prd_info
WHERE prd_nm!= TRIM(prd_nm) 

--Check for NULLs or Negative Numbers
--Expectation: No result
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT prd_cost 
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
 
--Check the consistency of values in low cardinality columns
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

SELECT DISTINCT prd_line
FROM Silver.crm_prd_info
 
--Check for invalid date orders
SELECT prd_id,prd_key,prd_nm,prd_start_date,prd_end_date,
CAST(LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date)-1 AS DATE) as prd_end_date
FROM silver.crm_prd_info

SELECT prd_id,prd_key,prd_nm,prd_start_date,
CAST(LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date)-1 AS DATE) as prd_end_date
FROM Silver.crm_prd_info

--==================================================================================
--Checking: silver.crm_sales_info
--==================================================================================
--Check unwanted spaces
--Expectation: No result
SELECT sls_prd_key 
FROM silver.crm_sales_info
WHERE sls_prd_key != TRIM(sls_prd_key)

SELECT sls_cust_id
FROM silver.crm_sales_info
WHERE sls_cust_id NOT IN(
SELECT DISTINCT cst_id FROM Silver.crm_cust_info
)

-- Check for invalid date
SELECT NULLIF(sls_order_date,0) sls_order_date
FROM Silver.crm_sales_info
WHERE sls_order_date <= 0 
OR LEN(sls_order_date) !=8 
OR sls_order_date <19000101 
OR sls_order_date > 20500101 

SELECT NULLIF(sls_ship_date,0) sls_ship_date
FROM Silver.crm_sales_info
WHERE sls_ship_date <= 0
OR LEN(sls_ship_date) !=8 
OR sls_ship_date <19000101 
OR sls_ship_date > 20500101 

SELECT NULLIF(sls_due_date,0) sls_due_date
FROM silver.crm_sales_info
WHERE sls_due_date <= 0
OR LEN(sls_due_date) !=8 
OR sls_due_date <19000101 
OR sls_due_date > 20500101 

-- check invalid date orders
SELECT * 
FROM Silver.crm_sales_info
WHERE sls_order_date > sls_ship_date OR sls_order_date > sls_due_date

--Check data consistency: between sales, price, quantity
-->> Sales = Quantity * Price
-->> Values must not be Null, Zero or Negative

SELECT DISTINCT
sls_sales as oldsales,
CASE  WHEN  sls_sales <=0 OR sls_sales IS NULL 
				OR sls_sales != sls_quantity * ABS(sls_price)
	     THEN sls_quantity * ABS(sls_price)
	  ELSE sls_sales
END sls_sales ,
sls_quantity,
sls_price AS oldprice,
CASE WHEN sls_price IS NULL OR sls_price <=0 
     THEN sls_sales / NULLIF(sls_quantity,0)
     ELSE sls_price
END sls_price
FROM silver .crm_sales_info
WHERE sls_sales != sls_quantity * sls_price 
OR  sls_sales IS NULL OR sls_quantity IS NULL OR  sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0

--==================================================================================
--Checking: silver.erp_cust_az12
--==================================================================================

SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) -- Remove 'NAS' Prefic if present
	 ELSE cid
END cid
FROM silver.erp_cust_az12
WHERE 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END
NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

--Identify out of range dates
SELECT 
bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE() -- set future birthdate to null

--DATA Standardization & Consisdency

SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END gen                              --Normalize gender values and handle unknown cases
FROM silver.erp_cust_az12

--==================================================================================
--Checking: erp_loc_a101
--==================================================================================
SELECT
REPLACE(cid,'-', '')cid,
CASE WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(cntry) = 'DE'THEN 'Germany'
	 WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'n/a'
	 ELSE cntry                               --Data Standardization and Consistency
ENd cntry                                   -- Handle missing or blank country code

FROM Silver.erp_loc_a101

--==================================================================================
--Checking: erp_px_cat_g1v2
--==================================================================================

SELECT id FROM silver.erp_px_cat_g1v2
WHERE id NOT IN 
				(SELECT DISTINCT cat_id FROM Silver.crm_prd_info)

-- Check for unwanted space

SELECT cat 
FROM silver.erp_px_cat_g1v2 
WHERE cat != TRIM(subcat) OR subcat != TRIM(subcat) OR maintenace != TRIM(maintenace)

-- Data Standardization & Consistency
SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2 

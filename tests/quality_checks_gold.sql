/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:

    This script performs quality checks to validate the intergate, consistency
and accuracy of the gold layer.

These checks ensure:
- Uniquness of the surrogate keys for the dimension tables.
- Refrencial intergrity between the fact table and dimension tables.
- validation of relationships in the data model for analytical purpose.

Usage Notes:
  - Run these checks after data loading silver layer.
  - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

--===============================================================================
-- Integrating CRM and ERP Customer Data to Create Gold Layer Dimension  
--===============================================================================

-- 1.Quality Check: Check for duplicate records using primary or business keys.
SELECT cst_id, COUNT(*) FROM
	(SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gender,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
	FROM Silver.crm_cust_info ci
	LEFT JOIN Silver.erp_cust_az12 ca ON 
	ci.cst_key = ca.cid
	LEFT JOIN Silver.erp_loc_a101 LA ON
	ci.cst_key = la.cid)t
GROUP BY cst_id 
HAVING COUNT(*) >1

--2.Quality Check:Standardization of Gender Attribute Across CRM and ERP Sources
SELECT DISTINCT
	ci.cst_gender,
	ca.gen,
	CASE WHEN 	ci.cst_gender != 'n/a' THEN ci.cst_gender
		 ELSE COALESCE(ca.gen,'n/a')
	END new_gen
	FROM Silver.crm_cust_info ci
	LEFT JOIN Silver.erp_cust_az12 ca ON 
	ci.cst_key = ca.cid
	LEFT JOIN Silver.erp_loc_a101 LA ON
	ci.cst_key = la.cid
order by 1,2

--===============================================================
-- Checking: 'gold.dim_customers' 
--===============================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 

SELECT DISTINCT gender FROM gold.dim_customers;

 --Quality Check: Check for duplicate records
 -- Expectation: No results 

SELECT 
customer_key,
count(customer_key) as [dublicate count]
FROM gold.dim_customers
GROUP BY customer_key
HAVING count(customer_key) >1;

--===============================================================
-- Checking: 'gold.dim_products'
--===============================================================

--Quality Check: Check for duplicate records
-- Expectation: No results 

SELECT 
product_key,
count(product_key) as [dublicate count]
FROM gold.dim_products
GROUP BY product_key
HAVING count(product_key) >1;

--===============================================================
-- Checking: 'gold.fact_sales'
--===============================================================

-- Check the data model connectivity between fact and dimensions

SELECT * 
FROM gold.fact_sales f
LEFT JOIN Gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN Gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL


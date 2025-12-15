/*
===========================================================================================
DDL Script: Create Gold Views
===========================================================================================
Script Purpose:
    This script creates views for gold layer in the data warehouse.
    The gold layer represents the final dimension and fact tables (stat schema)

    Each view performs transformations and combines data from the silver layer to
    produce a clean, enriched and business ready dataset.

Usage:

    - These views can be queried directly for analytics and reporting.

===========================================================================================
*/

--=======================================================
--Create dimention: gold.dim_customers 
--=======================================================

IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
DROP VIEW gold.dim_customers

GO

CREATE VIEW gold.dim_v_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id ) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN 	ci.cst_gender != 'n/a' THEN ci.cst_gender
		 ELSE COALESCE(ca.gen,'n/a')
	END gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca ON 
ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 LA ON
ci.cst_key = la.cid
GO
--========================================================================================
--Create dimention: gold.dim_products 
--========================================================================================
IF OBJECT_ID ('gold.dim_products', 'V') IS NOT NULL
DROP VIEW gold.dim_products

GO 

CREATE VIEW gold.dim_v_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY prd_start_date,prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS Product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenace,
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
	pn.prd_start_date AS product_start_date
FROM Silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_date IS NULL -- Filter out all historical data
GO
--========================================================================================
--Create fact: gold.fact_sales 
--========================================================================================
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
DROP VIEW gold.fact_sales
GO
CREATE VIEW gold.fact_v_sales AS
SELECT 
	si.sls_order_num AS order_number,
	gp.product_key,
	gc.customer_key,
	si.sls_order_date AS order_date,
	si.sls_ship_date AS shipping_date,
	si.sls_due_date AS due_date,
	si.sls_sales AS sales_amount,
	si.sls_quantity AS quantity,
	si.sls_price AS price
FROM Silver.crm_sales_info si
LEFT JOIN Gold.dim_v_products gp 
ON si.sls_prd_key = gp.Product_number
LEFT JOIN Gold.dim_v_customers gc
ON si.sls_cust_id = gc.customer_id

--=======================================================
--Create dimention Table: gold.dim_customers 
--=======================================================

IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
DROP TABLE gold.dim_customers
CREATE TABLE gold.dim_customers
 (
customer_key INT,
customer_id INT,
customer_number NVARCHAR(50),
first_name NVARCHAR(50),
last_name NVARCHAR(50),
country NVARCHAR(50),
marital_status NVARCHAR(50),
gender NVARCHAR(50),
birthdate DATE,
create_date DATE
)
--=======================================================
--Inserting date into: gold.dim_customers 
--=======================================================

TRUNCATE TABLE gold.dim_customers
INSERT INTO DataWarehouse.Gold.dim_customers
SELECT * FROM gold.dim_v_customers


--=======================================================
--Create Dimention Table: gold.dim_products
--=======================================================

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
DROP TABLE gold.dim_products
CREATE TABLE gold.dim_products
 (
product_key INT,
product_id INT,
product_number NVARCHAR(50),
product_name NVARCHAR(50),
category_id NVARCHAR(50) ,
category NVARCHAR(50),
subcategory NVARCHAR(50),
maintence NVARCHAR(50),
product_cost INT,
product_line NVARCHAR(50),
product_start_date DATE
)
--=======================================================
--Inserting date into: gold.dim_products 
--=======================================================

TRUNCATE TABLE gold.dim_products
INSERT INTO DataWarehouse.Gold.dim_products
select * from gold.dim_products

--=======================================================
--Create Fact Table: gold.fact_sales 
--=======================================================

IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
DROP TABLE gold.fact_sales
CREATE TABLE gold.fact_sales
(
order_number NVARCHAR(50),
product_key INT,
customer_key INT,
order_date DATE,
shipping_date DATE,
due_date DATE,
sales_amount INT,
quantity INT,
price INT
)
--=======================================================
--Inserting date into: gold.fact_sales 
--=======================================================

TRUNCATE TABLE gold.fact_sales
INSERT INTO DataWarehouse.gold.fact_sales
select * from gold.fact_v_sales




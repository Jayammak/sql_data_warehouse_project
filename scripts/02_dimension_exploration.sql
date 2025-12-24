/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/
--2.DIMENSIONS EXPLORATION
--Explore all countries our customer comes from
SELECT 
DISTINCT country 
FROM Gold.dim_customers

--Explore all the categories " The Major Divisions"

SELECT DISTINCT 
category, 
subcategory,
product_name
FROM Gold.dim_products
ORDER BY 1,2,3

/*
=========================================================================
Customer Report
=========================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours

Highlights:
1. Gathers essitial fields such as names, ages and transactional details.
2. Segments customers into categories (VIP,Regular,New) and age groups.
3. Aggregates customer_level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - life span (in months)	
4. calculate valuable KPIs:
   - recency (month since last order)
   - average order value
   - average monthly spend

===========================================================================
*/
CREATE VIEW Gold.report_customers AS

WITH base_query AS(
/*-------------------------------------------------------------------------
1) Base Query: Retrive core columns from tables 
---------------------------------------------------------------------------*/
SELECT
S.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(first_name,' ',last_name) AS customer_name,
DATEDIFF(YEAR,birthdate, GETDATE()) AS age
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c
ON S.customer_key = C.customer_key
WHERE order_date IS NOT NULL),
customer_aggregation AS(
/*-------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the cusotmer level
---------------------------------------------------------------------------*/

SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
COUNT( DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_qty
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
	)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and above'
END age_group,
total_orders, 
total_products,
CASE 
	 WHEN total_sales >=5000 and lifespan >=12 THEN 'VIP'
     WHEN total_sales <=5000 and lifespan >=12 THEN 'Regular'
	 ELSE 'New'
END customer_segmentation,
last_order,
DATEDIFF(MONTH,last_order,GETDATE()) AS recency,
total_sales,
total_qty,
--Compute average order  value (AVO)
CASE
	WHEN total_sales =0 THEN 0	
	ELSE total_sales/total_orders 
END AS avg_order_value,
--Compute average monthly spend
CASE
	WHEN lifespan=0 THEN 0	
	ELSE total_sales/lifespan 
END AS avg_monthly_spending
FROM customer_aggregation


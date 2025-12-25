/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

--09. PERFORMANCE ANALYSIS
-- Analyze the yearly performance of products
-- by comparing each product's sales to both
-- its average sales performance and the previous year's sales
WITH yearly_product_sales AS
(
	SELECT
	p.product_name,
	YEAR(s.order_date) as order_year,
	sum(s.sales_amount) as current_sales
	FROM Gold.fact_sales s
	LEFT JOIN Gold.dim_products p
	ON S.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY YEAR(order_date) ,p.product_name
)
SELECT
product_name,
order_year,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) as avg_year_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) as avg_difference,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
     WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name ) <0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
lag(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year ) as previous_year_sales,
current_sales - lag(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year) as pre_diff,
CASE WHEN current_sales - lag(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
     WHEN current_sales - lag(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year) <0 THEN 'Decresing'
	 ELSE 'No Change'
END pre_year_change
FROM yearly_product_sales

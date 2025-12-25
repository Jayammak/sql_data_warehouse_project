/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

--11. DATA SEGMENTATION
-- Segment product into cost ranges and 
--count how many products fall into each sengments
WITH product_segment AS
(
	SELECT 
	product_name,
	product_cost,
	CASE WHEN product_cost < 100 THEN 'Below 100'
		 WHEN product_cost BETWEEN 100 AND 500 THEN '100 to 500'
		 WHEN product_cost BETWEEN 500 AND 1000 THEN '500 to 1000'
		 ELSE 'Above 1000'
	END cost_range
	FROM Gold.dim_products)

SELECT
cost_range,
COUNT(product_name) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC

/*-- Group customers into three segments based on their spending behaviour
	-VIP: atleast 12 months of history and spending more than 5000
	-Regular: atleast 12 months of history but spending 5000or less
	-New: lifespan less than 12 months
 and find the total number of cutomers by each group
*/
WITH customer_spending AS(
	SELECT 
	c.customer_key,
	SUM(s.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
	FROM Gold.fact_sales s
	LEFT JOIN Gold.dim_customers c
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key
	),
 customer_segment AS
 (
SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN total_spending >=5000 and lifespan >=12 THEN 'VIP'
     WHEN total_spending <=5000 and lifespan >=12 THEN 'Regular'
	 ELSE 'New'
END customer_segmentation
FROM customer_spending
)

SELECT 
customer_segmentation,
COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_segmentation

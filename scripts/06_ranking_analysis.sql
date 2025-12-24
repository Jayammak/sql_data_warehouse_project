/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

--6. RANKING ANALYSIS
--Which 5 products generate the highest revenue
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN Gold.dim_products p
ON S.product_key = P.product_key
GROUP BY P.product_name
ORDER BY total_revenue DESC

SELECT *
FROM
(
	SELECT 
	p.product_name,
	SUM(s.sales_amount) total_revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount)DESC) AS rank_revenue 
	FROM gold.fact_sales s
	LEFT JOIN Gold.dim_products p
	ON S.product_key = P.product_key
	GROUP BY P.product_name)t
WHERE rank_revenue <= 5


--Which 5 worst performing products in terms of sales
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN Gold.dim_products p
ON S.product_key = P.product_key
GROUP BY P.product_name
ORDER BY total_revenue ASC

--Find the top 10 customers who have generated the highest revenue
-- and 3 customers with fewest order placed
SELECT TOP 10
c.customer_key,c.first_name,
SUM(s.sales_amount) as total_customer_revenue
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name
ORDER BY SUM(s.sales_amount) DESC

-- and 3 customers with fewest order placed
SELECT TOP 3
c.customer_key,c.first_name,
COUNT(s.order_number) as total_orders
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name
ORDER BY total_orders ASC

 

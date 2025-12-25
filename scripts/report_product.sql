/*
=========================================================================================
Product Report
=========================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours
	
Highlights:

	1. Gathers essential fields such as product name, category,subcategory and cost.
	2. Segments products by revenue to identify High_performeres,Mid_range,Low_performerse
	3. Aggregate product-level metrics:
		- total orders
		- total quantity sold
		- total customers (unique)
		- lifespan in month
	4. Calculate valuable KPIs:
		- recency (month sice last sale)
		- average order revenue (AOR)
		- average monthly revenue
		
=========================================================================================
*/
GO
CREATE VIEW Gold.report_product AS
WITH product_base_query AS(
/*-------------------------------------------------------------------------
1) Base Query: Retrive core columns from tables 
---------------------------------------------------------------------------*/

 SELECT
 p.product_key,
 p.Product_number,
 p.product_name,
 p.category,
 p.subcategory,
 S.order_number,
 s.order_date,
 s.sales_amount,
 s.quantity,
 s.customer_key,
 p.product_start_date,
 p.product_cost
 FROM Gold.fact_sales s
 LEFT JOIN Gold.dim_products P
 ON s.product_key = p.product_key
 WHERE order_date IS NOT NULL
 ), product_aggregation AS
 (
 /*-------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/

 SELECT 
 product_key,
 Product_number,
 product_name,
 category,
 subcategory,
 product_cost,
 COUNT(DISTINCT order_number) AS total_orders,
 COUNT(DISTINCT customer_key) AS total_customers,
 SUM(sales_amount) AS total_sales,
 SUM(quantity) AS total_qty_sold,
 MAX(order_date) AS last_order,
 DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
 ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS Avg_selling_price
 FROM product_base_query
 GROUP BY 
	 product_key,
	 Product_number,
	 product_name,
	 category,
	  product_cost,
	 subcategory
 )
/*-------------------------------------------------------------------------
3) Final Query: Combines all product results into one output 
---------------------------------------------------------------------------*/

SELECT 
 product_key,
 Product_number,
 product_name,
 category,
 subcategory,
 product_cost,
 last_order,
 DATEDIFF(MONTH,last_order,GETDATE()) AS recency,
 CASE
	 WHEN total_sales > 50000 THEN 'High Performer'
	 WHEN total_sales >+ 10000 THEN 'Mid-Range'
	 ELSE 'Low Performer'
END product_segment,
 lifespan,
 total_orders,
 total_sales,
 total_qty_sold,
 total_customers,
 Avg_selling_price,
 --Average order reveune (AOR)
 CASE
     WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders 
END AS avg_order_revenue,
-- Average monthly revenue (AMR)
 CASE
     WHEN lifespan = 0 THEN 0
	 ELSE total_sales / lifespan 
END AS avg_monthly_revenue

 FROM product_aggregation

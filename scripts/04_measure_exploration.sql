/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
--4. MEASURES EXPLORATION
--Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM Gold.fact_sales

--Find how many items are sold
SELECT SUM(quantity) AS total_item_sold
FROM Gold.fact_sales

--Find the average selling price
SELECT AVG(price) AS average_price
FROM Gold.fact_sales

--Find the total number of orders
SELECT COUNT(order_number) as total_order
FROM Gold.fact_sales

SELECT COUNT(DISTINCT order_number) as total_order
FROM Gold.fact_sales

--Find the total number of products
SELECT COUNT(product_key) as total_products
FROM Gold.dim_products
--Find the total number of customers
SELECT COUNT(DISTINCT customer_key) as total_customers
FROM Gold.fact_sales

--Find the total number of customers that have place the orders
SELECT COUNT(DISTINCT customer_key) as total_customers
FROM Gold.fact_sales


--Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS Measure_Name, SUM(sales_amount) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS Measure_Name, SUM(quantity) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Average price' AS Measure_Name, AVG(price) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS Measure_Name, COUNT(DISTINCT order_number) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total products' AS Measure_Name, COUNT(DISTINCT product_key) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total Customers' AS Measure_Name, COUNT(DISTINCT customer_key) AS Measure_value FROM Gold.fact_sales
UNION ALL
SELECT 'Total Customers' AS Measure_Name, COUNT(DISTINCT customer_key) AS Measure_value FROM Gold.fact_sales

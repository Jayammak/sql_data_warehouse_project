/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/
--ADVANCED DATA ANALYTICS

--7.CHANGE OVER TIME ANALYSIS

--Analyze sales performance over time
-- Changes over year 
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
--Changes over month
SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date),YEAR(order_date)
ORDER BY MONTH(order_date)

--Calculate the total sales per month
-- and the Running total of sales over time

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
avg_price,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price 
FROM
(
SELECT
DATETRUNC(MONTH,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
)T

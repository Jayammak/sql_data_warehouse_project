/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
--3.DATE EXPLORATION
-- Find the date of the first order and last order
--How many years of sales are available
SELECT
MIN(order_date) as first_order_date,
MAX(order_date) as last_order_date,
DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) order_range_years 
FROM Gold.fact_sales

--Find the youngest and oldest customer

SELECT
MIN(birthdate) AS oldest_customer,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) oldest_age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) youngest_age
FROM Gold.dim_customers

--4. MEASURES EXPLORATION
--Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM Gold.fact_sales

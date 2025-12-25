/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

--10. PART_TO_WHOLE 
--Which categories contributes more to the overall sales
GO
 WITH category_contribution AS
 (
 SELECT
 category,
 SUM(s.sales_amount)AS category_sales
 FROM Gold.fact_sales s
 LEFT JOIN Gold.dim_products p
 ON p.product_key = s.product_key
 GROUP BY category
 )
 SELECT 
 category,
 category_sales,
 SUM(category_sales) OVER () AS total_sales,
 CONCAT(ROUND((CAST(category_sales AS FLOAT) / SUM(category_sales) OVER ()) *100,2),'%') AS pert_of_total
 FROM category_contribution
ORDER BY pert_of_total  DESC

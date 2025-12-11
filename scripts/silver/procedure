/*
=============================================================================================================
Stored Procedure : Load silver layer (Bronze --> silver)
=============================================================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'silver'
  schema tables from the 'Bronze' schema.
  
Actions Performed : 
  -Truncate silver tables.
  -Inserts transformed and cleaned data from Bronze in to silver tables.

Parameters :
None
This stored procedure does not accept any parameters or return any values.

Usage Example : 
    EXEC silver.load_silver;
=============================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
SET @batch_start_time = GETDATE()
BEGIN TRY

		PRINT '===================================================';
		PRINT	'Loading  Silver Layer';
		PRINT '===================================================';

		PRINT '---------------------------------------------------';
		PRINT  'Loading CRM Tables in Silver Layer';
		PRINT '---------------------------------------------------';

		SET @start_time = GETDATE()
		PRINT '>> Truncation Table: Silver.crm_cust_info';	
		TRUNCATE TABLE Silver.crm_cust_info;
		PRINT 'Inserting Data Into :Silver.crm_cust_info';
		INSERT INTO Silver.crm_cust_info
			(cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gender,
			cst_create_date
		)
		SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname ,

		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 ELSE 'n/a'
		END cst_marital_status,

		CASE WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
			 WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
			 ELSE 'n/a'
		END cst_gender,
		cst_create_date
		FROM
		(
			SELECT *,
			ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM Bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
			)t
		WHERE flag_last = 1
		SET @end_time = GETDATE()
		PRINT 'Loading Duration : '+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds'
		PRINT '>>------------------------------'

		SET @start_time = GETDATE ()
		PRINT '>> Truncation Table: Silver.crm_prd_info';	
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT 'Inserting Data Into: Silver.crm_prd_info'; 
		INSERT INTO Silver.crm_prd_info
		(
			prd_id,			
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_date,
			prd_end_date)	
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) prd_cost ,

		CASE UPPER(TRIM(prd_line)) 
			 WHEN 'M' THEN 'Mountain'
			 WHEN 'R' THEN 'Road'
			 WHEN 'S' THEN 'Other Sales'
			 WHEN 'T' THEN 'Touring'
			 ELSE 'n/a'
		END prd_line,
		CAST(prd_start_date AS DATE) prd_start_date,
		CAST(LEAD(prd_start_date) OVER 
						(PARTITION BY prd_key ORDER BY prd_start_date)-1 AS DATE) as prd_end_date
		FROM Bronze.crm_prd_info;

		SET @end_time = GETDATE ()
		PRINT 'Loading Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR) + 'Seconds'
		PRINT '>>-------------------------------------'

		SET @start_time = GETDATE ();
		PRINT '>> Truncation Table: silver.crm_sales_info';
		TRUNCATE TABLE silver.crm_sales_info;
		PRINT 'Inserting Data Into: silver.crm_sales_info'; 
		INSERT INTO silver.crm_sales_info
		(
			 sls_order_num,
			 sls_prd_key,
			 sls_cust_id,
			 sls_order_date,
			 sls_ship_date,
			 sls_due_date,
			 sls_sales,
			 sls_quantity,
			 sls_price		
			 )
		SELECT 
		sls_order_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_date = 0 OR LEN(sls_order_date) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_date AS varchar)AS DATE)
		END sls_order_date,

		CASE WHEN sls_ship_date = 0 OR LEN(sls_ship_date) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_date AS varchar)AS DATE)
		END sls_ship_date,

		CASE WHEN sls_due_date = 0 OR LEN(sls_due_date) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_date AS varchar)AS DATE)
		END sls_due_date,
		CASE  WHEN  sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)	
			  THEN sls_quantity * ABS(sls_price)
			  ELSE sls_sales
		END sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <=0 
			 THEN sls_sales / NULLIF(sls_quantity,0)
			 ELSE sls_price
		END sls_price
		FROM bronze.crm_sales_info;
		SET @end_time = GETDATE ();
		PRINT 'Loading Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR) + 'Seconds'
		PRINT '>>-------------------------------------------------';

		PRINT '---------------------------------------------------';
		PRINT  'Loading CRM Tables in Silver Layer';
		PRINT '---------------------------------------------------';

		SET @start_time = GETDATE ();
		PRINT '>> Truncation Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT 'Inserting Data Into: silver.erp_cust_az12'; 
		INSERT INTO silver.erp_cust_az12
		(cid,
		bdate, 
		gen)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
			 ELSE cid
		END cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			 ELSE 'n/a'
		END gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE ();
		PRINT 'Loading Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR) + 'Seconds'
		PRINT '>>-------------------------------------';

		SET @start_time = GETDATE ();
		PRINT '>> Truncation Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT 'Inserting Data Into: silver.erp_loc_a101'; 
		INSERT INTO silver.erp_loc_a101
			(cid,
			cntry
			)
		SELECT
		REPLACE(cid,'-', '')cid,
		CASE WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
			 WHEN TRIM(cntry) = 'DE'THEN 'Germany'
			 WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'n/a'
			 ELSE cntry
		ENd cntry
		FROM Bronze.erp_loc_a101;
		SET @end_time = GETDATE ();
		PRINT 'Loading Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR) + 'Seconds'
		PRINT '>>-------------------------------------'

		SET @start_time = GETDATE ();
		PRINT '>> Truncation Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT 'Inserting Data Into: silver.erp_px_cat_g1v2'; 
		INSERT INTO silver.erp_px_cat_g1v2
			(id,
			cat,
			subcat,
			maintenace
		)
		SELECT 
		id,
		cat,
		subcat,
		maintenace
		FROM Bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE ();
		PRINT 'Loading Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time)AS VARCHAR) + 'Seconds'
		PRINT '>>-------------------------------------'
 SET @batch_end_time = GETDATE()

 PRINT'============================================================='

 PRINT 'Silver Batch Loading Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS VARCHAR) + 'Seconds'
 
 PRINT'============================================================='

 END TRY
 BEGIN CATCH
 PRINT'============================================================='
 PRINT'Error Message: ' + error_message();
 PRINT'Error line: ' + error_line();
 PRINT'Error Number: ' + error_Number();
 PRINT'Error procedure: ' + error_procedure();
 PRINT'Error Seviarity: ' + error_Severity();
 PRINT'Error State: ' + error_State();
 PRINT'============================================================='
 END CATCH
END

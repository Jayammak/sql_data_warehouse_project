
========================================================================
DDL Script: Create Bronze Layer
========================================================================

**Script Purpose:**
This script creates tables in the 'Bronze' schema, dropping exixying
tables if they already exists.
Run this script to re_define the DDL Structure of 'Bronze Tables

=========================================================================



IF OBJECT_ID ('Bronze.crm_cust_info', 'U') IS NOT NULL
DROP TABLE Bronze.crm_cust_info;

 CREATE TABLE Bronze.crm_cust_info(
	 cst_id					INT,
	 cst_key				NVARCHAR(50),
	 cst_firstname			NVARCHAR(50),
	 cst_lastname			NVARCHAR (50),
	 cst_marital_status		NVARCHAR (50),
	 cst_gender				NVARCHAR(50),
	 cst_create_date		NVARCHAR(50)
 )

IF OBJECT_ID ('Bronze.crm_prd_info', 'U') IS NOT NULL
DROP TABLE Bronze.crm_prd_info;

  CREATE TABLE Bronze.crm_prd_info(
	 prd_id			INT,
	 prd_key		NVARCHAR(50),
	 prd_nm 		NVARCHAR(50),
	 prd_cost		INT,
	 prd_line		NVARCHAR(50),
	 prd_start_date DATETIME,
	 prd_end_date	DATETIME
 )

 IF OBJECT_ID ('Bronze.crm_sales_info', 'U') IS NOT NULL
DROP TABLE Bronze.crm_sales_info;

  CREATE TABLE Bronze.crm_sales_info(
	 sls_order_num		NVARCHAR(50),
	 sls_prd_key		NVARCHAR(50),
	 sls_cust_id		INT,
	 sls_order_date		INT,
	 sls_ship_date		INT,
	 sls_due_date		INT,
	 sls_sales			INT,
	 sls_quantity		INT,
	 sls_price			INT

 )

 IF OBJECT_ID ('Bronze.erp_cust_az12', 'U') IS NOT NULL
 DROP TABLE Bronze.erp_cust_az12;

 CREATE TABLE Bronze.erp_cust_az12(
cid		NVARCHAR(50),
bdate	DATE,
gen		NVARCHAR (50)
)

 IF OBJECT_ID ('Bronze.erp_loc_a101', 'U') IS NOT NULL
 DROP TABLE Bronze.erp_loc_a101;

CREATE TABLE Bronze.erp_loc_a101(
cid		NVARCHAR(50),
cntry	NVARCHAR (50)
)

 IF OBJECT_ID ('Bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
 DROP TABLE Bronze.erp_px_cat_g1v2;

CREATE TABLE Bronze.erp_px_cat_g1v2(
id			NVARCHAR(50),
cat			NVARCHAR (50),
subcat		NVARCHAR (50),
maintenace	NVARCHAR (50)
)
**-- Bronze.crm_cust_info Bulk Insert**
TRUNCATE TABLE  Bronze.crm_cust_info;
BULK INSERT Bronze.crm_cust_info
FROM 'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\crm\cust_info.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK
)

**--Bulk Insert Bronze.crm_prd_info**

TRUNCATE TABLE  Bronze.crm_prd_info;
BULK INSERT Bronze.crm_prd_info
FROM'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\crm\prd_info.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK)

**--Bulk Insert Bronze.crm_sales_info**

TRUNCATE TABLE  Bronze.crm_sales_info;
BULK INSERT Bronze.crm_sales_info
FROM'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\crm\sales_details.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK)

**-- Bulk Insert Bronze.erp_cust_az12**

TRUNCATE TABLE  Bronze.erp_cust_az12;
BULK INSERT Bronze.erp_cust_az12
FROM'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\erp\CUST_AZ12.CSV'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK)  

**-- Bulk Insert Bronze.erp_loc_a101**

TRUNCATE TABLE  Bronze.erp_loc_a101;
BULK INSERT Bronze.erp_loc_a101
FROM'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\erp\LOC_A101.CSV'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK)  

**-- Bulk Insert Bronze.erp_px_cat_g1v2**

TRUNCATE TABLE  Bronze.erp_px_cat_g1v2;
BULK INSERT Bronze.erp_px_cat_g1v2
FROM'C:\Users\lenovo\OneDrive\Desktop\SERVER SQL\Data warehouse project\erp\PX_CAT_G1V2.CSV'
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
TABLOCK)  


/* 
=============================================
**Create Database and Schema**
============================================

Script purpose:
  This scripts cteate new database name **DataWarehouse** . After checking 
if its already exists, it is dropped and recreated. Additionally this 
script set up with three schema within the database: 'Bronze','Silver', 'Gold'.

**Warning:**
  Running the script will drop the entire 'DataWarehouse' database if its exists.
All data in the database will be permanetly deleted proceed with caution and ensure 
you have proper backup before running the scripts.
*/

use master;
-- Drop and recreate the 'DataWarehouse' database

IF EXISTS (SELECT 1 FROM sys.database WHERE name = DataWarehouse)

BEGIN ALTER Database DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP Database DataWarehouse;
END;
GO

-- Create Database
CREATE DATABASE DataWarehouse;
GO
-- Create Schema
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;

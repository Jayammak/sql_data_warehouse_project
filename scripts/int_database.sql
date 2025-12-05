/* 
=============================================
**Create Database and Schema**1
============================================

Script purpose:
  This scripts cteate new database name **DataWarehouse** . Additionally this script set up
with three schema within the database: 'Bronze','Silver', 'Gold'.

**Warning:**
  Running the script will drop the entire 'DataWarehouse' database if its exists.
All data in the database will be permanetly deleted proceed with caution and ensure 
you have proper backup before running the scripts.


-- Create Database
CREATE DATABASE DataWarehouse;
GO
-- Create Schema
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;

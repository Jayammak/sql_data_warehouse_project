/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:

    This script performs quality checks to validate the intergate, consistency
and accuracy of the gold layer.

These checks ensure:
- Uniquness of the surrogate keys for the dimension tables.
- Refrencial intergrity between the fact table and dimension tables.
- validation of relationships in the data model for analytical purpose.

Usage Notes:
  - Run these checks after data loading silver layer.
  - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- Databricks notebook source
------------------------------------------------------------
---VIEW THE DATA
-------------------------------------------------------------
SELECT *
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;

-------------------------------------------------------------
-- Check the structure and datatypes of the table
-------------------------------------------------------------
DESCRIBE brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
--------------------------------------------------------------
-- CHECKING PRODUCT CATEGORIES
--------------------------------------------------------------
-- Checking the different product categories
SELECT DISTINCT product_category
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;

-- Checking for NULL values and blank spaces in product_category and replace them with uknown 
SELECT DISTINCT
      product_category,
      CASE
          WHEN product_category IS NULL THEN 'unknown'
          WHEN TRIM(product_category) = '' THEN 'unknown'
          ELSE product_category
      END AS Product_cat
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
--------------------------------------------------------
-- CHECKING PRODUCT TYPES
---------------------------------------------------------
-- Inspecting product types
SELECT DISTINCT product_type
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;

-- Cleaning product types
SELECT DISTINCT
      product_type,
      CASE
          WHEN product_type IS NULL THEN 'unknown'
          WHEN TRIM(product_type) = '' THEN 'unknown'
          ELSE product_type
      END AS Product_typ
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
----------------------------------------------------------------
-- CREATING THE REVENUE COLUMN
----------------------------------------------------------------
-- Calculate revenue for each transaction
SELECT transaction_qty,
      product_type,
      product_category,
      unit_price,
      CAST(transaction_qty AS DOUBLE) *
      CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS Total_Amount
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
-- Calculate total revenue
SELECT
     ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
          CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS Total_Amount
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
----------------------------------------------------------------
-- TOTAL SALES AND REVENUE
----------------------------------------------------------------
-- Total number of items sold and total revenue
SELECT SUM(CAST(transaction_qty AS DOUBLE)) AS total_daily_sales,
      ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
          CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS total_amount
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
----------------------------------------------------------------
-- REVENUE BY PRODUCT CATEGORY
-----------------------------------------------------------------
---Which product categories generate the most revenue?
SELECT product_category,
      ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
              CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS Total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY Total_revenue DESC;
---------------------------------------------------------------
-- REVENUE BY PRODUCT TYPE
---------------------------------------------------------------
SELECT product_type,
      ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
            CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS Total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_type
ORDER BY Total_revenue DESC;
---------------------------------------------------------------
-- TRANSACTION DUPLICATE CHECK
---------------------------------------------------------------
-- Checking whether transaction IDs are duplicated
SELECT transaction_id,
      COUNT(*) AS Duplicate_cnt
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY Duplicate_cnt DESC;
---------------------------------------------------------------
-- CHECKING DUPLICATES ACROSS ALL COLUMNS
----------------------------------------------------------------
-- GROUP BY ALL allows us to check whether complete rows are duplicated.
SELECT *,
      COUNT(*) AS Duplicate_cnt
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY ALL
HAVING COUNT(*) > 1;
---------------------------------------------------------------
-- CHECKING THE DATE COLUMN
---------------------------------------------------------------
-- Inspect unique transaction dates
SELECT DISTINCT transaction_date
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
ORDER BY transaction_date;

-- Extract the month name
SELECT DISTINCT
      DATE_FORMAT(transaction_date, 'MMMM') AS Month_name
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
---------------------------------------------------------------
-- CHECKING THE TRANSACTION TIME COLUMN
----------------------------------------------------------------
-- Inspect unique transaction times
SELECT DISTINCT transaction_time
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
-- Format the transaction time
SELECT DISTINCT
      DATE_FORMAT(transaction_time, 'HH:mm:ss') AS Time
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
---------------------------------------------------------------
-- CREATING TIME BUCKETS
---------------------------------------------------------------
-- Categorise transactions according to the hour of the day
SELECT DISTINCT
      CASE
          WHEN HOUR(transaction_time) BETWEEN 7 AND 11 THEN 'Morning'
          WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
          WHEN HOUR(transaction_time) BETWEEN 17 AND 21 THEN 'Evening'
      ELSE 'Other'
      END AS time_bucket
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
---------------------------------------------------------------
-- SALES BY PRODUCT
----------------------------------------------------------------
SELECT product_category,
      product_type,
      product_detail,
      unit_price,
      SUM( CAST(transaction_qty AS DOUBLE) ) AS total_transaction_qty,
  ROUND(
      SUM( CAST(transaction_qty AS DOUBLE) *
         CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS total_price
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_category, product_type, product_detail, unit_price
ORDER BY total_price DESC;
----------------------------------------------------------------
-- SALES BY PRODUCT CATEGORY AND PRODUCT TYPE
----------------------------------------------------------------
SELECT product_category,
      product_type,
  SUM( CAST(transaction_qty AS DOUBLE) ) AS total_transaction_qty,
ROUND(
   SUM( CAST(transaction_qty AS DOUBLE) *
       CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_category,product_type
ORDER BY total_revenue DESC;

-----------------------------------------------------------------
-- CHECKING TOTAL REVENUE PER STORE LOCATION
-- This shows which store location generates the most revenue.
SELECT store_location,
     ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
             CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) ), 2 ) AS Total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY store_location
ORDER BY Total_revenue DESC;
------------------------------------------------------------------------
-- CHECKING HIGH-PERFORMING AND LOW-PERFORMING PRODUCT CATEGORIES
--------------------------------------------------------------------------
-- This shows which product categories generate the most and least revenue.
SELECT product_category,
     ROUND(
          SUM( CAST(transaction_qty AS DOUBLE) *
          CAST(REPLACE(unit_price, ',', '.') AS DOUBLE)), 2 ) AS Total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY Total_revenue DESC;
--------------------------------------------------------------------
-- CHECKING HIGH-PERFORMING AND LOW-PERFORMING PRODUCT TYPES
--------------------------------------------------------------------
-- This provides a more detailed view than product category.
-- For example, it can show which individual product types generate the highest revenue.
SELECT product_type,
ROUND(
     SUM( CAST(transaction_qty AS DOUBLE) *
     CAST(REPLACE(unit_price, ',', '.') AS DOUBLE)), 2 ) AS Total_revenue
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY product_type
ORDER BY Total_revenue DESC;
--------------------------------------------------
-- CHECKING THE DATE RANGE OF THE DATA
----------------------------------------------------
-- MIN() finds the earliest transaction date.
-- MAX() finds the latest transaction date.
SELECT
      MIN(transaction_date) AS Earliest_date,
      MAX(transaction_date) AS Latest_date
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis;
---------------------------------------------------
-- CHECKING DUPLICATE TRANSACTION IDs
----------------------------------------------------
SELECT transaction_id, COUNT(*) AS Duplicate_cnt
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY Duplicate_cnt DESC;
------------------------------------------------------------
-- CHECKING COMPLETE DUPLICATE RECORDS
----------------------------------------------------------
SELECT*, COUNT(*) AS Duplicate_cnt
FROM brightcoffee.bright_coffee_shop.bright_coffee_shop_analysis
GROUP BY ALL
HAVING COUNT(*) > 1;

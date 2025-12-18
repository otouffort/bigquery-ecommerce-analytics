--No null customer IDs

SELECT COUNT(*) 
FROM ecommerce_silver.stg_online_retail
WHERE CustomerID IS NULL;

--No negative price

SELECT COUNT(*) 
FROM ecommerce_silver.clean_online_retail
WHERE Price < 0;

--Sum of revenue

SELECT SUM(line_revenue) 
FROM ecommerce_silver.clean_online_retail

--See first 10 rows of data

SELECT *
FROM ecommerce_silver.clean_online_retail
LIMIT 10;

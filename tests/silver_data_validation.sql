--No null customer IDs

SELECT COUNT(*) 
FROM ecommerce_silver.stg_online_retail
WHERE CustomerID IS NULL;

--No negative price

SELECT COUNT(*) 
FROM ecommerce_silver.clean_online_retail
WHERE Price < 0;

--See first 10 rows of data

SELECT *
FROM ecommerce_silver.clean_online_retail
LIMIT 10;

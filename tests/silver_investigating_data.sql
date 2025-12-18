--Investigation for dim_product gold layer table. 
--Check for null StockCodes. Result: 0 rows with null StockCode

SELECT *
FROM ecommerce_silver.clean_online_retail
WHERE StockCode IS NULL

--Check for StockCode with more than one type of distinct product description. Result: 624 of 4,646 products with multiple variations of product descriptions.

SELECT StockCode, COUNT(DISTINCT Description) as description_count
FROM ecommerce_silver.clean_online_retail
GROUP BY StockCode
HAVING description_count>1
ORDER BY StockCode

--Investigate choosing product description for products with variations of product descriptions based on how frequently it appears.

SELECT StockCode, Description, COUNT(*) as numberofproductids
FROM ecommerce_silver.clean_online_retail
WHERE StockCode IN (
    SELECT StockCode
    FROM ecommerce_silver.clean_online_retail
    GROUP BY StockCode
    HAVING COUNT(DISTINCT Description) > 1
)
GROUP BY StockCode, Description
HAVING numberofproductids > 1
ORDER BY StockCode

--Investigation for dim_customer gold layer table.
--Check for null CustomerIDs. Result: 0 rows with null CustomerIDs

SELECT *
FROM ecommerce_silver.clean_online_retail
WHERE CustomerID IS NULL

--Check for CustomerID with more than one country. Result: 13 of 5,939 customers with two associated countries. 

SELECT CustomerID, COUNT(DISTINCT Country) as country_count
FROM ecommerce_silver.clean_online_retail
GROUP BY CustomerID
HAVING country_count>1
ORDER BY CustomerID

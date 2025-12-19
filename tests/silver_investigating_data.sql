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

SELECT  StockCode, ARRAY_AGG(DISTINCT Description)
FROM ecommerce_silver.clean_online_retail
GROUP BY StockCode
HAVING COUNT(DISTINCT Description) > 1
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

--Investigate why the 13 customers have two associated countries. Result: InvoiceDate shows that customer changed their billing/shipping country over time.

SELECT *
FROM ecommerce_silver.clean_online_retail
WHERE CustomerID IN (
    SELECT CustomerID
    FROM ecommerce_silver.clean_online_retail
    GROUP BY CustomerID
    HAVING COUNT(DISTINCT Country) > 1
)
ORDER BY CustomerID

--Investigation for fact_orders gold layer table. 
--Check for null Invoice numbers. Result: 0 rows with null Invoice.

SELECT *
FROM ecommerce_silver.clean_online_retail
WHERE Invoice IS NULL

--Check for one row per order line item (order line is combination of Invoice, StockCode, and CustomerID). Result: found that the same product appears more than once in the same invoice for the same customer

SELECT
    Invoice,
    StockCode,
    CustomerID,
    COUNT(*) AS cnt
FROM ecommerce_silver.clean_online_retail
GROUP BY Invoice, StockCode, CustomerID
HAVING cnt > 1
LIMIT 10;

--Investigate why the same product appears more than once in the same invoice for the same customer. Looked into three order line items that had the issue. Result: Noticed that duplicate combination occurs because of price or quantity changes. Shows that silver table reflects a transactional system (order line events) instead of order line item data.

SELECT *
FROM ecommerce_silver.clean_online_retail
WHERE (Invoice, StockCode, CustomerID) IN (
    ('C570556', '22273', '16029'),
    ('C574922', '22635', '15502'),
    ('C548830', 'M',     '12744')
)
ORDER BY Invoice, StockCode, CustomerID;

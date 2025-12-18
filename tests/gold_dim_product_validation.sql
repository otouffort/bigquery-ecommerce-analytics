--Check that product ID is unique for all rows. Result: 0 rows with duplicate product IDs.

SELECT ProductID, COUNT(*) as numberofproductids
FROM ecommerce_gold.dim_product
GROUP BY ProductID
HAVING numberofproductids > 1

--Chose 3 product IDs with variations of product descriptions and checked that table kept the most frequent description for each product. Compared it to silver layer table frequency count.

SELECT *
FROM ecommerce_gold.dim_product
WHERE ProductID IN ("20718","20615","17129F")
ORDER BY ProductID

SELECT StockCode, Description, COUNT(*) as numberofproductids
FROM ecommerce_silver.clean_online_retail
WHERE StockCode ("20718","20615","17129F")
GROUP BY StockCode, Description
HAVING numberofproductids > 1
ORDER BY StockCode


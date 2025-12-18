--Check to see if product ID is unique for all rows

SELECT ProductID, COUNT(*) as numberofproductids
FROM ecommerce_gold.dim_product
GROUP BY ProductID
HAVING numberofproductids > 1

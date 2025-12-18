--Check for negative product price

SELECT COUNT(*) AS negative_price_count
FROM ecommerce_bronze.raw_online_retail_clean
WHERE Price < 0;

--Check for returns (negative quantity)

SELECT COUNT(*) AS negative_quantity_count
FROM ecommerce_bronze.raw_online_retail_clean
WHERE Quantity < 0;

--Check for null customerIDs

SELECT COUNT(*) AS null_customers
FROM ecommerce_bronze.raw_online_retail_clean
WHERE CustomerID IS NULL;

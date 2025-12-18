--Test to confirm that transformation didn't accidentally null everything
  
SELECT
  COUNT(*) AS total_rows,
  COUNT(CustomerID) AS non_null_customer_ids
FROM ecommerce_bronze.raw_online_retail_clean;

--Test to compare count of non-null values before and after transformation

SELECT
  COUNT(*) AS total_rows,
  COUNT(`Customer ID`) AS raw_non_null,
  COUNT(SAFE_CAST(FLOOR(`Customer ID`) AS STRING)) AS cleaned_non_null
FROM ecommerce_bronze.raw_online_retail;

--Test to validate format. Specifically, to see that there are no decimal places.

SELECT CustomerID
FROM ecommerce_bronze.raw_online_retail_clean
WHERE CustomerID LIKE '%.%'
LIMIT 10;

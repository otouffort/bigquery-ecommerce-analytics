--Check for no null customer ID. Result: 0 rows returned.

SELECT CustomerID
FROM ecommerce_gold.dim_customer
WHERE CustomerID IS NULL

--Chose 3 customers to check that most recent country was picked for customers with more than one country. Result: Confirmed the most recent country was picked for these customers.

SELECT CustomerID, Country, MAX(InvoiceDate) as latest_invoice_date
FROM ecommerce_silver.clean_online_retail
WHERE CustomerID IN ("12370","12417","12423")
GROUP BY CustomerID, Country
ORDER BY CustomerID, latest_invoice_date

SELECT *
FROM ecommerce_gold.dim_customer
WHERE CustomerID IN ("12370","12417","12423")
ORDER BY CustomerID

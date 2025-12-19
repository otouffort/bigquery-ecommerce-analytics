--Uniqueness of surrogate key. Result: 0 rows returned.

SELECT OrderLineID, COUNT(OrderLineID) AS count_of_rows
FROM ecommerce_gold.fact_orders
GROUP BY OrderLineID
HAVING count_of_rows>1;

--No null InvoiceID. Result: 0 rows returned.

SELECT *
FROM ecommerce_gold.fact_orders
WHERE CustomerID IS NULL OR ProductID IS NULL;

--No null foreign keys. Result: 0 rows returned.

SELECT *
FROM ecommerce_gold.fact_orders
WHERE CustomerID IS NULL OR ProductID IS NULL;

--Check revenue calculation

SELECT Quantity, UnitPrice, Revenue
FROM ecommerce_gold.fact_orders
LIMIT 10;

-- Check that revenue total in gold layer matches revenue total in silver layer. Result: Both gave the same total revenue of $16,648,292.39.

SELECT SUM(Revenue)
FROM ecommerce_gold.fact_orders;

SELECT SUM(Quantity * Price) as Revenue
FROM ecommerce_silver.clean_online_retail;

--Analyze customers with the most number of total orders, date of their latest order, and how long they have been purchasing

WITH first_purchase AS (
    SELECT CustomerID, MIN(InvoiceDate) AS first_order
    FROM ecommerce_gold.fact_orders
    GROUP BY CustomerID
)
SELECT
    f.CustomerID,
    COUNT(DISTINCT f.InvoiceID) AS total_orders,
    MAX(f.InvoiceDate) AS last_order,
    DATE_DIFF(MAX(f.InvoiceDate), MIN(f.InvoiceDate), DAY) AS days_between_first_last
FROM ecommerce_gold.fact_orders f
JOIN first_purchase fp
ON f.CustomerID = fp.CustomerID
GROUP BY f.CustomerID
ORDER BY total_orders DESC
LIMIT 20;

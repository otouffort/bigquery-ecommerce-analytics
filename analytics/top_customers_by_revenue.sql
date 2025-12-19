--Analyze the top customers by revenue, and their average order value (AOV). Result: The top customer by revenue is Customer ID 18102. They have 153 orders worth $598,215.22 which equates to an AOV of $3,909.90.

WITH customer_totals AS (
    SELECT
        c.CustomerID,
        COUNT(DISTINCT f.InvoiceID) AS total_orders,
        SUM(f.Revenue) AS total_revenue
    FROM ecommerce_gold.fact_orders f
    JOIN ecommerce_gold.dim_customers c
    ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID
)
SELECT
    CustomerID,
    total_orders,
    total_revenue,
    total_revenue / total_orders AS average_order_value
FROM customer_totals
ORDER BY total_revenue DESC
LIMIT 10;

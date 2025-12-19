--Analysis for each group of customers who made their first purchase in a given month (cohort), how many of them were active in subsequent months?

WITH first_purchase AS (
    SELECT CustomerID, DATE_TRUNC(MIN(InvoiceDate), MONTH) AS cohort_month
    FROM ecommerce_gold.fact_orders
    GROUP BY CustomerID
)
SELECT
    fp.cohort_month,
    DATE_TRUNC(f.InvoiceDate, MONTH) AS order_month,
    COUNT(DISTINCT f.CustomerID) AS active_customers
FROM ecommerce_gold.fact_orders f
JOIN first_purchase fp
ON f.CustomerID = fp.CustomerID
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

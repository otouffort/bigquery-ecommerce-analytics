--Anayze how monthly revenue has changed over time.

SELECT
    DATE_TRUNC(InvoiceDate, MONTH) AS month,
    SUM(Revenue) AS monthly_revenue
FROM ecommerce_gold.fact_orders
GROUP BY month
ORDER BY month;

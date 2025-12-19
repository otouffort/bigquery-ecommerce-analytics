--Top 10 products by revenue. Result: The top product by revenue is REGENCY CAKESTAND 3 TIER (Product ID: 22423) with 23,431 units sold for a value of $269,736.70

SELECT
    p.ProductID,
    p.Description,
    SUM(f.Revenue) AS TotalRevenue,
    SUM(f.Quantity) AS TotalUnitsSold
FROM ecommerce_gold.fact_orders f
JOIN ecommerce_gold.dim_product p
ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.Description
ORDER BY TotalRevenue DESC
LIMIT 10;

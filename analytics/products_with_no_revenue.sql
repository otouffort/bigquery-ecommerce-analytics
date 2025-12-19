--Analyze how many products have no sales. Result: 12 products have no sales. 

SELECT
    p.ProductID,
    p.Description,
    SUM(f.Revenue) AS TotalRevenue,
    SUM(f.Quantity) AS TotalUnitsSold
FROM ecommerce_gold.fact_orders f
JOIN ecommerce_gold.dim_product p
ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.Description
HAVING TotalRevenue = 0
ORDER BY p.ProductID

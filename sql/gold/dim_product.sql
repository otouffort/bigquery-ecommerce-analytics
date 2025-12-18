--Product dimension table with product attributes. Product Description assigned based on top frequency. 

CREATE OR REPLACE TABLE ecommerce_gold.dim_products AS
WITH description_counts AS (
    SELECT
        StockCode AS ProductID,
        Description,
        COUNT(*) AS cnt
    FROM ecommerce_silver.clean_online_retail
    GROUP BY StockCode, Description
),
ranked_descriptions AS (
    SELECT
        ProductID,
        Description,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY cnt DESC) AS rn
    FROM description_counts
)
SELECT
    ProductID,
    Description
FROM ranked_descriptions
WHERE rn = 1;

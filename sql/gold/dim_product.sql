--Product dimension table with product attributes. Product description assigned based on highest frequency count in silver layer table. 

CREATE OR REPLACE TABLE ecommerce_gold.dim_product AS
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

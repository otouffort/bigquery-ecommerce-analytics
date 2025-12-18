--Product dimension table with product attributes

CREATE OR REPLACE TABLE ecommerce_gold.dim_product AS
SELECT DISTINCT
    StockCode as ProductID,
    Description
FROM ecommerce_silver.clean_online_retail;

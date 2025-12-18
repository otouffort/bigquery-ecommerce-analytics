-- Silver layer: cleaned table with revenue calculation

CREATE OR REPLACE TABLE ecommerce_silver.clean_online_retail AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CustomerID,
    Country,
    Quantity * Price AS line_revenue
FROM ecommerce_bronze.raw_online_retail_clean
WHERE
    CustomerID IS NOT NULL
    AND Price > 0;

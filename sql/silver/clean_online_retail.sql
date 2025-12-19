-- Silver layer: cleaned table
-- Removes null CustomerIDs
-- Removes Price less than or equal to zero

CREATE OR REPLACE TABLE ecommerce_silver.clean_online_retail AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CustomerID,
    Country
FROM ecommerce_bronze.raw_online_retail_clean
WHERE
    CustomerID IS NOT NULL
    AND Price > 0;

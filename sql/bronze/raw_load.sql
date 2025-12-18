-- Bronze layer transformation
-- Standardizes CustomerID from FLOAT to STRING
-- Handles numeric IDs (e.g. 17850.0) safely
-- Preserves NULLs and raw data integrity

CREATE OR REPLACE TABLE ecommerce_bronze.raw_online_retail_clean AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    SAFE_CAST(FLOOR(`Customer ID`) AS STRING) AS CustomerID,
    Country
FROM ecommerce_bronze.raw_online_retail;

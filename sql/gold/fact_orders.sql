--Fact table with transactional events (order line events). Includes surrogate key as unique identifier and revenue derived metric.

CREATE OR REPLACE TABLE ecommerce_gold.fact_orders AS
SELECT
    GENERATE_UUID() AS OrderLineID,
    Invoice AS InvoiceID,
    CustomerID,
    StockCode AS ProductID,
    InvoiceDate,
    Quantity,
    Price AS UnitPrice,
    Quantity * Price AS Revenue
FROM ecommerce_silver.clean_online_retail;

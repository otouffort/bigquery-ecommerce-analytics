--Customer dimension table with customer attributes. Goal is one row per customer ID. 
--Investigation in silver layer showed multiple countries per customer. Decided to handle this by keeping most recent country based on InvoicedDate. 

CREATE OR REPLACE TABLE ecommerce_gold.dim_customer AS
WITH ranked_customers AS (
    SELECT
        CustomerID,
        Country,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID
            ORDER BY InvoiceDate DESC
        ) AS rn
    FROM ecommerce_silver.clean_online_retail
)
SELECT
    CustomerID,
    Country
FROM ranked_customers
WHERE rn = 1;

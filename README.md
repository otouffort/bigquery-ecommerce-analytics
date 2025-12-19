# bigquery-ecommerce-analytics

# Bronze Layer: Raw Ingestion & Schema Normalization

The Online Retail dataset was manually uploaded into BigQuery using schema auto-detection due to inconsistent data types in the source CSV. Dataset has 1,067,371 rows of retail data. Customer ID was inferred as a FLOAT (e.g., 17850.0) becausse of the CSV’s formatting.

To standardize the customer identifier while preserving raw data integrity, a Bronze-layer transformation was applied to (refer to raw_load.sql in sql/bronze folder):
- Convert Customer ID from FLOAT to STRING
- Remove trailing decimals using FLOOR and SAFE_CAST
- Retain null values for missing customer identifiers
- Maintain all other fields in their original, unfiltered form

Data quality checks were applied to validate Bronze-layer transformation (refer to bronze_customer_id_validation.sql in tests folder):
- No loss of non-null Customer IDs
- Consistent non-null values row counts before and after transformation
- Correct formatting of IDs

Data investigation of Bronze Layer before creating Silver Layer to understand potential data quality issues (refer to bronze_investigating_data.sql in tests folder):
- Check for negative prices. Result: 5 rows with negative prices
- Check for negative quantities (returns). Result: 22,950 rows indicate returned items. Note: Returns are kept in the dataset for future revenue and refund analysis.
- Check for null customer IDs. Result: 243,007 of 1,067,371 rows are missing customer IDs

# Silver Layer: Cleaned and Enriched E-commerce Transactions

The Silver layer contains cleaned and standardized data from the Bronze layer. This layer ensures data quality for downstream Gold tables and dashboard visualizations.

Transformations applied to create clean Silver Layer table (refer to clean_online.sql in sql/silver folder):
1. Filtered invalid records
- Removed rows with null customer IDs
- Removed rows with negative product price

2. Added a derived metric
- Added line_revenue as Quantity * Price for each transaction

Data quality checks were applied to validate Silver-layer transformation (refer to silver_data_validation.sql in tests folder):
- Confirmed no null Customer IDs. 
- Confirmed no negative price. 
- Confirmed revenue calculation.

Data investigation of Silver Layer before creating Gold Layer to understand potential issues (refer to silver_investigating_data.sql in tests folder):

...

# Gold Layer: Fact and Dimension Tables

Product Dimension Table: Represents unique products in ecommerce dataset and product attributes.

Goal: 
- Ensure one row per product for analytics and dashboard purposes.
- Resolve multiple descriptions per product found in the Silver layer.

Transformation to create dim_product table (refer to dim_product.sql in sql/gold folder):
- Counts description frequency per product in Silver Layer (description_counts)
- Rank descriptions per product by frequency (ranked_descriptions)
- Select the top-ranked description (rn = 1) to keep in the dimension table.

Data quality checks were applied to validate Gold-layer transformation for dim_product table (refer to gold_dim_product_validation.sql in tests folder):
- Confirmed that ProductID is unique
- Confirmed no null ProductIDs
- Spot checked for description correctness: Verified that the description chosen for each product matches the most frequent description in the Silver layer.

Customer Dimension Table: Represents unique customers in ecommerce dataset and customer attributes.

Goal: 
- Ensure one row per CustomerID for analytics and dashboard purposes.
- Resolve customers associated with multiple countries over time.

Approach:
- Selected the most recent country per customer based on InvoiceDate.
  - Ensures consistency and a single country value for each customer in analytics.
- Observed that 13 customers had country changes over time.  
  - These changes were due to real-world behavior (e.g., relocation or billing changes).  
  - For simplicity in this project, only the most recent country was kept (Type 1 Slowly Changing Dimension).  
  - Optionally, a Type 2 SCD could be implemented in a production scenario to track historical country changes.

Transformation to create dim_customer table (refer to dim_customer.sql in sql/gold folder):
- Groups all orders by each customer (PARTITION BY CustomerID)
- Sorts each customer’s orders from most recent to oldest (ORDER BY InvoiceDate DESC)
- Assigns a rank to each row within the customer’s orders, wherein, the most recent order gets rn = 1.
- Keeps only the latest country per customer.

Data quality checks were applied to validate Gold-layer transformation for dim_customer table (refer to gold_dim_customer_validation.sql in tests folder):
- Confirmed that CustomerID is unique
- Confirmed no null Customer ID
- Spot-checked customers with multiple countries to confirme that most recent country was selected.

Fact Orders Table: Represents transactional data (order line events).

Goal:
- Capture one row per order line event
- Keep the schema clean and normalized: descriptive attributes like product name and customer country remain in dimension tables.
- Include derived metrics for quick analysis (e.g., revenue per line).

Transformation to create fact_orders table (refer to fact_orders.sql in sql/gold folder):

...

Data quality checks were applied to validate Gold-layer transformation for fact_orders table (refer to gold_fact_orders_validation.sql in tests folder):

...

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

Data Profiling of Bronze Layer before creating Silver Layer to understand potential data quality issues (refer to bronze_investigating_data.sql in tests folder):
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

# Gold Layer: Fact and Dimension Tables

Product Dimension Table: Represents unique products in ecommerce dataset

Goal: 
- Ensure one row per product for analytics and dashboard purposes.
- Resolve multiple descriptions per product found in the Silver layer.

Transformation to create dim_product table (refer to dim_product.sql in sql/gold folder):
- Counts description frequency per product in Silver Layer (description_counts)
- Rank descriptions per product by frequency (ranked_descriptions)
- Select the top-ranked description (rn = 1) to keep in the dimension table.

Data quality checks were applied to validate Gold-layer transformation for dim_product table (refer to gold_dim_product_validation.sql in tests folder):
- Confirmed that ProductID is unique
- Spot checked for description correctness: Verified that the description chosen for each product matches the most frequent description in the Silver layer.



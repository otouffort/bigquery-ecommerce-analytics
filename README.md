# bigquery-ecommerce-analytics

# Bronze Layer: Raw Ingestion & Schema Normalization

The Online Retail dataset was manually uploaded into BigQuery using schema auto-detection due to inconsistent data types in the source CSV. Dataset has 1,067,371 rows of retail data. Customer ID was inferred as a FLOAT (e.g., 17850.0) becausse of the CSV’s formatting.

To standardize the customer identifier while preserving raw data integrity, a Bronze-layer transformation was applied to:
- Convert Customer ID from FLOAT to STRING
- Remove trailing decimals using FLOOR and SAFE_CAST
- Retain null values for missing customer identifiers
- Maintain all other fields in their original, unfiltered form

Data quality checks were applied to validate Bronze-layer transformation:
- No loss of non-null Customer IDs
- Consistent non-null values row counts before and after transformation
- Correct formatting of IDs

Data Profiling of Bronze Layer before creating Silver Layer to understand potential data quality issues (refer to investigating_data.sql in tests folder):
- Check for negative prices. Result: 5 rows with negative prices
- Check for negative quantities (returns). Result: 22,950 rows indicate returned items. Note: Returns are kept in the dataset for future revenue and refund analysis.
- Check for null customer IDs. Result: 243,007 of 1,067,371 rows are missing customer IDs


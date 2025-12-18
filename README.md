# bigquery-ecommerce-analytics

# Bronze Layer: Raw Ingestion & Schema Normalization

The Online Retail dataset was manually uploaded into BigQuery using schema auto-detection due to inconsistent data types in the source CSV. Customer ID was inferred as a FLOAT (e.g., 17850.0) becausse of the CSV’s formatting.

To standardize identifiers while preserving raw data integrity, a Bronze-layer transformation was applied to:
- Normalize Customer ID from FLOAT → STRING
- Safely remove decimal artifacts using SAFE_CAST and FLOOR
- Retain null values for missing customer identifiers
- Maintain all other fields in their original, unfiltered form

This approach reflects real-world ingestion practices where raw data may contain inconsistent types and requires controlled normalization before downstream transformations.

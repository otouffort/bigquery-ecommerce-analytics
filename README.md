# Google BigQuery E-Commerce Analytics Pipeline

<img width="1080" height="584" alt="ArchitectureDiagram" src="https://github.com/user-attachments/assets/706e57ed-be78-4c0b-a937-b97ab9d4637d" />

# Project Overview

This project demonstrates a full e-commerce data pipeline built using Google BigQuery, showcasing skills in data ingestion, cleaning, transformation, dimensional modeling, and analytics. Tech Stack: Google BigQuery, SQL, Looker Studio.

The dataset used is the Online Retail II dataset from Kaggle, which contains transactional data for an online retail store.

The project follows a medallion architecture:
- Bronze Layer: Raw transactional data is ingested into BigQuery, preserving the original dataset.
- Silver Layer: Data is cleaned and standardized, including:
  - Removing negative Price values
  - Removing null CustomerID
- Gold Layer: Analytics-ready tables are created, including:
  - Dimension tables: dim_product and dim_customers
  - Fact table: fact_orders capturing individual order lines with derived revenue metric

Analytics queries were performed to answer business questions such as:
- Which products and customers generate the most revenue?
- How does monthly revenue trend over time?
- Which customers are most active, and how is retention over time?
- Which products have not generated revenue?

This project highlights:
- SQL expertise: DML, DDL, joins, aggregations, CTEs, and window functions
- Data engineering skills: Data cleaning, transformations, star schema modeling, and fact/dimension table creation
- Business analytics skills: Deriving actionable insights for e-commerce decision-making using SQL and Looker Studio dashboard

The repository includes SQL scripts organized by layer, data quality checks, analytics queries, and Looker Studio dashboard demonstrating a full end-to-end data workflow.

# Folder Structure

The repository is organized to reflect a full data engineering and analytics workflow, following the medallion architecture (bronze → silver → gold):
- data/: Contains raw CSV files downloaded manually from Kaggle. This is the starting point for the pipeline.
- sql/: Organizes all SQL scripts by purpose:
  - bronze/: Scripts for raw data ingestion into BigQuery.
  - silver/: Scripts for cleaning, standardizing.
  - gold/: Scripts for creating dimensional (dim_product, dim_customers) and fact (fact_orders) tables.
- analytics/: SQL queries answering business questions, such as top products, customer retention, and revenue trends.
- tests/: Data validation scripts to ensure correctness at each medallion stage (e.g., no null CustomerID, no negative prices, uniqueness checks).
- dashboard/: visualizations summarizing key metrics and insights
- docs/: architecture diagram
  
# Bronze Layer: Raw Ingestion & Schema Normalization

The Online Retail dataset was manually uploaded into BigQuery using schema auto-detection due to inconsistent data types in the source CSV. Dataset has 1,067,371 rows of retail data. Customer ID was inferred as a FLOAT (e.g., 17850.0) because of the CSV’s formatting.

To standardize the customer identifier while preserving raw data integrity, a bronze layer transformation was applied to (refer to raw_load.sql in sql/bronze folder):
- Convert Customer ID from FLOAT to STRING
- Remove trailing decimals using FLOOR and SAFE_CAST
- Retain null values for missing customer identifiers
- Maintain all other fields in their original, unfiltered form

Data quality checks were applied to validate bronze layer transformation (refer to bronze_customer_id_validation.sql in tests folder):
- No loss of non-null Customer IDs
- Consistent non-null values row counts before and after transformation
- Correct formatting of Customer IDs

Data investigation of bronze layer before creating silver layer to understand potential data quality issues (refer to bronze_investigating_data.sql in tests folder):
- Check for negative prices. Result: 5 rows with negative prices
- Check for negative quantities (returns). Result: 22,950 rows indicate returned items. Note: Returns are kept in the dataset for future revenue and refund analysis.
- Check for null customer IDs. Result: 243,007 of 1,067,371 rows have null customer IDs

# Silver Layer: Cleaned Data from Bronze Layer

The silver layer contains cleaned and standardized data from the bronze layer. This layer ensures data quality for downstream gold tables and dashboard visualizations.

Transformations applied to create clean silver layer table (refer to clean_online.sql in sql/silver folder):
- Removed rows with null customer IDs
- Removed rows with negative product price

Data quality checks were applied to validate silver layer transformation (refer to silver_data_validation.sql in tests folder):
- Confirmed no null Customer IDs. 
- Confirmed no negative price. 

Data investigation of silver Layer before creating gold Layer to understand potential issues (refer to silver_investigating_data.sql in tests folder):
- Investigation for dim_product gold layer table. 
  - Check for null StockCodes. Result: 0 rows with null StockCode
  - Check for StockCode with more than one type of distinct product description. Result: 624 of 4,646 products with multiple variations of product descriptions.
  - Investigate choosing product description for products with variations of product descriptions based on frequency.
- Investigation for dim_customer gold layer table.
  - Check for null CustomerIDs. Result: 0 rows with null CustomerIDs
  - Check for CustomerID with more than one country. Result: 13 of 5,939 customers with two associated countries. 
  - Investigate why the 13 customers have two associated countries. Result: InvoiceDate shows that customer changed their billing/shipping country over time.
- Investigation for fact_orders gold layer table. 
  - Check for null Invoice IDs. Result: 0 rows with null Invoice.
  - Check for one row per order line item (order line is combination of Invoice, StockCode, and CustomerID). Result: found that the same product appears more than once in the same invoice for the same customer
  - Investigate why the same product appears more than once in the same invoice for the same customer. Looked into three order line items that had the issue. Result: Noticed that duplicate combination occurs because of price or quantity changes. Shows that silver table reflects a transactional system (order line events) instead of order line item data.

# Gold Layer: Fact and Dimension Tables

Product Dimension Table: Represents unique products in the e-commerce dataset and product attributes.

Goal: 
- Ensure one row per product for analytics and dashboard purposes.
- Resolve multiple descriptions per product found in the silver layer.

Transformation to create dim_product table (refer to dim_product.sql in sql/gold folder):
- Counts description frequency per product in silver Layer (description_counts)
- Rank descriptions per product by frequency (ranked_descriptions)
- Select the top-ranked description (rn = 1) to keep in the dimension table.

Data quality checks were applied to validate gold layer transformation for dim_product table (refer to gold_dim_product_validation.sql in tests folder):
- Confirmed that ProductID is unique
- Confirmed no null ProductIDs
- Spot-checked for description accuracy to verified that the description chosen for each product matches the most frequent description in the silver layer.

Customer Dimension Table: Represents unique customers in the e-commerce dataset and customer attributes.

Goal: 
- Ensure one row per CustomerID for analytics and dashboard purposes.
- Resolve customers associated with multiple countries over time.

Approach:
- Selected the most recent country per customer based on InvoiceDate.
  - Ensures consistency and a single country value for each customer in analytics.
- Observed that 13 customers had country changes over time.  
  - These changes are due to real-world behavior (e.g., relocation or billing changes).  
  - For simplicity in this project, only the most recent country was kept (Type 1 Slowly Changing Dimension).  
  - Optionally, a Type 2 SCD could be implemented in a production scenario to track historical country changes.

Transformation to create dim_customer table (refer to dim_customer.sql in sql/gold folder):
- Groups all orders by each customer (PARTITION BY CustomerID)
- Sorts each customer’s orders from most recent to oldest (ORDER BY InvoiceDate DESC)
- Assigns a rank to each row within the customer’s orders, wherein, the most recent order gets rn = 1.
- Keeps only the latest country per customer.

Data quality checks were applied to validate gold layer transformation for dim_customer table (refer to gold_dim_customer_validation.sql in tests folder):
- Confirmed that CustomerID is unique
- Confirmed no null Customer ID
- Spot-checked customers with multiple countries to confirm that most recent country was selected

Fact Orders Table: Represents transactional data (order line events).

Goal:
- Capture one row per order line event
- Keep the schema clean and normalized: descriptive attributes like product name and customer country remain in dimension tables.
- Include derived metrics for quick analysis (e.g., revenue per line).

Transformation to create fact_orders table (refer to fact_orders.sql in sql/gold folder):
- Generate a surrogate key
- Renamed columns for clarity and consistency
- Added derived revenue metric

Data quality checks were applied to validate gold layer transformation for fact_orders table (refer to gold_fact_orders_validation.sql in tests folder):
- Uniqueness of surrogate key
- No null InvoiceID
- No null foreign keys
- Confirmed that total revenue in gold layer matches total revenue in silver layer

# Analytics/Insights

1. Top Customers by Revenue (refer to top_customers_by_revenue.sql in analytics folder)
- Question: Who are the top customers by total revenue and what is their average order value?
- Business insight: Helps target high-value customers for marketing campaigns or loyalty programs.

2. Top Products by Revenue (refer to top_products_by_revenue.sql in analytics folder)
- Question: Which products generate the most revenue?
- Business insight: Helps identify highest-revenue products to inform inventory management. 

3. Products with No Revenue (refer to products_with_no_revenue.sql in analytics folder)
- Question: Which products have generated no revenue?
- Business insight: Helps identify underperforming or inactive products.
  
4. Revenue by Month (refer to revenue_by_month.sql in analtics folder)
- Question: How has monthly revenue changed over time?
- Business insight: Identifies trends in sales to show seasonal cycles. 

5. Customer Purchase Activity (refer to customer_purchase_activity.sql in analytics folder)
- Question: Which customers are the most active? How long have they been making purchases, and how frequently?
- Business insight: Highlights top customers by engagement, showing who places the most orders.

7. Customer Retention (refer to customer_retention.sql in analytics folder)
- Question: How do customers who made their first purchase in a given month behave in subsequent months? How many customers from each cohort remain active over time?
- Busienss insight: Measures customer retention over time, showing how cohorts continue to engage with the business after their first purchase. This can help identify trends in loyalty, potential churn, and effectiveness of onboarding or promotional strategies.

### Fact Orders Optimization

In a production environment, the fact_orders table could be partitioned by InvoiceDate to improve query performance and reduce scanned data.  
Additionally, clustering by CustomerID and ProductID could further speed up queries that filter or aggregate on these columns.  

For this project, partitioning and clustering were not implemented to simplify setup, but the table design is compatible with these optimizations.

#  Looker Studio Dashboard

A Looker Studio executive-level dashboard was created on top of the gold-layer tables to visualize key e-commerce metrics. The dashboard features KPI cards, revenue over time, and ranked tables for top products and customers.

<img width="1438" height="1077" alt="LookerStudioDashboard" src="https://github.com/user-attachments/assets/f98d5aae-9b3c-4ead-aa8b-99c98f4ff403" />


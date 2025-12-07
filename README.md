# CSCI E-103 Final Project – Energy Prosumers Lakehouse  
### Group 1 – Fall 2025

---

## 📘 Project Overview

Our team was tasked with acting as consultants for a SaaS company aiming to build a **scalable data lakehouse** and a **machine learning prediction pipeline**.  
The use case is based on **Estonian energy prosumers** (customers who both consume and produce energy, often via solar panels).  

Our objectives were to:

1. **Ingest** raw Kaggle datasets into a governed Lakehouse  
2. **Apply multi-layer transformations** using the Medallion Architecture (Bronze → Silver → Gold)  
3. Build a **machine learning model** to help predict **electricity production and consumption**  
4. Deliver a **business intelligence dashboard** powered by curated Gold tables  
5. Provide architectural, modeling, and data governance documentation  

---

## 👥 Team Members & Roles

| Name      | Role(s) |
|-----------|---------|
| **Luke** | Data Engineer 1 |
| **Kenichi** | Data Engineer 2 |
| **Selin** | Data Scientist 1 |
| **Liwei** | Data Scientist 2 & BI Analyst 1 |
| **Peiran** | BI Analyst 2 |
| **Abby** | Data Architect 1 & Group Leader |
| **Chijioke** | Data Architect 2 |

---

# 🏗️ Architecture Summary

We implemented a **Lakehouse** using Delta Lake with three layers:

### **BRONZE** – Raw Delta tables created from CSVs  
### **SILVER** – Cleaned, enriched, and (for weather data) **streamed**  
### **GOLD** – Aggregated, business-ready tables for BI and ML  

Streaming was implemented for the Silver layer using Structured Streaming + `trigger(once=True)`.

---

# 📊 End-to-End Data Lineage Diagram  
*(Developed by Kenichi – Data Engineer 2)*

This diagram shows how raw data flows from ingestion to BI outputs.

```text
                             ┌──────────────────────────────┐
                             │     Raw CSV Files (Kaggle)    │
                             │  client.csv                   │
                             │  train.csv                    │
                             │  gas_prices.csv               │
                             │  electricity_prices.csv       │
                             │  historical_weather.csv        │
                             │  forecast_weather.csv          │
                             │  weather_station_mapping.csv   │
                             └───────────────┬────────────────┘
                                             |
                                             v
                          ┌────────────────────────────────────────┐
                          │              BRONZE LAYER              │
                          │     (Raw, Ingested Delta Tables)       │
                          │-----------------------------------------│
                          │ bronze_client                          │
                          │ bronze_train                           │
                          │ bronze_gas_prices                      │
                          │ bronze_electricity_prices              │
                          │ bronze_weather_hist                    │
                          │ bronze_weather_forecast                │
                          │ bronze_weather_mapping                 │
                          └───────────────┬────────────────────────┘
                                          |
                                          v
                ┌──────────────────────────────────────────────────────────┐
                │                      SILVER LAYER                        │
                │       (Cleaned, Enriched, **STREAMING** Version)        │
                │----------------------------------------------------------│
                │ Streaming read from:                                     │
                │   - bronze_weather_hist                                  │
                │   - bronze_weather_forecast                              │
                │ Join with static mapping table:                          │
                │   - bronze_weather_mapping (adds county)                 │
                │ Structured Streaming w/ trigger=once →                   │
                │   - silver_weather_hist_stream                           │
                │   - silver_weather_forecast_stream                       │
                │ Checkpoints stored in UC Volume                          │
                └───────────────┬──────────────────────────────────────────┘
                                |
                                v
        ┌─────────────────────────────────────────────────────────────────────────┐
        │                                GOLD LAYER                               │
        │     (Business-level aggregates, upserts, optimized for BI queries)      │
        │-------------------------------------------------------------------------│
        │ gold_daily_energy_report                                                │
        │ - Combines county weather, pricing, and consumption                     │
        │ - Uses Delta MERGE for incremental updates                              │
        │ - OPTIMIZE + ZORDER BY (county, date)                                   │
        └───────────────────┬──────────────────────────────────────────────────────┘
                            |
                            v
                   ┌──────────────────────────────────┐
                   │   BI Dashboards + ML Workloads    │
                   │  (Consuming curated Gold tables)  │
                   └──────────────────────────────────┘


🛠️ Data Engineering
Data Engineer 1 – Luke

Luke built the foundation of the data pipeline, including:

✔ GitHub Repository & Initial Notebook Framework

Created the group repository and structured the project

Provided the starting point for the lakehouse pipeline

✔ Bronze Layer Ingestion

Ingested raw CSVs into Delta format using:

bronze_client

bronze_train

bronze_gas_prices

bronze_electricity_prices

bronze_weather_hist

bronze_weather_forecast

bronze_weather_mapping

✔ Batch Silver Layer

Joined weather tables with county mapping

Produced initial Silver tables for downstream use

✔ Gold Aggregations & MERGE Logic

Built gold_daily_energy_report with:

Daily aggregations

Pricing joins

Delta MERGE for incremental updates

Luke’s work established the compute-ready Lakehouse that the rest of the team built upon.

Data Engineer 2 – Kenichi

Kenichi completed the remaining Data Engineering requirements and enhanced pipeline robustness, performance, and documentation.

🔹 1. Implemented Silver STRUCTURED STREAMING pipeline (trigger=once)

Converted Silver weather transformations into a streaming job

Used spark.readStream.table(...) for Bronze weather inputs

Joined with static mapping table

Wrote outputs to:

silver_weather_hist_stream

silver_weather_forecast_stream

Added checkpointing in Unity Catalog Volume

Fulfilled the DE rubric requirement for incremental streaming via trigger(once=True)

🔹 2. Added Data Quality Checks + Configuration Layer

Verified Bronze table existence

Checked for required columns (lat, long, datetime)

Centralized catalog, schema, and volume configuration

Improved maintainability and debugging for all teammates

🔹 3. Optimized the Gold Layer

Added BI performance tuning:

OPTIMIZE gold_daily_energy_report
ZORDER BY (county, date);

🔹 4. Created End-to-End Data Lineage Diagram

Produced a clean, intuitive pipeline diagram

Added 00_data_lineage_diagram notebook with documentation

Provided a key visual aid for the final presentation

🔹 5. Added Helper Utilities for the Team

Reusable functions such as:

table_info()

compare_schemas()

preview()

validate_columns()

These tools improved debugging, exploration, and development efficiency.

🔹 6. Documentation, Hardening & Cross-team Support

Improved notebook explanations

Added comments and markdown

Ensured consistency across pipeline layers

🤖 Data Science (to be completed by Selin & Liwei)

Examples of what will go here:

Data exploration & feature engineering

Model training (e.g., XGBoost, AutoML)

MLflow tracking: parameters, metrics, artifacts

Model evaluation and comparison

Serving predictions or saving Gold ML inference tables

(This section is a placeholder for DS teammates to complete.)

📊 BI & Dashboarding (to be completed by Liwei & Peiran)

Examples expected here:

SQL queries used to build the dashboard

Visualizations created (line charts, bar charts, time-series views)

Role-based access model (California vs non-California groups)

Refresh schedule and materialized views

(This section is a placeholder for BI teammates to complete.)

🏛️ Data Architecture (to be completed by Abby & Chijioke)

This section should include:

ERD diagram with PK/FK relationships

Explanation of table cardinality & scale

Partitioning strategy

CI/CD considerations

Disaster recovery plan

Extended dataflow diagram (if applicable)

(This section is a placeholder for Data Architects to complete.)

📁 Repository Structure
final-project/
│
├── 00_data_lineage_diagram
├── 00_helper_utilities
├── 01_ingest_bronze
├── 02_processing_silver
├── 02A_processing_silver_streaming   ← (Kenichi)
├── 03_reporting_gold
└── README.md

▶️ Running the Pipeline

Run 01_ingest_bronze to create Bronze Delta tables

Run 02_processing_silver OR 02A_processing_silver_streaming

Run 03_reporting_gold

BI dashboard queries pull from Gold tables

ML model consumes curated Silver/Gold features

📚 References

Databricks Delta Lake Documentation

CSCI E-103 Course Content

Kaggle Estonian Energy Prosumers Dataset

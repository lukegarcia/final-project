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
```

---

# 🧑‍💼 Team Contributions

This section describes the contributions of each role in our group, aligned to the project requirements of CSCI E-103.

---

## 🛠️ Data Engineering

### **Data Engineer 1 – Luke**

Luke developed the foundational components of our Lakehouse pipeline:

#### ✔ Repository & Project Framework
- Created the GitHub repository and initial notebook structure  
- Established folder organization used throughout the project  

#### ✔ Bronze Layer Ingestion
Converted raw Kaggle CSVs into Delta tables, including:

- `bronze_client`  
- `bronze_train`  
- `bronze_gas_prices`  
- `bronze_electricity_prices`  
- `bronze_weather_hist`  
- `bronze_weather_forecast`  
- `bronze_weather_mapping`  

#### ✔ Batch Silver Layer  
- Joined weather data with county mapping  
- Produced initial Silver weather tables used by downstream consumers  

#### ✔ Gold Aggregation Layer (Batch)
Implemented the first Gold-level business table:

- Built `gold_daily_energy_report`  
- Performed daily aggregations  
- Added Delta **MERGE** logic for incremental updates  

**Luke’s work created the initial medallion pipeline upon which the rest of the system was built.**

---

### **Data Engineer 2 – Kenichi**

Kenichi completed the remaining Data Engineering requirements and significantly enhanced reliability and performance.

#### 🔹 1. Implemented Silver Structured Streaming Layer (`trigger=once`)
- Converted the Silver weather processing pipeline into a **Structured Streaming** job  
- Streaming inputs:  
  - `bronze_weather_hist`  
  - `bronze_weather_forecast`
- Joined with dimension table:  
  - `bronze_weather_mapping` (adds county)
- Outputs:
  - `silver_weather_hist_stream`  
  - `silver_weather_forecast_stream`
- Implemented checkpointing in UC Volume  
- Fully satisfies the DE rubric requirement for *incremental processing via streaming*  

#### 🔹 2. Added Configuration + Data Quality Checks  
Strengthened pipeline quality by adding:

- Centralized catalog/schema/volume configuration  
- Table existence checks before streaming  
- Required column validation (lat/long/datetime)  
- Clear error surfacing to prevent silent failures  

#### 🔹 3. Optimized Gold Layer Performance  
Added BI-focused optimization:

```sql
OPTIMIZE gold_daily_energy_report
ZORDER BY (county, date);
```
#### 🔹 4. Created the End-to-End Data Lineage Diagram
- Authored a clear, intuitive lineage diagram (notebook: `00_data_lineage_diagram`)  
- Illustrates how data moves through the Medallion Architecture  
- Highlights where Structured Streaming occurs  
- Used as a visual anchor during the final presentation  

#### 🔹 5. Added Data Engineering Helper Utilities
Developed reusable helper functions used by Data Engineering, Data Science, and BI:

- `table_info(table)` – Row count, column count, schema  
- `compare_schemas(table1, table2)` – Highlights differences between tables  
- `preview(table)` – Displays first rows and schema  
- `validate_columns(table, expected_cols)` – Checks for required columns  

These utilities speed up debugging, validation, and schema exploration across the team.

#### 🔹 6. Pipeline Hardening & Documentation
- Added markdown explanations to notebooks  
- Ensured naming and configuration conventions were consistent  
- Improved maintainability and clarity of the DE pipeline  

---

## 🤖 Data Science  
*(To be completed by Selin & Liwei)*

Expected content for this section:

- Exploratory Data Analysis (EDA)  
- Feature engineering  
- Model training (e.g., XGBoost, AutoML)  
- MLflow experiment tracking (parameters, metrics, artifacts)  
- Model evaluation methodology  
- Integration of predictions with Silver/Gold tables  

---

## 📊 Business Intelligence  
*(To be completed by Liwei & Peiran)*

Expected BI deliverables:

- SQL queries powering dashboards  
- Visualizations of daily usage, pricing, and production trends  
- Materialized views or refresh schedules  
- BI security model (California vs non-California access rules)  
- Dashboard layout and business insights  

---

## 🏛️ Data Architecture  
*(To be completed by Abby & Chijioke)*

Expected content for this section:

- ERD with PK/FK relationships  
- Table cardinality & scale explanations  
- Partitioning & indexing strategy  
- CI/CD & deployment considerations  
- Disaster recovery planning  
- Extended enterprise architecture diagrams  

---

## 📁 Repository Structure

final-project/
│
├── 00_data_lineage_diagram/ ← Lineage diagram (Kenichi)
├── 00_helper_utilities/ ← Helper DE utilities (Kenichi)
├── 01_ingest_bronze/ ← Bronze ingestion (Luke)
├── 02_processing_silver/ ← Silver (batch) (Luke)
├── 02A_processing_silver_streaming/ ← Silver (streaming) (Kenichi)
├── 03_reporting_gold/ ← Gold aggregation + optimization
└── README.md


---

## ▶️ Running the Pipeline

1. **Run `01_ingest_bronze`** to create Bronze Delta tables  
2. **Run either:**
   - `02_processing_silver` (batch)  
   - `02A_processing_silver_streaming` (streaming – recommended)  
3. **Run `03_reporting_gold`** to generate Gold aggregates  
4. BI & ML workflows consume Gold tables as inputs  

---

## 📚 References

- Databricks Delta Lake Documentation  
- CSCI E-103 Course Lectures & Labs  
- Kaggle: Estonian Energy Prosumers Dataset  


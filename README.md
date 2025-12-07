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
---

# 🛠️ Data Engineering

## **Data Engineer 1 – Luke**

Luke built the foundation of the Lakehouse pipeline, enabling the rest of the team to work from a consistent and well-structured environment.

### ✔ GitHub Repository & Project Framework  
- Created the GitHub repository for team collaboration  
- Set up the initial folder and notebook structure  

### ✔ Bronze Layer Ingestion  
Developed the full ingestion layer, converting raw CSVs into managed Delta tables:

- `bronze_client`  
- `bronze_train`  
- `bronze_gas_prices`  
- `bronze_electricity_prices`  
- `bronze_weather_hist`  
- `bronze_weather_forecast`  
- `bronze_weather_mapping`  

### ✔ Batch Silver Layer  
- Joined historic and forecast weather data with station-to-county mapping  
- Produced the initial Silver tables for modeling and BI use:  
  - `silver_weather_hist`  
  - `silver_weather_forecast`  

### ✔ Gold Aggregation Layer (Batch)  
Implemented the first version of the Gold layer aggregations:

- Created `gold_daily_energy_report`  
- Performed daily aggregations on energy usage  
- Joined pricing and weather data  
- Implemented Delta **MERGE** for incremental upserts  

**Luke’s work established the core ingestion and transformation pipeline that the rest of the team built upon.**

---

## **Data Engineer 2 – Kenichi**

Kenichi completed the remaining Data Engineering requirements and significantly enhanced pipeline reliability, performance, and documentation.

### 🔹 **1. Implemented Silver Structured Streaming Pipeline (trigger=once)**  
Converted the Silver weather processing into a **streaming** architecture:

- Streaming inputs:  
  - `bronze_weather_hist`  
  - `bronze_weather_forecast`
- Joined with static mapping:  
  - `bronze_weather_mapping`
- Output tables:  
  - `silver_weather_hist_stream`  
  - `silver_weather_forecast_stream`
- Added checkpointing in UC Volume  
- Implemented **`trigger(once=True)`** to meet the DE rubric’s incremental processing requirement  

### 🔹 **2. Added Configuration + Data Quality Checks**  
Strengthened pipeline robustness by verifying:

- Bronze table existence  
- Expected columns (latitude, longitude, datetime)  
- Centralized configuration for catalog, schema, and storage paths  
- Improved readability and reduced risk of silent failures  

### 🔹 **3. Gold Layer Performance Optimization**  
Added BI-focused performance tuning:

```sql
OPTIMIZE gold_daily_energy_report
ZORDER BY (county, date);


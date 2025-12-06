# Databricks notebook source
# MAGIC %md
# MAGIC # Data Engineering Lineage Diagram  
# MAGIC **Prepared by: Kenichi Carter – Data Engineer**
# MAGIC
# MAGIC This notebook provides a visual overview of our project’s end-to-end data flow using the Lakehouse Medallion Architecture (Bronze → Silver → Gold).  
# MAGIC It highlights how raw Kaggle data is ingested, refined, streamed, enriched with mapping data, and finally transformed into business-ready aggregates for BI dashboards and analytical use cases.
# MAGIC
# MAGIC A key component of this pipeline is the **Silver Structured Streaming layer**, which I implemented using Delta Live Structured Streaming with `trigger(once=True)` and checkpointing stored in our UC Volume. This enables incremental, reproducible data refinement consistent with modern Data Engineering practices. This diagram illustrates our project’s medallion architecture, with raw Kaggle CSVs landing in the Bronze layer, followed by my Structured Streaming Silver transformations, and culminating in optimized Gold aggregates ready for BI.
# MAGIC
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## 📊 End-to-End Data Lineage Diagram
# MAGIC
# MAGIC ```text
# MAGIC                              ┌──────────────────────────────┐
# MAGIC                              │     Raw CSV Files (Kaggle)    │
# MAGIC                              │  client.csv                   │
# MAGIC                              │  train.csv                    │
# MAGIC                              │  gas_prices.csv               │
# MAGIC                              │  electricity_prices.csv       │
# MAGIC                              │  historical_weather.csv        │
# MAGIC                              │  forecast_weather.csv          │
# MAGIC                              │  weather_station_mapping.csv   │
# MAGIC                              └───────────────┬────────────────┘
# MAGIC                                              |
# MAGIC                                              v
# MAGIC                           ┌────────────────────────────────────────┐
# MAGIC                           │              BRONZE LAYER              │
# MAGIC                           │     (Raw, Ingested Delta Tables)       │
# MAGIC                           │-----------------------------------------│
# MAGIC                           │ bronze_client                          │
# MAGIC                           │ bronze_train                           │
# MAGIC                           │ bronze_gas_prices                      │
# MAGIC                           │ bronze_electricity_prices              │
# MAGIC                           │ bronze_weather_hist                    │
# MAGIC                           │ bronze_weather_forecast                │
# MAGIC                           │ bronze_weather_mapping                 │
# MAGIC                           └───────────────┬────────────────────────┘
# MAGIC                                           |
# MAGIC                                           v
# MAGIC                 ┌──────────────────────────────────────────────────────────┐
# MAGIC                 │                      SILVER LAYER                        │
# MAGIC                 │       (Cleaned, Enriched, **STREAMING** Version)        │
# MAGIC                 │----------------------------------------------------------│
# MAGIC                 │ Streaming read from:                                     │
# MAGIC                 │   - bronze_weather_hist                                  │
# MAGIC                 │   - bronze_weather_forecast                              │
# MAGIC                 │ Join with static table:                                  │
# MAGIC                 │   - bronze_weather_mapping (adds county)                 │
# MAGIC                 │ Written with Structured Streaming (trigger=once):        │
# MAGIC                 │   - silver_weather_hist_stream                           │
# MAGIC                 │   - silver_weather_forecast_stream                       │
# MAGIC                 │ Checkpoints stored in UC Volume for reproducibility      │
# MAGIC                 └───────────────┬──────────────────────────────────────────┘
# MAGIC                                 |
# MAGIC                                 v
# MAGIC         ┌─────────────────────────────────────────────────────────────────────────┐
# MAGIC         │                                GOLD LAYER                               │
# MAGIC         │     (Business-level aggregates, upserts, optimized for BI queries)      │
# MAGIC         │-------------------------------------------------------------------------│
# MAGIC         │ gold_daily_energy_report                                                │
# MAGIC         │ - Combines county weather, pricing, and consumption                     │
# MAGIC         │ - Aggregates daily energy use                                           │
# MAGIC         │ - Uses Delta MERGE for incremental updates                              │
# MAGIC         │ - Performance tuning: Z-ORDER BY (county, date)                         │
# MAGIC         └───────────────────┬──────────────────────────────────────────────────────┘
# MAGIC                             |
# MAGIC                             v
# MAGIC                    ┌──────────────────────────────────┐
# MAGIC                    │   BI Dashboards + ML Workloads    │
# MAGIC                    │  (Consuming curated Gold tables)  │
# MAGIC                    └──────────────────────────────────┘
# MAGIC
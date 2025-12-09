# Databricks notebook source
"""
GOLD LAYER
- aggregate for daily reporting and upserts
"""
from delta.tables import *
from pyspark.sql.functions import col, sum, avg, to_date

def create_gold():
    print("Building Gold Layer")

    # Get energy consumption from bronze
    energy_df = spark.read.table("bronze_train") \
        .filter(col("is_consumption") == 1) \
        .withColumn("date", to_date("datetime")) \
        .groupBy("date", "county") \
        .agg(sum("target").alias("total_energy"))

    # Get temp from silver
    weather_df = spark.read.table("silver_weather_hist") \
        .withColumn("date", to_date("datetime")) \
        .groupBy("date", "county") \
        .agg(avg("temperature").alias("avg_temp"))

    # Create master table for Gold layer
    report_df = energy_df.join(weather_df, on=["date", "county"], how="left")

    # Create target table
    target_table_name = "gold_daily_energy_report"
    target_path = "/Volumes/workspace/default/cscie103_final_project/gold_report"
    
    if not spark.catalog.tableExists(target_table_name):
        print("Creating table...")
        report_df.write.format("delta").saveAsTable(target_table_name)
        print("Table created.")
        return

    # Merge with upsert logic
    deltaTable = DeltaTable.forName(spark, target_table_name)

    deltaTable.alias("target").merge(
        report_df.alias("source"),
        "target.date = source.date AND target.county = source.county"
    ).whenMatchedUpdateAll(
    ).whenNotMatchedInsertAll(
    ).execute()

    print(f"Merge/Upsert complete for {target_table_name}")

create_gold()

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Optimize the Gold table for faster BI queries
# MAGIC OPTIMIZE gold_daily_energy_report
# MAGIC ZORDER BY (county, date);
# MAGIC

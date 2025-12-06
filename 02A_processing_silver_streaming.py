# Databricks notebook source
# Use the same catalog and schema as the other notebooks
spark.sql("USE CATALOG workspace")
spark.sql("USE SCHEMA default")


# COMMAND ----------

# -----------------------------------------
# CONFIGURATION & DATA QUALITY CHECKS
# -----------------------------------------

# Centralized configuration for easier maintenance
CATALOG = "workspace"
SCHEMA = "default"
VOLUME = "/Volumes/workspace/default/cscie103_final_project"

print(f"Using catalog: {CATALOG}, schema: {SCHEMA}")
print(f"Project volume: {VOLUME}")

# Basic sanity check on Bronze input tables
required_tables = ["bronze_weather_hist", "bronze_weather_forecast", "bronze_weather_mapping"]

for tbl in required_tables:
    try:
        df = spark.read.table(tbl)
        print(f"✓ Table '{tbl}' loaded successfully with {df.count()} rows and {len(df.columns)} columns.")
    except Exception as e:
        raise Exception(f"ERROR: Table '{tbl}' could not be read. "
                        f"Please confirm Bronze ingestion completed. Details: {e}")

# Check for required columns in weather data
bronze_hist = spark.read.table("bronze_weather_hist")
expected_cols = {"latitude", "longitude", "datetime"}

missing = expected_cols - set(bronze_hist.columns)
if missing:
    raise Exception(f"ERROR: Missing expected columns in bronze_weather_hist: {missing}")
else:
    print("✓ bronze_weather_hist contains all required columns:", expected_cols)


# COMMAND ----------

"""
SILVER LAYER (STREAMING VERSION)
- Reads from Bronze Delta tables as a streaming source
- Joins with static mapping table (bronze_weather_mapping) to add 'county'
- Writes to Silver Delta tables using structured streaming with trigger=once
- This satisfies the 'stream from one Delta table to another incrementally using trigger once' requirement.
"""

from pyspark.sql.functions import col

# Base checkpoint root 
checkpoint_root = "/Volumes/workspace/default/cscie103_final_project/checkpoints/silver"

def process_silver_streaming(source_table: str, target_table: str, checkpoint_subdir: str):
    """
    Streaming version of the Silver processing step.

    Parameters
    ----------
    source_table : str
        Name of the Bronze Delta table to read as a streaming source.
    target_table : str
        Name of the Silver Delta table to write.
    checkpoint_subdir : str
        Subdirectory name (under checkpoint_root) for this stream's checkpoints.
    """

    print(f"Streaming processing from {source_table} -> {target_table}")

    # Static mapping table – read once, regular batch DataFrame
    mapping_df = (
        spark.read.table("bronze_weather_mapping")
             .drop("_ingestion_time", "_source_file")
    )

    # Streaming source: read from Bronze Delta table
    weather_stream_df = (
        spark.readStream
             .table(source_table)   # = readStream.format("delta").table(...)
    )

    # Join streaming weather with static mapping to get 'county'
    enriched_stream_df = (
        weather_stream_df.join(
            mapping_df,
            on=["latitude", "longitude"],
            how="left"
        )
    )

    # Build checkpoint path for this specific stream
    checkpoint_path = f"{checkpoint_root}/{checkpoint_subdir}"

    (
        enriched_stream_df.writeStream
            .format("delta")
            .outputMode("append")            # we're appending new rows
            .trigger(once=True)              # process all available data once, then stop
            .option("checkpointLocation", checkpoint_path)
            .option("mergeSchema", "true")   # allow schema evolution if needed
            .toTable(target_table)
    )

    print(f"Streaming write started for {target_table}. "
          "This run will finish when all available data is processed.")


# Run streaming jobs for both historical and forecast weather
process_silver_streaming(
    source_table="bronze_weather_hist",
    target_table="silver_weather_hist_stream",
    checkpoint_subdir="silver_weather_hist"
)

process_silver_streaming(
    source_table="bronze_weather_forecast",
    target_table="silver_weather_forecast_stream",
    checkpoint_subdir="silver_weather_forecast"
)


# COMMAND ----------

spark.table("silver_weather_hist_stream").show(5)
spark.table("silver_weather_forecast_stream").show(5)

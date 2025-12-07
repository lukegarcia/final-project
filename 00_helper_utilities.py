# Databricks notebook source
# -----------------------------------------
# Helper Utilities for Data Engineering
# Prepared by: Kenichi Carter – Data Engineer
# -----------------------------------------

from pyspark.sql import DataFrame

def table_info(table_name: str):
    """
    Prints row count, column count, and schema for a Delta table.
    """
    try:
        df = spark.read.table(table_name)
        print(f"\n=== TABLE INFO: {table_name} ===")
        print(f"Rows: {df.count():,}")
        print(f"Columns: {len(df.columns)}")
        print("\nSchema:")
        df.printSchema()
    except Exception as e:
        print(f"ERROR: Could not read table '{table_name}'. Details: {e}")


def compare_schemas(table1: str, table2: str):
    """
    Compares schemas of two tables and prints differences.
    """
    df1 = spark.read.table(table1)
    df2 = spark.read.table(table2)

    cols1 = set(df1.columns)
    cols2 = set(df2.columns)

    print(f"\n=== SCHEMA COMPARISON: {table1} vs {table2} ===")
    print("Columns in table1 but NOT in table2:", cols1 - cols2)
    print("Columns in table2 but NOT in table1:", cols2 - cols1)


def preview(table_name: str, n: int = 5):
    """
    Displays the first n rows of a table and its schema.
    """
    df = spark.read.table(table_name)
    print(f"\n=== PREVIEW OF {table_name} (first {n} rows) ===")
    display(df.limit(n))   # Databricks display()
    df.printSchema()


def validate_columns(table_name: str, expected_cols: set):
    """
    Ensures the table contains required columns.
    """
    df = spark.read.table(table_name)
    missing = expected_cols - set(df.columns)

    print(f"\n=== COLUMN VALIDATION FOR {table_name} ===")
    print("Expected:", expected_cols)
    print("Missing:", missing if missing else "None ✓")

    return missing

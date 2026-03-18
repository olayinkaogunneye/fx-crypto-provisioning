"""
FX SFTP Ingestion Script
------------------------

This script simulates downloading FX rate data from an external SFTP source.
Since we don't have access to a real SFTP server, we store a CSV file
in a GitHub repository and download it using its raw URL.

This script is Fabric‑ready:
- Python is used for downloading + pandas
- PySpark is used for writing to the Lakehouse
- Designed to be imported and executed inside a Fabric notebook
"""

# -------------------------------------------------------------
# 1. Imports
# -------------------------------------------------------------
import pandas as pd
import requests
import io
from datetime import datetime
from pyspark.sql import SparkSession


# Ensure Spark session exists (Fabric provides one automatically)
spark = SparkSession.builder.getOrCreate()


# -------------------------------------------------------------
# 2. Helper Function: Download CSV File
# -------------------------------------------------------------
def download_fx_csv(file_url: str) -> pd.DataFrame:
    """
    Downloads a CSV file from a given URL and loads it into a pandas DataFrame.
    """

    response = requests.get(file_url)
    response.raise_for_status()

    csv_bytes = response.content
    csv_buffer = io.StringIO(csv_bytes.decode("utf-8"))

    df = pd.read_csv(csv_buffer)
    return df


# -------------------------------------------------------------
# 3. Helper Function: Add Metadata
# -------------------------------------------------------------
def add_ingestion_metadata(df: pd.DataFrame, source_name: str) -> pd.DataFrame:
    """
    Adds ingestion metadata (timestamp + source file name).
    """

    df_with_meta = df.copy()
    df_with_meta["ingestion_timestamp"] = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    df_with_meta["source_file_name"] = source_name

    return df_with_meta


# -------------------------------------------------------------
# 4. Helper Function: Write to Bronze Layer
# -------------------------------------------------------------
def write_to_bronze(df: pd.DataFrame, table_name: str):
    """
    Writes the DataFrame to the Bronze layer inside the Fabric Lakehouse.
    """

    spark_df = spark.createDataFrame(df)

    (
        spark_df
        .write
        .format("delta")
        .mode("append")
        .saveAsTable(table_name)
    )

    print(f"✔ Data successfully written to Bronze table: {table_name}")


# -------------------------------------------------------------
# 5. Main Ingestion Function
# -------------------------------------------------------------
def run_fx_ingestion():
    """
    Orchestrates the entire FX ingestion workflow.
    """

    # ---------------------------------------------------------
    # Step 1: Define the source URL for the FX CSV file.
    # ---------------------------------------------------------
    file_url = "https://raw.githubusercontent.com/olayinkaogunneye/fx-crypto-provisioning/refs/heads/main/data/fx_global_daily.csv"
    source_name = "fx_global_daily.csv"

    print("Starting FX ingestion process...")
    print(f"Downloading FX data from: {file_url}")

    # ---------------------------------------------------------
    # Step 2: Download the CSV file into a pandas DataFrame.
    # ---------------------------------------------------------
    fx_df = download_fx_csv(file_url)
    print(f"✔ Download complete. Rows loaded: {len(fx_df)}")

    # ---------------------------------------------------------
    # Step 3: Add ingestion metadata.
    # ---------------------------------------------------------
    fx_df_with_meta = add_ingestion_metadata(fx_df, source_name)
    print("✔ Metadata added to DataFrame.")

    # ---------------------------------------------------------
    # Step 4: Write the data to the Bronze table in Fabric.
    # ---------------------------------------------------------
    table_name = "bronze_fx_rates_raw"
    write_to_bronze(fx_df_with_meta, table_name)

    print("✔ FX ingestion process completed successfully.")
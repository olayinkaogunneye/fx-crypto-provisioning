"""
FX SFTP Ingestion Script
------------------------

This script simulates downloading FX rate data from an external SFTP source.
Since we don't have access to a real SFTP server, we will store a CSV file
in a GitHub repository and download it using its raw URL.

This version includes the first real piece of logic:
- The function that downloads the CSV file and loads it into a pandas DataFrame.
"""

# -------------------------------------------------------------
# 1. Imports
# -------------------------------------------------------------
import pandas as pd
import requests
import io
from datetime import datetime


# -------------------------------------------------------------
# 2. Helper Function: Download CSV File
# -------------------------------------------------------------
def download_fx_csv(file_url: str) -> pd.DataFrame:
    """
    Downloads a CSV file from a given URL and loads it into a pandas DataFrame.

    Parameters
    ----------
    file_url : str
        The URL pointing to the raw CSV file in GitHub (simulating SFTP).

    Returns
    -------
    pd.DataFrame
        A pandas DataFrame containing the FX data.

    Explanation
    -----------
    This function does three simple things:
    1. Sends an HTTP GET request to download the CSV file.
    2. Converts the downloaded bytes into a text stream.
    3. Uses pandas to read the CSV into a DataFrame.

    We keep the logic simple and readable so anyone can follow it.
    """

    # Step 1: Send a GET request to the URL
    # If the request fails (e.g., wrong URL), we raise an error.
    response = requests.get(file_url)
    response.raise_for_status()  # This stops the script if the download fails.

    # Step 2: Convert the downloaded bytes into a file-like object.
    # pandas can read from this object as if it were a real file.
    csv_bytes = response.content
    csv_buffer = io.StringIO(csv_bytes.decode("utf-8"))

    # Step 3: Load the CSV into a pandas DataFrame.
    df = pd.read_csv(csv_buffer)

    return df


# -------------------------------------------------------------
# 3. Helper Function: Add Metadata (placeholder)
# -------------------------------------------------------------
def add_ingestion_metadata(df: pd.DataFrame, source_name: str) -> pd.DataFrame:
    """
    Adds ingestion metadata to the DataFrame.
    (Implementation will be added later.)
    """
    pass


# -------------------------------------------------------------
# 4. Helper Function: Write to Bronze Layer (placeholder)
# -------------------------------------------------------------
def write_to_bronze(df: pd.DataFrame, table_name: str):
    """
    Writes the DataFrame to the Bronze layer.
    (Implementation will be added later.)
    """
    pass


# -------------------------------------------------------------
# 5. Main Ingestion Function (placeholder)
# -------------------------------------------------------------
def run_fx_ingestion():
    """
    Orchestrates the FX ingestion process.
    (Implementation will be added later.)
    """
    pass


# -------------------------------------------------------------
# 6. Script Entry Point
# -------------------------------------------------------------
if __name__ == "__main__":
    run_fx_ingestion()


def add_ingestion_metadata(df: pd.DataFrame, source_name: str) -> pd.DataFrame:
    """
    Adds ingestion metadata to the DataFrame.

    Why this matters:
    -----------------
    In real data engineering work, every dataset needs to be traceable.
    If someone asks:
        - "When was this data ingested?"
        - "Which file did it come from?"
    …we should be able to answer confidently.

    This function adds two simple but important columns:
        1. ingestion_timestamp  -> when the data entered our system
        2. source_file_name     -> which file or URL it came from

    Parameters
    ----------
    df : pd.DataFrame
        The FX data loaded from the CSV file.
    source_name : str
        The name of the file or source (e.g., 'fx_rates.csv').

    Returns
    -------
    pd.DataFrame
        The same DataFrame, but with metadata columns added.
    """

    # Make a copy of the DataFrame so we don't accidentally modify the original.
    df_with_meta = df.copy()

    # Add the timestamp of when the ingestion happened.
    # We use UTC to avoid timezone confusion.
    df_with_meta["ingestion_timestamp"] = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

    # Add the name of the source file or URL.
    df_with_meta["source_file_name"] = source_name

    return df_with_meta

def write_to_bronze(df: pd.DataFrame, table_name: str):
    """
    Writes the DataFrame to the Bronze layer inside the Fabric Lakehouse.

    This is the real ingestion step. The logic is simple:
        1. Convert the pandas DataFrame into a Spark DataFrame.
        2. Write it as a Delta table inside the Lakehouse.
        3. Use 'append' mode so new data adds to the table.

    Parameters
    ----------
    df : pd.DataFrame
        The FX data with metadata already added.
    table_name : str
        The name of the Bronze table (e.g., 'bronze_fx_rates_raw').

    Returns
    -------
    None
    """

    # Convert pandas DataFrame to Spark DataFrame.
    # Fabric notebooks run on a Spark engine, so this is supported.
    spark_df = spark.createDataFrame(df)

    # Write the Spark DataFrame into the Lakehouse as a Delta table.
    # 'append' means new data is added without overwriting existing data.
    (
        spark_df
        .write
        .format("delta")
        .mode("append")
        .saveAsTable(table_name)
    )

    print(f"✔ Data successfully written to Bronze table: {table_name}")

def run_fx_ingestion():
    """
    Orchestrates the entire FX ingestion workflow.

    This function ties all the steps together in a simple, readable way.
    The goal is to make the ingestion process easy to follow for anyone
    reading the code — whether they are a beginner or an experienced engineer.

    Steps performed:
        1. Download the FX CSV file from GitHub.
        2. Add ingestion metadata (timestamp + source file name).
        3. Write the data into the Bronze layer using Spark.

    Notes:
    ------
    - The file_url should point to the raw CSV file in your GitHub repo.
    - The table_name should match the Bronze table you want to write to.
    """

    # ---------------------------------------------------------
    # Step 1: Define the source URL for the FX CSV file.
    # ---------------------------------------------------------
    # Replace this with the actual raw GitHub URL once your CSV is uploaded.
    file_url = "https://raw.githubusercontent.com/<your-username>/<your-repo>/main/data/fx_rates.csv"
    source_name = "fx_rates.csv"

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

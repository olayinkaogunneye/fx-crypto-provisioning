import requests
import pandas as pd
from datetime import datetime
from pyspark.sql import SparkSession
from pyspark.sql.functions import lit
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType

def run_crypto_ingestion():
    print("Starting Crypto ingestion process...")

    # -----------------------------------------
    # 1. Define API endpoint + assets to ingest
    # -----------------------------------------
    assets = ["bitcoin", "ethereum", "solana"]
    vs_currency = "usd"

    api_url = (
        "https://api.coingecko.com/api/v3/simple/price"
        f"?ids={','.join(assets)}&vs_currencies={vs_currency}"
    )

    print(f"Calling CoinGecko API: {api_url}")

    # -----------------------------------------
    # 2. Call API
    # -----------------------------------------
    response = requests.get(api_url)

    if response.status_code != 200:
        raise Exception(f"API request failed: {response.status_code} - {response.text}")

    data = response.json()
    print("✓ API call successful.")

    # -----------------------------------------
    # 3. Convert JSON → pandas DataFrame
    # -----------------------------------------
    rows = []
    ingestion_ts = datetime.utcnow()

    for asset in assets:
        if asset in data:
            price = data[asset].get(vs_currency)
            rows.append({
                "asset_symbol": asset,
                "price_usd": price,
                "source_api": "coingecko",
                "ingestion_ts": ingestion_ts
            })

    pdf = pd.DataFrame(rows)
    print(f"✓ Parsed {len(pdf)} crypto price records.")

    # -----------------------------------------
    # 4. Convert pandas → Spark DataFrame
    # -----------------------------------------
    spark = SparkSession.builder.getOrCreate()

    schema = StructType([
        StructField("asset_symbol", StringType(), True),
        StructField("price_usd", DoubleType(), True),
        StructField("source_api", StringType(), True),
        StructField("ingestion_ts", TimestampType(), True)
    ])

    df = spark.createDataFrame(pdf, schema=schema)

    # -----------------------------------------
    # 5. Write to Bronze table
    # -----------------------------------------
    bronze_table = "bronze_crypto_prices_raw"

    df.write.mode("append").format("delta").saveAsTable(bronze_table)

    print(f"✓ Crypto data successfully written to Bronze table: {bronze_table}")
    print("✓ Crypto ingestion process completed successfully.")
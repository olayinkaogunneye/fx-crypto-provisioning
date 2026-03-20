{{ config(materialized='view') }}

select
    cast(ingestion_ts as date) as date,
    cast(price_usd as float) as price,
    asset_symbol as symbol,
    source_api as source,
    ingestion_ts as ingestion_timestamp
from FX_Crypto_Lakehouse.dbo.bronze_crypto_prices_raw
select
    cast(date as date) as date,
    cast(rate as float) as rate,
    currency_pair,
    source,
    ingestion_timestamp,
    source_file_name
from FX_Crypto_Lakehouse.dbo.bronze_fx_rates_raw
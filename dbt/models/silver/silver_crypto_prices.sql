with cleaned as (
    select
        date,
        price,
        upper(symbol) as symbol,
        source,
        ingestion_timestamp
    from {{ ref('bronze_crypto_prices_raw') }}
    where price > 0
),

deduped as (
    select
        *,
        row_number() over (
            partition by date, symbol
            order by ingestion_timestamp desc
        ) as rn
    from cleaned
)

select
    date,
    price,
    symbol,
    source,
    ingestion_timestamp
from deduped
where rn = 1
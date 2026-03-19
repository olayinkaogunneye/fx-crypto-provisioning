with cleaned as (
    select
        date,
        rate,
        upper(currency_pair) as currency_pair,
        source,
        ingestion_timestamp,
        source_file_name
    from {{ ref('bronze_fx_rates_raw') }}
    where rate is not null
),

deduped as (
    select
        *,
        row_number() over (
            partition by date, currency_pair
            order by ingestion_timestamp desc
        ) as rn
    from cleaned
)

select
    date,
    rate,
    currency_pair,
    source,
    ingestion_timestamp,
    source_file_name
from deduped
where rn = 1
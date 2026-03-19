{{ config(
    materialized = 'table',
    tags = ['gold', 'snapshot']
) }}

-- FX snapshot: attach instrument metadata
with fx as (
    select
        f.date,
        f.instrument_key,                     -- unified surrogate key
        i.instrument_name,
        i.instrument_type,
        f.rate as price,
        f.daily_return,
        f.rate_7d_avg as price_7d_avg,
        f.rate_30d_avg as price_30d_avg,
        f.rate_7d_volatility as price_7d_volatility,
        f.rate_30d_volatility as price_30d_volatility,
        i.base_currency,
        i.quote_currency,
        f.source,
        f.ingestion_timestamp
    from {{ ref('fact_fx_rates_daily') }} f
    left join {{ ref('dim_instrument') }} i
        on f.instrument_key = i.instrument_key
),

-- Crypto snapshot: attach instrument metadata
crypto as (
    select
        c.date,
        c.instrument_key,                     -- unified surrogate key
        i.instrument_name,
        i.instrument_type,
        c.price,
        c.daily_return,
        c.price_7d_avg,
        c.price_30d_avg,
        c.price_7d_volatility,
        c.price_30d_volatility,
        i.base_currency,
        i.quote_currency,
        c.source,
        c.ingestion_timestamp
    from {{ ref('fact_crypto_prices_daily') }} c
    left join {{ ref('dim_instrument') }} i
        on c.instrument_key = i.instrument_key
),

-- Combine FX + Crypto into unified snapshot
unioned as (
    select * from fx
    union all
    select * from crypto
)

-- Final snapshot output (no ORDER BY in dbt models)
select
    date,
    instrument_key,
    instrument_name,
    instrument_type,
    price,
    daily_return,
    price_7d_avg,
    price_30d_avg,
    price_7d_volatility,
    price_30d_volatility,
    base_currency,
    quote_currency,
    source,
    ingestion_timestamp
from unioned

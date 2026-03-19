{{ config(
    materialized = 'table',
    tags = ['gold', 'snapshot']
) }}

-- FX snapshot: enrich FX fact table with currency pair metadata
with fx as (
    select
        f.date,
        f.currency_key as asset_key,          -- surrogate key from dim_currency
        f.currency_pair as asset_name,        -- natural key for readability
        f.rate as price,
        f.daily_return,
        f.rate_7d_avg as price_7d_avg,
        f.rate_30d_avg as price_30d_avg,
        f.rate_7d_volatility as price_7d_volatility,
        f.rate_30d_volatility as price_30d_volatility,
        'FX' as asset_type,
        f.source,
        f.ingestion_timestamp,
        c.base_currency,
        c.quote_currency
    from {{ ref('fact_fx_rates_daily') }} f
    left join {{ ref('dim_currency') }} c
        on f.currency_key = c.currency_key
),

-- Crypto snapshot: enrich crypto fact table with asset metadata
crypto as (
    select
        c.date,
        a.asset_key,                          -- surrogate key from dim_asset
        c.symbol as asset_name,               -- natural key for readability
        c.price,
        c.daily_return,
        c.price_7d_avg,
        c.price_30d_avg,
        c.price_7d_volatility,
        c.price_30d_volatility,
        'CRYPTO' as asset_type,
        c.source,
        c.ingestion_timestamp,
        a.asset_type as base_currency,        -- crypto category (e.g., 'crypto')
        null as quote_currency                -- crypto has no quote currency
    from {{ ref('fact_crypto_prices_daily') }} c
    left join {{ ref('dim_asset') }} a
        on c.symbol = a.symbol
),

-- Combine FX and crypto into a unified market snapshot
unioned as (
    select * from fx
    union all
    select * from crypto
)

-- Final unified snapshot output
select
    date,
    asset_key,
    asset_name,
    asset_type,
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
order by date, asset_name

{{ config(materialized='table') }}

-- Base crypto prices from Silver layer
with base as (
    select
        date,
        symbol,
        price,
        source,
        ingestion_timestamp
    from {{ ref('silver_crypto_prices') }}
),

-- Compute previous day's price for return calculation
returns as (
    select
        *,
        lag(price) over (
            partition by symbol
            order by date
        ) as prev_price
    from base
),

-- Calculate daily returns
with_returns as (
    select
        date,
        symbol,
        price,
        source,
        ingestion_timestamp,
        case 
            when prev_price is null then null
            else (price - prev_price) / prev_price
        end as daily_return
    from returns
),

-- Compute rolling averages and rolling volatility
rolling as (
    select
        *,
        avg(price) over (
            partition by symbol
            order by date
            rows between 6 preceding and current row
        ) as price_7d_avg,
        avg(price) over (
            partition by symbol
            order by date
            rows between 29 preceding and current row
        ) as price_30d_avg,
        stdev(price) over (
            partition by symbol
            order by date
            rows between 6 preceding and current row
        ) as price_7d_volatility,
        stdev(price) over (
            partition by symbol
            order by date
            rows between 29 preceding and current row
        ) as price_30d_volatility
    from with_returns
),

-- Attach surrogate key from dim_asset
with_dim as (
    select
        r.*,
        a.asset_key
    from rolling r
    left join {{ ref('dim_asset') }} a
        on r.symbol = a.asset_symbol
)

-- Final crypto fact table
select
    date,
    asset_key,
    symbol,
    price,
    round(daily_return, 6) as daily_return,
    round(price_7d_avg, 6) as price_7d_avg,
    round(price_30d_avg, 6) as price_30d_avg,
    round(price_7d_volatility, 6) as price_7d_volatility,
    round(price_30d_volatility, 6) as price_30d_volatility,
    source,
    ingestion_timestamp
from with_dim

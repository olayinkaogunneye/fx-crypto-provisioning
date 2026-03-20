{{ config(
    materialized='incremental',
    unique_key=['date', 'currency_key']
) }}

-- Base FX rates from Silver layer
with base as (
    select
        date,
        currency_pair,
        source,
        ingestion_timestamp,
        rate
    from {{ ref('silver_fx_rates') }}
),

-- Compute previous day's rate for return calculation
returns as (
    select
        *,
        lag(rate) over (
            partition by currency_pair
            order by date
        ) as prev_rate
    from base
),

-- Calculate daily returns
with_returns as (
    select
        date,
        currency_pair,
        source,
        ingestion_timestamp,
        rate,
        case 
            when prev_rate is null then null
            else (rate - prev_rate) / prev_rate
        end as daily_return
    from returns
),

-- Compute rolling averages and rolling volatility
rolling as (
    select
        *,
        avg(rate) over (
            partition by currency_pair
            order by date
            rows between 6 preceding and current row
        ) as rate_7d_avg,
        avg(rate) over (
            partition by currency_pair
            order by date
            rows between 29 preceding and current row
        ) as rate_30d_avg,
        stdev(rate) over (
            partition by currency_pair
            order by date
            rows between 6 preceding and current row
        ) as rate_7d_volatility,
        stdev(rate) over (
            partition by currency_pair
            order by date
            rows between 29 preceding and current row
        ) as rate_30d_volatility
    from with_returns
),

-- Attach surrogate key from dim_currency
with_dim as (
    select
        r.*,
        c.currency_key
    from rolling r
    left join {{ ref('dim_currency') }} c
        on r.currency_pair = c.currency_pair
)

-- Final FX fact table
select
    date,
    currency_key as instrument_key,
    currency_pair,
    rate,
    round(daily_return, 6) as daily_return,
    round(rate_7d_avg, 6) as rate_7d_avg,
    round(rate_30d_avg, 6) as rate_30d_avg,
    round(rate_7d_volatility, 6) as rate_7d_volatility,
    round(rate_30d_volatility, 6) as rate_30d_volatility,
    source,
    ingestion_timestamp
from with_dim

{% if is_incremental() %}
  where ingestion_timestamp > (select max(ingestion_timestamp) from {{ this }})
{% endif %}
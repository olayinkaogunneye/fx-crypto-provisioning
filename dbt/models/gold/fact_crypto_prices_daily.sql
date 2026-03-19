with base as (
    select
        date,
        symbol,
        price
    from {{ ref('silver_crypto_prices') }}
),

returns as (
    select
        *,
        lag(price) over (
            partition by symbol
            order by date
        ) as prev_price
    from base
),

with_returns as (
    select
        date,
        symbol,
        price,
        case 
            when prev_price is null then null
            else (price - prev_price) / prev_price
        end as daily_return
    from returns
),

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
)

select
    date,
    symbol,
    price,
    round(daily_return, 6) as daily_return,
    round(price_7d_avg, 6) as price_7d_avg,
    round(price_30d_avg, 6) as price_30d_avg,
    round(price_7d_volatility, 6) as price_7d_volatility,
    round(price_30d_volatility, 6) as price_30d_volatility
from rolling
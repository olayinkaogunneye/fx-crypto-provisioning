with base as (
    select
        date,
        currency_pair,
        rate
    from {{ ref('silver_fx_rates') }}
),

returns as (
    select
        *,
        lag(rate) over (
            partition by currency_pair
            order by date
        ) as prev_rate
    from base
),

with_returns as (
    select
        date,
        currency_pair,
        rate,
        case 
            when prev_rate is null then null
            else (rate - prev_rate) / prev_rate
        end as daily_return
    from returns
),

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
)

select
    date,
    currency_pair,
    rate,
    round(daily_return, 6) as daily_return,
    round(rate_7d_avg, 6) as rate_7d_avg,
    round(rate_30d_avg, 6) as rate_30d_avg,
    round(rate_7d_volatility, 6) as rate_7d_volatility,
    round(rate_30d_volatility, 6) as rate_30d_volatility
from rolling
with pairs as (
    select distinct
        currency_pair
    from {{ ref('silver_fx_rates') }}
),

split as (
    select
        currency_pair,
        left(currency_pair, 3) as base_currency,
        right(currency_pair, 3) as quote_currency
    from pairs
)

select
    currency_pair,
    base_currency,
    quote_currency
from split
with assets as (
    select distinct
        symbol
    from {{ ref('silver_crypto_prices') }}
)

select
    symbol,
    symbol as asset_name,
    'crypto' as category
from assets
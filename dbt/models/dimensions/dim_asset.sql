{{ config(materialized='table') }}

with assets as (
    select distinct
        symbol
    from {{ ref('silver_crypto_prices') }}
),

final as (
    select
        row_number() over (order by symbol) as asset_key,
        symbol as asset_symbol,
        symbol as asset_name,
        'crypto' as category
    from assets
)

select * from final
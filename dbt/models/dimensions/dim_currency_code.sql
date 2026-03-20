{{ config(materialized='table') }}

-- Extract all unique currency codes from FX pairs
with all_currencies as (
    select base_currency as currency_code
    from {{ ref('dim_currency') }}
    union
    select quote_currency as currency_code
    from {{ ref('dim_currency') }}
),

-- Add metadata (optional, can be expanded later)
final as (
    select
        row_number() over (order by currency_code) as currency_key,
        currency_code,
        currency_code as currency_name,   -- placeholder
        null as region,                   -- placeholder
        null as iso_number                -- placeholder
    from all_currencies
)

select * from final
{{ config(materialized='table') }}

-- 1. FX instruments
with fx as (
    select
        currency_key as instrument_key,          -- reuse FX surrogate key
        'FX' as instrument_type,
        currency_pair as instrument_name,
        base_currency,
        quote_currency,
        'FX' as category
    from {{ ref('dim_currency') }}
),

-- 2. Crypto instruments
crypto as (
    select
        asset_key + (select max(currency_key) from {{ ref('dim_currency') }}) 
            as instrument_key,                  -- shift crypto keys above FX keys
        'CRYPTO' as instrument_type,
        asset_symbol as instrument_name,
        null as base_currency,
        null as quote_currency,
        category
    from {{ ref('dim_asset') }}
),

-- 3. Combine into unified dimension
unioned as (
    select * from fx
    union all
    select * from crypto
)

select * from unioned
# Data Provisioning  
### FX & Crypto Market Data Provisioning Pipeline

This document explains how the final, business-ready datasets are prepared and made available for downstream use.  
It is written to be **professional, clear, and easy to understand**, even for someone new to data engineering.

---

## 1. Overview

The purpose of data provisioning is to deliver **clean, reliable, and analytics-ready** datasets to the teams and systems that need them.

In this project, provisioning happens at the **Gold layer**, where data has already been:

- Ingested (Bronze)
- Cleaned and standardised (Silver)
- Modelled into business entities (Gold)

The final output is a set of tables that can be used by:

- BI dashboards  
- Analysts  
- Data scientists  
- Reporting systems  
- Downstream applications  

---

## 2. Provisioning Architecture Diagram

Gold Layer (Business Models)
├── dim_currency
├── dim_asset
└── fact_market_snapshot
↓
Provisioned Output
└── mart_market_snapshot


The **mart_market_snapshot** table is the final, provisioned dataset.

---

## 3. Gold Layer Models

### 3.1 `dim_currency`

A simple dimension table containing:

- Currency codes (e.g., USD, EUR)
- Currency names
- Metadata fields

Purpose:
- Provide a consistent reference for FX-related analysis

---

### 3.2 `dim_asset`

A dimension table for crypto assets:

- Asset symbol (e.g., BTC)
- Asset name (e.g., Bitcoin)
- Metadata fields

Purpose:
- Provide a consistent reference for crypto-related analysis

---

### 3.3 `fact_market_snapshot`

A fact table that combines:

- FX rates  
- Crypto prices  
- Standardised timestamps  
- Normalised fields  

Purpose:
- Provide a unified view of market data at a point in time  
- Enable cross-asset analysis  
- Support dashboards and reporting  

---

## 4. Final Provisioned Table: `mart_market_snapshot`

This is the **single source of truth** for downstream consumers.

### 4.1 What it contains

| Field | Description |
|--------|-------------|
| `snapshot_ts` | Timestamp of the market snapshot |
| `base_currency` | FX base currency |
| `quote_currency` | FX quote currency |
| `fx_rate` | Exchange rate |
| `asset_symbol` | Crypto asset symbol |
| `asset_price_usd` | Price of the asset in USD |
| `source` | Data source (FX or Crypto) |
| `ingestion_ts` | When the data was ingested |

### 4.2 Why it matters

This table is:

- Clean  
- Consistent  
- Easy to query  
- Suitable for BI tools  
- Designed for real-world analytics  

It represents the final output of the entire pipeline.

---

## 5. Provisioning Workflow

### Step 1 — Ingestion  
Python scripts load raw data into Bronze.

### Step 2 — Transformation  
dbt models convert Bronze → Silver → Gold.

### Step 3 — Provisioning  
Gold models are combined into a final, curated dataset.

### Step 4 — Consumption  
Downstream users access the provisioned table via:

- Fabric SQL endpoint  
- Power BI  
- Notebooks  
- External tools  

---

## 6. Why Provisioning Matters

Provisioning ensures that:

- Data is **ready to use**  
- Data is **consistent across teams**  
- Analysts don’t need to clean or join raw data  
- Business logic is centralised and documented  
- The organisation has a **single source of truth**  

This is one of the core responsibilities of a **Data Provisioning Engineer**.

---

## 7. Summary

Provisioning is the final step in the pipeline, where clean, modelled data is delivered to end users.  
In this project, the key output is:

- `mart_market_snapshot` — a unified, analytics-ready market dataset

This table demonstrates how external market data can be transformed into a reliable asset for the business.

---
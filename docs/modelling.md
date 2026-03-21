# Data Modelling  
### FX & Crypto Market Data Provisioning Pipeline

This document explains how data is transformed through the **Medallion Architecture** using dbt.  
It is written to be **professional, clear, and easy to understand**, even for someone new to data engineering.

---

## 1. Overview

The project uses the **Medallion Architecture**, a widely adopted pattern for structuring data in modern data platforms:

- **Bronze** → Raw data exactly as ingested  
- **Silver** → Cleaned, standardised, and validated data  
- **Gold** → Business-ready models for analytics and provisioning  

dbt is used to manage all transformations, tests, and documentation.

---

## 2. Medallion Architecture Diagram

Bronze Layer (Raw)
├── bronze_fx_rates_raw
└── bronze_crypto_prices_raw
↓
Silver Layer (Cleaned)
├── silver_fx_rates
└── silver_crypto_prices
↓
Gold Layer (Business Models)
├── dim_currency
├── dim_asset
└── fact_market_snapshot


Each layer builds on the previous one, ensuring clarity, traceability, and reliability.

---

## 3. Bronze Layer — Raw Data

### Purpose  
The Bronze layer stores data **exactly as it arrives** from external sources.

### Characteristics  
- No transformations  
- No renaming  
- No business logic  
- Only ingestion metadata added  
- Stored in Delta format in the Fabric Lakehouse  

### Tables  
| Table | Description |
|--------|-------------|
| `bronze_fx_rates_raw` | Raw FX rates from CSV files |
| `bronze_crypto_prices_raw` | Raw crypto prices from API responses |

### Why it matters  
This layer provides a **single source of truth** for all raw inputs and supports auditability.

---

## 4. Silver Layer — Cleaned & Standardised Data

### Purpose  
The Silver layer applies **light transformations** to make the data consistent and analytics-ready.

### Transformations include  
- Renaming columns  
- Converting data types  
- Removing duplicates  
- Flattening JSON (for API data)  
- Standardising timestamps  
- Basic quality checks (e.g., non-null values)  

### Tables  
| Table | Description |
|--------|-------------|
| `silver_fx_rates` | Cleaned FX rates with consistent schema |
| `silver_crypto_prices` | Cleaned crypto prices with standardised fields |

### Why it matters  
This layer ensures that downstream models work with **clean, reliable, and consistent** data.

---

## 5. Gold Layer — Business Models

### Purpose  
The Gold layer contains **final business-ready tables** used for analytics, dashboards, and provisioning.

### Models  
| Model | Description |
|--------|-------------|
| `dim_currency` | Reference table for FX currencies |
| `dim_asset` | Reference table for crypto assets |
| `fact_market_snapshot` | Combined FX + crypto snapshot for analysis |

### Why it matters  
These models represent the **single source of truth** for market data within the organisation.

They are optimised for:
- BI tools  
- Reporting  
- Downstream systems  
- Provisioning to other teams  

---

## 6. dbt Project Structure

The dbt project follows a clean, scalable structure:

dbt/models/
├── staging/     # Optional: renaming + typing
├── bronze/      # Raw tables
├── silver/      # Cleaned tables
└── gold/        # Business models


### Additional dbt components  
- **tests/** → data quality tests  
- **macros/** → reusable SQL logic  
- **dbt_project.yml** → project configuration  

This structure mirrors best practices used in modern data engineering teams.

---

## 7. Incremental Models

Some models (especially in Silver and Gold) may be configured as **incremental** to improve performance.

Incremental logic typically includes:
- Detecting new records  
- Updating changed records  
- Preserving historical data  

dbt handles this efficiently using:
- `is_incremental()` logic  
- Delta Lake merge operations  

---

## 8. Summary

The modelling layer transforms raw FX and crypto data into clean, reliable, and business-ready tables using:

- The **Medallion Architecture**  
- dbt transformations  
- Clear, modular SQL models  

This approach ensures the pipeline is:
- Scalable  
- Maintainable
- auditable  
- Easy to understand  
- Suitable for real-world data provisioning workflows  

---

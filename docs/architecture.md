# Architecture Overview  
### FX & Crypto Market Data Provisioning Pipeline

This document explains the architecture of the FX & Crypto Market Data Provisioning Pipeline.  
It is written to be **professional, clear, and easy to understand**, even for someone new to data engineering.

---

## 1. Project Summary

This project demonstrates how external market data (FX rates and crypto prices) can be:

- **Ingested** using Python  
- **Stored** in a Fabric Lakehouse  
- **Transformed** using dbt  
- **Organized** using the Medallion Architecture (Bronze → Silver → Gold)  
- **Provisioned** for downstream analytics  

It simulates the workflow of a **Data Provisioning Engineer**, focusing on reliability, clarity, and reproducibility.

---

## 2. High-Level Architecture Diagram

External Sources
├── FX Rates (CSV via simulated SFTP)
└── Crypto Prices (REST API)
↓
Python Ingestion (Fabric Notebook or Script)
↓
Bronze Layer (Raw Lakehouse Tables)
├── bronze_fx_rates_raw
└── bronze_crypto_prices_raw
↓
dbt Transformations
↓ Silver Layer (Cleaned Tables)
├── silver_fx_rates
└── silver_crypto_prices
↓ Gold Layer (Business Models)
├── dim_currency
├── dim_asset
└── fact_market_snapshot
↓
Provisioned Output
└── mart_market_snapshot


This flow mirrors real-world market data pipelines used in fintech, trading, and analytics teams.

---

## 3. Layer-by-Layer Explanation

### 3.1 Bronze Layer — Raw Data

The Bronze layer stores data **exactly as it arrives** from external sources.

Characteristics:
- No transformations  
- No renaming  
- No business logic  
- Only ingestion metadata added (e.g., timestamp, file name)

Purpose:
- Preserve original data for auditability  
- Enable reproducibility  
- Provide a single source of truth for raw inputs  

---

### 3.2 Silver Layer — Cleaned & Standardised Data

The Silver layer applies **light transformations** using dbt:

- Standardize column names  
- Convert data types  
- Remove duplicates  
- Flatten JSON (for API data)  
- Apply basic quality checks  

Purpose:
- Create reliable, analytics-ready tables  
- Ensure consistency across data sources  
- Prepare data for business modelling  

---

### 3.3 Gold Layer — Business Models

The Gold layer contains **final business-ready tables** used by analysts, dashboards, and downstream systems.

Includes:
- `dim_currency` — reference table for FX currencies  
- `dim_asset` — reference table for crypto assets  
- `fact_market_snapshot` — combined FX + crypto snapshot  

Purpose:
- Provide clean, well-structured tables  
- Support reporting, analytics, and provisioning  
- Represent the “single source of truth” for market data  

---

## 4. Ingestion Architecture

### 4.1 FX Rates (Simulated SFTP)

- CSV files stored in GitHub or Azure Storage  
- Python script reads the file  
- Adds metadata (file name, ingestion timestamp)  
- Writes to Bronze table: `bronze_fx_rates_raw`

Why this approach:
- Simulates real SFTP ingestion  
- Easy to automate  
- Matches common market data ingestion patterns  

---

### 4.2 Crypto Prices (REST API)

- Python script calls a public crypto API  
- Parses JSON response  
- Extracts timestamp, symbol, and price  
- Writes to Bronze table: `bronze_crypto_prices_raw`

Why Python:
- Flexible  
- Excellent API support  
- Industry standard for ingestion  

---

## 5. Transformation Architecture (dbt)

dbt handles all transformations from **Bronze → Silver → Gold**.

dbt responsibilities:
- SQL modelling  
- Incremental loads  
- Data quality tests  
- Documentation  
- Lineage graph  

Folder structure:

dbt/models/
├── staging/
├── bronze/
├── silver/
└── gold/


This structure follows dbt best practices used in modern data teams.

---

## 6. Storage Architecture (Fabric Lakehouse)

Fabric Lakehouse provides:

- Delta-based storage  
- SQL endpoint for dbt  
- Unified storage for all layers  
- Easy integration with notebooks and pipelines  

Why it works well:
- Supports medallion architecture  
- Scales easily  
- Ideal for provisioning pipelines  

---

## 7. Orchestration Architecture

Fabric Pipelines will orchestrate:

1. FX ingestion  
2. Crypto ingestion  
3. dbt transformations  
4. Final provisioning  

This ensures the pipeline runs automatically and reliably.

---

## 8. Why This Architecture Matters

This project demonstrates the exact skills expected from a **Data Provisioning Engineer**:

- Ingesting external data sources  
- Working with APIs and file-based feeds  
- Building medallion architectures  
- Using dbt for modelling and testing  
- Preparing clean, provisioned datasets  
- Documenting systems clearly  

It shows not just *what* was built, but *why* each component exists.

---
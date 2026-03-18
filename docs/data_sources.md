# Data Sources  
### FX & Crypto Market Data Provisioning Pipeline

This document describes the external data sources used in this project.  
It is written to be **professional, clear, and easy to understand**, even for someone new to data engineering.

---

## 1. Overview

This project uses two types of external market data:

1. **Foreign Exchange (FX) Rates**  
   - Provided as CSV files  
   - Simulates an SFTP-based market data feed  

2. **Cryptocurrency Prices**  
   - Retrieved from a public REST API  
   - Represents real-time or near real-time market data  

These two sources allow us to demonstrate ingestion patterns for both **file-based** and **API-based** data — a common requirement in data provisioning roles.

---

## 2. FX Rates (CSV via Simulated SFTP)

### 2.1 Description  
FX rates represent the exchange rate between two currencies (e.g., USD → EUR).  
In real organisations, FX data often arrives via:

- SFTP servers  
- Vendor feeds (e.g., Bloomberg, Refinitiv)  
- Daily batch files  

To simulate this, we use **CSV files stored in a controlled location** (GitHub or Azure Storage).

### 2.2 Example Fields  
| Column | Description |
|--------|-------------|
| `fx_date` | Date of the FX rate |
| `base_currency` | Currency being converted from (e.g., USD) |
| `quote_currency` | Currency being converted to (e.g., EUR) |
| `rate` | Exchange rate value |
| `source_file_name` | Name of the ingested file |
| `ingestion_ts` | Timestamp when the file was ingested |

### 2.3 Ingestion Method  
- Python script reads the CSV file  
- Adds metadata (file name, ingestion timestamp)  
- Writes raw data to the **Bronze** table:  
  `bronze_fx_rates_raw`

### 2.4 Why This Source Matters  
FX data is widely used in:

- Trading  
- Risk management  
- Treasury operations  
- Financial reporting  

It is a perfect example of a **file-based market data feed**.

---

## 3. Crypto Prices (REST API)

### 3.1 Description  
Cryptocurrency price data is retrieved from a public REST API.  
This simulates real-time market data ingestion, which is common in:

- Trading platforms  
- Market data teams  
- Analytics dashboards  

We will use a simple, free API such as:

- CoinGecko  
- AlphaVantage  
- Yahoo Finance (unofficial)  

### 3.2 Example Fields  
| Field | Description |
|--------|-------------|
| `price_ts` | Timestamp of the price |
| `asset_symbol` | Crypto symbol (e.g., BTC) |
| `asset_name` | Full name (e.g., Bitcoin) |
| `price_usd` | Price in USD |
| `source_api` | API name used |
| `ingestion_ts` | Timestamp when data was ingested |
| `raw_payload` | Optional JSON payload for traceability |

### 3.3 Ingestion Method  
- Python script calls the API  
- Parses JSON response  
- Extracts relevant fields  
- Writes raw data to the **Bronze** table:  
  `bronze_crypto_prices_raw`

### 3.4 Why This Source Matters  
Crypto data demonstrates:

- API integration  
- JSON parsing  
- Real-time ingestion patterns  
- Handling semi-structured data  

This is a core skill for modern data engineers.

---

## 4. Data Update Frequency

| Source | Frequency | Notes |
|--------|-----------|-------|
| FX Rates (CSV) | Daily or hourly | Simulated batch ingestion |
| Crypto Prices (API) | On demand or scheduled | Can simulate real-time ingestion |

This flexibility allows us to demonstrate both **batch** and **stream-like** ingestion patterns.

---

## 5. Assumptions

To keep the project simple and focused:

- FX CSV files are assumed to be well-formed  
- API responses are assumed to be available and stable  
- No authentication is required for the chosen API  
- Timezones are handled at ingestion time  
- All data is stored in the Fabric Lakehouse  

These assumptions allow us to focus on the **data engineering workflow**, not vendor-specific complexities.

---

## 6. Summary

This project uses two complementary data sources:

- **FX Rates (CSV)** → demonstrates file-based ingestion  
- **Crypto Prices (API)** → demonstrates API-based ingestion  

Together, they provide a realistic foundation for building a **market data provisioning pipeline** using Python, Fabric Lakehouse, and dbt.

---
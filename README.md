# FX & Crypto Market Data Provisioning Pipeline  
A modern data engineering project that demonstrates how to ingest, model, and provision external market data using Python, Fabric Lakehouse, and dbt.

This project simulates a real-world **Data Provisioning Engineer** workflow by combining:
- External data ingestion (SFTP-like CSV + REST API)
- Medallion architecture (Bronze → Silver → Gold)
- dbt transformations and testing
- Fabric Lakehouse as the storage and compute engine

The goal is to build a clean, reliable, and well‑documented pipeline that prepares market data for downstream analytics and reporting.

---

## 📂 Project Structure

fx-crypto-provisioning/
│
├── docs/                     # Architecture, data sources, modelling, provisioning
├── src/                      # All source code
│   ├── ingestion/            # Python ingestion scripts
│   └── notebooks/            # Exploration notebooks
│
├── dbt/                      # dbt project (models, tests, macros)
└── pipelines/                # Fabric pipeline definitions


Each folder is documented in the `docs/` directory.

---

## 🎯 Project Objectives

This project demonstrates the core responsibilities of a Data Provisioning Engineer:

1. **Ingest external market data**  
   - FX rates from a simulated SFTP source  
   - Crypto prices from a REST API  

2. **Store raw data in a Lakehouse (Bronze layer)**  
   - Preserve original structure  
   - Add ingestion metadata  

3. **Transform and clean data using dbt (Silver layer)**  
   - Standardize formats  
   - Remove duplicates  
   - Apply basic quality checks  

4. **Model business-ready tables (Gold layer)**  
   - Dimensions (currencies, assets)  
   - Fact tables (market snapshots)  

5. **Provision final datasets for analytics**  
   - A clean, query-ready market snapshot table  

---

## 🧱 Technologies Used

- **Python** — ingestion and API integration  
- **Fabric Lakehouse** — storage + SQL endpoint  
- **dbt** — transformations, testing, documentation  
- **Medallion Architecture** — Bronze, Silver, Gold  
- **REST APIs & CSV ingestion** — external data sources  

---

## 📘 Documentation

All detailed explanations live in the `docs/` folder:

- `architecture.md` — system design and data flow  
- `data_sources.md` — FX and crypto data definitions  
- `modelling.md` — dbt models and transformation logic  
- `provisioning.md` — final output tables and use cases  

---

## 🚀 Future Extensions

This project is designed to grow over time.  
Planned enhancements include:

- Adding more market data sources  
- Introducing orchestration pipelines  
- Implementing CI/CD for dbt  
- Expanding to a second cloud pattern (Azure + AWS)  

---

## 👤 Author

Built by **Olayinka Ogunneye** as part of a portfolio demonstrating real-world data engineering and provisioning skills.

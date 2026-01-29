# ETL Project Overview

## Project Summary

This project demonstrates a **finance‑focused, production‑style data engineering workflow** where data from **CRM and ERP systems** is transformed into reliable, analytics‑ready datasets using a **modern data warehouse design**. The solution is built around the **Medallion Architecture**, clear **ETL pipelines**, and **well‑structured financial data modeling** to ensure scalability, accuracy, and auditability.

The goal of the project is not just to move data from source to destination, but to **showcase how real‑world financial data platforms are designed**, including:

* Integrating customer‑facing (CRM) and operational/financial (ERP) systems
* Separation of concerns across data layers
* Repeatable ETL processes
* Analytics‑friendly financial data models
* Engineering best practices (automation, version control, and environment configuration)

---

## High‑Level Architecture

At a high level, the pipeline follows this flow:

**CRM & ERP Source Systems → Bronze Layer → Silver Layer → Gold Layer → Finance Analytics / BI / Reporting**

* **CRM systems** provide customer, sales, and interaction data
* **ERP systems** provide invoices, payments, revenue, operational financial records

---

## Medallion Architecture Explained

The warehouse is designed using the **Medallion Architecture**, which organizes data into three logical layers: **Bronze, Silver, and Gold**. Each layer represents an increasing level of data quality, structure, and business value.

### 1. Bronze Layer — Raw Data Layer

**Purpose:**
The Bronze layer stores **raw CRM and ERP data** exactly as it is received from the source systems.

**Key Characteristics:**

* CRM and ERP data ingested separately
* Minimal or no transformation applied
* Schemas closely mirror source systems
* Acts as a historical and financial audit trail


**Typical Operations:**

* Extract customers, deals, and interactions from CRM
* Extract invoices, payments, and ledger‑level data from ERP
* Load data into raw tables with ingestion metadata (source system, load timestamp)

---

### 2. Silver Layer — Cleaned & Conformed Data Layer

**Purpose:**
The Silver layer contains **cleaned, standardized, and conformed financial data** across CRM and ERP systems.

**Key Characteristics:**

* Data quality rules applied (null handling, deduplication, validation)
* Standardized formats (dates, currencies, numeric precision)
* CRM and ERP identifiers aligned (e.g. unified customer IDs)
* Core financial and business entities created


**Typical Operations:**

* Customer and account matching across systems
* Deduplication of financial transactions
* Validation of invoice amounts, dates, and statuses
* Creation of clean, reusable core models

---

### 3. Gold Layer — Analytics & Business Layer

**Purpose:**
The Gold layer provides **finance‑ready, analytics‑focused datasets** for reporting and decision‑making.

**Key Characteristics:**

* Business‑friendly financial models
* Pre‑aggregated metrics and KPIs
* Optimized for BI and analytical workloads
* Consistent metric definitions across reports

**Why it matters:**
This layer enables stakeholders to answer key financial questions such as:

* What is total revenue by customer, product, or period?
* How do CRM sales figures reconcile with ERP revenue?
* What are outstanding invoices and payment trends?

**Typical Operations:**

* Revenue, invoice, and payment aggregations
* Financial KPI calculations
* Dimensional modeling for finance analytics

---

## ETL Pipelines

The ETL pipelines are designed to be **modular, repeatable, and automated**.

### Extract

* Data is sourced from external systems or files
* Connections and credentials are managed securely using environment variables
* Pipelines are designed to support re‑runs and incremental loads

### Transform

* Transformations are split logically across layers
* Heavy cleaning and validation occur in the Silver layer
* Analytical transformations occur in the Gold layer
* SQL and Python are used where each is strongest

### Load

* Data is loaded into a relational data warehouse
* Transactions are handled carefully to avoid partial loads
* Tables are created and managed using version‑controlled SQL scripts

---

## Data Modeling Approach

The project uses **financial analytics data modeling principles** to unify CRM and ERP data into a single warehouse.

### Modeling Layers

#### Staging / Raw Models

* Mirror CRM and ERP source tables
* Preserve original schemas and field names
* Used strictly as transformation inputs

#### Core / Silver Models

* Represent clean financial business entities (customers, invoices, payments)
* One row per business key
* CRM and ERP records reconciled and aligned

#### Mart / Gold Models

* Built using **dimensional modeling** concepts
* **Fact tables** capture financial events (sales, invoices, payments)
* **Dimension tables** describe customers, time, products, and accounts

### Benefits of This Approach

* Accurate reconciliation between CRM and ERP systems
* Clear and consistent financial metric definitions
* Scalable foundation for additional finance use cases

---

## Engineering Best Practices Applied

* **Modular SQL scripts** for schema and table creation
* **Environment‑based configuration** using `.env` files
* **Version control** for all code and SQL
* **Reproducible pipelines** that can be re‑run safely
* **Clear naming conventions** for schemas, tables, and columns

---

## About Me

I am Ifeoma Sandra Orji. A **Data Engineer** with a strong interest in building **finance‑focused, production‑ready data platforms**. I enjoy designing systems that integrate multiple business systems—such as CRM and ERP—and turn raw operational data into trustworthy financial insights.

My interests include:

* Financial data warehousing and analytics engineering
* CRM and ERP data integration
* Revenue, invoicing, and customer analytics
* Building scalable ETL pipelines using Python and SQL

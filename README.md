# modern-data-platform-olist

An end-to-end data engineering project demonstrating a modern, production-grade ELT pipeline for the Olist e-commerce dataset. This repository showcases the implementation of a Medallion Lakehouse architecture to ingest raw data, process it through quality-gated layers, and serve it in an analytics-ready format for business intelligence.   

The primary goal is to provide a complete blueprint for best practices in data modeling, transformation, quality testing, and orchestration using a contemporary data stack.   

Core Architecture
Lakehouse: A hybrid architecture combining the low-cost, flexible storage of a data lake with the performance and reliability of a data warehouse.   

Medallion Framework: Data is progressively refined through three distinct layers to ensure quality and traceability :   

Bronze Layer: Ingests and stores raw, immutable source data.

Silver Layer: Creates a validated, "single source of truth" by cleaning, conforming, and enriching the data.

Gold Layer: Aggregates data into business-specific, analytics-optimized data marts, often using a Star Schema.

Technology Stack
Cloud Provider: AWS or Azure

Data Lake Storage: Amazon S3 or Azure Data Lake Storage (ADLS) Gen2

Data Warehouse: Snowflake or Google BigQuery

Data Transformation: dbt (Data Build Tool)

Data Ingestion: Python (boto3, azure-storage-blob) or Airbyte

Workflow Orchestration: Apache Airflow

Business Intelligence: Tableau or Power BI

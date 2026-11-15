
# Online Bookstore Data Warehouse | SSIS & SQL Server

An end-to-end Data Warehouse project built using **SQL Server Integration Services (SSIS)** and **Microsoft SQL Server**, designed to demonstrate ETL development, incremental data loading, data quality management, dimensional modeling, and analytical data preparation.


<img width="1536" height="1024" alt="c72630fe-76fa-4753-a8da-e2e3b7f7e30d" src="https://github.com/user-attachments/assets/b453c1f2-ba24-4e5d-abd2-c3b2931ad0bf" />


The project follows a layered Data Warehouse architecture, extracting data from an Azure SQL Database, processing it through ODS and Staging layers, and loading a dimensional model designed for analytical queries and reporting.

**Project Status:** In Progress

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Business Scenario](#2-business-scenario)
3. [Project Objectives](#3-project-objectives)
4. [Technology Stack](#4-technology-stack)
5. [Source System](#5-source-system)
6. [Architecture](#6-architecture)
7. [ETL Workflow](#7-etl-workflow)
8. [Incremental Loading Strategy](#8-incremental-loading-strategy)
9. [Data Warehouse Design](#9-data-warehouse-design)
10. [Data Quality and Validation](#10-data-quality-and-validation)
11. [SSIS Implementation](#11-ssis-implementation)
12. [Error Handling and Logging](#12-error-handling-and-logging)
13. [Project Structure](#13-project-structure)
14. [Setup and Execution](#14-setup-and-execution)
15. [Key Engineering Concepts](#15-key-engineering-concepts)
16. [Current Progress and Future Enhancements](#16-current-progress-and-future-enhancements)

---

# 1. Project Overview

This project focuses on building an ETL pipeline and dimensional Data Warehouse for an online bookstore.

The source data is hosted in an Azure SQL Database, while the Data Warehouse is hosted on a local Microsoft SQL Server instance.

SSIS is used as the primary ETL and orchestration tool to extract, transform, validate, and load data across the different layers.

The architecture consists of three main data processing layers:

- **Operational Data Store (ODS):** Stores extracted source data.
- **Staging (STG):** Handles data cleansing, standardization, and validation.
- **Data Warehouse (DWH):** Stores business-oriented dimensional data in a star-schema-oriented model.

The project also incorporates incremental loading to process new and changed records rather than repeatedly reloading the entire dataset.

The overall objective is to simulate an ETL solution similar to those used in enterprise data engineering environments.

# 2. Business Scenario

An online bookstore manages information about its books, categories, promotions, and sales transactions.

As the business grows, analytical requirements become more complex.

The business needs to understand:

- Sales performance over time.
- Best-selling books.
- Revenue by book category.
- Customer purchasing trends, where customer data is available.
- Payment method distribution.
- Promotion effectiveness.
- The impact of individual promotional benefits on sales.

The operational database is designed to support transactions, whereas analytical queries require integrated, structured, and historically useful data.

A dedicated Data Warehouse provides a foundation for these analytical requirements.

# 3. Project Objectives

The project aims to demonstrate the following data engineering capabilities:

### Data Integration
- Extract data from an Azure SQL Database.
- Transfer source data into a local SQL Server environment.
- Manage reusable connections through SSIS Connection Managers.

### ETL Development
- Design SSIS Control Flow workflows.
- Develop SSIS Data Flow pipelines.
- Apply data transformations and standardization.
- Load data across multiple warehouse layers.

### Incremental Loading
- Identify new and modified records.
- Avoid unnecessary full reloads.
- Apply appropriate insert and update operations.
- Maintain load information for subsequent executions.

### Data Quality
- Detect invalid and missing values.
- Validate dimension references.
- Handle unmatched lookup records.
- Prevent duplicate records.
- Isolate rejected records where necessary.

### Dimensional Modeling
- Design dimension and fact tables.
- Implement surrogate keys.
- Define fact table grain.
- Handle relationships between promotions and promotional benefits.

### ETL Orchestration
- Control package execution order.
- Implement task dependencies.
- Handle failures.
- Maintain execution logs and load statistics.

# 4. Technology Stack

| Technology | Purpose |
|---|---|
| Azure SQL Database | Source operational database |
| Microsoft SQL Server | Local Data Warehouse |
| SQL Server Management Studio (SSMS) | Database administration and SQL development |
| Visual Studio Community | SSIS project development |
| SQL Server Integration Services (SSIS) | ETL and workflow orchestration |
| T-SQL | Database objects, queries, and SQL-based transformations |
| SQL Server Agent | Planned ETL scheduling and execution |
| Git & GitHub | Version control and project documentation |

# 5. Source System

The source database is hosted in Azure SQL.

**Source Database:** `datab5`

The project extracts data from four source tables.

| Source Table | Description | Initial Record Count |
|---|---|---:|
| Categories | Book category information | 6 |
| Books | Book details and pricing | 30 |
| Promotions | Promotional packages and their benefits | 16 |
| Sales | Sales transaction details | 120 |
| **Total** | | **172** |

*These counts represent the initial source dataset and are not necessarily the counts of records processed during every incremental execution.*

## 5.1 Source Table Relationships

The source system contains the following business relationships:

- A category can contain multiple books.
- A promotion package can contain multiple promotional benefits.
- A sales transaction line can reference a book.
- A sales transaction line can reference a promotion package.

### Important: Promotion Structure

The Promotions table has a particular structure that influences the Data Warehouse design.

It contains:

- `PromotionBenefitID`: Unique identifier and primary key for each promotional benefit.
- `PromotionID`: Identifier of the promotional package; it is not unique.
- `BenefitCode`: Code identifying the individual benefit.
- `BenefitName`: Description of the individual benefit.
- `DiscountPercent`: Discount percentage associated with the benefit.

A single promotion package can contain multiple benefits.

For example:

| PromotionBenefitID | PromotionID | BenefitName | Discount |
|---|---|---|---:|
| 1 | 10 | Seasonal Discount | 10% |
| 2 | 10 | Loyalty Discount | 5% |
| 3 | 10 | Special Offer | 3% |

The total discount associated with promotion package 10 is the sum of its benefits.

**Total package discount = 10% + 5% + 3% = 18%**

The Sales table contains a single `PromotionID` attribute referencing the package.

Therefore, promotional benefits must be aggregated by `PromotionID` before joining the promotion information to sales. Joining individual benefit records directly to sales would multiply sales rows when a package contains multiple benefits.

This is an important consideration for maintaining the correct fact table grain.

# 6. Architecture

The project follows a layered ETL architecture:

```text
                 AZURE SQL DATABASE
                    (SOURCE)
                         |
                         |
                  SSIS PROJECT
                 (VISUAL STUDIO)
                         |
                 Incremental Extract
                         |
                         v
              OPERATIONAL DATA STORE
                      (ODS)
                         |
                         v
                   STAGING LAYER
                      (STG)
                         |
                         v
                DATA WAREHOUSE
                      (DWH)
                         |
                         v
                REPORTING & ANALYTICS
```

## 6.1 Source Layer

The Azure SQL Database contains the original operational data.

SSIS extracts the required records from the source tables.

## 6.2 ODS Layer

The Operational Data Store is responsible for holding extracted source data.

Its primary purpose is to provide a local representation of the source system.

The ODS layer is designed to:

- Preserve source attributes.
- Maintain source identifiers.
- Support incremental extraction.
- Provide a consistent input for subsequent ETL operations.

The ODS tables are created using T-SQL, while SSIS packages handle the data loading.

## 6.3 Staging Layer

The Staging layer prepares source data for dimensional modeling.

Its responsibilities include:

- Data type conversion.
- Data cleansing.
- Handling missing and invalid values.
- Standardizing attributes.
- Validating business rules.
- Preparing records for dimension and fact loading.

The objective is to ensure that only validated and appropriately standardized data proceeds into the Data Warehouse.

## 6.4 Data Warehouse Layer

The DWH layer stores business-oriented data using dimensional modeling.

It contains dimensions that describe business entities and a fact table containing measurable business events.

The model is designed to support analytical queries and reporting.

# 7. ETL Workflow

SSIS is responsible for coordinating the ETL process.

The workflow is divided into multiple logical stages.

### Step 1: Extract Source Data

Extract data from the Azure SQL source database.

Depending on the loading strategy, the extraction process retrieves either the initial dataset or records identified as new or modified.

### Step 2: Load ODS

Load the extracted records into the corresponding ODS tables.

The ODS layer provides the first local persistence point for source data.

### Step 3: Load Staging

Transfer data from ODS into Staging.

Apply transformations, standardization, and validation.

### Step 4: Load Dimensions

Load dimension tables and resolve surrogate keys.

Ensure that dimension records are available before loading the corresponding fact records.

### Step 5: Load Fact Tables

Load sales transactions into the fact table.

Resolve the corresponding dimension surrogate keys through lookup operations.

Calculate the required measures, including gross amount, discount amount, and net amount.

### Step 6: Validate and Audit

Verify record counts, data consistency, and load results.

Record execution information and handle rejected records.

# 8. Incremental Loading Strategy

Incremental loading is an important component of this project.

Instead of extracting and processing every source record during every execution, the ETL process identifies records that are new or have changed since the previous successful load.

## 8.1 Full Load vs. Incremental Load

| Full Load | Incremental Load |
|---|---|
| Processes the entire dataset | Processes new or changed records |
| Can involve unnecessary data movement | Reduces unnecessary data movement |
| Useful for initial population | Useful for subsequent executions |
| Can become expensive as data grows | More efficient for growing datasets |

The initial execution populates the target tables.

Subsequent executions process changes according to the incremental loading logic.

## 8.2 Incremental Loading Workflow

```text
       Previous Successful Load
                  |
                  v
         Identify New Changes
                  |
                  v
          Extract Changed Data
                  |
                  v
          Detect Record Status
                  |
          +-------+-------+
          |               |
        INSERT           UPDATE
          |               |
          +-------+-------+
                  |
                  v
          Transform & Validate
                  |
                  v
           Load Target Tables
                  |
                  v
          Record Load Results
                  |
                  v
          Update Load Metadata
```

The exact change-detection mechanism must match the available source metadata and business requirements.

Possible approaches include:

- Last-modified timestamps or watermarks.
- Source identifiers and comparison against existing records.
- Change Data Capture, if supported and enabled.
- Hash-based change detection.

The implementation should not assume a modification timestamp exists until the actual source schema has been inspected.

## 8.3 Record Classification

The incremental process can classify records according to their required action:

| ISNEW | Action | Description |
|---:|---|---|
| 0 | IGNORE | No change detected |
| 1 | INSERT | New record |
| 2 | UPDATE | Existing record with changed attributes |
| 3 | DELETE | Record identified for deletion |

This classification provides a consistent way to determine what should happen to each record.

The corresponding SSIS workflow can route records into the appropriate processing paths.

**Important:** A record marked for deletion should not automatically be physically deleted from every warehouse layer. The appropriate handling depends on the business requirements and the selected dimensional modeling strategy.

## 8.4 Insert and Update Operations

The target loading process must distinguish between:

**INSERT**

A source record does not yet exist in the target.

A new target record is created.

**UPDATE**

A matching target record exists, but its tracked attributes have changed.

The existing target record is updated according to the selected change-handling strategy.

For fact tables, the process must also prevent duplicate sales lines.

## 8.5 Incremental Loading Considerations

A reliable incremental pipeline should consider:

- Initial load versus subsequent loads.
- Duplicate prevention.
- Failed execution recovery.
- Watermark management.
- Late-arriving records.
- Updates to existing records.
- Deletion handling.
- Load auditing.

The load watermark should only advance after the corresponding processing has completed successfully. This helps prevent missed records when an execution fails.

# 9. Data Warehouse Design

The DWH uses dimensional modeling to organize data for analytical workloads.

The current proposed model contains five dimensions and one fact table.

## 9.1 Dimension Tables

| Dimension | Description | Key |
|---|---|---|
| DimDate | Calendar attributes for sales analysis | Date_SK |
| DimBook | Book and category information | Book_SK |
| DimPromotion | Promotional package information | Promotion_SK |
| DimPaymentMethod | Payment method descriptions | PaymentMethod_SK |
| DimPromotionBenefit | Individual benefits belonging to promotional packages | PromotionBenefit_SK |

### DimDate

Provides calendar attributes for time-based analysis.

Attributes include:

- FullDate
- DayNumber
- DayName
- MonthNumber
- QuarterNumber
- YearNumber

The date surrogate key is represented using an integer.

### DimBook

Contains descriptive book attributes.

It also includes category information to make category-based analysis easier without requiring a separate category lookup during reporting.

Attributes include:

- BookID
- ISBN
- BookTitle
- CategoryID
- CategoryName
- CategoryDescription
- CurrentPrice

### DimPromotion

Contains promotional package information.

Each promotion package has one record, identified by `PromotionID`.

Attributes include:

- PromotionID
- PromotionCode
- PromotionName
- TotalDiscountPercent

The total discount percentage is derived by aggregating the individual benefits belonging to the package.

### DimPaymentMethod

Contains standardized payment method values.

It allows sales to be analyzed by payment method without repeating descriptive text throughout the fact table.

### DimPromotionBenefit

Contains individual promotional benefits.

Each benefit is uniquely identified by its source `PromotionBenefitID`.

It also references the corresponding promotion package through `Promotion_SK`.

This preserves the individual benefit information instead of storing only the aggregated package discount.

## 9.2 Fact Table

### FactSales

The FactSales table stores measurable sales transactions.

**Declared grain: One row per sales line.**

This means every fact record represents one individual sales line, not an entire receipt or transaction.

The table contains:

**Transaction identifiers**
- SalesLineID
- SaleID
- ReceiptNumber
- LineNumber

**Dimension foreign keys**
- Book_SK
- Date_SK
- Promotion_SK
- PaymentMethod_SK

**Measures**
- Quantity
- UnitPrice
- GrossAmount
- DiscountAmount
- NetAmount

### Measures

The intended calculations are:

```text
GrossAmount = Quantity × UnitPrice

NetAmount = GrossAmount - DiscountAmount
```

The discount calculation must follow the actual source business rules, including the aggregation of promotional benefits.

## 9.3 Surrogate Keys

Surrogate keys are warehouse-generated identifiers used to uniquely identify dimension records.

For example:

- `Book_SK`
- `Promotion_SK`
- `PaymentMethod_SK`

They provide a consistent way to reference dimension records independently of source-system identifiers.

The fact table stores these surrogate keys instead of relying exclusively on source business identifiers.

## 9.4 Promotion Benefits and the Bridge Table

The promotion structure introduces a potential many-to-many analytical relationship.

One promotion package contains multiple benefits, while multiple sales lines can reference the same package.

The current model stores the package reference in FactSales and stores individual benefits in DimPromotionBenefit.

If the requirement is to analyze sales measures against individual benefits, a separate bridge table may be

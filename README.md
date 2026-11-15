# Online Bookstore Data Warehouse | SSIS & SQL Server

An end-to-end Data Warehouse project developed using **SQL Server Integration Services (SSIS)** and **Microsoft SQL Server**, demonstrating ETL pipeline development, incremental data loading, data quality management, dimensional modeling, and analytical data preparation.

The project follows a layered Data Warehouse architecture, integrating data from an Azure SQL Database, processing it through Operational Data Store (ODS) and Staging layers, and loading a dimensional model designed for analytical queries and reporting.

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

This project focuses on designing and implementing an ETL pipeline and dimensional Data Warehouse for an online bookstore.

The source data is hosted in an Azure SQL Database, while the Data Warehouse is hosted on a local Microsoft SQL Server instance.

SSIS serves as the primary ETL and orchestration tool, responsible for extracting, transforming, validating, and loading data across the different layers.

The architecture consists of three main data processing layers:

- **Operational Data Store (ODS):** Maintains extracted source data.
- **Staging (STG):** Handles data cleansing, standardization, and validation.
- **Data Warehouse (DWH):** Stores business-oriented dimensional data designed for analytical workloads.

The project incorporates incremental loading to process new and modified records rather than repeatedly reloading the entire dataset.

The overall objective is to develop a structured, maintainable ETL solution that reflects data engineering practices used in enterprise data environments.

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

The operational database is designed to support transactions, whereas analytical workloads require integrated, structured, and historically useful data.

A dedicated Data Warehouse provides a foundation for these analytical requirements.

# 3. Project Objectives

The project aims to demonstrate the following data engineering capabilities:

### Data Integration

- Extract data from an Azure SQL Database.
- Integrate source data into a local SQL Server environment.
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

| Technology                             | Purpose                                                  |
| -------------------------------------- | -------------------------------------------------------- |
| Azure SQL Database                     | Source operational database                              |
| Microsoft SQL Server                   | Local Data Warehouse                                     |
| SQL Server Management Studio (SSMS)    | Database administration and SQL development              |
| Visual Studio Community                | SSIS project development                                 |
| SQL Server Integration Services (SSIS) | ETL and workflow orchestration                           |
| T-SQL                                  | Database objects, queries, and SQL-based transformations |
| SQL Server Agent                       | Planned ETL scheduling and execution                     |
| Git & GitHub                           | Version control and project documentation                |

# 5. Source System

The source database is hosted in Azure SQL.

**Source Database:** `datab5`

The project integrates data from four source tables:

| Source Table | Description                             |
| ------------ | --------------------------------------- |
| Categories   | Book category information               |
| Books        | Book details and pricing                |
| Promotions   | Promotional packages and their benefits |
| Sales        | Sales transaction details               |

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

The total discount associated with a promotion package is calculated by aggregating its individual benefits.

The Sales table contains a single `PromotionID` attribute referencing the package.

Therefore, promotional benefits must be aggregated by `PromotionID` before joining the promotion information to Sales. Joining individual benefit records directly to Sales would multiply sales rows when a package contains multiple benefits.

This is an important consideration for maintaining the correct fact table grain and ensuring accurate analytical calculations.

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

Verify data consistency and load results.

Record execution information and handle rejected records.

# 8. Incremental Loading Strategy

Incremental loading is an important component of this project.

Instead of extracting and processing every source record during every execution, the ETL process identifies records that are new or have changed since the previous successful load.

## 8.1 Full Load vs. Incremental Load

| Full Load                             | Incremental Load                    |
| ------------------------------------- | ----------------------------------- |
| Processes the entire dataset          | Processes new or changed records    |
| Can involve unnecessary data movement | Reduces unnecessary data movement   |
| Useful for initial population         | Useful for subsequent executions    |
| Can become expensive as data grows    | More efficient for growing datasets |

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

| ISNEW | Action | Description                             |
| ----: | ------ | --------------------------------------- |
|     0 | IGNORE | No change detected                      |
|     1 | INSERT | New record                              |
|     2 | UPDATE | Existing record with changed attributes |
|     3 | DELETE | Record identified for deletion          |

This classification provides a consistent way to determine what should happen to each record.

The corresponding SSIS workflow can route records into the appropriate processing paths.

**Important:** A record marked for deletion should not automatically be physically deleted from every warehouse layer. The appropriate handling depends on business requirements and the selected dimensional modeling strategy.

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

| Dimension           | Description                                           | Key                 |
| ------------------- | ----------------------------------------------------- | ------------------- |
| DimDate             | Calendar attributes for sales analysis                | Date_SK             |
| DimBook             | Book and category information                         | Book_SK             |
| DimPromotion        | Promotional package information                       | Promotion_SK        |
| DimPaymentMethod    | Payment method descriptions                           | PaymentMethod_SK    |
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

If the requirement is to analyze sales measures against individual benefits, a separate bridge table may be needed to associate sales lines with their promotional benefits.

This design decision must be resolved before finalizing the dimensional model.

A bridge table should not be introduced simply because the source contains multiple benefit records. Its necessity depends on the analytical requirements and the desired fact-to-benefit relationship.

# 10. Data Quality and Validation

Data quality is addressed during the Staging and Data Warehouse loading processes.

The objective is to prevent invalid data from silently entering the analytical model.

### Data Type Validation

Ensure that values can be converted into the expected target data types.

Examples:

- Numeric values must be valid numbers.
- Dates must be valid dates.
- Discount percentages must be valid decimal values.

### Missing Value Handling

Identify required fields containing NULL or missing values.

Determine whether the record should:

- Receive a default value.
- Be handled through an unknown dimension member.
- Be rejected or quarantined.

### Duplicate Detection

Identify duplicate source or staging records.

For FactSales, enforce the declared sales-line grain and prevent duplicate fact records.

### Referential Integrity

Validate relationships between facts and dimensions.

For example, a sales record referencing an unknown book should not silently enter the fact table without an appropriate handling strategy.

### Dimension Validation

Use SSIS Lookup transformations to identify matching dimension records.

Handle unmatched records through an appropriate error or no-match path.

A common warehouse technique is to create special dimension members, such as an Unknown member with a surrogate key of `-1`, where that approach is appropriate.

### Quarantine Records

Records that cannot be processed safely may be redirected into quarantine tables.

This allows the pipeline to preserve rejected records for investigation without necessarily failing the entire batch.

# 11. SSIS Implementation

SSIS is used to implement the ETL pipeline.

The project is developed using Visual Studio Community with the SQL Server Integration Services extension.

## 11.1 Control Flow

Control Flow defines the execution sequence and orchestration of ETL operations.

It determines:

- Which tasks execute.
- Their execution order.
- Dependencies between tasks.
- What happens when a task succeeds or fails.
- Whether tasks execute sequentially or in parallel.

Example:

```text
       Extract Source
              |
              v
           Load ODS
              |
              v
         Load Staging
              |
              v
        Load Dimensions
              |
              v
          Load Facts
              |
              v
        Validate Results
```

## 11.2 Data Flow

Data Flow defines how records move through the ETL pipeline.

A typical Data Flow contains:

```text
       OLE DB Source
              |
              v
       Transformations
              |
              v
       Lookup / Validation
              |
              v
       Conditional Split
              |
              v
       OLE DB Destination
```

It is responsible for extracting, processing, and loading individual rows.

## 11.3 SSIS Components

| Component              | Purpose                                       |
| ---------------------- | --------------------------------------------- |
| OLE DB Source          | Extract records from relational sources       |
| OLE DB Destination     | Load records into SQL Server tables           |
| Lookup                 | Match incoming records against reference data |
| Conditional Split      | Route records according to conditions         |
| Derived Column         | Create or modify column values                |
| Data Conversion        | Convert data types                            |
| Aggregate              | Group and aggregate records                   |
| Merge Join             | Combine sorted data streams                   |
| Sort                   | Sort records based on selected columns        |
| Execute SQL Task       | Execute SQL statements                        |
| Sequence Container     | Group related Control Flow tasks              |
| Precedence Constraints | Control task execution dependencies           |

Components should be selected according to actual transformation requirements rather than using every available transformation.

# 12. Error Handling and Logging

A reliable ETL pipeline needs to provide visibility into its execution.

The planned error-handling and logging strategy includes:

### Error Handling

- Handle connection failures.
- Capture transformation errors.
- Redirect invalid rows where appropriate.
- Handle unmatched dimension lookups.
- Prevent incomplete loads from being treated as successful.

### Logging and Auditing

Maintain information such as:

- Package name.
- Execution start time.
- Execution end time.
- Execution status.
- Source record count.
- Inserted record count.
- Updated record count.
- Rejected record count.
- Error details.

This information helps troubleshoot failures and monitor pipeline performance.

# 13. Project Structure

The intended repository structure is:

```text
OnlineBookstore_DWH/
│
├── README.md
│
├── docs/
│   ├── architecture/
│   │   └── architecture.png
│   │
│   └── data-model/
│       └── dimensional-model.png
│
├── sql/
│   ├── 01_Create_ODS.sql
│   ├── 02_Create_STG.sql
│   ├── 03_Create_DWH.sql
│   └── 04_Validation_Queries.sql
│
├── SSIS/
│   └── OnlineBookstore_SSIS/
│       ├── Connection Managers/
│       ├── Packages/
│       └── Project.params
│
└── .gitignore
```

*This is the proposed organization; filenames and folders should be adjusted to match the actual repository as development progresses.*

# 14. Setup and Execution

## Prerequisites

- Microsoft SQL Server.
- SQL Server Management Studio.
- Visual Studio Community.
- SQL Server Integration Services Projects extension.
- Access to the Azure SQL source database.
- Appropriate database permissions.

## Step 1: Clone the Repository

```bash
git clone <repository-url>
```

## Step 2: Prepare the Destination Database

Create the local database:

```sql
CREATE DATABASE Bookstore_DWH;
```

## Step 3: Create the Database Layers

Execute the SQL scripts in the following order:

1. ODS schema and tables.
2. Staging schema and tables.
3. DWH schema and tables.

## Step 4: Configure SSIS Connections

Configure the connection managers for:

- Azure SQL source database.
- Local SQL Server destination database.

Connection details should be configured for the local environment rather than hardcoded into shared project files.

## Step 5: Open the SSIS Project

Open the SSIS solution in Visual Studio.

Review the connection managers and package configurations.

## Step 6: Execute the ETL Pipeline

Execute the packages according to their dependencies.

The initial execution performs the initial data load.

Subsequent executions follow the incremental loading process.

*Exact execution instructions will be updated as the packages are implemented and tested.*

# 15. Key Engineering Concepts

This project provides practical exposure to several important data engineering concepts.

| Concept              | Application                                            |
| -------------------- | ------------------------------------------------------ |
| ETL                  | Extracting, transforming, and loading operational data |
| Incremental Loading  | Processing new and modified records                    |
| Data Integration     | Combining data from source and destination systems     |
| ODS                  | Maintaining extracted operational data                 |
| Staging              | Cleansing and validating incoming records              |
| Dimensional Modeling | Organizing data for analytical workloads               |
| Star Schema          | Structuring dimensions around a central fact           |
| Surrogate Keys       | Providing warehouse-generated identifiers              |
| Fact Table Grain     | Defining the level of detail represented by each fact  |
| Lookup Operations    | Resolving dimension references                         |
| Data Quality         | Identifying and handling invalid data                  |
| Error Handling       | Managing failed or rejected records                    |
| Orchestration        | Coordinating multiple ETL operations                   |
| Auditing             | Tracking pipeline execution and record counts          |

# 16. Current Progress and Future Enhancements

The project is being developed incrementally.

## Current Progress

- [x] Defined the online bookstore business scenario.
- [x] Identified the source database and source tables.
- [x] Established the initial layered architecture.
- [x] Created the SSIS project in Visual Studio.
- [x] Explored the Control Flow and Data Flow concepts.
- [x] Drafted the initial DWH dimensional table definitions.
- [ ] Complete source schema inspection and data profiling.
- [ ] Finalize the ODS and Staging designs.
- [ ] Finalize the dimensional model and promotion-benefit relationship.
- [ ] Implement SSIS source extraction.
- [ ] Implement ODS loading.
- [ ] Implement Staging transformations and validations.
- [ ] Implement dimension loading.
- [ ] Implement fact loading.
- [ ] Implement and test incremental loading.
- [ ] Implement error handling and auditing.
- [ ] Develop master package orchestration.
- [ ] Configure SQL Server Agent execution.
- [ ] Test the complete pipeline.
- [ ] Finalize documentation and deployment.

## Future Enhancements

Potential improvements include:

- Implementing Slowly Changing Dimensions (SCD), particularly Type 1 and Type 2.
- Supporting late-arriving dimension records.
- Introducing a dedicated ETL audit framework.
- Implementing robust failure recovery.
- Improving package configuration and parameter management.
- Deploying packages to the SSIS Catalog.
- Integrating the warehouse with Power BI for reporting and visualization.

---

## Final Note

This project is being developed with an emphasis on understanding the engineering decisions behind each ETL component, rather than simply building a collection of SSIS packages.

The goal is to create a maintainable and reliable Data Warehouse pipeline that demonstrates practical skills in SQL Server, SSIS, incremental ETL, data quality, dimensional modeling, and data integration.

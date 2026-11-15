/*
===============================================================================
Project: Online Bookstore Data Warehouse
Script: 01_Create_DWH.sql

Description:
    Creates the Data Warehouse schema and its dimensional model.

Current Model:
    Dimensions:
        1. DimDate
        2. DimBook
        3. DimPromotion
        4. DimPaymentMethod
        5. DimPromotionBenefit

    Fact:
        1. FactSales

    Total: 6 tables

Architecture:
    Star Schema with a promotion-benefit child dimension.

Note:
    This script drops and recreates existing DWH tables.
    Existing data in these tables will be lost.
    Intended for development and initial database setup.
===============================================================================
*/

USE Bookstore_DWH;
GO

/*=============================================================================
    STEP 1: Create DWH Schema
=============================================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'dwh'
)
BEGIN
    EXEC('CREATE SCHEMA dwh');
END;
GO


/*=============================================================================
    STEP 2: Drop Existing DWH Tables

    Drop dependent tables before their referenced tables.
=============================================================================*/

DROP TABLE IF EXISTS dwh.FactSales;
DROP TABLE IF EXISTS dwh.DimPromotionBenefit;

DROP TABLE IF EXISTS dwh.DimPaymentMethod;
DROP TABLE IF EXISTS dwh.DimPromotion;
DROP TABLE IF EXISTS dwh.DimBook;
DROP TABLE IF EXISTS dwh.DimDate;
GO


/*=============================================================================
    STEP 3: Create Dimension Tables
=============================================================================*/

-- 3.1 Date Dimension

CREATE TABLE dwh.DimDate
(
    Date_SK         INT             NOT NULL,
    FullDate        DATE            NOT NULL,
    DayNumber       TINYINT         NOT NULL,
    DayName         NVARCHAR(15)    NOT NULL,
    MonthNumber     TINYINT         NOT NULL,
    QuarterNumber   TINYINT         NOT NULL,
    YearNumber      SMALLINT        NOT NULL,

    CONSTRAINT PK_DimDate
        PRIMARY KEY (Date_SK),

    CONSTRAINT UQ_DimDate_FullDate
        UNIQUE (FullDate)
);


-- 3.2 Book Dimension

CREATE TABLE dwh.DimBook
(
    Book_SK                 INT IDENTITY(1,1) NOT NULL,
    BookID                  INT NOT NULL,
    ISBN                    NVARCHAR(20),
    BookTitle               NVARCHAR(150),
    CategoryID              INT,
    CategoryName            NVARCHAR(100),
    CategoryDescription     NVARCHAR(250),
    CurrentPrice            DECIMAL(10,2),

    CONSTRAINT PK_DimBook
        PRIMARY KEY (Book_SK),

    CONSTRAINT UQ_DimBook_BookID
        UNIQUE (BookID)
);


-- 3.3 Promotion Dimension

CREATE TABLE dwh.DimPromotion
(
    Promotion_SK            INT IDENTITY(1,1) NOT NULL,
    PromotionID             INT NOT NULL,
    PromotionCode           NVARCHAR(30),
    PromotionName           NVARCHAR(120),
    TotalDiscountPercent    DECIMAL(7,2),

    CONSTRAINT PK_DimPromotion
        PRIMARY KEY (Promotion_SK),

    CONSTRAINT UQ_DimPromotion_PromotionID
        UNIQUE (PromotionID)
);


-- 3.4 Payment Method Dimension

CREATE TABLE dwh.DimPaymentMethod
(
    PaymentMethod_SK    INT IDENTITY(1,1) NOT NULL,
    PaymentMethod       NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_DimPaymentMethod
        PRIMARY KEY (PaymentMethod_SK),

    CONSTRAINT UQ_DimPaymentMethod_PaymentMethod
        UNIQUE (PaymentMethod)
);


-- 3.5 Promotion Benefit Dimension

CREATE TABLE dwh.DimPromotionBenefit
(
    PromotionBenefit_SK INT IDENTITY(1,1) NOT NULL,
    PromotionBenefitID  INT NOT NULL,
    Promotion_SK        INT NOT NULL,
    BenefitCode         NVARCHAR(30) NOT NULL,
    BenefitName         NVARCHAR(120) NOT NULL,
    DiscountPercent     DECIMAL(5,2) NOT NULL,

    CONSTRAINT PK_DimPromotionBenefit
        PRIMARY KEY (PromotionBenefit_SK),

    CONSTRAINT UQ_DimPromotionBenefit_SourceID
        UNIQUE (PromotionBenefitID),

    CONSTRAINT FK_DimPromotionBenefit_DimPromotion
        FOREIGN KEY (Promotion_SK)
        REFERENCES dwh.DimPromotion(Promotion_SK)
);
GO


/*=============================================================================
    STEP 4: Create Fact Table
=============================================================================*/

CREATE TABLE dwh.FactSales
(
    -- Fact table primary key
    Sales_SK            INT IDENTITY(1,1) NOT NULL,

    -- Source transaction identifiers
    SalesLineID         INT NOT NULL,
    SaleID              INT,
    ReceiptNumber       NVARCHAR(30),
    LineNumber          INT,

    -- Dimension foreign keys
    Book_SK             INT NOT NULL,
    Date_SK             INT NOT NULL,
    Promotion_SK        INT NOT NULL,
    PaymentMethod_SK    INT NOT NULL,

    -- Measures
    Quantity            INT,
    UnitPrice           DECIMAL(10,2),
    GrossAmount         DECIMAL(12,2),
    DiscountAmount      DECIMAL(10,2),
    NetAmount           DECIMAL(12,2),

    CONSTRAINT PK_FactSales
        PRIMARY KEY (Sales_SK),

    CONSTRAINT UQ_FactSales_SalesLineID
        UNIQUE (SalesLineID),

    CONSTRAINT UQ_FactSales_Receipt_Line
        UNIQUE (ReceiptNumber, LineNumber),

    CONSTRAINT FK_FactSales_DimBook
        FOREIGN KEY (Book_SK)
        REFERENCES dwh.DimBook(Book_SK),

    CONSTRAINT FK_FactSales_DimDate
        FOREIGN KEY (Date_SK)
        REFERENCES dwh.DimDate(Date_SK),

    CONSTRAINT FK_FactSales_DimPromotion
        FOREIGN KEY (Promotion_SK)
        REFERENCES dwh.DimPromotion(Promotion_SK),

    CONSTRAINT FK_FactSales_DimPaymentMethod
        FOREIGN KEY (PaymentMethod_SK)
        REFERENCES dwh.DimPaymentMethod(PaymentMethod_SK)
);
GO

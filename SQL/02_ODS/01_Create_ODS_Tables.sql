/*-----------------------------------------------------------------------
    Project: Online Bookstore Data Warehouse
    Phase A: Step 2 - Creating ODS Tables

    Description:
        Creates the four tables in the Operational Data Store (ODS)
        layer to hold extracted source data.

    Tables:
        1. Categories
        2. Promotions
        3. Books
        4. Sales

    Note:
        Data loading is handled by SSIS packages.
        This script is intended for initial database setup.
 -----------------------------------------------------------------------*/

USE Bookstore_DWH;
GO

--============ Step 1: Create the ODS tables ===================


-- Creating Categories table

IF OBJECT_ID('ods.Categories', 'U') IS NULL
BEGIN
    CREATE TABLE ods.Categories (
        CategoryID INT NOT NULL PRIMARY KEY,
        CategoryName NVARCHAR(100) NULL,
        Description NVARCHAR(250) NULL
    );
END;
GO


-- Creating Promotions table

IF OBJECT_ID('ods.Promotions', 'U') IS NULL
BEGIN
    CREATE TABLE ods.Promotions (
        PromotionBenefitID INT NOT NULL PRIMARY KEY,
        PromotionID INT NOT NULL,
        PromotionCode NVARCHAR(30) NOT NULL,
        PromotionName NVARCHAR(120) NOT NULL,
        BenefitCode NVARCHAR(30) NOT NULL,
        BenefitName NVARCHAR(120) NOT NULL,
        DiscountPercent NVARCHAR(20) NOT NULL
    );
END;
GO


-- Creating Books table

IF OBJECT_ID('ods.Books', 'U') IS NULL
BEGIN
    CREATE TABLE ods.Books (
        BookID INT NOT NULL PRIMARY KEY,
        ISBN NVARCHAR(20) NULL,
        BookTitle NVARCHAR(150) NULL,
        CategoryID INT NOT NULL,
        Price NVARCHAR(30) NULL
    );
END;
GO


-- Creating Sales table

IF OBJECT_ID('ods.Sales', 'U') IS NULL
BEGIN
    CREATE TABLE ods.Sales (
        SalesLineID INT NOT NULL PRIMARY KEY,
        SaleID INT NOT NULL,
        ReceiptNumber NVARCHAR(30) NOT NULL,
        LineNumber INT NOT NULL,
        BookID INT NOT NULL,
        SaleDate NVARCHAR(30) NULL,
        PaymentMethod NVARCHAR(50) NULL,
        Quantity NVARCHAR(10) NULL,
        UnitPrice NVARCHAR(30) NULL,
        DiscountAmount NVARCHAR(30) NULL,
        PromotionID NVARCHAR(100) NULL
    );
END;
GO

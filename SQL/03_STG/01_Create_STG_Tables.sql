
/*========================================================================
    Phase B: Creating the Staging (STG) Layer

    Purpose:
        - Create staging tables for data cleansing and standardization.
        - Prepare consistent, analysis-ready records.
        - Support incremental loading through the ISNEW flag.

    Steps:
        1. Create STG tables.

========================================================================*/


/*========================================================================
    Step 1: Create STG Tables
========================================================================*/


-- ---------------------------------------------------------------------
-- Categories
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS stg.Categories;

CREATE TABLE stg.Categories (
    CategoryID      INT             NOT NULL,
    CategoryName    NVARCHAR(100)   NULL,
    Description     NVARCHAR(250)   NULL,

    CONSTRAINT PK_stg_Categories
        PRIMARY KEY (CategoryID)
);


-- ---------------------------------------------------------------------
-- Promotions
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS stg.Promotions;

CREATE TABLE stg.Promotions (
    PromotionBenefitID  INT             NOT NULL,
    PromotionID         INT             NOT NULL,
    PromotionCode       NVARCHAR(30)    NOT NULL,
    PromotionName       NVARCHAR(120)   NOT NULL,
    BenefitCode         NVARCHAR(30)    NOT NULL,
    BenefitName         NVARCHAR(120)   NOT NULL,
    DiscountPercent     DECIMAL(5,2)    NOT NULL,

    CONSTRAINT PK_stg_Promotions
        PRIMARY KEY (PromotionBenefitID)
);


-- ---------------------------------------------------------------------
-- Books
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS stg.Books;

CREATE TABLE stg.Books (
    BookID      INT             NOT NULL,
    ISBN        NVARCHAR(20)    NULL,
    BookTitle   NVARCHAR(150)   NULL,
    CategoryID  INT             NOT NULL,
    Price       DECIMAL(10,2)   NULL,

    CONSTRAINT PK_stg_Books
        PRIMARY KEY (BookID)
);


-- ---------------------------------------------------------------------
-- Sales
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS stg.Sales;

CREATE TABLE stg.Sales (
    SalesLineID     INT             NOT NULL,
    SaleID          INT             NOT NULL,
    ReceiptNumber   NVARCHAR(30)    NOT NULL,
    LineNumber      INT             NOT NULL,
    BookID          INT             NOT NULL,
    SaleDate        DATE            NULL,
    PaymentMethod   NVARCHAR(50)    NULL,
    Quantity        INT             NULL,
    UnitPrice       DECIMAL(10,2)   NULL,
    DiscountAmount  DECIMAL(10,2)   NULL,
    PromotionID     INT             NULL,
    ISNEW           INT             NOT NULL
        CONSTRAINT DF_stg_Sales_ISNEW DEFAULT (0),

    CONSTRAINT PK_stg_Sales
        PRIMARY KEY (SalesLineID)
);

GO

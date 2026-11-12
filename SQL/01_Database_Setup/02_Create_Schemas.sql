/*
    Script: 02_Create_Schemas.sql

    Description:
        Creates the three database schemas used in the
        Online Bookstore Data Warehouse project.

    Purpose:
        - ODS: Stores extracted source data.
        - STG: Holds staging data for transformation
               and incremental change detection.
        - DWH: Stores the final dimensional data model
               for analytical purposes.
*/


USE Bookstore_DWH;
GO

CREATE SCHEMA ODS;
GO

CREATE SCHEMA STG;
GO

CREATE SCHEMA DWH;
GO
